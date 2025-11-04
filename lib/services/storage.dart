import 'package:flutter/foundation.dart';
import '../models/outfit.dart';
import '../models/clothing.dart';

class StorageService {
  const StorageService();

  Future<(List<OutfitSuggestion>, List<ClothingItem>)> loadState() async {
    // MVP: no persistence yet; return empty lists
    return (const <OutfitSuggestion>[], const <ClothingItem>[]);
  }

  Future<void> saveState({
    required List<OutfitSuggestion> outfits,
    required List<ClothingItem> images,
  }) async {
    // MVP: no-op
    if (kDebugMode) {
      // ignore: avoid_print
      print('StorageService.saveState called (noop). outfits=${outfits.length}, images=${images.length}');
    }
  }
}
