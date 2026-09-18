import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _prefKey = 'admin_logged_in';
  static const _demoUser = 'admin';
  static const _demoPass = 'admin123';

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    if (SupabaseService.isConfigured) {
      _isLoggedIn = SupabaseService.client!.auth.currentSession != null;
    } else {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_prefKey) ?? false;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    if (SupabaseService.isConfigured) {
      try {
        await SupabaseService.client!.auth.signInWithPassword(email: username.trim(), password: password);
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } catch (_) {
        return false;
      }
    }

    final localUser = username.trim().split('@').first;
    final success = localUser == _demoUser && password == _demoPass;
    if (success) {
      _isLoggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, true);
      notifyListeners();
    }
    return success;
  }

  Future<void> logout() async {
    if (SupabaseService.isConfigured) {
      await SupabaseService.client!.auth.signOut();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, false);
    }
    _isLoggedIn = false;
    notifyListeners();
  }
}
