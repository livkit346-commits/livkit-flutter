import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  /// -----------------------------
  /// AUTHENTICATION
  /// -----------------------------
  Future<AuthResponse> signUp(String email, String password, String username) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async => await _client.auth.signOut();

  /// -----------------------------
  /// SESSION HELPERS
  /// -----------------------------
  Future<String?> getAccessToken() async {
    return _client.auth.currentSession?.accessToken;
  }

  bool get isAuthenticated => _client.auth.currentSession != null;

  Future<Map<String, dynamic>> fetchUserData() async => {};
  Future<void> updateProfile({required String displayName, required String bio, required String phone}) async {}
  Future<void> uploadAvatar(String path) async {}

  Future<String?> getUserId() async {
    return _client.auth.currentUser?.id;
  }

  Future<String?> getUsername() async {
    return _client.auth.currentUser?.userMetadata?['username'] ?? "User";
  }

  /// -----------------------------
  /// PASSWORD RESET
  /// -----------------------------
  Future<void> forgotPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}
