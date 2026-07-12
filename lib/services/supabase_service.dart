import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static Future<void> initialize() async {
    // Only initialize if credentials are provided and differ from placeholders
    if (url.isNotEmpty &&
        url != 'YOUR_SUPABASE_PROJECT_URL' &&
        anonKey.isNotEmpty &&
        anonKey != 'YOUR_SUPABASE_ANON_KEY') {
      await Supabase.initialize(
        url: url,
        publishableKey: anonKey,
      );
    }
  }

  static SupabaseClient get client {
    return Supabase.instance.client;
  }

  static bool get isInitialized {
    try {
      Supabase.instance;
      return true;
    } catch (_) {
      return false;
    }
  }
}
