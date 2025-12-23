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
  /// Backend RecommendOutfitDto formatına uygun:
  /// { "date": "YYYY-MM-DD", "occasion": "iş görüşmesi", "city": "Istanbul" }
  Future<OutfitRecommendationResponse> getRecommendations({
    required DateTime date,
    required String occasion,
    String city = 'Istanbul',
  }) async {
    final uri = Uri.parse('$_baseUrl/outfits/recommend');
    
    // Backend YYYY-MM-DD formatı bekliyor
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    
    final body = {
      'date': dateStr,
      'occasion': occasion,
      'city': city,
    };

    final resp = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return OutfitRecommendationResponse.fromJson(data);
    }

    throw Exception('Kombin önerisi alınamadı: ${resp.statusCode} ${resp.body}');
  }

  /// Geriye uyumluluk için eski metod imzası
  /// @deprecated Use getRecommendations instead
  Future<OutfitSuggestion> getRecommendation({
    required DateTime date,
    required String eventType, // Eski isim, occasion'a çevrilecek
    String? location,
  }) async {
    final response = await getRecommendations(
      date: date,
      occasion: eventType,
      city: location ?? 'Istanbul',
    );

    // İlk öneriyi döndür
    if (response.outfits.isEmpty) {
      throw Exception('Kombin önerisi bulunamadı');
    }

    return OutfitSuggestion.fromBackendOutfitDto(
      response.outfits.first,
      forDate: date,
      purpose: eventType,
    );
  }

  /// Birden fazla öneri al ve OutfitSuggestion listesi olarak döndür
  Future<List<OutfitSuggestion>> getSuggestions({
    required DateTime date,
    required String occasion,
    String city = 'Istanbul',
  }) async {
    final response = await getRecommendations(
      date: date,
      occasion: occasion,
      city: city,
    );

    return response.outfits
        .map((dto) => OutfitSuggestion.fromBackendOutfitDto(
              dto,
              forDate: date,
              purpose: occasion,
            ))
        .toList();
  }
}
