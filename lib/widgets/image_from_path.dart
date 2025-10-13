import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io' show File;

class ImageFromPath extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  const ImageFromPath({super.key, required this.path, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return const Center(child: Icon(Icons.checkroom, size: 48));
    }
    if (kIsWeb) {
      // image_picker on web returns a blob URL; Image.network ile gösterilir
      return Image.network(path!, fit: fit, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.image_not_supported)));
    } else {
      return Image.file(File(path!), fit: fit, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.image_not_supported)));
    }
  }
}

