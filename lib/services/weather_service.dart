import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class WeatherInfo {
  final int temperatureC;
  final String condition;
  const WeatherInfo({required this.temperatureC, required this.condition});
}

class WeatherService {
  Future<WeatherInfo> getWeatherFor(DateTime date, {String city = 'İstanbul'}) async {
    // Note: The backend endpoints are /weather/current and /weather/forecast.
    // This method signature is a bit different from endpoints but we can adapt.
    // If the date is close to now, use current, otherwise forecast.
    // For simplicity, let's just use current for now or try to match.
    
    // Check if we want current or forecast
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    if (isToday) {
      return await _getCurrentWeather(city);
    } else {
      return await _getForecast(city, date);
    }
  }

  Future<WeatherInfo> _getCurrentWeather(String city) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/weather/current?city=$city');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Adjust parsing based on actual backend response structure
      // Assuming: { "temperature": 20, "description": "Sunny" } etc.
      return WeatherInfo(
        temperatureC: (data['temperature'] as num).toInt(),
        condition: data['description'] ?? data['condition'] ?? 'Unknown',
      );
    }
    // Fallback or throw
     return const WeatherInfo(temperatureC: 20, condition: 'Bilinmiyor');
  }

  Future<WeatherInfo> _getForecast(String city, DateTime date) async {
    // Formatting date as YYYY-MM-DD for API
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/weather/forecast?city=$city&date=$dateStr');
    
    final response = await http.get(uri);
     if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeatherInfo(
        temperatureC: (data['temperature'] as num).toInt(),
        condition: data['description'] ?? data['condition'] ?? 'Unknown',
      );
    }
    return const WeatherInfo(temperatureC: 20, condition: 'Tahmin Yok');
  }
}


