import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:innerscape/providers/app_providers.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

import 'package:provider/provider.dart';
import 'providers/journal_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final journalProvider = JournalProvider();
  await journalProvider.init();

  runApp(
    MultiProvider(
      providers: appProviders,
      child: const InnerscapeApp(),
    ),
  );
}

class InnerscapeApp extends StatelessWidget {
  const InnerscapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<JournalProvider>().lightMode;
    
    // Dynamically update status bar icon colors
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'Innerscape',
      debugShowCheckedModeBanner: false,
      theme: InnerscapeTheme.theme,
      darkTheme: InnerscapeTheme.darkTheme,
      themeMode: isLight ? ThemeMode.light : ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}
