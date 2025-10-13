import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:combine_maker/models/outfit.dart';
import 'package:combine_maker/models/image_library.dart';
import 'package:combine_maker/screens/image_library_page.dart';
import 'package:combine_maker/widgets/image_from_path.dart';

class CreateOutfitPage extends StatefulWidget {
  final AppState appState;
  final ImageLibraryState? libraryState;
  final Outfit? editing;
  const CreateOutfitPage({super.key, required this.appState, this.libraryState, this.editing});

  @override
  State<CreateOutfitPage> createState() => _CreateOutfitPageState();
}

class _CreateOutfitPageState extends State<CreateOutfitPage> {
  final ImagePicker _picker = ImagePicker();
  String? _topImagePath;
  String? _bottomImagePath;
  String? _shoesImagePath;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    if (editing != null) {
      _titleController.text = editing.title;
      _topImagePath = editing.items.elementAtOrNull(0)?.imagePath;
      _bottomImagePath = editing.items.elementAtOrNull(1)?.imagePath;
      _shoesImagePath = editing.items.elementAtOrNull(2)?.imagePath;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kombin Oluştur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final isEditing = widget.editing != null;
              final outfit = Outfit(
                id: isEditing ? widget.editing!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text.isEmpty ? 'Kombin' : _titleController.text.trim(),
                items: [
                  ClothingItem(category: 'Üst Giyim', imagePath: _topImagePath),
                  ClothingItem(category: 'Alt Giyim', imagePath: _bottomImagePath),
                  ClothingItem(category: 'Ayakkabı', imagePath: _shoesImagePath),
                ],
                createdAt: isEditing ? widget.editing!.createdAt : DateTime.now(),
              );
              if (isEditing) {
                widget.appState.updateOutfit(outfit);
              } else {
                widget.appState.addOutfit(outfit);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Kombin başlığı (opsiyonel)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _buildClothingCategory('Üst Giyim'),
            const SizedBox(height: 16),
            _buildClothingCategory('Alt Giyim'),
            const SizedBox(height: 16),
            _buildClothingCategory('Ayakkabı'),
          ],
        ),
      ),
    );
  }

  Widget _buildClothingCategory(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _pickImageFor(title),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(child: _previewFor(title)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Kütüphaneden seç',
              icon: const Icon(Icons.photo_library),
              onPressed: () => _pickFromLibrary(title),
            ),
          ],
        ),
      ],
    );
  }

  Widget _previewFor(String title) {
    String? path;
    if (title == 'Üst Giyim') path = _topImagePath;
    if (title == 'Alt Giyim') path = _bottomImagePath;
    if (title == 'Ayakkabı') path = _shoesImagePath;
    if (path == null) return const Icon(Icons.add_a_photo, size: 40, color: Colors.grey);
    return ImageFromPath(path: path, fit: BoxFit.cover);
  }

  Future<void> _pickImageFor(String title) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      final path = picked.path;
      if (title == 'Üst Giyim') _topImagePath = path;
      if (title == 'Alt Giyim') _bottomImagePath = path;
      if (title == 'Ayakkabı') _shoesImagePath = path;
    });
  }

  Future<void> _pickFromLibrary(String title) async {
    if (widget.libraryState == null) return;
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageLibraryPage(libraryState: widget.libraryState!),
      ),
    );
    if (selected is StoredImage) {
      setState(() {
        if (title == 'Üst Giyim') _topImagePath = selected.path;
        if (title == 'Alt Giyim') _bottomImagePath = selected.path;
        if (title == 'Ayakkabı') _shoesImagePath = selected.path;
      });
    }
  }
}
