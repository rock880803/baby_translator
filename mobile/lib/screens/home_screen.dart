import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mbti_type.dart';
import '../services/api_service.dart';
import 'mbti_selection_screen.dart';
import 'analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// 聊天訊息模型
class ChatMessage {
  final String text;
  final bool isMe; // true = 自己, false = 對方

  ChatMessage({required this.text, required this.isMe});
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _geminiKeyController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<ChatMessage> _chatMessages = []; // 聊天記錄
  MBTIType? _myMBTI;      // 自己的 MBTI
  MBTIType? _partnerMBTI; // 對方的 MBTI
  bool _isLoading = false;
  String? _extractedText; // 截圖擷取的文字
  String? _geminiApiKey;  // Gemini API 金鑰

  @override
  void initState() {
    super.initState();
    _loadGeminiApiKey();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _geminiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _geminiApiKey = prefs.getString('gemini_api_key');
      _geminiKeyController.text = _geminiApiKey ?? '';
    });
  }

  Future<void> _saveGeminiApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key);
    setState(() {
      _geminiApiKey = key;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() => _isLoading = true);

      final apiService = context.read<ApiService>();

      // 讀取圖片 bytes（Web 和移動平台都支援）
      final imageBytes = await image.readAsBytes();

      // 呼叫 OCR API 取得對話資料
      Map<String, dynamic>? result;
      try {
        result = await apiService.extractConversationFromImage(
          image.path,
          imageBytes: imageBytes,
        );
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OCR 解析失敗: $e')),
          );
        }
        return;
      }

      setState(() => _isLoading = false);

      // 解析 API 返回的對話資料
      if (result != null && result.containsKey('messages')) {
        final messagesData = result['messages'];

        if (messagesData is List) {
          // 自動匯入所有訊息到聊天室
          setState(() {
            for (var msg in messagesData) {
              if (msg is Map) {
                _chatMessages.add(ChatMessage(
                  text: msg['text']?.toString() ?? '',
                  isMe: msg['is_me'] == true,
                ));
              }
            }
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已匯入 ${messagesData.length} 則訊息'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API 設定'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 後端 API 位址
              Text(
                '後端 API 位址',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ApiService.baseUrl,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '提示：\n• Android 模擬器使用 10.0.2.2:8000\n• iOS 模擬器使用 localhost:8000\n• 實體裝置使用電腦的 IP 位址',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              // Gemini API 金鑰
              Text(
                'Gemini AI API 金鑰',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _geminiKeyController,
                decoration: InputDecoration(
                  hintText: '輸入您的 Gemini API Key',
                  border: const OutlineInputBorder(),
                  suffixIcon: _geminiApiKey != null
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                ),
                obscureText: true,
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  // 開啟 Gemini API 取得頁面
                },
                child: const Text(
                  '如何取得 Gemini API 金鑰？ →',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '前往 Google AI Studio (aistudio.google.com) 免費取得',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final key = _geminiKeyController.text.trim();
              if (key.isNotEmpty) {
                _saveGeminiApiKey(key);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gemini API 金鑰已儲存'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('儲存'),
          ),
        ],
      ),
    );
  }

  // 建立聊天氣泡 Widget
  Widget _buildChatBubble(ChatMessage message) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isMe
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Colors.black87,
            fontSize: 15,
          ),
        ),
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
            // 聊天室區塊
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '💬 聊天室',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (_chatMessages.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              setState(() => _chatMessages.clear());
                            },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('清空'),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: _chatMessages.isEmpty
                        ? Center(
                            child: Text(
                              '尚無對話\n上傳截圖後選擇「對方」或「自己」來建立對話',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _chatMessages.length,
                            itemBuilder: (context, index) {
                              return _buildChatBubble(_chatMessages[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 訊息輸入區塊
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
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.screenshot),
                            label: const Text('上傳截圖'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _isLoading ? null : _analyzeMessage,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.auto_awesome),
                            label: const Text('分析並生成回覆'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
