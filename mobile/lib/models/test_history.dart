import 'auto_test_model.dart';

class TestHistory {
  final String id;
  final String url;
  final String userIntent;
  final String status;
  final String code;
  final List<ThoughtStep> thoughtStream;
  final DateTime timestamp;

  const TestHistory({
    required this.id,
    required this.url,
    required this.userIntent,
    required this.status,
    required this.code,
    required this.thoughtStream,
    required this.timestamp,
  });

  factory TestHistory.fromResponse({
    required String url,
    required String userIntent,
    required AutoTestResponse response,
  }) =>
      TestHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        url: url,
        userIntent: userIntent,
        status: response.status,
        code: response.code,
        thoughtStream: response.thoughtStream,
        timestamp: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'userIntent': userIntent,
        'status': status,
        'code': code,
        'thoughtStream': thoughtStream.map((t) => t.toJson()).toList(),
        'timestamp': timestamp.toIso8601String(),
      };

  factory TestHistory.fromJson(Map<String, dynamic> json) => TestHistory(
        id: json['id'] as String,
        url: json['url'] as String,
        userIntent: json['userIntent'] as String,
        status: json['status'] as String,
        code: json['code'] as String,
        thoughtStream: (json['thoughtStream'] as List? ?? [])
            .map((e) => ThoughtStep.fromJson(e as Map<String, dynamic>))
            .toList(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
