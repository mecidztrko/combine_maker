import 'dart:convert';
import 'package:http_parser/http_parser.dart';

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
      final dynamic decoded = jsonDecode(resp.body);
      List<dynamic> listData;
      
      if (decoded is List) {
        listData = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('data') && decoded['data'] is List) {
          listData = decoded['data'];
        } else if (decoded.containsKey('items') && decoded['items'] is List) {
          listData = decoded['items'];
        } else {
           print('Beklenmeyen yanıt formatı (Map): $decoded');
           throw Exception('Backend liste yerine nesne döndürdü: $decoded');
        }
      } else {
         throw Exception('Beklenmeyen yanıt formatı: ${decoded.runtimeType}');
      }

      return listData
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
      final dynamic decoded = jsonDecode(resp.body);
      List<dynamic> listData;
      
      if (decoded is List) {
        listData = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('data') && decoded['data'] is List) {
          listData = decoded['data'];
        } else if (decoded.containsKey('items') && decoded['items'] is List) {
          listData = decoded['items'];
        } else {
           print('Beklenmeyen yanıt formatı (Map): $decoded');
           throw Exception('Backend liste yerine nesne döndürdü: $decoded');
        }
      } else {
         throw Exception('Beklenmeyen yanıt formatı: ${decoded.runtimeType}');
      }

      return listData
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

  /// POST /clothing-items/upload - Upload image file
  Future<ClothingItem> upload(String filePath) async {
    final uri = Uri.parse('$_baseUrl/clothing-items/upload');
    final request = http.MultipartRequest('POST', uri);
    
    // Add Authorization header
    final token = _userService.accessToken;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Determine mime type
    final ext = filePath.split('.').last.toLowerCase();
    MediaType? mediaType;
    if (ext == 'jpg' || ext == 'jpeg') {
      mediaType = MediaType('image', 'jpeg');
    } else if (ext == 'png') {
      mediaType = MediaType('image', 'png');
    } else if (ext == 'webp') {
      mediaType = MediaType('image', 'webp');
    } else {
      mediaType = MediaType('image', 'jpeg');
    }

    print('Uploading file to $uri with field name: image');
    request.files.add(await http.MultipartFile.fromPath(
      'image', 
      filePath,
      contentType: mediaType,
    ));

    // Add name (required by backend)
    // Extract a default name from the file path, e.g. "image_picker_123.jpg" -> "New Item" or just filename
    final fileName = filePath.split('/').last;
    request.fields['name'] = 'Kıyafet ${DateTime.now().millisecond}'; // Unique-ish default name

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return ClothingItem.fromBackendJson(data);
    }
    
    throw Exception(_extractError(response));
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


