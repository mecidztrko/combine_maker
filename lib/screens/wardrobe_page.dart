import 'package:flutter/material.dart';
import 'dart:math';
import '../models/image_library.dart';
import '../models/clothing.dart';
import '../services/ai_service.dart';
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

  void _addMockItem() async {
    // MVP: use a dialog to get a name/hint, then auto-categorize
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Parça ekle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Örn: "siyah sneaker"'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('İptal')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(controller.text.trim()), child: const Text('Ekle')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;

    final category = widget.ai.autoCategorize(name);
    final item = ClothingItem(
      id: '${DateTime.now().millisecondsSinceEpoch}-${_rng.nextInt(1 << 32)}',
      name: name,
      imageUrl: 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/200/200',
      category: category,
      warmth: switch (category) {
        ClothingCategory.outerwear => 8,
        ClothingCategory.top => 4,
        ClothingCategory.bottom => 4,
        ClothingCategory.shoes => 3,
        ClothingCategory.accessory => 1,
      },
      formality: name.toLowerCase().contains('takım') || name.toLowerCase().contains('ceket') ? 7 : 4,
    );
    widget.imageLibraryState.addItem(item);
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
                onPressed: _addMockItem,
              ),
            ],
          ),
          body: items.isEmpty
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
              : CustomScrollView(
                  slivers: [
                    // Category Tabs
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildCategoryTab('All', null),
                              const SizedBox(width: 12),
                              ...categories.map((cat) => Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: _buildCategoryTab(_getCategoryLabel(cat), cat),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Content Sections
                    if (_selectedCategory == null || _selectedCategory == ClothingCategory.top)
                      _buildCategorySection('Shirts', categoryItems[ClothingCategory.top] ?? []),
                    if (_selectedCategory == null || _selectedCategory == ClothingCategory.outerwear)
                      _buildCategorySection('Jackets', categoryItems[ClothingCategory.outerwear] ?? []),
                    if (_selectedCategory == null || _selectedCategory == ClothingCategory.bottom)
                      _buildCategorySection('Trousers', categoryItems[ClothingCategory.bottom] ?? []),
                    if (_selectedCategory == null || _selectedCategory == ClothingCategory.shoes)
                      _buildCategorySection('Shoes', categoryItems[ClothingCategory.shoes] ?? []),
                    if (_selectedCategory == null || _selectedCategory == ClothingCategory.accessory)
                      _buildCategorySection('Accessories', categoryItems[ClothingCategory.accessory] ?? []),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
                return ClothingCard(
                  item: items[index],
                  onRemove: () => widget.imageLibraryState.removeById(items[index].id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


