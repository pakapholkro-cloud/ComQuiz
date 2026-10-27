import 'package:flutter/material.dart';
import 'services/app_store.dart';
import 'screens/screens.dart';
import 'ui/design.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore(DeviceStorage());
  await store.load();
  runApp(ComQuizApp(store: store));
}

class ComQuizApp extends StatelessWidget {
  const ComQuizApp({super.key, required this.store});
  final AppStore store;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ComQuiz',
    debugShowCheckedModeBanner: false,
    theme: CQ.theme,
    home: HomeShell(store: store),
  );
}
