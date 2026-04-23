import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class StreamingService {
  final String _baseUrl = 'https://livkit.onrender.com/api/streaming'; // Target Django backend
  final AuthService _auth = AuthService();

  /// HELPER: Get Auth Headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _auth.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// CREATE LIVE (Streamer)
  Future<Map<String, dynamic>> createLiveStream({
    required String title,
    bool isPrivate = false,
    String? password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/create/'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'title': title,
        'is_private': isPrivate,
        'password': password ?? '',
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to create stream: ${response.body}");
    }

    return jsonDecode(response.body);
  }

  /// JOIN LIVE (Viewer)
  Future<Map<String, dynamic>> joinLiveStream({
    required String streamId,
    String? password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$streamId/join/'),
      headers: await _getHeaders(),
      body: jsonEncode({'password': password ?? ''}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to join stream: ${response.body}");
    }

    return jsonDecode(response.body);
  }

  /// HEARTBEAT (Viewer)
  Future<void> sendHeartbeat({required String streamId}) async {
    await http.post(
      Uri.parse('$_baseUrl/$streamId/heartbeat/'),
      headers: await _getHeaders(),
    );
  }

  /// LEAVE LIVE (Viewer)
  Future<void> leaveLiveStream({required String streamId}) async {
    await http.post(
      Uri.parse('$_baseUrl/$streamId/leave/'),
      headers: await _getHeaders(),
    );
  }

  /// END LIVE (Streamer)
  Future<void> endLiveStream({required String streamId}) async {
    await http.post(
      Uri.parse('$_baseUrl/$streamId/end/'),
      headers: await _getHeaders(),
    );
  }

  /// HOME FEED 
  Future<Map<String, dynamic>> fetchHomeFeed() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/feed/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch feed: ${response.body}");
    }

    return jsonDecode(response.body);
  }

  /// SEND GIFT
  Future<void> sendGift({
    required String streamId,
    required int amount,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$streamId/gift/'),
      headers: await _getHeaders(),
      body: jsonEncode({'amount': amount}),
    );

    if (response.statusCode != 200) {
       throw Exception("Failed to send gift: ${response.body}");
    }
  }

  /// SEARCH
  Future<Map<String, dynamic>> search({required String query}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search/?q=$query'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception("Search failed: ${response.body}");
    }

    return jsonDecode(response.body);
  }
}
