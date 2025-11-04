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
  const CreateOutfitPage({super.key, required this.appState, this.libraryState});

  @override
  State<CreateOutfitPage> createState() => _CreateOutfitPageState();
}

class _CreateOutfitPageState extends State<CreateOutfitPage> {
  final ImagePicker _picker = ImagePicker();
  String? _topImagePath;
  String? _bottomImagePath;
  String? _shoesImagePath;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        title: const Text('Create Your Style'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () {
              // Upload functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Outfit Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preview Outfit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Model Preview Area
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(Icons.person, size: 100, color: Colors.grey.shade400),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Outfit Components
                    if (_topImagePath != null || _bottomImagePath != null || _shoesImagePath != null)
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (_topImagePath != null) _buildComponentCard('Shirt', _topImagePath!),
                          if (_bottomImagePath != null) _buildComponentCard('Trousers', _bottomImagePath!),
                          if (_shoesImagePath != null) _buildComponentCard('Shoes', _shoesImagePath!),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Edit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showEditDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text('Edit or Change Outfit'),
                ),
              ),
              const SizedBox(height: 32),
              // Outfits to Try Section
              const Text(
                'Outfits to Try',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Placeholder for suggested outfits
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                color: Colors.grey.shade100,
                              ),
                              child: Center(
                                child: Icon(Icons.image, color: Colors.grey.shade400),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Outfit ${index + 1}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComponentCard(String label, String imagePath) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ImageFromPath(
          path: imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _showEditDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Outfit',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildClothingCategory('Üst Giyim'),
                    const SizedBox(height: 16),
                    _buildClothingCategory('Alt Giyim'),
                    const SizedBox(height: 16),
                    _buildClothingCategory('Ayakkabı'),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Save Outfit'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
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
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _pickImageFor(title),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(child: _previewFor(title)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                tooltip: 'Kütüphaneden seç',
                icon: Icon(Icons.photo_library, color: Colors.grey.shade600),
                onPressed: () => _pickFromLibrary(title),
              ),
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
    // Page returns a String (image url) or null
    if (selected is String) {
      setState(() {
        if (title == 'Üst Giyim') _topImagePath = selected;
        if (title == 'Alt Giyim') _bottomImagePath = selected;
        if (title == 'Ayakkabı') _shoesImagePath = selected;
      });
    }
  }
}
