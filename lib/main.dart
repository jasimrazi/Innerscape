import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

import 'package:provider/provider.dart';
import 'providers/journal_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => JournalProvider(),
      child: const InnerscapeApp(),
    ),
  );
}

class InnerscapeApp extends StatelessWidget {
  const InnerscapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Innerscape',
      debugShowCheckedModeBanner: false,
      theme: InnerscapeTheme.theme,
      home: const SplashScreen(),
    );
  }
}
