import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auto_test_model.dart';

class AutoTesterService {
  final String baseUrl;

  const AutoTesterService({required this.baseUrl});

  Future<AutoTestResponse> generateTest({
    required String url,
    required String userIntent,
  }) async {
    final uri = Uri.parse('$baseUrl/generate-test');

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'url': url, 'user_intent': userIntent}),
        )
        .timeout(const Duration(minutes: 2));

    if (response.statusCode == 200) {
      return AutoTestResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception('Server ${response.statusCode}: ${response.body}');
  }
}
