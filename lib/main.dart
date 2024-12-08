import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weekly_todo/constants.dart';
import 'package:weekly_todo/utils/fs.dart';
import 'package:weekly_todo/widgets/layout.dart';
import 'package:window_manager/window_manager.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(1280, 800),
    backgroundColor: Colors.transparent,
  );
  await windowManager.waitUntilReadyToShow(windowOptions);
  await fs.init();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weekly Todo',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: DColors.activeColor,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: DColors.backgroundDeep,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(DSize.widgetPadding),
            constraints: const BoxConstraints(minWidth: 1280, maxWidth: 1920),
            child: const Layout(),
          ),
        ),
      );
}
