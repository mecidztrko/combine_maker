import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

/// Uygulama genelinde tek bir kullanıcı oturumu tutulması için
/// [UserService] basit bir singleton olarak tasarlandı.
class UserService {
  UserService._internal();
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;

  static const String _baseUrl = AppConfig.apiBaseUrl;
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user';

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
      await _storeAuth(response.body);
      return true;
    }

    throw Exception(_extractError(response));
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final uri = Uri.parse('$_baseUrl/auth/login');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Bağlantı zaman aşımına uğradı. Backend çalışıyor mu?');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _storeAuth(response.body);
        return true;
      }

      throw Exception(_extractError(response));
    } on http.ClientException catch (e) {
      throw Exception('Backend\'e bağlanılamadı: ${e.message}\n\nBackend çalışıyor mu? (http://localhost:3000)');
    } on FormatException catch (e) {
      throw Exception('Geçersiz yanıt formatı: $e');
    } catch (e) {
      if (e.toString().contains('timeout')) {
        rethrow;
      }
      throw Exception('Giriş hatası: $e');
    }
  }

  /// App açıldığında token'ı yükle
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);

    if (token != null) {
      _accessToken = token;
      if (userJson != null) {
        _currentUser = jsonDecode(userJson) as Map<String, dynamic>;
      }
    }
  }

  /// Token'ı kaydet
  Future<void> _saveToken(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  /// Token'ı temizle
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Logout
  Future<void> logout() async {
    await clearToken();
    _accessToken = null;
    _currentUser = null;
  }

  Future<void> _storeAuth(String body) async {
    final data = jsonDecode(body) as Map<String, dynamic>;
    _accessToken = data['access_token'] as String?;
    _currentUser = data['user'] as Map<String, dynamic>?;

    if (_accessToken != null && _currentUser != null) {
      await _saveToken(_accessToken!, _currentUser!);
    }
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
