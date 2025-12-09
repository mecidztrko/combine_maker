import 'dart:convert';
import 'package:flutter/foundation.dart';

enum ClothingCategory {
  top,
  bottom,
  shoes,
  outerwear,
  accessory,
}

@immutable
class ClothingItem {
  final String id;
  final String name;
  final String imageUrl; // Could be asset, network, or file path
  final ClothingCategory category;
  final int warmth; // 1-10 subjective warmth
  final int formality; // 1-10 subjective formality

  const ClothingItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.warmth,
    required this.formality,
  });

  ClothingItem copyWith({
    String? id,
    String? name,
    String? imageUrl,
    ClothingCategory? category,
    int? warmth,
    int? formality,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      warmth: warmth ?? this.warmth,
      formality: formality ?? this.formality,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'category': category.name,
      'warmth': warmth,
      'formality': formality,
    };
  }

  /// Local JSON format (uygulama içi / storage için)
  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      category: ClothingCategory.values
          .firstWhere((e) => e.name == json['category'] as String),
      warmth: json['warmth'] as int,
      formality: json['formality'] as int,
    );
  }

  /// Backend'den gelen JSON'u (Prisma + kategori objesi) normalize eder.
  ///
  /// Beklenen örnek response:
  /// ```json
  /// {
  ///   "id": "...",
  ///   "name": "Beyaz Basic T-shirt",
  ///   "imageUrl": "https://...",
  ///   "color": "white",
  ///   "category": { "id": "...", "name": "T-SHIRT" }
  /// }
  /// ```
  factory ClothingItem.fromBackendJson(Map<String, dynamic> json) {
    final rawCategoryName = ((json['category'] as Map?)?['name'] ?? '') as String;
    final categoryName = rawCategoryName.toLowerCase();

    final category = _mapBackendCategory(categoryName);
    final warmth = _defaultWarmthFor(category);
    final formality = _defaultFormalityFor(categoryName);

    return ClothingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      category: category,
      warmth: warmth,
      formality: formality,
    );
  }

  static String encodeList(List<ClothingItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<ClothingItem> decodeList(String data) {
    final raw = jsonDecode(data) as List<dynamic>;
    return raw.map((e) => ClothingItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}

ClothingCategory _mapBackendCategory(String categoryName) {
  if (categoryName.contains('pant') ||
      categoryName.contains('jean') ||
      categoryName.contains('trouser') ||
      categoryName.contains('etek') ||
      categoryName.contains('skirt')) {
    return ClothingCategory.bottom;
  }
  if (categoryName.contains('shoe') ||
      categoryName.contains('sneaker') ||
      categoryName.contains('boot') ||
      categoryName.contains('ayakk')) {
    return ClothingCategory.shoes;
  }
  if (categoryName.contains('coat') ||
      categoryName.contains('jacket') ||
      categoryName.contains('mont') ||
      categoryName.contains('kaban')) {
    return ClothingCategory.outerwear;
  }
  if (categoryName.contains('watch') ||
      categoryName.contains('belt') ||
      categoryName.contains('bag') ||
      categoryName.contains('aksesuar') ||
      categoryName.contains('accessory')) {
    return ClothingCategory.accessory;
  }
  // Varsayılan olarak üst giyim
  return ClothingCategory.top;
}

int _defaultWarmthFor(ClothingCategory category) {
  switch (category) {
    case ClothingCategory.outerwear:
      return 8;
    case ClothingCategory.top:
      return 4;
    case ClothingCategory.bottom:
      return 4;
    case ClothingCategory.shoes:
      return 3;
    case ClothingCategory.accessory:
      return 1;
  }
}

int _defaultFormalityFor(String categoryName) {
  final lowered = categoryName.toLowerCase();
  if (lowered.contains('takim') ||
      lowered.contains('suit') ||
      lowered.contains('smoking') ||
      lowered.contains('ceket')) {
    return 7;
  }
  return 4;
}



