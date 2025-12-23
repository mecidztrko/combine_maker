import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io' show File, Platform;

class ImageFromPath extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  const ImageFromPath({super.key, required this.path, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return const Center(child: Icon(Icons.checkroom, size: 48, color: Colors.grey));
    }
    String value = path!;
    final bool isNetwork = value.startsWith('http://') || value.startsWith('https://');

    if (kIsWeb || isNetwork) {
      // Fix localhost for Android emulator
      if (!kIsWeb && Platform.isAndroid && value.contains('localhost')) {
        value = value.replaceFirst('localhost', '10.0.2.2');
      }
      print('ImageFromPath loading network image: $value');
    } else if (value.startsWith('/uploads')) {
      // Relative path from backend - prepend base URL
      final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
      value = '$baseUrl$value';
      print('ImageFromPath converted relative path to: $value');
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Image.network(
        value, 
        fit: fit, 
        errorBuilder: (c, e, s) => Container(
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(value), 
        fit: fit, 
        errorBuilder: (c, e, s) => const Center(child: Icon(Icons.image_not_supported)),
      );
    }
  }
}

