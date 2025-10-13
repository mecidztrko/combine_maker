import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:combine_maker/models/outfit.dart';
import 'package:combine_maker/models/image_library.dart';

class StorageService {
  static const String _kOutfitsKey = 'outfits_json';
  static const String _kImagesKey = 'images_json';

  Future<void> saveState({required List<Outfit> outfits, required List<StoredImage> images}) async {
    final prefs = await SharedPreferences.getInstance();
    final outfitsJson = jsonEncode(outfits.map((e) => e.toJson()).toList());
    final imagesJson = jsonEncode(images.map((e) => e.toJson()).toList());
    await prefs.setString(_kOutfitsKey, outfitsJson);
    await prefs.setString(_kImagesKey, imagesJson);
  }

  Future<(List<Outfit>, List<StoredImage>)> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final outfitsStr = prefs.getString(_kOutfitsKey);
    final imagesStr = prefs.getString(_kImagesKey);

    final outfits = outfitsStr == null
        ? <Outfit>[]
        : (jsonDecode(outfitsStr) as List)
            .cast<Map<String, dynamic>>()
            .map(Outfit.fromJson)
            .toList();

    final images = imagesStr == null
        ? <StoredImage>[]
        : (jsonDecode(imagesStr) as List)
            .cast<Map<String, dynamic>>()
            .map(StoredImage.fromJson)
            .toList();

    return (outfits, images);
  }
}

