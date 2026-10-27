import 'package:flutter/material.dart';
import '../models/quiz.dart';

abstract final class CQ {
  static const background = Color(0xFF0B1020);
  static const surface = Color(0xFF151E32);
  static const line = Color(0xFF29364D);
  static const cyan = Color(0xFF67E8E1);
  static const muted = Color(0xFF9BAAC2);
  static const good = Color(0xFF80E6B0);
  static const wrong = Color(0xFFFFA6A6);
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    fontFamily: 'Sarabun',
    colorScheme: ColorScheme.fromSeed(
      seedColor: cyan,
      brightness: Brightness.dark,
      surface: surface,
      primary: cyan,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.35,
      ),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, height: 1.55),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Sarabun',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: background,
      indicatorColor: cyan.withValues(alpha: .13),
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(fontFamily: 'Sarabun', fontSize: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerTheme: const DividerThemeData(color: line),
  );
}

IconData categoryIcon(QuizCategory c) => switch (c) {
  QuizCategory.hardware => Icons.memory_rounded,
  QuizCategory.software => Icons.code_rounded,
  QuizCategory.internet => Icons.language_rounded,
};
Color categoryColor(QuizCategory c) => switch (c) {
  QuizCategory.hardware => CQ.cyan,
  QuizCategory.software => const Color(0xFFB6A6FF),
  QuizCategory.internet => const Color(0xFFFFC88B),
};

Color difficultyColor(QuizDifficulty d) => switch (d) {
  QuizDifficulty.easy => CQ.good,
  QuizDifficulty.medium => const Color(0xFFFFC88B),
  QuizDifficulty.hard => CQ.wrong,
};
IconData difficultyIcon(QuizDifficulty d) => switch (d) {
  QuizDifficulty.easy => Icons.eco_rounded,
  QuizDifficulty.medium => Icons.psychology_rounded,
  QuizDifficulty.hard => Icons.rocket_launch_rounded,
};

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.controller});
  final List<Widget> children;
  final ScrollController? controller;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    ),
  );
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.color, this.padding = 20});
  final Widget child;
  final Color? color;
  final double padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: color ?? CQ.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: CQ.line),
    ),
    child: child,
  );
}

class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.color = CQ.cyan});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

class StatTile extends StatelessWidget {
  const StatTile(this.value, this.label, {super.key, this.color = CQ.cyan});
  final String value;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Panel(
      padding: 14,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: CQ.muted, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class CircuitArt extends StatelessWidget {
  const CircuitArt({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 112,
    width: double.infinity,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: CustomPaint(painter: _CircuitPainter())),
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: CQ.cyan.withValues(alpha: .08),
            border: Border.all(color: CQ.cyan.withValues(alpha: .5)),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: CQ.cyan.withValues(alpha: .1), blurRadius: 35),
            ],
          ),
          child: const Icon(Icons.memory_rounded, color: CQ.cyan, size: 50),
        ),
      ],
    ),
  );
}

class _CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = CQ.cyan.withValues(alpha: .25)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;
    final cx = size.width / 2, cy = size.height / 2;
    for (final side in [-1, 1]) {
      for (var row = -1; row <= 1; row++) {
        final start = Offset(cx + side * 43, cy + row * 19);
        final end = Offset(cx + side * (size.width * .44), cy + row * 33);
        final path = Path()
          ..moveTo(start.dx, start.dy)
          ..lineTo(cx + side * 66, start.dy)
          ..lineTo(cx + side * 80, end.dy)
          ..lineTo(end.dx, end.dy);
        canvas.drawPath(path, p);
        canvas.drawCircle(end, 3, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<bool> confirm(
  BuildContext context,
  String title,
  String description,
  String action,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;

void message(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));
