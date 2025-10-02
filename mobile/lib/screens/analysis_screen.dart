import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/mbti_type.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class AnalysisScreen extends StatefulWidget {
  final String message;
  final MBTIType mbtiType;

  const AnalysisScreen({
    super.key,
    required this.message,
    required this.mbtiType,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  AnalysisResult? _analysis;
  List<GeneratedReply>? _replies;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _performAnalysis();
  }

  Future<void> _performAnalysis() async {
    try {
      final apiService = context.read<ApiService>();

      // Analyze message
      final analysis = await apiService.analyzeMessage(widget.message);

      // Generate replies
      final replies = await apiService.generateReplies(
        messageContent: widget.message,
        mbtiType: widget.mbtiType,
        analysis: analysis,
      );

      setState(() {
        _analysis = analysis;
        _replies = replies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _copyReply(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已複製到剪貼簿')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分析結果'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('錯誤: $_error'),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _error = null;
                            });
                            _performAnalysis();
                          },
                          child: const Text('重試'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Original Message
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '原始訊息',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(widget.message),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Analysis Results
                      if (_analysis != null) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '情感分析',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 12),
                                _buildAnalysisRow('情緒', _analysis!.emotion),
                                _buildAnalysisRow('語氣', _analysis!.tone),
                                _buildAnalysisRow('心情', _analysis!.mood),
                                _buildAnalysisRow(
                                  '情感分數',
                                  '${(_analysis!.sentimentScore * 100).toStringAsFixed(1)}%',
                                ),
                                if (_analysis!.underlyingNeeds.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    '潛在需求:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  ..._analysis!.underlyingNeeds.map(
                                    (need) => Padding(
                                      padding: const EdgeInsets.only(left: 8, top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.arrow_right, size: 16),
                                          const SizedBox(width: 4),
                                          Text(need),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Generated Replies
                      if (_replies != null && _replies!.isNotEmpty) ...[
                        Text(
                          '建議回覆 (${widget.mbtiType.name})',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ..._replies!.map((reply) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            reply.style.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Chip(
                                          label: Text(
                                            '${(reply.confidence * 100).toInt()}%',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      reply.style.description,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const Divider(height: 24),
                                    Text(reply.content),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: FilledButton.tonalIcon(
                                        onPressed: () => _copyReply(reply.content),
                                        icon: const Icon(Icons.copy, size: 16),
                                        label: const Text('複製'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildAnalysisRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
