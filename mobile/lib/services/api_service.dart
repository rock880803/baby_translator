import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/mbti_type.dart';

class ApiService {
  // TODO: Replace with your actual API endpoint
  static const String baseUrl = 'http://localhost:8000/api';

  Future<AnalysisResult> analyzeMessage(String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 200) {
        return AnalysisResult.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to analyze message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<GeneratedReply>> generateReplies({
    required String messageContent,
    required MBTIType mbtiType,
    required AnalysisResult analysis,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-replies'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': messageContent,
          'mbti_type': mbtiType.name,
          'analysis': {
            'emotion': analysis.emotion,
            'tone': analysis.tone,
            'mood': analysis.mood,
            'sentiment_score': analysis.sentimentScore,
          },
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['replies'];
        return data.map((item) => GeneratedReply.fromJson(item)).toList();
      } else {
        throw Exception('Failed to generate replies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<String> extractTextFromImage(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/extract-text'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseData)['text'];
      } else {
        throw Exception('Failed to extract text: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
