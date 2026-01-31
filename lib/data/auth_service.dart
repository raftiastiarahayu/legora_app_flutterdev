import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  /// LOGIN
  static Future<void> login(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  /// REGISTER
  static Future<void> register(String email, String password) async {
    await _supabase.auth.signUp(email: email, password: password);
  }

  /// LOGOUT
  static Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
