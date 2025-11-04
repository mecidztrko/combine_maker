class WeatherInfo {
  final int temperatureC;
  final String condition;
  const WeatherInfo({required this.temperatureC, required this.condition});
}

class WeatherService {
  Future<WeatherInfo> getWeatherFor(DateTime date, {String city = 'İstanbul'}) async {
    // MVP: mock weather by month and day
    final month = date.month;
    if (month <= 2 || month == 12) {
      return const WeatherInfo(temperatureC: 7, condition: 'Soğuk ve bulutlu');
    }
    if (month <= 4) {
      return const WeatherInfo(temperatureC: 15, condition: 'Ilık ve parçalı bulutlu');
    }
    if (month <= 9) {
      return const WeatherInfo(temperatureC: 27, condition: 'Sıcak ve güneşli');
    }
    return const WeatherInfo(temperatureC: 18, condition: 'Serin ve rüzgarlı');
  }
}


