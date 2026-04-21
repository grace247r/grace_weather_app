import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const BASE_URL = "http://api.openweathermap.org/data/2.5/weather";
  final String apiKey = "0ae75f1ad921a77278b69aadf582f72a";

  Future<WeatherModel> getWeather(String cityName) async {
    final response = await http.get(
      Uri.parse("$BASE_URL?q=$cityName&appid=$apiKey&units=metric"),
    );

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal mengambil data cuaca');
    }
  }
}
