import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initListener();
  }

  void _initListener() {
    if (!SupabaseService.isInitialized) return;
    
    // Listen for authentication changes (sign in, sign out, etc.)
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    if (!SupabaseService.isInitialized) {
      _errorMessage = 'Supabase credentials are not configured in supabase_service.dart';
      notifyListeners();
      return false;
    }
    _errorMessage = null;
    try {
      await SupabaseService.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.innerscape://login-callback/',
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    if (!SupabaseService.isInitialized) {
      _errorMessage = 'Supabase credentials are not configured in supabase_service.dart';
      notifyListeners();
      return false;
    }
    _errorMessage = null;
    try {
      await SupabaseService.client.auth.signInWithOAuth(
        OAuthProvider.apple,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    if (!SupabaseService.isInitialized) return;
    _setLoading(true);
    try {
      await SupabaseService.client.auth.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}
