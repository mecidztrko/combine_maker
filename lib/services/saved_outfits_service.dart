import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/saved_outfit.dart';
import 'user_service.dart';

/// Backend saved-outfits endpoint'lerine bağlantı servisi
class SavedOutfitsService {
  SavedOutfitsService({http.Client? client, UserService? userService})
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

  /// POST /saved-outfits - Kombini kaydet
  Future<SavedOutfit> save(SaveOutfitRequest request) async {
    final uri = Uri.parse('$_baseUrl/saved-outfits');
    final resp = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode(request.toJson()),
    );

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return SavedOutfit.fromJson(data);
    }

    throw Exception(_extractError(resp));
  }

  /// GET /saved-outfits - Tüm kayıtlı kombinleri listele
  Future<SavedOutfitsListResponse> fetchAll() async {
    final uri = Uri.parse('$_baseUrl/saved-outfits');
    final resp = await _client.get(uri, headers: _headers());

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return SavedOutfitsListResponse.fromJson(data);
    }

    throw Exception(_extractError(resp));
  }

  /// GET /saved-outfits/by-occasion?occasion=X - Etkinliğe göre filtrele
  Future<List<SavedOutfit>> fetchByOccasion(String occasion) async {
    final uri = Uri.parse('$_baseUrl/saved-outfits/by-occasion?occasion=${Uri.encodeComponent(occasion)}');
    final resp = await _client.get(uri, headers: _headers());

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      return data
          .map((e) => SavedOutfit.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception(_extractError(resp));
  }

  /// GET /saved-outfits/:id - ID'ye göre detay
  Future<SavedOutfit> getById(String id) async {
    final uri = Uri.parse('$_baseUrl/saved-outfits/$id');
    final resp = await _client.get(uri, headers: _headers());

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return SavedOutfit.fromJson(data);
    }

    throw Exception(_extractError(resp));
  }

  /// DELETE /saved-outfits/:id - Kombini sil
  Future<void> delete(String id) async {
    final uri = Uri.parse('$_baseUrl/saved-outfits/$id');
    final resp = await _client.delete(uri, headers: _headers());

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return;
    }

    throw Exception(_extractError(resp));
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
