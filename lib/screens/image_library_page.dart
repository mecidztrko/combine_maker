import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:combine_maker/models/image_library.dart';
import 'package:combine_maker/models/clothing.dart';

class ImageLibraryPage extends StatefulWidget {
  final ImageLibraryState libraryState;
  const ImageLibraryPage({super.key, required this.libraryState});

  @override
  State<ImageLibraryPage> createState() => _ImageLibraryPageState();
}

class _ImageLibraryPageState extends State<ImageLibraryPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görsel Kütüphanesi'),
      ),
      body: ValueListenableBuilder<List<ClothingItem>>(
        valueListenable: widget.libraryState,
        builder: (context, images, _) {
          if (images.isEmpty) {
            return const Center(child: Text('Henüz görsel yok. Sağ üstten ekleyin.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final img = images[index];
              return GestureDetector(
                onLongPress: () => _confirmDelete(img.id),
                onTap: () => Navigator.pop(context, img.imageUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    img.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE0E0E0),
                      child: const Icon(Icons.image, color: Color(0xFF9E9E9E)),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görseli sil?'),
        content: const Text('Bu görsel kütüphaneden kaldırılacak.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
        ],
      ),
    );
    if (ok == true) {
      widget.libraryState.removeById(id);
    }
  }
}

