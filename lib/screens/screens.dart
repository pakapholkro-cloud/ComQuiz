import 'package:flutter/material.dart';
import '../data/question_bank.dart';
import '../models/quiz.dart';
import '../services/app_store.dart';
import '../ui/design.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.store});
  final AppStore store;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) => Scaffold(
      body: switch (tab) {
        0 => HomeScreen(store: widget.store),
        1 => StatsScreen(store: widget.store),
        _ => AboutScreen(store: widget.store),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'หน้าแรก',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'สถิติ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'ผู้จัดทำ',
          ),
        ],
      ),
    ),
  );
}

void openCategories(BuildContext context, AppStore store) => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => CategoryScreen(store: store)),
);
void openDifficulty(
  BuildContext context,
  AppStore store,
  QuizCategory category,
) => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DifficultyScreen(store: store, category: category),
  ),
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store});
  final AppStore store;
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      const Row(
        children: [
          Icon(Icons.memory_rounded, color: CQ.cyan, size: 29),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'ComQuiz',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(width: 8),
          Tag('PLAY & LEARN'),
        ],
      ),
      const SizedBox(height: 30),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Tag('COMPUTER KNOWLEDGE'),
            const SizedBox(height: 16),
            Text(
              'คอมเก่งขึ้น\nอีกนิด ทุกวัน.',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'ท้าทายความรู้เรื่องคอมพิวเตอร์\nเล่นสั้น ๆ ได้ความรู้กลับไปทุกข้อ',
              style: TextStyle(color: CQ.muted, height: 1.65),
            ),
            const CircuitArt(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('start'),
                onPressed: () => openCategories(context, store),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('เริ่มเล่น'),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                '3 ระดับ  ·  รอบละ 10 ข้อ  ·  เล่นออฟไลน์ได้',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: CQ.muted),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          StatTile('${store.stats.played}', 'รอบที่เล่นจบ'),
          const SizedBox(width: 12),
          StatTile('${store.stats.highest}', 'คะแนนสูงสุด'),
        ],
      ),
      if (store.warning != null)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(store.warning!, style: const TextStyle(color: CQ.wrong)),
        ),
      const SizedBox(height: 28),
      Row(
        children: [
          Expanded(
            child: Text(
              'เลือกเรื่องที่อยากเก่ง',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(width: 10),
          const Text('3 หมวด', style: TextStyle(color: CQ.muted)),
        ],
      ),
      const SizedBox(height: 14),
      for (final c in QuizCategory.values)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: CQ.surface,
            borderRadius: BorderRadius.circular(18),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 6,
              ),
              leading: Icon(categoryIcon(c), color: categoryColor(c), size: 30),
              title: Text(c.title),
              subtitle: const Text(
                '30 คำถาม · 3 ระดับ',
                style: TextStyle(color: CQ.muted),
              ),
              trailing: const Icon(Icons.arrow_forward_rounded, size: 20),
              onTap: () => openDifficulty(context, store, c),
            ),
          ),
        ),
    ],
  );
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, required this.store});
  final AppStore store;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('เลือกหมวดคำถาม')),
    body: PageBody(
      children: [
        const Tag('CHOOSE YOUR CHALLENGE'),
        const SizedBox(height: 16),
        Text(
          'วันนี้อยากลอง\nเรื่องไหนดี?',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        const Text(
          'เลือกหมวด แล้วเลือกระดับง่าย กลาง หรือยาก\nรอบละ 10 ข้อ พร้อมเฉลยทุกข้อ',
          style: TextStyle(color: CQ.muted, height: 1.6),
        ),
        const SizedBox(height: 24),
        for (final c in QuizCategory.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(categoryIcon(c), size: 34, color: categoryColor(c)),
                      const Spacer(),
                      Tag(
                        'BEST ${store.stats.categoryBest(c)}',
                        color: categoryColor(c),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(c.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(c.description, style: const TextStyle(color: CQ.muted)),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: Key('category-${c.name}'),
                      onPressed: () => openDifficulty(context, store, c),
                      label: Text('เลือกหมวด${c.title}'),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({
    super.key,
    required this.store,
    required this.category,
  });
  final AppStore store;
  final QuizCategory category;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('เลือกระดับความยาก')),
      body: PageBody(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Tag(category.title, color: categoryColor(category)),
          ),
          const SizedBox(height: 16),
          Text(
            'ท้าทายตัวเอง\nในระดับที่ใช่',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 10),
          const Text(
            '10 ข้อ · เต็ม 100 คะแนน · ไม่จับเวลา',
            style: TextStyle(color: CQ.muted),
          ),
          const SizedBox(height: 22),
          for (final d in QuizDifficulty.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          difficultyIcon(d),
                          size: 28,
                          color: difficultyColor(d),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            d.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Tag(
                          'BEST ${store.stats.bestFor(category, d)}',
                          color: difficultyColor(d),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      d.description,
                      style: const TextStyle(color: CQ.muted),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: Key('difficulty-${d.name}'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizScreen(
                              store: store,
                              category: category,
                              difficulty: d,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text('เล่นระดับ${d.title}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Text(
            'คะแนนสูงสุดแยกตามหมวดและระดับ เล่นซ้ำเพื่อทบทวนได้',
            style: TextStyle(color: CQ.muted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.store,
    required this.category,
    required this.difficulty,
  });
  final AppStore store;
  final QuizCategory category;
  final QuizDifficulty difficulty;
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizSession session = QuizSession(
    widget.category,
    questionBank,
    difficulty: widget.difficulty,
  );
  final scroll = ScrollController();
  bool ending = false;
  bool leaving = false;
  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  Future<void> leave() async {
    if (leaving || ending) return;
    leaving = true;
    final exit = await confirm(
      context,
      'ออกจากรอบนี้?',
      'รอบที่เล่นไม่ครบจะไม่ถูกบันทึกในสถิติ',
      'ออกจากเกม',
    );
    if (mounted && exit) Navigator.pop(context);
    leaving = false;
  }

  void advance() {
    if (ending || !session.answered) return;
    if (session.last) {
      ending = true;
      final result = session.finish();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            store: widget.store,
            result: result,
            answers: session.answers,
          ),
        ),
      );
    } else {
      setState(session.next);
      if (scroll.hasClients) scroll.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = session.current;
    final answer = session.answered ? session.answers.last : null;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) leave();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'ออกจากเกม',
            onPressed: leave,
            icon: const Icon(Icons.close_rounded),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.category.title, style: const TextStyle(fontSize: 18)),
              Text(
                'ระดับ${widget.difficulty.title}',
                style: TextStyle(
                  fontSize: 12,
                  color: difficultyColor(widget.difficulty),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Tag('${session.score} คะแนน'),
            ),
          ],
        ),
        body: PageBody(
          controller: scroll,
          children: [
            Row(
              children: [
                Text(
                  'คำถามที่ ${session.index + 1}',
                  style: const TextStyle(
                    color: CQ.cyan,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${session.index + 1} / 10',
                  style: const TextStyle(color: CQ.muted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (session.index + 1) / 10,
                minHeight: 6,
                backgroundColor: CQ.line,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              q.prompt,
              key: const Key('question'),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 24, height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'เลือกคำตอบที่ถูกต้องเพียงข้อเดียว',
              style: TextStyle(color: CQ.muted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < q.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AnswerOption(
                  key: Key('answer-$i'),
                  letter: String.fromCharCode(65 + i),
                  text: q.options[i],
                  selected: answer?.choice == i,
                  revealCorrect: answer != null && q.correctIndex == i,
                  enabled: answer == null,
                  onTap: () => setState(() => session.answer(i)),
                ),
              ),
            if (answer != null) ...[
              const SizedBox(height: 8),
              Panel(
                color: answer.correct
                    ? const Color(0xFF15302D)
                    : const Color(0xFF322332),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          answer.correct
                              ? Icons.check_circle_rounded
                              : Icons.info_outline_rounded,
                          color: answer.correct ? CQ.good : CQ.wrong,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            answer.correct
                                ? 'ถูกต้อง! +10 คะแนน'
                                : 'ยังไม่ใช่ ลองจำข้อนี้ไว้',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: answer.correct ? CQ.good : CQ.wrong,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(q.explanation),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('next'),
              onPressed: answer == null ? null : advance,
              child: Text(
                answer == null
                    ? 'เลือกคำตอบก่อน'
                    : session.last
                    ? 'ดูผลคะแนน'
                    : 'ข้อต่อไป',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    super.key,
    required this.letter,
    required this.text,
    required this.selected,
    required this.revealCorrect,
    required this.enabled,
    required this.onTap,
  });
  final String letter, text;
  final bool selected, revealCorrect, enabled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final color = revealCorrect
        ? CQ.good
        : selected
        ? CQ.wrong
        : CQ.muted;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: '$letter $text',
      onTap: enabled ? onTap : null,
      child: ExcludeSemantics(
        child: Material(
          color: revealCorrect
              ? const Color(0xFF16312D)
              : selected
              ? const Color(0xFF322332)
              : CQ.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
            side: BorderSide(
              color: revealCorrect || selected ? color : CQ.line,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      letter,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                  if (revealCorrect || selected)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        revealCorrect
                            ? Icons.check_rounded
                            : Icons.close_rounded,
                        color: color,
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.store,
    required this.result,
    required this.answers,
  });
  final AppStore store;
  final GameResult result;
  final List<QuizAnswer> answers;
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool saving = true;
  bool saved = false;
  late final bool newBest;
  @override
  void initState() {
    super.initState();
    newBest =
        widget.result.score >
        widget.store.stats.bestFor(
          widget.result.category,
          widget.result.difficulty,
        );
    save();
  }

  Future<void> save() async {
    final ok = await widget.store.record(widget.result);
    if (mounted) {
      setState(() {
        saving = false;
        saved = ok;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ผลคะแนน')),
    body: PageBody(
      children: [
        Center(child: Tag(newBest ? 'NEW PERSONAL BEST' : 'ROUND COMPLETE')),
        const SizedBox(height: 26),
        Center(
          child: SizedBox(
            width: 190,
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: widget.result.score / 100,
                    strokeWidth: 10,
                    backgroundColor: CQ.line,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.result.score}',
                      key: const Key('score'),
                      style: const TextStyle(
                        fontSize: 62,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: CQ.cyan,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'จาก 100 คะแนน',
                      style: TextStyle(color: CQ.muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        Text(
          widget.result.score >= 80
              ? 'เก่งมาก! ไปต่อได้อีก'
              : widget.result.score >= 50
              ? 'ทำได้ดี ลองอีกสักรอบ'
              : 'ทุกข้อคือโอกาสเรียนรู้',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(
          '${widget.result.category.title} · ระดับ${widget.result.difficulty.title}\nถูก ${widget.result.correct} / 10 ข้อ',
          textAlign: TextAlign.center,
          style: const TextStyle(color: CQ.muted),
        ),
        const SizedBox(height: 20),
        if (saving)
          const Center(child: Text('กำลังบันทึกสถิติ…'))
        else if (saved)
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 16,
                color: CQ.good,
              ),
              SizedBox(width: 6),
              Text(
                'บันทึกสถิติแล้ว',
                style: TextStyle(color: CQ.good, fontSize: 13),
              ),
            ],
          )
        else
          Panel(
            child: Column(
              children: [
                const Text(
                  'บันทึกไม่สำเร็จ รอบนี้ยังไม่อยู่ในสถิติ',
                  style: TextStyle(color: CQ.wrong),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => saving = true);
                    save();
                  },
                  child: const Text('ลองบันทึกอีกครั้ง'),
                ),
              ],
            ),
          ),
        const SizedBox(height: 26),
        FilledButton.icon(
          key: const Key('replay'),
          onPressed: saving
              ? null
              : () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      store: widget.store,
                      category: widget.result.category,
                      difficulty: widget.result.difficulty,
                    ),
                  ),
                ),
          icon: const Icon(Icons.replay_rounded),
          label: const Text('เล่นระดับนี้อีกครั้ง'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          key: const Key('change-difficulty'),
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('เปลี่ยนระดับความยาก'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: saving
              ? null
              : () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  openCategories(context, widget.store);
                },
          child: const Text('เลือกหมวดอื่น'),
        ),
        TextButton(
          key: const Key('home'),
          onPressed: saving
              ? null
              : () => Navigator.popUntil(context, (route) => route.isFirst),
          child: const Text('กลับหน้าแรก'),
        ),
        const SizedBox(height: 24),
        Text('ทบทวนคำตอบ', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        for (var i = 0; i < widget.answers.length; i++)
          _ReviewTile(index: i, answer: widget.answers[i]),
      ],
    ),
  );
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.index, required this.answer});
  final int index;
  final QuizAnswer answer;
  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
    leading: Icon(
      answer.correct ? Icons.check_circle_outline : Icons.cancel_outlined,
      color: answer.correct ? CQ.good : CQ.wrong,
    ),
    title: Text(
      '${index + 1}. ${answer.question.prompt}',
      style: const TextStyle(fontSize: 14),
    ),
    childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
    expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'ตอบ: ${answer.question.options[answer.choice]}',
        style: TextStyle(color: answer.correct ? CQ.good : CQ.wrong),
      ),
      if (!answer.correct)
        Text(
          'คำตอบที่ถูก: ${answer.question.options[answer.question.correctIndex]}',
          style: const TextStyle(color: CQ.good),
        ),
      const SizedBox(height: 8),
      Text(
        answer.question.explanation,
        style: const TextStyle(color: CQ.muted),
      ),
    ],
  );
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.store});
  final AppStore store;
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      const Tag('YOUR PROGRESS'),
      const SizedBox(height: 18),
      Text(
        'เก่งขึ้นแค่ไหนแล้ว?',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 8),
      const Text(
        'สถิติจากรอบที่เล่นจบในอุปกรณ์นี้',
        style: TextStyle(color: CQ.muted),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          StatTile('${store.stats.played}', 'รอบที่เล่นจบ'),
          const SizedBox(width: 10),
          StatTile('${store.stats.accuracy}%', 'ตอบถูกทั้งหมด'),
        ],
      ),
      const SizedBox(height: 28),
      Text(
        'คะแนนสูงสุดแต่ละระดับ',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 14),
      Panel(
        child: Column(
          children: [
            for (final c in QuizCategory.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          categoryIcon(c),
                          color: categoryColor(c),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(c.title)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final d in QuizDifficulty.values)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              difficultyIcon(d),
                              color: difficultyColor(d),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(d.title),
                            const Spacer(),
                            Text(
                              store.stats.best.containsKey(scoreKey(c, d))
                                  ? '${store.stats.bestFor(c, d)} / 100'
                                  : 'ยังไม่เล่น',
                              key: Key('best-${c.name}-${d.name}'),
                              style: TextStyle(color: difficultyColor(d)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 28),
      Text('10 รอบล่าสุด', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 14),
      if (store.stats.history.isEmpty)
        Panel(
          child: Column(
            children: [
              const Icon(
                Icons.sports_esports_outlined,
                size: 40,
                color: CQ.muted,
              ),
              const SizedBox(height: 12),
              const Text('ยังไม่มีสถิติ มาเล่นรอบแรกกัน'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => openCategories(context, store),
                child: const Text('เริ่มเล่น'),
              ),
            ],
          ),
        )
      else ...[
        for (final r in store.stats.history.take(10))
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              categoryIcon(r.category),
              color: categoryColor(r.category),
            ),
            title: Text('${r.category.title} · ${r.difficulty.title}'),
            subtitle: Text(
              _date(r.date),
              style: const TextStyle(color: CQ.muted),
            ),
            trailing: Text(
              '${r.score}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: CQ.cyan,
              ),
            ),
          ),
        const SizedBox(height: 18),
        TextButton.icon(
          onPressed: () async {
            if (await confirm(
              context,
              'ล้างสถิติทั้งหมด?',
              'คะแนนสูงสุดและประวัติในอุปกรณ์นี้จะถูกลบ ข้อมูลผู้จัดทำจะยังอยู่',
              'ล้างสถิติ',
            )) {
              final ok = await store.reset();
              if (context.mounted) {
                message(
                  context,
                  ok ? 'ล้างสถิติแล้ว' : 'ล้างสถิติไม่สำเร็จ ลองอีกครั้ง',
                );
              }
            }
          },
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('ล้างสถิติ'),
        ),
      ],
      const SizedBox(height: 12),
      const Text(
        'ข้อมูลเก็บเฉพาะเครื่องนี้ การถอนแอปหรือล้างข้อมูลเบราว์เซอร์อาจทำให้สถิติหาย',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: CQ.muted),
      ),
    ],
  );
  String _date(DateTime date) {
    final d = date.toLocal();
    return '${d.day}/${d.month}/${d.year + 543} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required this.store});
  final AppStore store;
  Future<void> edit(BuildContext context) async {
    final name = TextEditingController(text: store.author);
    final id = TextEditingController(text: store.studentId);
    final form = GlobalKey<FormState>();
    final values = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ข้อมูลผู้จัดทำ'),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  maxLength: 60,
                  decoration: const InputDecoration(labelText: 'ชื่อผู้จัดทำ'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'กรอกชื่อก่อนนะ' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: id,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    labelText: 'รหัสนักศึกษา (เว้นว่างได้)',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(ctx, [name.text, id.text]);
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
    // Dispose after the dialog's exit animation has finished.
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      name.dispose();
      id.dispose();
    });
    if (values != null) {
      final ok = await store.saveAuthor(values[0], values[1]);
      if (context.mounted) {
        message(
          context,
          ok ? 'บันทึกข้อมูลแล้ว' : 'บันทึกไม่สำเร็จ ลองอีกครั้ง',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      const Tag('MADE TO LEARN'),
      const SizedBox(height: 18),
      Text(
        'เกี่ยวกับ ComQuiz',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 22),
      const CircuitArt(),
      const SizedBox(height: 18),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ผู้จัดทำ', style: TextStyle(color: CQ.muted)),
            const SizedBox(height: 8),
            Text(store.author, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              store.studentId.isEmpty
                  ? 'ยังไม่ได้ระบุรหัสนักศึกษา'
                  : 'รหัสนักศึกษา ${store.studentId}',
              style: const TextStyle(color: CQ.muted),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              key: const Key('edit-author'),
              onPressed: () => edit(context),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('แก้ไขข้อมูลผู้จัดทำ'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'เรียนรู้ผ่านการเล่น',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 10),
      const Text(
        'เกมตอบคำถามความรู้คอมพิวเตอร์เบื้องต้น เพื่อทบทวนเรื่องฮาร์ดแวร์ ซอฟต์แวร์ และอินเทอร์เน็ต ผ่านคำถามสั้น ๆ พร้อมคำอธิบาย',
      ),
      const SizedBox(height: 22),
      const Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'วิธีเล่น',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            Text(
              '1. เลือกหมวดและระดับความยาก\n2. เลือกคำตอบ 1 จาก 4 ตัวเลือก\n3. อ่านเฉลย แล้วไปข้อต่อไป\n4. ตอบครบ 10 ข้อเพื่อบันทึกสถิติ\n\nคำถามรวม 90 ข้อ แยกเป็น 3 หมวด × 3 ระดับ',
              style: TextStyle(height: 1.9),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        'โปรเจกต์รายวิชาการพัฒนาแอปพลิเคชันบนอุปกรณ์เคลื่อนที่\nพัฒนาด้วย Flutter · เวอร์ชัน 1.1.0',
        textAlign: TextAlign.center,
        style: TextStyle(color: CQ.muted, fontSize: 12, height: 1.7),
      ),
    ],
  );
}
