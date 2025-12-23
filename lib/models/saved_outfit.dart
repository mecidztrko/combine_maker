import 'clothing.dart';

/// Backend SavedOutfitResponseDto formatına uygun model
class SavedOutfit {
  final String id;
  final String userId;
  final String occasion;
  final String date;
  final String city;
  final Map<String, dynamic> weather;
  final String explanation;
  final double score;
  final DateTime createdAt;
  final List<SavedOutfitItem> items;

  const SavedOutfit({
    required this.id,
    required this.userId,
    required this.occasion,
    required this.date,
    required this.city,
    required this.weather,
    required this.explanation,
    required this.score,
    required this.createdAt,
    required this.items,
  });

  factory SavedOutfit.fromJson(Map<String, dynamic> json) {
    return SavedOutfit(
      id: json['id'] as String,
      userId: json['userId'] as String,
      occasion: json['occasion'] as String,
      date: json['date'] as String,
      city: json['city'] as String,
      weather: json['weather'] as Map<String, dynamic>? ?? {},
      explanation: json['explanation'] as String,
      score: (json['score'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => SavedOutfitItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'occasion': occasion,
      'date': date,
      'city': city,
      'weather': weather,
      'explanation': explanation,
      'score': score,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

/// Backend OutfitItemDto formatına uygun (saved outfit içindeki item)
class SavedOutfitItem {
  final String id;
  final String clothingItemId;
  final SavedOutfitClothingItem clothingItem;

  const SavedOutfitItem({
    required this.id,
    required this.clothingItemId,
    required this.clothingItem,
  });

  factory SavedOutfitItem.fromJson(Map<String, dynamic> json) {
    return SavedOutfitItem(
      id: json['id'] as String,
      clothingItemId: json['clothingItemId'] as String,
      clothingItem: SavedOutfitClothingItem.fromJson(
          json['clothingItem'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clothingItemId': clothingItemId,
      'clothingItem': clothingItem.toJson(),
    };
  }
}

/// Saved outfit içindeki kıyafet detayı
class SavedOutfitClothingItem {
  final String id;
  final String name;
  final String imageUrl;
  final String color;
  final String categoryName;

  const SavedOutfitClothingItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.color,
    required this.categoryName,
  });

  factory SavedOutfitClothingItem.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    return SavedOutfitClothingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      color: json['color'] as String? ?? '',
      categoryName: category?['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'color': color,
      'category': {'name': categoryName},
    };
  }

  /// ClothingItem'a dönüştür
  ClothingItem toClothingItem() {
    return ClothingItem(
      id: id,
      name: name,
      imageUrl: imageUrl,
      category: _mapCategoryToEnum(categoryName),
      warmth: 5,
      formality: 5,
      color: color,
    );
  }
}

ClothingCategory _mapCategoryToEnum(String categoryName) {
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

/// Backend SaveOutfitDto formatına uygun - kaydetme isteği
class SaveOutfitRequest {
  final String occasion;
  final String date;
  final String city;
  final Map<String, dynamic> weather;
  final String explanation;
  final double score;
  final List<String> clothingItemIds;

  const SaveOutfitRequest({
    required this.occasion,
    required this.date,
    required this.city,
    required this.weather,
    required this.explanation,
    required this.score,
    required this.clothingItemIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'occasion': occasion,
      'date': date,
      'city': city,
      'weather': weather,
      'explanation': explanation,
      'score': score,
      'clothingItemIds': clothingItemIds,
    };
  }
}

/// Backend SavedOutfitsListResponseDto formatına uygun
class SavedOutfitsListResponse {
  final List<SavedOutfit> outfits;
  final int total;

  const SavedOutfitsListResponse({
    required this.outfits,
    required this.total,
  });

  factory SavedOutfitsListResponse.fromJson(Map<String, dynamic> json) {
    return SavedOutfitsListResponse(
      outfits: (json['outfits'] as List<dynamic>?)
              ?.map((e) => SavedOutfit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
    );
  }
}
