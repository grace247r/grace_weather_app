import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/info_card.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with SingleTickerProviderStateMixin {
  final _weatherService = WeatherService();
  WeatherModel? _weather;
  AnimationController? _floatingController;
  int _selectedTimeIndex = 2; // Default: 7:00 (index 2)

  // Hourly forecast data
  late List<Map<String, dynamic>> _hourlyForecast;
  late double _displayTemperature;
  late String _displayCondition;

  // 3-day forecast
  late List<Map<String, dynamic>> _threeDayForecast;

  // Alerts/tips from Ody
  late List<String> _odyAlerts;

  // Fungsi ambil data
  _fetchWeather() async {
    try {
      final weather = await _weatherService.getWeather("Jakarta");
      if (!mounted) return;
      setState(() {
        _weather = weather;
        // Initialize 24-hour forecast data
        _hourlyForecast = List.generate(24, (index) {
          final tempVariation = (index % 5 - 2) * 2;
          return {
            'time': '${index.toString().padLeft(2, '0')}:00',
            'temp': (weather.temperature + tempVariation).round(),
            'condition': index > 8 && index < 16 ? weather.condition : 'clouds',
          };
        });

        _displayTemperature = _hourlyForecast[12]['temp'].toDouble();
        _displayCondition = _hourlyForecast[12]['condition'];

        // 3-day forecast
        _threeDayForecast = [
          {
            'day': 'TODAY',
            'temp': weather.temperature.round(),
            'condition': weather.condition,
          },
          {
            'day': 'MON',
            'temp': (weather.temperature - 1).round(),
            'condition': 'clouds',
          },
          {
            'day': 'TUE',
            'temp': (weather.temperature - 2).round(),
            'condition': 'rain',
          },
        ];

        // Ody alerts based on weather
        _odyAlerts = _getOdyAlerts(weather.condition);
      });
    } catch (e) {
      print(e);
    }
  }

  // Fungsi untuk mendapatkan alert dari Ody
  List<String> _getOdyAlerts(String condition) {
    final alerts = <String>[];
    final lowerCondition = condition.toLowerCase();

    if (lowerCondition.contains('rain') || lowerCondition.contains('drizzle')) {
      alerts.add('Bawa payung yaa! 🌧️');
      alerts.add('Jalan hati-hati klo basah');
    } else if (lowerCondition.contains('clear') ||
        lowerCondition.contains('sunny')) {
      alerts.add('Pake sunscreen! ☀️');
      alerts.add('Jangan lupa minum air');
    } else if (lowerCondition.contains('cloud')) {
      alerts.add('Cuaca sedang mendung nih');
      alerts.add('Tetap semangat! 💪');
    }

    return alerts.isEmpty ? ['Cuaca hari ini cukup baik!'] : alerts;
  }

  // Logika memilih maskot Ody
  String getOdyAsset(String? condition) {
    if (condition == null) return 'assets/ody.png';
    switch (condition.toLowerCase()) {
      case 'clouds':
        return 'assets/cloudy ody.png';
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return 'assets/rainy ody.png';
      case 'clear':
        return 'assets/sunny ody.png';
      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
      case 'dust':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
        return 'assets/windy ody.png';
      default:
        return 'assets/ody.png';
    }
  }

  AnimationController _ensureFloatingController() {
    final controller = _floatingController;
    if (controller != null) {
      return controller;
    }

    final createdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatingController = createdController;
    return createdController;
  }

  Widget buildOdyImage(String assetName) {
    return Image.asset(
      assetName,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(
            Icons.cloud_queue_rounded,
            size: 96,
            color: Color(0xFF264653),
          ),
        );
      },
    );
  }

  Widget _buildTimeCard(String time, int index) {
    final isActive = _selectedTimeIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeIndex = index;
          _displayTemperature = _hourlyForecast[index]['temp'].toDouble();
          _displayCondition = _hourlyForecast[index]['condition'];
          // Update alerts based on new condition
          _odyAlerts = _getOdyAlerts(_displayCondition);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 400 ? 14 : 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blue.shade400
              : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.blue.shade400.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : Colors.grey.shade700,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isActive ? "Now" : "Later",
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Colors.white.withOpacity(0.85)
                    : Colors.grey.shade500,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _ensureFloatingController();
    _fetchWeather();
  }

  @override
  void dispose() {
    _floatingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB8E6F0), Color(0xFFD4F1E8)],
          ),
        ),
        child: Stack(
          children: [
            _weather == null
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: Column(
                      children: [
                        // Header dengan Ody mascot besar di kanan
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hey,",
                                    style: TextStyle(
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  const Text(
                                    "This is Ody",
                                    style: TextStyle(
                                      fontSize: 22,
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1a1a2e),
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ],
                              ),
                              // Ody mascot besar tanpa background
                              Image.asset(
                                'assets/ody.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.emoji_nature_outlined,
                                    size: 100,
                                    color: Colors.blue.shade400,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // Location & Temperature & 3-Day Forecast
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _weather!.cityName.toUpperCase(),
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width > 400
                                      ? 32
                                      : 24,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1a1a2e),
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Temperature (BESAR)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  "${_displayTemperature.round()}°",
                                  key: ValueKey(_displayTemperature),
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width > 400
                                        ? 96
                                        : 72,
                                    height: 0.85,
                                    fontWeight: FontWeight.w100,
                                    color: const Color(0xFF1a1a2e),
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // 3-Day forecast (responsive grid)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _threeDayForecast.map((day) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              day['day'] ?? 'DAY',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.8,
                                                color: Colors.grey.shade600,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${day['temp'] ?? 0}° • ${(day['condition'] ?? 'clouds').toUpperCase()}",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Ody image with floating alert bubble
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedBuilder(
                                      animation: _ensureFloatingController(),
                                      builder: (context, child) {
                                        final offset =
                                            (0.5 -
                                                _ensureFloatingController()
                                                    .value) *
                                            14;
                                        final scale =
                                            1.0 +
                                            (_ensureFloatingController().value *
                                                0.04);
                                        return Transform.translate(
                                          offset: Offset(0, offset),
                                          child: Transform.scale(
                                            scale: scale,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.of(
                                                    context,
                                                  ).size.width >
                                                  400
                                              ? 300
                                              : 240,
                                          maxHeight:
                                              MediaQuery.of(
                                                    context,
                                                  ).size.width >
                                                  400
                                              ? 300
                                              : 240,
                                        ),
                                        child: buildOdyImage(
                                          getOdyAsset(_displayCondition),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Weather condition (dibawah Ody)
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Text(
                                        _displayCondition.toUpperCase(),
                                        key: ValueKey(_displayCondition),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2,
                                          color: Colors.grey.shade700,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Floating bubble di sebelah Ody
                                Positioned(
                                  right: MediaQuery.of(context).size.width > 400
                                      ? 20
                                      : 10,
                                  top:
                                      MediaQuery.of(context).size.height * 0.15,
                                  child: SingleChildScrollView(
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.35,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: _odyAlerts.map((alert) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 6,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Colors.blue.shade300,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Text(
                                                alert,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue.shade800,
                                                  fontFamily: 'Roboto',
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 24-hour time slider
                        SizedBox(
                          height: MediaQuery.of(context).size.width > 400
                              ? 70
                              : 60,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width > 400
                                  ? 20
                                  : 12,
                            ),
                            child: Row(
                              children: List.generate(24, (index) {
                                return _buildTimeCard(
                                  _hourlyForecast[index]['time'],
                                  index,
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width > 400
                                ? 20
                                : 12,
                            vertical: 12,
                          ),
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
                                value: "${_weather!.windSpeed} km/h",
                                icon: Icons.air,
                              ),
                              InfoCard(
                                label: "Sky",
                                value: _weather!.condition,
                                icon: Icons.wb_cloudy_outlined,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
