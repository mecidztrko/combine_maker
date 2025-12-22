
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/outfit.dart';
import 'user_service.dart';

class OutfitService {
  OutfitService({http.Client? client, UserService? userService})
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

  /// POST /outfits/recommend
  /// Body: { "date": "iso-date", "eventType": "wedding" ... }
  Future<OutfitSuggestion> getRecommendation({
    required DateTime date,
    required String eventType, // e.g. "business", "casual", "wedding"
    String? location,
  }) async {
    final uri = Uri.parse('$_baseUrl/outfits/recommend');
    
    final body = {
      'date': date.toIso8601String(),
      'eventType': eventType,
      if (location != null) 'location': location,
    };

    final resp = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      // Expecting backend to return a structure compatible with OutfitSuggestion
      // or we might need a fromBackendJson adapter in OutfitSuggestion.
      // For now, assume it matches or is close enough to use existing fromJson or we adapt here.
      
      // If backend returns just the items list directly?
      // Swagger says "Tarih ve etkinlik bazlı kombin önerisi" -> likely one recommendation object.
      
      return OutfitSuggestion.fromJson(data);
    }

    throw Exception('Failed to get recommendation: ${resp.statusCode} ${resp.body}');
  }
}
