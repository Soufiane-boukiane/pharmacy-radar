class Weather {
  final double temperature;
  final String condition;
  final double humidity;
  final double windSpeed;
  final double feelsLike;
  final int uvIndex;
  final double visibility;
  final int pressure;
  final String icon;
  final List<WeatherForecast> forecast;

  Weather({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    required this.uvIndex,
    required this.visibility,
    required this.pressure,
    required this.icon,
    required this.forecast,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      condition: json['weather'][0]['main'] ?? '',
      humidity: (json['main']['humidity'] ?? 0).toDouble(),
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      uvIndex: json['uvi'] ?? 0,
      visibility: (json['visibility'] ?? 0).toDouble() / 1000,
      pressure: json['main']['pressure'] ?? 0,
      icon: json['weather'][0]['icon'] ?? '',
      forecast: (json['daily'] as List?)
              ?.map((f) => WeatherForecast.fromJson(f))
              .toList() ??
          [],
    );
  }
}

class WeatherForecast {
  final String day;
  final double high;
  final double low;
  final String condition;
  final String icon;

  WeatherForecast({
    required this.day,
    required this.high,
    required this.low,
    required this.condition,
    required this.icon,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      day: json['day'] ?? '',
      high: (json['temp']['max'] ?? 0).toDouble(),
      low: (json['temp']['min'] ?? 0).toDouble(),
      condition: json['weather'][0]['main'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
    );
  }
}
