import 'package:flutter/material.dart';
import '../models/clothing.dart';
import '../widgets/image_from_path.dart';
import '../services/user_preferences.dart';

class ClothingDetailPage extends StatefulWidget {
  final ClothingItem item;

  const ClothingDetailPage({super.key, required this.item});

  @override
  State<ClothingDetailPage> createState() => _ClothingDetailPageState();
}

class _ClothingDetailPageState extends State<ClothingDetailPage> {
  String _userGender = 'Erkek';

  @override
  void initState() {
    super.initState();
    _loadUserGender();
  }

  Future<void> _loadUserGender() async {
    final gender = await UserPreferences.getGender();
    if (mounted) {
      setState(() => _userGender = gender);
    }
  }

  // Determine which gender to display for the clothing item
  String _getDisplayGender() {
    final itemGender = widget.item.gender;
    if (itemGender == null) return _userGender;
    
    // If unisex, show as-is
    if (itemGender.toLowerCase() == 'unisex') {
      return 'Unisex';
    }
    
    // If item gender differs from user gender, show user's gender
    final normalizedItemGender = itemGender.toLowerCase();
    final normalizedUserGender = _userGender.toLowerCase();
    
    // Map English to Turkish if needed
    final itemGenderNormalized = normalizedItemGender == 'men' || normalizedItemGender == 'erkek' 
        ? 'erkek' 
        : normalizedItemGender == 'women' || normalizedItemGender == 'kadın' || normalizedItemGender == 'kadin'
            ? 'kadın'
            : normalizedItemGender;
    
    final userGenderNormalized = normalizedUserGender == 'erkek' ? 'erkek' : 'kadın';
    
    // If different, return user's gender
    if (itemGenderNormalized != userGenderNormalized) {
      return _userGender;
    }
    
    return itemGender;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0), // Matching app theme
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black, // Back button color
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'clothing_${widget.item.id}',
                child: ImageFromPath(
                  path: widget.item.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(widget.item.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getCategoryLabel(widget.item.category),
                          style: TextStyle(
                            color: _getCategoryColor(widget.item.category),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Stats Section
                  _buildStatRow(
                    context,
                    'Sıcaklık',
                    widget.item.warmth / 10.0,
                    Colors.orange,
                    Icons.thermostat,
                  ),
                  const SizedBox(height: 24),
                  _buildStatRow(
                    context,
                    'Resmiyet',
                    widget.item.formality / 10.0,
                    Colors.indigo,
                    Icons.business_center,
                  ),
                  
                  // AI Confidence (if available)
                  if (widget.item.confidence != null) ...[
                    const SizedBox(height: 24),
                    _buildStatRow(
                      context,
                      'AI Güven Skoru',
                      widget.item.confidence!,
                      Colors.green,
                      Icons.psychology,
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // AI-detected properties section
                  if (widget.item.color != null || widget.item.style != null || widget.item.gender != null)
                    Container(
                      padding: const EdgeInsets.all(20),
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
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 20, color: Colors.purple.shade400),
                              const SizedBox(width: 8),
                              const Text(
                                'AI Analizi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              if (widget.item.color != null)
                                _buildInfoChip(Icons.palette, 'Renk', widget.item.color!, Colors.pink),
                              if (widget.item.style != null)
                                _buildInfoChip(Icons.style, 'Stil', widget.item.style!, Colors.teal),
                              if (widget.item.gender != null)
                                _buildInfoChip(Icons.person, 'Cinsiyet', _getDisplayGender(), Colors.blue),
                            ],
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 40),
                  
                  // Actions (Edit/Delete placeholder)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Edit functionality
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Düzenle'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Add to outfit
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Tamam'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    double value,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              '${(value * 10).toInt()}/10',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getCategoryLabel(ClothingCategory category) {
    switch (category) {
      case ClothingCategory.top:
        return 'Üst Giyim';
      case ClothingCategory.bottom:
        return 'Alt Giyim';
      case ClothingCategory.shoes:
        return 'Ayakkabı';
      case ClothingCategory.outerwear:
        return 'Dış Giyim';
      case ClothingCategory.accessory:
        return 'Aksesuar';
    }
  }

  Color _getCategoryColor(ClothingCategory category) {
    switch (category) {
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

  Widget _buildInfoChip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
