import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import '../models/image_library.dart';
import '../models/clothing.dart';
import '../services/ai_service.dart';
import '../services/clothing_items_service.dart';
import '../widgets/clothing_card.dart';

class WardrobePage extends StatefulWidget {
  final ImageLibraryState imageLibraryState;
  final AiAdapter ai;
  const WardrobePage({super.key, required this.imageLibraryState, required this.ai});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  final _rng = Random();
  ClothingCategory? _selectedCategory;
  final ClothingItemsService _service = ClothingItemsService();
  bool _loadingFromBackend = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _syncFromBackend();
  }

  Future<void> _syncFromBackend() async {
    setState(() {
      _loadingFromBackend = true;
      _error = null;
    });
    try {
      final items = await _service.fetchAll();
      widget.imageLibraryState.value = items;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingFromBackend = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadItem() async {
    try {
      final ImagePicker picker = ImagePicker();
      // Show dialog to choose camera or gallery
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Resim Kaynağı'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await picker.pickImage(source: source);
      if (image == null) return;

      if (!mounted) return;
      
      // Opt: ask for name or let backend/AI decide?
      // Backend create endpoint takes name/imageUrl, upload endpoint probably just file.
      // If upload endpoint returns the created item, we are good.
      // Let's assume upload endpoint handles everything including AI categorization.
      
      setState(() => _loadingFromBackend = true);
      
      final created = await _service.upload(image.path);
      widget.imageLibraryState.addItem(created);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kıyafet başarıyla eklendi!')),
      );
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingFromBackend = false);
      }
    }
  }

  String _getCategoryLabel(ClothingCategory category) {
    switch (category) {
      case ClothingCategory.top:
        return 'Shirts';
      case ClothingCategory.outerwear:
        return 'Jackets';
      case ClothingCategory.bottom:
        return 'Trousers';
      case ClothingCategory.shoes:
        return 'Shoes';
      case ClothingCategory.accessory:
        return 'Accessories';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.imageLibraryState,
      builder: (context, items, _) {
        // Group items by category
        final categories = ClothingCategory.values;
        final categoryItems = <ClothingCategory, List<ClothingItem>>{};
        for (var cat in categories) {
          categoryItems[cat] = items.where((e) => e.category == cat).toList();
        }

        final filteredItems = _selectedCategory == null
            ? items
            : items.where((item) => item.category == _selectedCategory).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F0),
          appBar: AppBar(
            title: const Text('My Wardrobe'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _pickAndUploadItem,
              ),
            ],
          ),
          body: _loadingFromBackend
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.checkroom_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Dolabın Boş',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'İlk parçanı eklemek için\n+ butonuna bas',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 40, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _syncFromBackend,
                              child: const Text('Tekrar dene'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        // Category Tabs
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 16, 20, 16),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildCategoryTab('All', null),
                                  const SizedBox(width: 12),
                                  ...categories.map((cat) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: _buildCategoryTab(
                                            _getCategoryLabel(cat), cat),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Content Sections
                        if (_selectedCategory == null ||
                            _selectedCategory ==
                                ClothingCategory.top)
                          _buildCategorySection(
                              'Shirts',
                              categoryItems[ClothingCategory.top] ??
                                  []),
                        if (_selectedCategory == null ||
                            _selectedCategory ==
                                ClothingCategory.outerwear)
                          _buildCategorySection(
                              'Jackets',
                              categoryItems[
                                      ClothingCategory.outerwear] ??
                                  []),
                        if (_selectedCategory == null ||
                            _selectedCategory ==
                                ClothingCategory.bottom)
                          _buildCategorySection(
                              'Trousers',
                              categoryItems[
                                      ClothingCategory.bottom] ??
                                  []),
                        if (_selectedCategory == null ||
                            _selectedCategory ==
                                ClothingCategory.shoes)
                          _buildCategorySection(
                              'Shoes',
                              categoryItems[
                                      ClothingCategory.shoes] ??
                                  []),
                        if (_selectedCategory == null ||
                            _selectedCategory ==
                                ClothingCategory.accessory)
                          _buildCategorySection(
                              'Accessories',
                              categoryItems[
                                      ClothingCategory.accessory] ??
                                  []),
                        const SliverToBoxAdapter(
                            child: SizedBox(height: 100)),
                      ],
                  ),
        );
      },
    );
  }

  Widget _buildCategoryTab(String label, ClothingCategory? category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, List<ClothingItem> items) {
    if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ClothingCard(
                  item: item,
                  onRemove: () => _deleteItem(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(ClothingItem item) async {
    final previous = widget.imageLibraryState.value;
    widget.imageLibraryState.removeById(item.id);
    try {
      await _service.delete(item.id);
    } catch (e) {
      if (!mounted) return;
      // Geri al
      widget.imageLibraryState.value = previous;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kıyafet silinemedi: $e')),
      );
    }
  }
}


