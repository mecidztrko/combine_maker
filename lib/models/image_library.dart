import 'package:flutter/foundation.dart';

class StoredImage {
  final String id; // unique id
  final String path; // file path (mobile) or blob/url (web)
  final DateTime addedAt;

  const StoredImage({required this.id, required this.path, required this.addedAt});

  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
        'addedAt': addedAt.toIso8601String(),
      };

  factory StoredImage.fromJson(Map<String, dynamic> json) => StoredImage(
        id: json['id'] as String,
        path: json['path'] as String,
        addedAt: DateTime.parse(json['addedAt'] as String),
      );
}

class ImageLibraryState extends ValueNotifier<List<StoredImage>> {
  ImageLibraryState() : super(const []);

  void addImage(StoredImage image) {
    value = [...value, image];
  }

  void removeImage(String id) {
    value = value.where((img) => img.id != id).toList(growable: false);
  }
}

