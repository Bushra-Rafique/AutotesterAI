class ThoughtStep {
  final String thought;
  final String action;

  const ThoughtStep({required this.thought, required this.action});

  factory ThoughtStep.fromJson(Map<String, dynamic> json) => ThoughtStep(
        thought: json['thought'] as String? ?? '',
        action: json['action'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'thought': thought,
        'action': action,
      };
}

class AutoTestResponse {
  final String status;
  final List<ThoughtStep> thoughtStream;
  final List<String> logs;
  final String code;
  final String? screenshot;

  const AutoTestResponse({
    required this.status,
    required this.thoughtStream,
    required this.logs,
    required this.code,
    this.screenshot,
  });

  factory AutoTestResponse.fromJson(Map<String, dynamic> json) =>
      AutoTestResponse(
        status: json['status'] as String? ?? 'error',
        thoughtStream: (json['thought_stream'] as List? ?? [])
            .map((e) => ThoughtStep.fromJson(e as Map<String, dynamic>))
            .toList(),
        logs: List<String>.from(json['logs'] as List? ?? []),
        code: json['code'] as String? ?? '',
        screenshot: json['screenshot'] as String?,
      );
}
