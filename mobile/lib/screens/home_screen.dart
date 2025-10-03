import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/mbti_type.dart';
import '../services/api_service.dart';
import 'mbti_selection_screen.dart';
import 'analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  MBTIType? _myMBTI;      // 自己的 MBTI
  MBTIType? _partnerMBTI; // 對方的 MBTI
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() => _isLoading = true);

      final apiService = context.read<ApiService>();
      // 先嘗試新端點：上傳並儲存對話，帶上 user_id
      String extractedText = '';
      try {
        extractedText = await apiService.uploadScreenshot(
          userId: ApiService.defaultUserId,
          imagePath: image.path,
        );
      } catch (_) {
        // fallback 舊的單純擷取端點
        extractedText = await apiService.extractTextFromImage(image.path);
      }

      setState(() {
        _messageController.text = extractedText;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('錯誤: $e')),
        );
      }
    }
  }

  Future<void> _analyzeMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入或上傳訊息')),
      );
      return;
    }

    if (_myMBTI == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先設定自己的 MBTI 類型')),
      );
      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisScreen(
          message: _messageController.text,
          mbtiType: _myMBTI!,
        ),
      ),
    );
  }

  void _showMBTISettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('MBTI 設定'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 自己的 MBTI
              Text(
                '自己的 MBTI',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<MBTIType>(
                value: _myMBTI,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '選擇您的 MBTI',
                ),
                items: MBTIType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text('${type.name} - ${type.description}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => _myMBTI = value);
                },
              ),
              const SizedBox(height: 24),
              // 對方的 MBTI
              Text(
                '對方的 MBTI',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<MBTIType>(
                value: _partnerMBTI,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '選擇對方的 MBTI（選填）',
                ),
                items: MBTIType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text('${type.name} - ${type.description}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => _partnerMBTI = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {}); // 更新主畫面
                Navigator.pop(context);
              },
              child: const Text('確定'),
            ),
          ],
        ),
      ),
    );
  }

  void _showApiSettingsDialog() {
    final apiService = context.read<ApiService>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API 設定'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '後端 API 位址',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              ApiService.baseUrl,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '提示：\n• Android 模擬器使用 10.0.2.2:8000\n• iOS 模擬器使用 localhost:8000\n• 實體裝置使用電腦的 IP 位址',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💕 Babe Translator'),
        actions: [
          // MBTI 設定按鈕
          IconButton(
            icon: const Icon(Icons.psychology),
            tooltip: 'MBTI 設定',
            onPressed: _showMBTISettingsDialog,
          ),
          // 顯示自己的 MBTI
          if (_myMBTI != null)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Center(
                child: Chip(
                  avatar: const Icon(Icons.person, size: 16),
                  label: Text(_myMBTI!.name, style: const TextStyle(fontSize: 12)),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          // 顯示對方的 MBTI
          if (_partnerMBTI != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Chip(
                  avatar: const Icon(Icons.favorite, size: 16),
                  label: Text(_partnerMBTI!.name, style: const TextStyle(fontSize: 12)),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          // API 串接按鈕
          IconButton(
            icon: const Icon(Icons.api),
            tooltip: 'API 串接',
            onPressed: _showApiSettingsDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💕 輸入或上傳訊息',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _messageController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: '在這裡輸入另一半的訊息...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('拍照'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('相簿'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _isLoading ? null : _analyzeMessage,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: const Text('分析並生成回覆'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
