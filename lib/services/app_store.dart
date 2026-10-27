import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz.dart';

abstract interface class TextStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class DeviceStorage implements TextStorage {
  final _preferences = SharedPreferencesAsync();
  @override
  Future<String?> read(String key) => _preferences.getString(key);
  @override
  Future<void> write(String key, String value) =>
      _preferences.setString(key, value);
}

class AppStore extends ChangeNotifier {
  AppStore(this.storage);
  final TextStorage storage;
  QuizStats stats = const QuizStats();
  String author = const String.fromEnvironment(
    'AUTHOR_NAME',
    defaultValue: 'Kan',
  );
  String studentId = const String.fromEnvironment('STUDENT_ID');
  String? warning;
  bool _busy = false;

  Future<void> load() async {
    try {
      final raw = await storage.read('comquiz.stats');
      if (raw != null) stats = QuizStats.fromJson(jsonDecode(raw));
    } catch (_) {
      warning = 'อ่านสถิติเดิมไม่ได้ เริ่มเล่นใหม่ได้ตามปกติ';
    }
    try {
      final raw = await storage.read('comquiz.author');
      if (raw != null) {
        final j = jsonDecode(raw) as Map;
        author = j['name'] as String;
        studentId = j['studentId'] as String;
      }
    } catch (_) {
      warning ??= 'อ่านข้อมูลผู้จัดทำเดิมไม่ได้ ใช้ข้อมูลเริ่มต้นแทน';
    }
    notifyListeners();
  }

  Future<bool> _saveStats(QuizStats next) async {
    if (_busy) return false;
    _busy = true;
    try {
      await storage.write('comquiz.stats', jsonEncode(next.toJson()));
      stats = next;
      warning = null;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    } finally {
      _busy = false;
    }
  }

  Future<bool> record(GameResult result) => _saveStats(stats.add(result));
  Future<bool> reset() => _saveStats(const QuizStats());

  Future<bool> saveAuthor(String name, String id) async {
    if (name.trim().isEmpty ||
        name.trim().length > 60 ||
        id.trim().length > 30) {
      return false;
    }
    try {
      await storage.write(
        'comquiz.author',
        jsonEncode({'name': name.trim(), 'studentId': id.trim()}),
      );
      author = name.trim();
      studentId = id.trim();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
