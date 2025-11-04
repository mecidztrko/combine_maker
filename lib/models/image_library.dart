import 'package:flutter/foundation.dart';
import 'clothing.dart';

class ImageLibraryState extends ValueNotifier<List<ClothingItem>> {
  ImageLibraryState() : super(const []);

  void addItem(ClothingItem item) {
    value = [...value, item];
  }

  void removeById(String id) {
    value = value.where((e) => e.id != id).toList();
  }
}
