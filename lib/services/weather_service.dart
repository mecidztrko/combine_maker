import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

/// Backend'den gelen hava durumu bilgisi
/// Backend WeatherResponseDto formatına uygun
class WeatherInfo {
  final String city;
  final int tempCelsius;
  final String condition;
  final String description;
  final bool isRainy;
  final bool isSnowy;
  final bool isCold;
  final bool isHot;
  final bool? isWindy;
  final bool? isHumid;
  final bool? isHighUv;
  final int? humidity;
  final double? windSpeed;
  final int? uvIndex;
  final String source;
  final String? date;

  const WeatherInfo({
    required this.city,
    required this.tempCelsius,
    required this.condition,
    required this.description,
    required this.isRainy,
    required this.isSnowy,
    required this.isCold,
    required this.isHot,
    this.isWindy,
    this.isHumid,
    this.isHighUv,
    this.humidity,
    this.windSpeed,
    this.uvIndex,
    required this.source,
    this.date,
  });

  /// Geriye uyumluluk için eski alan adı
  int get temperatureC => tempCelsius;

  factory WeatherInfo.fromBackendJson(Map<String, dynamic> json) {
    return WeatherInfo(
      city: json['city'] as String? ?? 'Unknown',
      tempCelsius: (json['temp_celsius'] as num?)?.toInt() ?? 20,
      condition: json['condition'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? 'Bilinmiyor',
      isRainy: json['is_rainy'] as bool? ?? false,
      isSnowy: json['is_snowy'] as bool? ?? false,
      isCold: json['is_cold'] as bool? ?? false,
      isHot: json['is_hot'] as bool? ?? false,
      isWindy: json['is_windy'] as bool?,
      isHumid: json['is_humid'] as bool?,
      isHighUv: json['is_high_uv'] as bool?,
      humidity: (json['humidity'] as num?)?.toInt(),
      windSpeed: (json['wind_speed'] as num?)?.toDouble(),
      uvIndex: (json['uv_index'] as num?)?.toInt(),
      source: json['source'] as String? ?? 'unknown',
      date: json['date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'temp_celsius': tempCelsius,
      'condition': condition,
      'description': description,
      'is_rainy': isRainy,
      'is_snowy': isSnowy,
      'is_cold': isCold,
      'is_hot': isHot,
      if (isWindy != null) 'is_windy': isWindy,
      if (isHumid != null) 'is_humid': isHumid,
      if (isHighUv != null) 'is_high_uv': isHighUv,
      if (humidity != null) 'humidity': humidity,
      if (windSpeed != null) 'wind_speed': windSpeed,
      if (uvIndex != null) 'uv_index': uvIndex,
      'source': source,
      if (date != null) 'date': date,
    };
  }

  /// Varsayılan fallback değeri
  static const WeatherInfo fallback = WeatherInfo(
    city: 'Bilinmiyor',
    tempCelsius: 20,
    condition: 'Unknown',
    description: 'Bilinmiyor',
    isRainy: false,
    isSnowy: false,
    isCold: false,
    isHot: false,
    source: 'fallback',
  );
}

class WeatherService {
  Future<WeatherInfo> getWeatherFor(DateTime date, {String city = 'Istanbul'}) async {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    if (isToday) {
      return await _getCurrentWeather(city);
    } else {
      return await _getForecast(city, date);
    }
  }

  Future<WeatherInfo> _getCurrentWeather(String city) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/weather/current?city=$city');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherInfo.fromBackendJson(data);
      }
    } catch (e) {
      print('Weather API hatası: $e');
    }
    return WeatherInfo.fallback;
  }

  Future<WeatherInfo> _getForecast(String city, DateTime date) async {
    try {
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/weather/forecast?city=$city&date=$dateStr');
      
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherInfo.fromBackendJson(data);
      }
    } catch (e) {
      print('Weather forecast API hatası: $e');
    }
    return WeatherInfo.fallback;
  }
}
