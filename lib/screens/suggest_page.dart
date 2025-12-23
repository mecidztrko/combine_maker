import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../models/image_library.dart';
import '../services/weather_service.dart';
import '../services/ai_service.dart';
import '../services/outfit_service.dart';


class SuggestPage extends StatefulWidget {
  final AppState appState;
  final ImageLibraryState imageLibraryState;
  final AiAdapter ai;
  const SuggestPage({super.key, required this.appState, required this.imageLibraryState, required this.ai});

  @override
  State<SuggestPage> createState() => _SuggestPageState();
}

class _SuggestPageState extends State<SuggestPage> {
  DateTime _date = DateTime.now();
  final TextEditingController _purpose = TextEditingController(text: 'iş görüşmesi');
  final _outfitService = OutfitService();
  final _weatherService = WeatherService();
  WeatherInfo? _weather;
  List<OutfitSuggestion> _results = const [];
  bool _loading = false;

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
      _results = const [];
    });
    
    // Check weather just to show user or verify?
    // The backend might already check weather if we pass date.
    // But keeping it here if we want to display it.
    try {
      final weather = await _weatherService.getWeatherFor(_date);
      
      final recommendation = await _outfitService.getRecommendation(
        date: _date,
        eventType: _purpose.text.trim().isEmpty ? 'genel' : _purpose.text.trim(),
        location: 'İstanbul', // Defaults for now
      );

      setState(() {
        _weather = weather;
        _results = [recommendation];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      setState(() => _loading = false);
    }
  }

  void _save(OutfitSuggestion outfit) {
    widget.appState.value = [...widget.appState.value, outfit];
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kombin kaydedildi')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F0),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
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
                              labelText: 'Amaç',
                              hintText: 'örn: iş görüşmesi',
                              prefixIcon: Icon(Icons.event_note, color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _pickDate,
                          icon: Icon(Icons.calendar_today, size: 20),
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
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(_loading ? 'Öneriliyor...' : 'Kombin Öner'),
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
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutQuad,
                switchOutCurve: Curves.easeInQuad,
                child: _results.isEmpty
                    ? Center(
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
                            'Kombin Önerisi Bekleniyor',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Yukarıdaki formu doldurup\n"Kombin Öner" butonuna bas',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : Column(
                        children: [
                          if (_weather != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _weather!.condition.toLowerCase().contains('yağ') ? Icons.grain : Icons.wb_sunny,
                                    color: _weather!.condition.toLowerCase().contains('yağ') ? Colors.blue : Colors.orange,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hava Durumu (${_date.day}.${_date.month})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        '${_weather!.temperatureC}°C, ${_weather!.condition}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: ListView.separated(
                        key: ValueKey(_results.length),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final outfit = _results[index];
                          return TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            tween: Tween(begin: 0.95, end: 1),
                            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                            child: Container(
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        outfit.purpose,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      outfit.rationale,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 130,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: outfit.items.length,
                                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                                        itemBuilder: (context, i) {
                                          final item = outfit.items[i];
                                          return Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: Colors.grey.shade200),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: Image.network(
                                                item.imageUrl,
                                                width: 130,
                                                height: 130,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  width: 130,
                                                  height: 130,
                                                  color: Colors.grey.shade200,
                                                  child: Icon(Icons.image, color: Colors.grey.shade400),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () => _save(outfit),
                                        icon: const Icon(Icons.bookmark_add_outlined),
                                        label: const Text('Kombini Kaydet', style: TextStyle(fontSize: 15)),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
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
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


