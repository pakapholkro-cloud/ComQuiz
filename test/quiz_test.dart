import 'dart:math';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:comquiz/data/question_bank.dart';
import 'package:comquiz/models/quiz.dart';
import 'package:comquiz/services/app_store.dart';

class MemoryStorage implements TextStorage {
  final data = <String, String>{};
  bool fail = false;
  @override
  Future<String?> read(String key) async => data[key];
  @override
  Future<void> write(String key, String value) async {
    if (fail) throw Exception('disk unavailable');
    data[key] = value;
  }
}

GameResult result(
  String id,
  int correct, {
  QuizCategory category = QuizCategory.hardware,
  QuizDifficulty difficulty = QuizDifficulty.easy,
}) => GameResult(
  id: id,
  category: category,
  difficulty: difficulty,
  correct: correct,
  total: 10,
  date: DateTime(2026, 10, 23),
);

void main() {
  test('90 unique questions, 10 per category and difficulty', () {
    expect(questionBank.length, 90);
    expect(questionBank.map((q) => q.id).toSet().length, 90);
    expect(questionBank.map((q) => q.prompt).toSet().length, 90);
    for (final c in QuizCategory.values) {
      for (final d in QuizDifficulty.values) {
        expect(
          questionBank
              .where((q) => q.category == c && q.difficulty == d)
              .length,
          10,
        );
      }
    }
    for (final q in questionBank) {
      expect(q.options.length, 4);
      expect(q.options.toSet().length, 4);
      expect(q.correctIndex, inInclusiveRange(0, 3));
      expect(q.explanation, isNotEmpty);
    }
  });
  test('shuffling retains correct meaning and no duplicates', () {
    for (var seed = 0; seed < 20; seed++) {
      final s = QuizSession(
        QuizCategory.hardware,
        questionBank,
        random: Random(seed),
      );
      expect(s.questions.map((q) => q.id).toSet().length, 10);
      for (final q in s.questions) {
        final original = questionBank.singleWhere((o) => o.id == q.id);
        expect(
          q.options[q.correctIndex],
          original.options[original.correctIndex],
        );
      }
    }
  });
  test('reject skipped, invalid, duplicate answers and early finish', () {
    final s = QuizSession(QuizCategory.software, questionBank);
    expect(s.next, throwsStateError);
    expect(s.finish, throwsStateError);
    expect(() => s.answer(4), throwsRangeError);
    expect(() => s.answer(-1), throwsRangeError);
    s.answer(s.current.correctIndex);
    expect(() => s.answer(0), throwsStateError);
    expect(s.score, 10);
  });
  test('complete rounds score 0, 50 and 100 correctly', () {
    for (final correct in [0, 5, 10]) {
      final s = QuizSession(QuizCategory.internet, questionBank);
      for (var i = 0; i < 10; i++) {
        s.answer(
          i < correct
              ? s.current.correctIndex
              : (s.current.correctIndex + 1) % 4,
        );
        if (!s.last) s.next();
      }
      expect(s.finish().score, correct * 10);
      expect(s.next, throwsStateError);
    }
  });
  test('statistics, max, deduplication and round trip', () {
    var stats = const QuizStats().add(result('a', 8)).add(result('b', 4));
    stats = stats.add(result('a', 8));
    expect(stats.played, 2);
    expect(stats.accuracy, 60);
    expect(stats.best['hardware.easy'], 80);
    expect(QuizStats.fromJson(stats.toJson()).correct, 12);
  });
  test('history bounded at 30 while lifetime totals remain', () {
    var stats = const QuizStats();
    for (var i = 0; i < 40; i++) {
      stats = stats.add(result('$i', 5));
    }
    expect(stats.history.length, 30);
    expect(stats.played, 40);
    expect(stats.total, 400);
    expect(stats.history.first.id, '39');
  });
  test('save reload reset preserves author', () async {
    final disk = MemoryStorage();
    final a = AppStore(disk);
    expect(await a.saveAuthor('Kan', '12345'), true);
    expect(await a.record(result('r', 7)), true);
    final b = AppStore(disk);
    await b.load();
    expect(b.stats.highest, 70);
    expect(b.studentId, '12345');
    expect(await b.reset(), true);
    final c = AppStore(disk);
    await c.load();
    expect(c.stats.played, 0);
    expect(c.studentId, '12345');
  });
  test('failed writes are visible and retries do not double count', () async {
    final disk = MemoryStorage()..fail = true;
    final s = AppStore(disk);
    final r = result('retry', 10);
    expect(await s.record(r), false);
    expect(s.stats.played, 0);
    disk.fail = false;
    expect(await s.record(r), true);
    expect(await s.record(r), true);
    expect(s.stats.played, 1);
    disk.fail = true;
    expect(await s.reset(), false);
    expect(s.stats.played, 1);
  });
  test('corrupted saved data does not crash launch', () async {
    final disk = MemoryStorage()..data['comquiz.stats'] = '{broken';
    final s = AppStore(disk);
    await s.load();
    expect(s.warning, isNotNull);
    expect(s.stats.played, 0);
  });
  test('author validation and failed save keep existing values', () async {
    final disk = MemoryStorage();
    final s = AppStore(disk);
    expect(await s.saveAuthor('   ', ''), false);
    expect(await s.saveAuthor('   Kan Test   ', ' 777 '), true);
    expect(s.author, 'Kan Test');
    expect(s.studentId, '777');
    disk.fail = true;
    expect(await s.saveAuthor('Other', '999'), false);
    expect(s.author, 'Kan Test');
  });

  test(
    'all nine pools retain answers after shuffling and result round trip',
    () {
      for (final c in QuizCategory.values) {
        for (final d in QuizDifficulty.values) {
          for (var seed = 0; seed < 5; seed++) {
            final session = QuizSession(
              c,
              questionBank,
              difficulty: d,
              random: Random(seed),
            );
            expect(session.questions.map((q) => q.id).toSet().length, 10);
            for (var i = 0; i < 10; i++) {
              final q = session.current;
              expect(q.category, c);
              expect(q.difficulty, d);
              final original = questionBank.singleWhere((o) => o.id == q.id);
              expect(
                q.options[q.correctIndex],
                original.options[original.correctIndex],
              );
              session.answer(q.correctIndex);
              if (!session.last) session.next();
            }
            final loaded = GameResult.fromJson(session.finish().toJson());
            expect(loaded.score, 100);
            expect(loaded.category, c);
            expect(loaded.difficulty, d);
          }
        }
      }
    },
  );
  test(
    'incomplete difficulty pool is rejected without borrowing easier questions',
    () {
      final incomplete = questionBank.where((q) => q.id != 'hh01').toList();
      expect(
        () => QuizSession(
          QuizCategory.hardware,
          incomplete,
          difficulty: QuizDifficulty.hard,
        ),
        throwsArgumentError,
      );
    },
  );
  test('bests are independent for every category and level', () {
    var s = const QuizStats();
    var i = 0;
    for (final c in QuizCategory.values) {
      for (final d in QuizDifficulty.values) {
        s = s.add(result('pool-${i++}', i, category: c, difficulty: d));
        expect(s.bestFor(c, d), i * 10);
      }
    }
    s = s.add(result('lower', 0, difficulty: QuizDifficulty.hard));
    expect(s.bestFor(QuizCategory.hardware, QuizDifficulty.hard), 30);
    expect(s.best.length, 9);
    expect(s.bestFor(QuizCategory.hardware, QuizDifficulty.easy), 10);
    expect(s.categoryBest(QuizCategory.internet), 90);
  });
  test(
    'old storage migrates to easy and survives saving a new hard round',
    () async {
      final oldResult = result('legacy', 10).toJson()..remove('difficulty');
      final disk = MemoryStorage();
      disk.data['comquiz.stats'] = jsonEncode({
        'played': 1,
        'correct': 10,
        'total': 10,
        'best': {'hardware': 100},
        'history': [oldResult],
      });
      final store = AppStore(disk);
      await store.load();
      expect(store.warning, isNull);
      expect(
        store.stats.bestFor(QuizCategory.hardware, QuizDifficulty.easy),
        100,
      );
      expect(store.stats.history.single.difficulty, QuizDifficulty.easy);
      expect(
        await store.record(
          result('new-hard', 6, difficulty: QuizDifficulty.hard),
        ),
        true,
      );
      final reloaded = AppStore(disk);
      await reloaded.load();
      expect(reloaded.stats.played, 2);
      expect(reloaded.stats.correct, 16);
      expect(reloaded.stats.total, 20);
      expect(
        reloaded.stats.bestFor(QuizCategory.hardware, QuizDifficulty.easy),
        100,
      );
      expect(
        reloaded.stats.bestFor(QuizCategory.hardware, QuizDifficulty.hard),
        60,
      );
      expect(reloaded.stats.history.last.difficulty, QuizDifficulty.easy);
      expect(jsonDecode(disk.data['comquiz.stats']!)['schemaVersion'], 2);
    },
  );
  test('invalid saved difficulty and best-score keys are rejected', () {
    final badResult = result('bad', 5).toJson()..['difficulty'] = 'impossible';
    expect(() => GameResult.fromJson(badResult), throwsArgumentError);
    final badStats = const QuizStats().toJson()
      ..['best'] = {'hardware.impossible': 50};
    expect(() => QuizStats.fromJson(badStats), throwsFormatException);
    final negative = const QuizStats().toJson()..['best'] = {'hardware': -10};
    expect(() => QuizStats.fromJson(negative), throwsFormatException);
  });
}
