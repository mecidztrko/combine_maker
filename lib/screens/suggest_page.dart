import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../models/saved_outfit.dart';
import '../services/weather_service.dart';
import '../services/outfit_service.dart';
import '../services/saved_outfits_service.dart';
import '../config.dart';

class SuggestPage extends StatefulWidget {
  const SuggestPage({super.key});

  @override
  State<SuggestPage> createState() => _SuggestPageState();
}

class _SuggestPageState extends State<SuggestPage> {
  DateTime _date = DateTime.now();
  final TextEditingController _purpose = TextEditingController(text: 'iş görüşmesi');
  final _outfitService = OutfitService();
  final _weatherService = WeatherService();
  final _savedOutfitsService = SavedOutfitsService();
  
  WeatherInfo? _weather;
  OutfitRecommendationResponse? _recommendation;
  bool _loading = false;
  Set<int> _savingIndices = {};

  @override
  void dispose() {
    _purpose.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _date,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _suggest() async {
    setState(() {
      _loading = true;
      _recommendation = null;
    });
    
    try {
      // Hava durumunu al
      final weather = await _weatherService.getWeatherFor(_date);
      
      // Backend'den kombin önerisi al (Gemini AI)
      final response = await _outfitService.getRecommendations(
        date: _date,
        occasion: _purpose.text.trim().isEmpty ? 'genel' : _purpose.text.trim(),
        city: 'Istanbul',
      );

      setState(() {
        _weather = weather;
        _recommendation = response;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _saveToFavorites(OutfitDto outfit, int index) async {
    if (_savingIndices.contains(index)) return;
    
    setState(() => _savingIndices.add(index));
    
    try {
      final dateStr = "${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}";
      
      await _savedOutfitsService.save(SaveOutfitRequest(
        occasion: _purpose.text.trim().isEmpty ? 'genel' : _purpose.text.trim(),
        date: dateStr,
        city: 'Istanbul',
        weather: _weather?.toJson() ?? {},
        explanation: outfit.explanation,
        score: outfit.score,
        clothingItemIds: outfit.items.map((item) => item.id).toList(),
      ));
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Kombin favorilere eklendi!'),
            ],
          ),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kaydetme hatası: $e'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _savingIndices.remove(index));
      }
    }
  }

  String _getImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return '${AppConfig.apiBaseUrl}$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F0),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Input Card
            Container(
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _purpose,
                            decoration: InputDecoration(
                              labelText: 'Etkinlik',
                              hintText: 'örn: iş görüşmesi, düğün',
                              prefixIcon: Icon(Icons.event_note, color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today, size: 20),
                          label: Text(
                            '${_date.day}.${_date.month}.${_date.year}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _suggest,
                        icon: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(_loading ? 'AI Düşünüyor...' : 'Kombin Öner'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Results
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _recommendation == null
                    ? _buildEmptyState()
                    : _buildResults(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Gemini AI Kombin Önerisi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Etkinlik ve tarih seçip\n"Kombin Öner" butonuna bas',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final outfits = _recommendation!.outfits;
    
    return Column(
      children: [
        // Weather Card
        if (_weather != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _weather!.isRainy ? Colors.blue.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _weather!.isRainy ? Colors.blue.shade100 : Colors.orange.shade100,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _weather!.isRainy ? Icons.grain : 
                  _weather!.isSnowy ? Icons.ac_unit :
                  _weather!.isCold ? Icons.severe_cold :
                  Icons.wb_sunny,
                  color: _weather!.isRainy ? Colors.blue : Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_weather!.city} - ${_date.day}.${_date.month}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      Text(
                        '${_weather!.tempCelsius}°C, ${_weather!.description}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        
        // AI Explanation
        if (_recommendation!.explanation.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.blue.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.psychology, color: Colors.purple.shade400),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _recommendation!.explanation,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        
        // Outfits List
        Expanded(
          child: ListView.separated(
            itemCount: outfits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final outfit = outfits[index];
              final isSaving = _savingIndices.contains(index);
              
              return Container(
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Score Badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green.shade400, Colors.teal.shade400],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${(outfit.score * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Öneri ${index + 1}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Explanation
                      Text(
                        outfit.explanation,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Items
                      SizedBox(
                        height: 130,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: outfit.items.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            final item = outfit.items[i];
                            return Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: _getImageUrl(item.imageUrl).isEmpty
                                        ? Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey.shade200,
                                            child: Icon(Icons.checkroom, color: Colors.grey.shade400),
                                          )
                                        : Image.network(
                                            _getImageUrl(item.imageUrl),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 100,
                                              height: 100,
                                              color: Colors.grey.shade200,
                                              child: Icon(Icons.image, color: Colors.grey.shade400),
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.category,
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Favorite Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isSaving ? null : () => _saveToFavorites(outfit, index),
                          icon: isSaving 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.favorite_outline),
                          label: Text(isSaving ? 'Kaydediliyor...' : 'Favorilere Ekle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
