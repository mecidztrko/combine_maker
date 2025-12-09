import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/clothing.dart';
import 'user_service.dart';

class ClothingItemsService {
  ClothingItemsService({http.Client? client, UserService? userService})
      : _client = client ?? http.Client(),
        _userService = userService ?? UserService();

  final http.Client _client;
  final UserService _userService;

  String get _baseUrl => AppConfig.apiBaseUrl;

  Map<String, String> _headers() {
    final token = _userService.accessToken;
    return <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET /clothing-items – giriş yapan kullanıcının tüm gardırobunu getirir.
  Future<List<ClothingItem>> fetchAll() async {
    final uri = Uri.parse('$_baseUrl/clothing-items');
    final resp = await _client.get(uri, headers: _headers());

    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
      return data
          .map((e) => ClothingItem.fromBackendJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception(_extractError(resp));
  }

  /// GET /clothing-items/category/{categoryName}
  ///
  /// Not: `categoryName` backend tarafındaki kategori tablosundaki isimle
  /// birebir aynı olmalıdır (örn: "T-SHIRT").
  Future<List<ClothingItem>> fetchByCategory(String categoryName) async {
    final uri = Uri.parse('$_baseUrl/clothing-items/category/$categoryName');
    final resp = await _client.get(uri, headers: _headers());

    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
      return data
          .map((e) => ClothingItem.fromBackendJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception(_extractError(resp));
  }

  /// POST /clothing-items – yeni bir kıyafet ekler.
  ///
  /// Backend sadece `name` ve `imageUrl` bekliyor.
  Future<ClothingItem> create({
    required String name,
    required String imageUrl,
  }) async {
    final uri = Uri.parse('$_baseUrl/clothing-items');
    final resp = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'imageUrl': imageUrl,
      }),
    );

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(resp.body) as Map<String, dynamic>;
      return ClothingItem.fromBackendJson(data);
    }

    throw Exception(_extractError(resp));
  }

  /// DELETE /clothing-items/{id}
  Future<void> delete(String id) async {
    final uri = Uri.parse('$_baseUrl/clothing-items/$id');
    final resp = await _client.delete(uri, headers: _headers());

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return;
    }

    throw Exception(_extractError(resp));
  }

  /// GET /clothing-items/{id}
  Future<ClothingItem> getById(String id) async {
    final uri = Uri.parse('$_baseUrl/clothing-items/$id');
    final resp = await _client.get(uri, headers: _headers());

    if (resp.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(resp.body) as Map<String, dynamic>;
      return ClothingItem.fromBackendJson(data);
    }

    throw Exception(_extractError(resp));
  }

  /// PATCH /clothing-items/{id}
  Future<ClothingItem> update({
    required String id,
    String? name,
    String? imageUrl,
  }) async {
    final uri = Uri.parse('$_baseUrl/clothing-items/$id');
    final Map<String, dynamic> body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (imageUrl != null) body['imageUrl'] = imageUrl;

    final resp = await _client.patch(
      uri,
      headers: _headers(),
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(resp.body) as Map<String, dynamic>;
      return ClothingItem.fromBackendJson(data);
    }

    throw Exception(_extractError(resp));
  }

  String _extractError(http.Response response) {
    try {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    } catch (_) {}
    return 'İstek başarısız (status: ${response.statusCode})';
  }
}


