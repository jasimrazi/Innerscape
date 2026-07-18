import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/supabase_service.dart';
import 'providers/auth_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/journal_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env
  await dotenv.load(fileName: ".env");
  
  // Safely initialize Supabase
  await SupabaseService.initialize();

  final journalProvider = JournalProvider();
  await journalProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: journalProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const InnerscapeApp(),
    ),
  );
}

class InnerscapeApp extends StatefulWidget {
  const InnerscapeApp({super.key});

  @override
  State<InnerscapeApp> createState() => _InnerscapeAppState();
}

class _InnerscapeAppState extends State<InnerscapeApp> {
  String? _lastSyncedUserId;

  @override
  Widget build(BuildContext context) {
    final journal = context.watch<JournalProvider>();
    final isLight = journal.lightMode;
    final auth = context.watch<AuthProvider>();

    // Sync local with cloud once on sign-in
    if (auth.isAuthenticated && auth.user?.id != null) {
      final currentUserId = auth.user!.id;
      if (currentUserId != _lastSyncedUserId) {
        _lastSyncedUserId = currentUserId;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          journal.syncWithCloud(currentUserId);
        });
      }
    } else if (!auth.isAuthenticated) {
      _lastSyncedUserId = null;
    }
    
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
