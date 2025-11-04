import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'clothing.dart';

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

  static String encodeList(List<OutfitSuggestion> items) => jsonEncode(items.map((e) => e.toJson()).toList());
  static List<OutfitSuggestion> decodeList(String data) {
    final raw = jsonDecode(data) as List<dynamic>;
    return raw.map((e) => OutfitSuggestion.fromJson(e as Map<String, dynamic>)).toList();
  }
}

// App state containers
class AppState extends ValueNotifier<List<OutfitSuggestion>> {
  AppState() : super(const []);
}
