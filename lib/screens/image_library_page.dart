import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:combine_maker/models/image_library.dart';
import 'package:combine_maker/widgets/image_from_path.dart';

class ImageLibraryPage extends StatefulWidget {
  final ImageLibraryState libraryState;
  const ImageLibraryPage({super.key, required this.libraryState});

  @override
  State<ImageLibraryPage> createState() => _ImageLibraryPageState();
}

class _ImageLibraryPageState extends State<ImageLibraryPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _addFromGallery() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    widget.libraryState.addImage(
      StoredImage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        path: picked.path,
        addedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görsel Kütüphanesi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: _addFromGallery,
          ),
        ],
      ),
      body: ValueListenableBuilder<List<StoredImage>>(
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
                onTap: () => Navigator.pop(context, img),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ImageFromPath(path: img.path, fit: BoxFit.cover),
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
      widget.libraryState.removeImage(id);
    }
  }
}

