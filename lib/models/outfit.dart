import 'package:flutter/foundation.dart';

class ClothingItem {
  final String category; // e.g., Üst Giyim, Alt Giyim, Ayakkabı
  final String? imagePath; // local file path

  const ClothingItem({required this.category, this.imagePath});

  ClothingItem copyWith({String? category, String? imagePath}) {
    return ClothingItem(
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'imagePath': imagePath,
      };

  factory ClothingItem.fromJson(Map<String, dynamic> json) => ClothingItem(
        category: json['category'] as String,
        imagePath: json['imagePath'] as String?,
      );
}

class Outfit {
  final String id;
  final String title;
  final List<ClothingItem> items;
  final DateTime createdAt;

  const Outfit({
    required this.id,
    required this.title,
    required this.items,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'items': items.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Outfit.fromJson(Map<String, dynamic> json) => Outfit(
        id: json['id'] as String,
        title: json['title'] as String,
        items: (json['items'] as List).cast<Map<String, dynamic>>().map(ClothingItem.fromJson).toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

// Simple global app state using ValueNotifier for quick demo
class AppState extends ValueNotifier<List<Outfit>> {
  AppState() : super(const []);

  void addOutfit(Outfit outfit) {
    value = [...value, outfit];
  }

  void updateOutfit(Outfit updated) {
    value = [
      for (final o in value) if (o.id == updated.id) updated else o,
    ];
  }

  void deleteOutfit(String id) {
    value = value.where((o) => o.id != id).toList(growable: false);
  }
}

