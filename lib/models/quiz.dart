import 'dart:math';

enum QuizCategory {
  hardware('ฮาร์ดแวร์', 'รู้จักอุปกรณ์และชิ้นส่วนคอมพิวเตอร์'),
  software('ซอฟต์แวร์', 'ระบบปฏิบัติการและโปรแกรมรอบตัว'),
  internet('อินเทอร์เน็ต', 'เครือข่ายและการใช้งานอย่างปลอดภัย');

  const QuizCategory(this.title, this.description);
  final String title;
  final String description;
}

enum QuizDifficulty {
  easy('ง่าย', 'เริ่มจากพื้นฐาน รู้จักคำศัพท์และหน้าที่ของอุปกรณ์'),
  medium('กลาง', 'นำความรู้ไปใช้ เลือกวิธีแก้ปัญหาในสถานการณ์ใกล้ตัว'),
  hard('ยาก', 'คิดวิเคราะห์ เชื่อมโยงเหตุผลและรายละเอียดทางเทคนิค');

  const QuizDifficulty(this.title, this.description);
  final String title;
  final String description;
}

String scoreKey(QuizCategory category, QuizDifficulty difficulty) =>
    '${category.name}.${difficulty.name}';

class QuizQuestion {
  const QuizQuestion(
    this.id,
    this.category,
    this.prompt,
    this.options,
    this.correctIndex,
    this.explanation, {
    this.difficulty = QuizDifficulty.easy,
  });
  final String id;
  final QuizCategory category;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final QuizDifficulty difficulty;

  QuizQuestion shuffled(Random random) {
    final indices = List.generate(options.length, (i) => i)..shuffle(random);
    return QuizQuestion(
      id,
      category,
      prompt,
      indices.map((i) => options[i]).toList(),
      indices.indexOf(correctIndex),
      explanation,
      difficulty: difficulty,
    );
  }
}

class QuizAnswer {
  const QuizAnswer(this.question, this.choice);
  final QuizQuestion question;
  final int choice;
  bool get correct => choice == question.correctIndex;
}

class QuizSession {
  QuizSession(
    this.category,
    List<QuizQuestion> bank, {
    Random? random,
    this.difficulty = QuizDifficulty.easy,
  }) {
    final rng = random ?? Random();
    final selected =
        bank
            .where((q) => q.category == category && q.difficulty == difficulty)
            .toList()
          ..shuffle(rng);
    if (selected.length < 10) {
      throw ArgumentError(
        'A category and difficulty must contain at least 10 questions',
      );
    }
    questions = selected.take(10).map((q) => q.shuffled(rng)).toList();
  }
  final QuizCategory category;
  final QuizDifficulty difficulty;
  late final List<QuizQuestion> questions;
  final List<QuizAnswer> _answers = [];
  int index = 0;
  List<QuizAnswer> get answers => List.unmodifiable(_answers);
  QuizQuestion get current => questions[index];
  bool get answered => _answers.length > index;
  bool get last => index == questions.length - 1;
  bool get complete => _answers.length == questions.length;
  int get correctCount => _answers.where((a) => a.correct).length;
  int get score => correctCount * 10;

  void answer(int choice) {
    if (answered) throw StateError('This question already has an answer');
    if (choice < 0 || choice >= current.options.length) {
      throw RangeError.index(choice, current.options);
    }
    _answers.add(QuizAnswer(current, choice));
  }

  void next() {
    if (!answered || last) throw StateError('Cannot advance');
    index++;
  }

  GameResult finish({DateTime? now}) {
    if (!complete) throw StateError('Finish all questions first');
    final date = now ?? DateTime.now();
    return GameResult(
      id: '${date.microsecondsSinceEpoch}-${Random().nextInt(1 << 30)}',
      category: category,
      difficulty: difficulty,
      correct: correctCount,
      total: questions.length,
      date: date,
    );
  }
}

class GameResult {
  const GameResult({
    required this.id,
    required this.category,
    required this.correct,
    required this.total,
    required this.date,
    this.difficulty = QuizDifficulty.easy,
  });
  final String id;
  final QuizCategory category;
  final int correct;
  final int total;
  final DateTime date;
  final QuizDifficulty difficulty;
  int get score => correct * 10;
  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'difficulty': difficulty.name,
    'correct': correct,
    'total': total,
    'date': date.toIso8601String(),
  };
  factory GameResult.fromJson(Map<String, dynamic> j) {
    final result = GameResult(
      id: j['id'] as String,
      category: QuizCategory.values.byName(j['category'] as String),
      difficulty: QuizDifficulty.values.byName(
        j['difficulty'] as String? ?? 'easy',
      ),
      correct: j['correct'] as int,
      total: j['total'] as int,
      date: DateTime.parse(j['date'] as String),
    );
    if (result.total != 10 || result.correct < 0 || result.correct > 10) {
      throw const FormatException('Invalid result');
    }
    return result;
  }
}

class QuizStats {
  const QuizStats({
    this.played = 0,
    this.correct = 0,
    this.total = 0,
    this.best = const {},
    this.history = const [],
  });
  final int played;
  final int correct;
  final int total;
  final Map<String, int> best;
  final List<GameResult> history;
  int get accuracy => total == 0 ? 0 : (correct / total * 100).round();
  int get highest => best.values.fold(0, max);
  int bestFor(QuizCategory c, QuizDifficulty d) => best[scoreKey(c, d)] ?? 0;
  int categoryBest(QuizCategory c) =>
      QuizDifficulty.values.map((d) => bestFor(c, d)).fold(0, max);
  QuizStats add(GameResult result) {
    if (history.any((r) => r.id == result.id)) return this;
    return QuizStats(
      played: played + 1,
      correct: correct + result.correct,
      total: total + result.total,
      best: {
        ...best,
        scoreKey(result.category, result.difficulty): max(
          bestFor(result.category, result.difficulty),
          result.score,
        ),
      },
      history: [result, ...history].take(30).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': 2,
    'played': played,
    'correct': correct,
    'total': total,
    'best': best,
    'history': history.map((r) => r.toJson()).toList(),
  };
  factory QuizStats.fromJson(Map<String, dynamic> j) {
    final migratedBest = <String, int>{};
    for (final entry in Map<String, int>.from(j['best'] as Map).entries) {
      final isLegacy = QuizCategory.values.any((c) => c.name == entry.key);
      final key = isLegacy ? '${entry.key}.easy' : entry.key;
      if (entry.value < 0 || entry.value > 100 || entry.value % 10 != 0) {
        throw const FormatException('Invalid best score');
      }
      migratedBest[key] = max(migratedBest[key] ?? 0, entry.value);
    }
    final s = QuizStats(
      played: j['played'] as int,
      correct: j['correct'] as int,
      total: j['total'] as int,
      best: migratedBest,
      history: (j['history'] as List)
          .map((r) => GameResult.fromJson(Map<String, dynamic>.from(r as Map)))
          .take(30)
          .toList(),
    );
    if (s.played < 0 ||
        s.total != s.played * 10 ||
        s.correct < 0 ||
        s.correct > s.total ||
        s.best.entries.any(
          (e) =>
              !QuizCategory.values.any(
                (c) =>
                    QuizDifficulty.values.any((d) => scoreKey(c, d) == e.key),
              ) ||
              e.value < 0 ||
              e.value > 100 ||
              e.value % 10 != 0,
        )) {
      throw const FormatException('Invalid statistics');
    }
    return s;
  }
}
