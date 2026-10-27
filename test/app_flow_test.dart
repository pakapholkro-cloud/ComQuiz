import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:comquiz/main.dart';
import 'package:comquiz/models/quiz.dart';
import 'package:comquiz/data/question_bank.dart';
import 'package:comquiz/services/app_store.dart';
import 'quiz_test.dart' show MemoryStorage, result;

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('full hard round and seven screens persist a perfect score', (
    t,
  ) async {
    final store = AppStore(MemoryStorage());
    await t.pumpWidget(ComQuizApp(store: store));
    await tap(t, find.byKey(const Key('start')));
    await tap(t, find.byKey(const Key('category-hardware')));
    await tap(t, find.byKey(const Key('difficulty-hard')));
    for (var i = 0; i < 10; i++) {
      final prompt = t.widget<Text>(find.byKey(const Key('question'))).data!;
      final q = questionBank.singleWhere((q) => q.prompt == prompt);
      await tap(t, find.text(q.options[q.correctIndex]));
      await tap(t, find.byKey(const Key('next')));
    }
    expect(find.text('บันทึกสถิติแล้ว'), findsOneWidget);
    expect(store.stats.highest, 100);
    expect(store.stats.played, 1);
    await tap(t, find.byKey(const Key('home')));
    await tap(t, find.text('สถิติ'));
    expect(find.text('เก่งขึ้นแค่ไหนแล้ว?'), findsOneWidget);
    await tap(t, find.text('ผู้จัดทำ').last);
    await tap(t, find.byKey(const Key('edit-author')));
    await t.enterText(find.byType(TextFormField).first, 'Kan Student');
    await t.enterText(find.byType(TextFormField).last, '123456');
    await tap(t, find.text('บันทึก'));
    expect(store.author, 'Kan Student');
    expect(store.studentId, '123456');
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'cancel exit retains round; confirmed exit never saves incomplete result',
    (t) async {
      final store = AppStore(MemoryStorage());
      await t.pumpWidget(ComQuizApp(store: store));
      await tap(t, find.byKey(const Key('start')));
      await tap(t, find.byKey(const Key('category-hardware')));
      await tap(t, find.byKey(const Key('difficulty-hard')));
      await tap(t, find.byKey(const Key('answer-0')));
      await tap(t, find.byTooltip('ออกจากเกม'));
      await tap(t, find.text('ยกเลิก'));
      expect(find.byKey(const Key('question')), findsOneWidget);
      await tap(t, find.byTooltip('ออกจากเกม'));
      await tap(t, find.widgetWithText(FilledButton, 'ออกจากเกม'));
      expect(find.text('เลือกระดับความยาก'), findsOneWidget);
      expect(store.stats.played, 0);
    },
  );
  testWidgets(
    '320px phone home about categories difficulty stats quiz have no layout overflow',
    (t) async {
      t.view.physicalSize = const Size(320, 740);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final smallStore = AppStore(MemoryStorage());
      for (final c in QuizCategory.values) {
        for (final d in QuizDifficulty.values) {
          await smallStore.record(
            result('${c.name}-${d.name}', 7, category: c, difficulty: d),
          );
        }
      }
      await t.pumpWidget(ComQuizApp(store: smallStore));
      expect(t.takeException(), isNull);
      await tap(t, find.text('สถิติ'));
      expect(t.takeException(), isNull);
      await tap(t, find.text('ผู้จัดทำ').last);
      expect(t.takeException(), isNull);
      await tap(t, find.text('หน้าแรก'));
      await tap(t, find.byKey(const Key('start')));
      expect(t.takeException(), isNull);
      await tap(t, find.byKey(const Key('category-hardware')));
      await tap(t, find.byKey(const Key('difficulty-hard')));
      expect(t.takeException(), isNull);
      await tap(t, find.byKey(const Key('answer-0')));
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'all three difficulty choices select only their own question pool',
    (t) async {
      final store = AppStore(MemoryStorage());
      await t.pumpWidget(ComQuizApp(store: store));
      await tap(t, find.byKey(const Key('start')));
      await tap(t, find.byKey(const Key('category-internet')));
      for (final d in QuizDifficulty.values) {
        await tap(t, find.byKey(Key('difficulty-${d.name}')));
        final prompt = t.widget<Text>(find.byKey(const Key('question'))).data!;
        final q = questionBank.singleWhere((q) => q.prompt == prompt);
        expect(q.category, QuizCategory.internet);
        expect(q.difficulty, d);
        await tap(t, find.byTooltip('ออกจากเกม'));
        await tap(t, find.widgetWithText(FilledButton, 'ออกจากเกม'));
      }
      expect(store.stats.played, 0);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'replay retains medium and returning refreshes its best independently',
    (t) async {
      final store = AppStore(MemoryStorage());
      await store.record(
        result('easy-best', 10, category: QuizCategory.software),
      );
      await t.pumpWidget(ComQuizApp(store: store));
      await tap(t, find.byKey(const Key('start')));
      await tap(t, find.byKey(const Key('category-software')));
      await tap(t, find.byKey(const Key('difficulty-medium')));
      for (var i = 0; i < 10; i++) {
        final prompt = t.widget<Text>(find.byKey(const Key('question'))).data!;
        final q = questionBank.singleWhere((q) => q.prompt == prompt);
        expect(q.difficulty, QuizDifficulty.medium);
        await tap(t, find.text(q.options[q.correctIndex]));
        await tap(t, find.byKey(const Key('next')));
      }
      expect(find.text('NEW PERSONAL BEST'), findsOneWidget);
      expect(
        store.stats.bestFor(QuizCategory.software, QuizDifficulty.easy),
        100,
      );
      expect(
        store.stats.bestFor(QuizCategory.software, QuizDifficulty.medium),
        100,
      );
      await tap(t, find.byKey(const Key('replay')));
      final prompt = t.widget<Text>(find.byKey(const Key('question'))).data!;
      expect(
        questionBank.singleWhere((q) => q.prompt == prompt).difficulty,
        QuizDifficulty.medium,
      );
      await tap(t, find.byTooltip('ออกจากเกม'));
      await tap(t, find.widgetWithText(FilledButton, 'ออกจากเกม'));
      expect(find.text('BEST 100'), findsNWidgets(2));
      expect(store.stats.played, 2);
      expect(t.takeException(), isNull);
    },
  );
}
