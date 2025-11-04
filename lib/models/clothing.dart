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

  static String encodeList(List<ClothingItem> items) => jsonEncode(items.map((e) => e.toJson()).toList());
  static List<ClothingItem> decodeList(String data) {
    final raw = jsonDecode(data) as List<dynamic>;
    return raw.map((e) => ClothingItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}


