import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'clothing.dart';

/// Backend OutfitItemDto formatına uygun
class OutfitItemDto {
  final String id;
  final String name;
  final String imageUrl;
  final String color;
  final String category;

  const OutfitItemDto({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.color,
    required this.category,
  });

  factory OutfitItemDto.fromJson(Map<String, dynamic> json) {
    // Category can be a string or an object { name: "..." }
    String categoryStr = '';
    final rawCategory = json['category'];
    if (rawCategory is String) {
      categoryStr = rawCategory;
    } else if (rawCategory is Map<String, dynamic>) {
      categoryStr = rawCategory['name'] as String? ?? '';
    }
    
    return OutfitItemDto(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      color: json['color'] as String? ?? '',
      category: categoryStr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'color': color,
      'category': category,
    };
  }
}

/// Backend OutfitDto formatına uygun - tek bir kombin önerisi
class OutfitDto {
  final List<OutfitItemDto> items;
  final double score;
  final String explanation;

  const OutfitDto({
    required this.items,
    required this.score,
    required this.explanation,
  });

  factory OutfitDto.fromJson(Map<String, dynamic> json) {
    return OutfitDto(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OutfitItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'score': score,
      'explanation': explanation,
    };
  }
}

/// Backend OutfitRecommendationResponseDto formatına uygun
class OutfitRecommendationResponse {
  final List<OutfitDto> outfits;
  final WeatherData weather;
  final String explanation;
  final String? weatherConsiderations;

  const OutfitRecommendationResponse({
    required this.outfits,
    required this.weather,
    required this.explanation,
    this.weatherConsiderations,
  });

  factory OutfitRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return OutfitRecommendationResponse(
      outfits: (json['outfits'] as List<dynamic>?)
              ?.map((e) => OutfitDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      weather: WeatherData.fromJson(json['weather'] as Map<String, dynamic>? ?? {}),
      explanation: json['explanation'] as String? ?? '',
      weatherConsiderations: json['weatherConsiderations'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'outfits': outfits.map((e) => e.toJson()).toList(),
      'weather': weather.toJson(),
      'explanation': explanation,
      if (weatherConsiderations != null)
        'weatherConsiderations': weatherConsiderations,
    };
  }
}

/// Hava durumu verisi (outfit response içinde kullanılır)
class WeatherData {
  final String city;
  final int tempCelsius;
  final String condition;
  final String description;
  final bool isRainy;
  final bool isSnowy;
  final bool isCold;
  final bool isHot;
  final String source;

  const WeatherData({
    required this.city,
    required this.tempCelsius,
    required this.condition,
    required this.description,
    required this.isRainy,
    required this.isSnowy,
    required this.isCold,
    required this.isHot,
    required this.source,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: json['city'] as String? ?? 'Unknown',
      tempCelsius: (json['temp_celsius'] as num?)?.toInt() ?? 20,
      condition: json['condition'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      isRainy: json['is_rainy'] as bool? ?? false,
      isSnowy: json['is_snowy'] as bool? ?? false,
      isCold: json['is_cold'] as bool? ?? false,
      isHot: json['is_hot'] as bool? ?? false,
      source: json['source'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'temp_celsius': tempCelsius,
      'condition': condition,
      'description': description,
      'is_rainy': isRainy,
      'is_snowy': isSnowy,
      'is_cold': isCold,
      'is_hot': isHot,
      'source': source,
    };
  }
}

// ====================================================================
// Legacy OutfitSuggestion - geriye uyumluluk için korunuyor
// ====================================================================

@immutable
class OutfitSuggestion {
  final String id;
  final DateTime forDate;
  final String purpose; // e.g., "iş görüşmesi"
  final List<ClothingItem> items;
  final String rationale; // why selected

  const OutfitSuggestion({
    required this.id,
    required this.forDate,
    required this.purpose,
    required this.items,
    required this.rationale,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'forDate': forDate.toIso8601String(),
      'purpose': purpose,
      'items': items.map((e) => e.toJson()).toList(),
      'rationale': rationale,
    };
  }

  factory OutfitSuggestion.fromJson(Map<String, dynamic> json) {
    return OutfitSuggestion(
      id: json['id'] as String,
      forDate: DateTime.parse(json['forDate'] as String),
      purpose: json['purpose'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => ClothingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      rationale: json['rationale'] as String,
    );
  }

  /// Backend OutfitDto'dan OutfitSuggestion'a dönüştür
  factory OutfitSuggestion.fromBackendOutfitDto(
    OutfitDto dto, {
    required DateTime forDate,
    required String purpose,
  }) {
    return OutfitSuggestion(
      id: '${forDate.millisecondsSinceEpoch}-${dto.score.hashCode}',
      forDate: forDate,
      purpose: purpose,
      items: dto.items
          .map((item) => ClothingItem(
                id: item.id,
                name: item.name,
                imageUrl: item.imageUrl,
                category: _mapBackendCategoryToEnum(item.category),
                warmth: 5,
                formality: 5,
                color: item.color,
              ))
          .toList(),
      rationale: dto.explanation,
    );
  }

  static String encodeList(List<OutfitSuggestion> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());
  static List<OutfitSuggestion> decodeList(String data) {
    final raw = jsonDecode(data) as List<dynamic>;
    return raw
        .map((e) => OutfitSuggestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

ClothingCategory _mapBackendCategoryToEnum(String categoryName) {
  final name = categoryName.toLowerCase();
  if (name.contains('pant') || name.contains('jean') || name.contains('trouser')) {
    return ClothingCategory.bottom;
  }
  if (name.contains('shoe') || name.contains('sneaker') || name.contains('boot')) {
    return ClothingCategory.shoes;
  }
  if (name.contains('coat') || name.contains('jacket') || name.contains('mont')) {
    return ClothingCategory.outerwear;
  }
  if (name.contains('watch') || name.contains('belt') || name.contains('bag')) {
    return ClothingCategory.accessory;
  }
  return ClothingCategory.top;
}

// App state containers
class AppState extends ValueNotifier<List<OutfitSuggestion>> {
  AppState() : super(const []);
}
