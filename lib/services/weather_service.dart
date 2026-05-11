import 'package:dio/dio.dart';
import '../models/weather.dart';

class WeatherService {
  final Dio _dio = Dio();
  static const String _openMeteoUrl = 'https://api.open-meteo.com/v1/forecast';

  // Sefrou coordinates
  static const double _sefrouLat = 33.8314;
  static const double _sefrouLng = -4.8264;

  Future<Weather?> getCurrentWeather() async {
    try {
      final response = await _dio.get(
        _openMeteoUrl,
        queryParameters: {
          'latitude': _sefrouLat,
          'longitude': _sefrouLng,
          'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,surface_pressure,visibility',
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
          'timezone': 'auto',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final current = data['current'];
        final daily = data['daily'];
        
        final weatherCode = current['weather_code'] as int;
        final condition = _getConditionFromCode(weatherCode);
        final icon = _getIconFromCode(weatherCode);

        // Process forecast
        final List<WeatherForecast> forecast = [];
        final List<dynamic> times = daily['time'];
        final List<dynamic> maxTemps = daily['temperature_2m_max'];
        final List<dynamic> minTemps = daily['temperature_2m_min'];
        final List<dynamic> codes = daily['weather_code'];

        for (int i = 0; i < times.length; i++) {
          final date = DateTime.parse(times[i]);
          final dayName = _getDayName(date.weekday);
          forecast.add(WeatherForecast(
            day: dayName,
            high: (maxTemps[i] as num).toDouble(),
            low: (minTemps[i] as num).toDouble(),
            condition: _getConditionFromCode(codes[i] as int),
            icon: _getIconFromCode(codes[i] as int),
          ));
        }

        return Weather(
          temperature: (current['temperature_2m'] as num).toDouble(),
          condition: condition,
          humidity: (current['relative_humidity_2m'] as num).toDouble(),
          windSpeed: (current['wind_speed_10m'] as num).toDouble(),
          feelsLike: (current['apparent_temperature'] as num).toDouble(),
          uvIndex: 0, // Not provided by default open-meteo free
          visibility: (current['visibility'] as num).toDouble() / 1000, // Convert to km
          pressure: (current['surface_pressure'] as num).toInt(),
          icon: icon,
          forecast: forecast,
        );
      }
      return _getMockWeather();
    } catch (e) {
      print('Weather Error: $e');
      return _getMockWeather();
    }
  }

  String _getConditionFromCode(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Mainly clear';
    if (code <= 48) return 'Foggy';
    if (code <= 57) return 'Drizzle';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Partly Cloudy';
  }

  String _getIconFromCode(int code) {
    if (code == 0) return '01d';
    if (code <= 3) return '02d';
    if (code <= 48) return '50d';
    if (code <= 57) return '09d';
    if (code <= 67) return '10d';
    if (code <= 77) return '13d';
    if (code <= 82) return '09d';
    if (code <= 99) return '11d';
    return '02d';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  Weather _getMockWeather() {
    return Weather(
      temperature: 22.0,
      condition: 'Partly Cloudy',
      humidity: 65.0,
      windSpeed: 12.0,
      feelsLike: 20.0,
      uvIndex: 6,
      visibility: 10.0,
      pressure: 1013,
      icon: '02d',
      forecast: [
        WeatherForecast(day: 'Mon', high: 24.0, low: 18.0, condition: 'Sunny', icon: '01d'),
        WeatherForecast(day: 'Tue', high: 22.0, low: 17.0, condition: 'Cloudy', icon: '02d'),
        WeatherForecast(day: 'Wed', high: 20.0, low: 15.0, condition: 'Rainy', icon: '09d'),
        WeatherForecast(day: 'Thu', high: 23.0, low: 16.0, condition: 'Sunny', icon: '01d'),
        WeatherForecast(day: 'Fri', high: 25.0, low: 19.0, condition: 'Sunny', icon: '01d'),
      ],
    );
  }
}
