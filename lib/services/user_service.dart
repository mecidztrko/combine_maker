import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

/// Uygulama genelinde tek bir kullanıcı oturumu tutulması için
/// [UserService] basit bir singleton olarak tasarlandı.
class UserService {
  UserService._internal();
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;

  static const String _baseUrl = AppConfig.apiBaseUrl;

  String? _accessToken;
  Map<String, dynamic>? _currentUser;

  String? get accessToken => _accessToken;
  Map<String, dynamic>? get currentUser => _currentUser;

  /// POST /auth/register – swagger: body { email, password }
  /// [name] UI'de kullanılıyor, backend şu an sadece email & password beklediği için
  /// isteğe eklenmiyor ama imzayı bozmayalım.
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _storeAuth(response.body);
      return true;
    }

    throw Exception(_extractError(response));
  }

  Future<bool> login({required String email, required String password}) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _storeAuth(response.body);
      return true;
    }

    throw Exception(_extractError(response));
  }

  void _storeAuth(String body) {
    final data = jsonDecode(body) as Map<String, dynamic>;
    _accessToken = data['access_token'] as String?;
    _currentUser = data['user'] as Map<String, dynamic>?;
  }

  String _extractError(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    } catch (_) {}
    return 'İstek başarısız (status: ${response.statusCode})';
  }
}
