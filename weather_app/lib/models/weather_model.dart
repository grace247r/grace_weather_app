class WeatherModel {
  final String cityName;
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double feelsLike;
  final int visibility;
  final int pressure;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    required this.visibility,
    required this.pressure,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      visibility: (json['visibility'] / 1000).round(),
      pressure: json['main']['pressure'],
    );
  }
}
