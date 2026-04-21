import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/info_card.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService();
  WeatherModel? _weather;

  // Fungsi ambil data
  _fetchWeather() async {
    try {
      final weather = await _weatherService.getWeather("Jakarta");
      setState(() => _weather = weather);
    } catch (e) {
      print(e);
    }
  }

  // Logika memilih maskot Ody
  String getOdyAsset(String? condition) {
    if (condition == null) return 'assets/ody_app.png';
    switch (condition.toLowerCase()) {
      case 'clouds':
        return 'assets/cloudy_ody.png';
      case 'rain':
      case 'drizzle':
        return 'assets/rainy_ody.png';
      case 'clear':
        return 'assets/sunny_ody.png';
      case 'thunderstorm':
        return 'assets/rainy_ody.png';
      default:
        return 'assets/ody_app.png';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD1E9F6),
              Color(0xFFD1F2EB),
            ], // Soft Blue & Soft Green
          ),
        ),
        child: _weather == null
            ? Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Text(
                      _weather!.cityName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      "${_weather!.temperature.round()}°C",
                      style: TextStyle(
                        fontSize: 90,
                        fontWeight: FontWeight.w100,
                      ),
                    ),

                    Expanded(
                      child: TweenAnimationBuilder(
                        duration: Duration(seconds: 2),
                        tween: Tween<double>(begin: 0, end: 10),
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(0, value), // Animasi melayang halus
                            child: Image.asset(
                              getOdyAsset(_weather!.condition),
                              width: 280,
                            ),
                          );
                        },
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _weather!.condition,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InfoCard(
                            label: "Humidity",
                            value: "${_weather!.humidity}%",
                            icon: Icons.water_drop_outlined,
                          ),
                          InfoCard(
                            label: "Wind",
                            value: "${_weather!.windSpeed}km/h",
                            icon: Icons.air,
                          ),
                          InfoCard(
                            label: "Condition",
                            value: "Normal",
                            icon: Icons.wb_cloudy_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
