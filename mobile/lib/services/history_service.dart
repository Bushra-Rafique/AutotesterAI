import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/test_history.dart';

class HistoryService {
  static const _key = 'test_history';
  static const _maxEntries = 30;

  Future<List<TestHistory>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => TestHistory.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();
  }

  Future<void> saveEntry(TestHistory entry) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(entry.toJson()));
    if (raw.length > _maxEntries) raw.removeAt(0);
    await prefs.setStringList(_key, raw);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
