import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class Session {
  final bool isAuthenticated;
  final bool isPaid;

  Session({required this.isAuthenticated, required this.isPaid});
}

class AuthService {
  final _client = Supabase.instance.client;

  /// -----------------------------
  /// SIGNUP
  /// -----------------------------
  Future<void> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  /// -----------------------------
  /// LOGIN
  /// -----------------------------
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// -----------------------------
  /// TOKEN HELPERS
  /// -----------------------------
  Future<String?> getAccessToken() async {
    return _client.auth.currentSession?.accessToken;
  }

  Future<String?> getRefreshToken() async {
    return _client.auth.currentSession?.refreshToken;
  }

  Future<void> logout() async => await _client.auth.signOut();

  /// -----------------------------
  /// FETCH SESSION 
  /// -----------------------------
  Future<Session> fetchSession() async {
    final session = _client.auth.currentSession;
    return Session(
      isAuthenticated: session != null,
      isPaid: false, // Can be fetched from Django backend or user metadata
    );
  }

  Future<String?> getUsername() async {
    return _client.auth.currentUser?.userMetadata?['username'];
  }

  Future<String?> getUserId() async {
    return _client.auth.currentUser?.id;
  }

  /// -----------------------------
  /// FETCH FULL USER DATA
  /// -----------------------------
  Future<Map<String, dynamic>> fetchUserData() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Not authenticated");

    // We can fetch profile from Supabase 'profiles' table (usually synced with Django)
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    
    return response as Map<String, dynamic>;
  }

  /// -----------------------------
  /// UPDATE PROFILE
  /// -----------------------------
  Future<void> updateProfile({
    required String displayName,
    required String bio,
    required String phone,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Not authenticated");

    await _client.from('profiles').update({
      'display_name': displayName,
      'bio': bio,
      'phone': phone,
    }).eq('id', user.id);
    
    await _client.auth.updateUser(UserAttributes(
      data: {'username': displayName},
    ));
  }

  /// -----------------------------
  /// UPLOAD AVATAR
  /// -----------------------------
  Future<void> uploadAvatar(String filePath) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Not authenticated");

    final file = File(filePath);
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'profilepics/${user.id}/$fileName';

    await _client.storage.from('avatars').upload(path, file);
    final downloadUrl = _client.storage.from('avatars').getPublicUrl(path);

    await _client.from('profiles').update({
      'avatar': downloadUrl
    }).eq('id', user.id);
  }

  /// -----------------------------
  /// PASSWORD RESET
  /// -----------------------------
  Future<void> forgotPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}
