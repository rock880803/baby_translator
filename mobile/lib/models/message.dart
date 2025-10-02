class Message {
  final String content;
  final DateTime timestamp;
  final MessageSource source;

  Message({
    required this.content,
    required this.timestamp,
    required this.source,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: MessageSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => MessageSource.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'source': source.name,
    };
  }
}

enum MessageSource {
  text,
  screenshot,
}

class AnalysisResult {
  final String emotion;
  final String tone;
  final String mood;
  final List<String> underlyingNeeds;
  final double sentimentScore;

  AnalysisResult({
    required this.emotion,
    required this.tone,
    required this.mood,
    required this.underlyingNeeds,
    required this.sentimentScore,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      emotion: json['emotion'] as String,
      tone: json['tone'] as String,
      mood: json['mood'] as String,
      underlyingNeeds: List<String>.from(json['underlying_needs'] ?? []),
      sentimentScore: (json['sentiment_score'] as num).toDouble(),
    );
  }
}

class ReplyStyle {
  final String name;
  final String description;

  ReplyStyle({
    required this.name,
    required this.description,
  });
}

class GeneratedReply {
  final String content;
  final ReplyStyle style;
  final double confidence;

  GeneratedReply({
    required this.content,
    required this.style,
    required this.confidence,
  });

  factory GeneratedReply.fromJson(Map<String, dynamic> json) {
    return GeneratedReply(
      content: json['content'] as String,
      style: ReplyStyle(
        name: json['style']['name'] as String,
        description: json['style']['description'] as String,
      ),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}
