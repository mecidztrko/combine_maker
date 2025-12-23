import 'package:flutter/material.dart';
import '../models/clothing.dart';
import '../screens/clothing_detail_page.dart';
import 'image_from_path.dart';

class ClothingCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback? onRemove;
  const ClothingCard({super.key, required this.item, this.onRemove});

  String get _categoryLabel {
    switch (item.category) {
      case ClothingCategory.top:
        return 'Üst';
      case ClothingCategory.bottom:
        return 'Alt';
      case ClothingCategory.shoes:
        return 'Ayakkabı';
      case ClothingCategory.outerwear:
        return 'Dış giyim';
      case ClothingCategory.accessory:
        return 'Aksesuar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClothingDetailPage(item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  color: Colors.grey.shade50,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    children: [
                      Hero(
                        tag: 'clothing_${item.id}',
                        child: ImageFromPath(
                          path: item.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (onRemove != null)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: InkWell(
                              onTap: onRemove,
                              customBorder: const CircleBorder(),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: Icon(Icons.close, size: 16, color: Colors.red.shade600),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _categoryLabel,
                          style: TextStyle(
                            color: _categoryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Color get _categoryColor {
    switch (item.category) {
      case ClothingCategory.top:
        return Colors.blue;
      case ClothingCategory.bottom:
        return Colors.brown;
      case ClothingCategory.shoes:
        return Colors.orange;
      case ClothingCategory.outerwear:
        return Colors.grey;
      case ClothingCategory.accessory:
        return Colors.purple;
    }
  }
}


