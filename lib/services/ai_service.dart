import 'dart:math';
import '../models/clothing.dart';
import '../models/outfit.dart';

abstract class AiAdapter {
  ClothingCategory autoCategorize(String imageHintOrName);
  List<OutfitSuggestion> suggestOutfits({
    required DateTime forDate,
    required String purpose,
    required List<ClothingItem> wardrobe,
    required int tempC,
    required String condition,
  });
}

class MockAiAdapter implements AiAdapter {
  final Random _rng = Random();

  @override
  ClothingCategory autoCategorize(String imageHintOrName) {
    final hint = imageHintOrName.toLowerCase();
    if (hint.contains('shoe') || hint.contains('sneaker') || hint.contains('ayakk')) {
      return ClothingCategory.shoes;
    }
    if (hint.contains('coat') || hint.contains('mont') || hint.contains('ceket')) {
      return ClothingCategory.outerwear;
    }
    if (hint.contains('pant') || hint.contains('jean') || hint.contains('etek') || hint.contains('skirt')) {
      return ClothingCategory.bottom;
    }
    if (hint.contains('watch') || hint.contains('saat') || hint.contains('belt') || hint.contains('kemer')) {
      return ClothingCategory.accessory;
    }
    return ClothingCategory.top;
  }

  @override
  List<OutfitSuggestion> suggestOutfits({
    required DateTime forDate,
    required String purpose,
    required List<ClothingItem> wardrobe,
    required int tempC,
    required String condition,
  }) {
    if (wardrobe.isEmpty) return const [];

    final tops = wardrobe.where((e) => e.category == ClothingCategory.top).toList();
    final bottoms = wardrobe.where((e) => e.category == ClothingCategory.bottom).toList();
    final shoes = wardrobe.where((e) => e.category == ClothingCategory.shoes).toList();
    final outers = wardrobe.where((e) => e.category == ClothingCategory.outerwear).toList();
    final accessories = wardrobe.where((e) => e.category == ClothingCategory.accessory).toList();

    List<OutfitSuggestion> results = [];

    int targetWarmth = tempC <= 5 ? 8 : tempC <= 15 ? 6 : tempC <= 25 ? 4 : 2;
    int targetFormality = purpose.toLowerCase().contains('iş') ? 7 : 4;

    for (int i = 0; i < 3; i++) {
      final top = tops.isNotEmpty ? tops[_rng.nextInt(tops.length)] : null;
      final bottom = bottoms.isNotEmpty ? bottoms[_rng.nextInt(bottoms.length)] : null;
      final shoe = shoes.isNotEmpty ? shoes[_rng.nextInt(shoes.length)] : null;
      final outer = (tempC < 18 && outers.isNotEmpty) ? outers[_rng.nextInt(outers.length)] : null;
      final accessory = accessories.isNotEmpty && _rng.nextBool() ? accessories[_rng.nextInt(accessories.length)] : null;

      final items = [top, bottom, shoe, outer, accessory].whereType<ClothingItem>().toList();
      if (items.isEmpty) continue;

      final warmthScore = items.map((e) => e.warmth).fold<int>(0, (a, b) => a + b) ~/ items.length;
      final formalityScore = items.map((e) => e.formality).fold<int>(0, (a, b) => a + b) ~/ items.length;

      final rationale = 'Hava: $tempC°C, $condition. Hedef sıcaklık ~$targetWarmth, formallik ~$targetFormality. '
          'Bu kombin ortalama sıcaklık $warmthScore ve formallik $formalityScore sunar.';

      results.add(OutfitSuggestion(
        id: '${forDate.millisecondsSinceEpoch}-$i',
        forDate: forDate,
        purpose: purpose,
        items: items,
        rationale: rationale,
      ));
    }

    return results;
  }
}

class RemoteAiAdapter implements AiAdapter {
  @override
  ClothingCategory autoCategorize(String imageHintOrName) {
    // Replace with real API call later
    throw UnimplementedError('Remote AI entegrasyonu eklenecek');
  }

  @override
  List<OutfitSuggestion> suggestOutfits({
    required DateTime forDate,
    required String purpose,
    required List<ClothingItem> wardrobe,
    required int tempC,
    required String condition,
  }) {
    // Replace with real API call later
    throw UnimplementedError('Remote AI entegrasyonu eklenecek');
  }
}


