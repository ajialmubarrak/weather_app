
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


void main() {
  runApp(
    const ProviderScope(child: WeatherApp()),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}


final weatherProvider = StateProvider<String>((ref) => "Cerah");


final locationProvider =
    StateProvider<String>((ref) => "Mendeteksi lokasi...");


final lightningProvider = StateProvider<bool>((ref) => false);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WeatherHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.cloud, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "WeatherApp",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class WeatherHomePage extends ConsumerStatefulWidget {
  const WeatherHomePage({super.key});

  @override
  ConsumerState<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends ConsumerState<WeatherHomePage>
    with TickerProviderStateMixin {
  late AnimationController _titlePulseController;
  late AnimationController _rainController;
  late AnimationController _cloudController;
  late Timer _lightningTimer;

  final Random _random = Random();

  final List<Map<String, dynamic>> weatherData = [
    {
      'condition': 'Cerah',
      'temperature': '30°C',
      'icon': Icons.wb_sunny,
      'color': const Color.fromARGB(255, 129, 236, 255),
    },
    {
      'condition': 'Hujan',
      'temperature': '25°C',
      'icon': Icons.cloud,
      'color': Colors.blueGrey,
    },
    {
      'condition': 'Mendung',
      'temperature': '28°C',
      'icon': Icons.wb_cloudy,
      'color': const Color.fromARGB(255, 65, 64, 64),
    },
  ];

  final List<Map<String, dynamic>> forecastData = [
    {
      'day': 'Besok',
      'condition': 'Cerah',
      'temperature': '31°C',
      'icon': Icons.wb_sunny,
      'color': Colors.orangeAccent,
    },
    {
      'day': 'Lusa',
      'condition': 'Mendung',
      'temperature': '27°C',
      'icon': Icons.wb_cloudy,
      'color': const Color.fromARGB(255, 63, 63, 63),
    },
    {
      'day': '3 Hari Lagi',
      'condition': 'Hujan',
      'temperature': '25°C',
      'icon': Icons.cloud,
      'color': Colors.blueGrey,
    },
  ];

  @override
  void initState() {
    super.initState();

    _titlePulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);

    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _getLocation();
    _startLightning();
  }

  Future<void> _getLocation() async {
    final loc = ref.read(locationProvider.notifier);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      loc.state = "GPS tidak aktif";
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        loc.state = "Izin lokasi ditolak";
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      loc.state = "Izin lokasi diblokir permanen";
      return;
    }

    Position pos = await Geolocator.getCurrentPosition();
    List<Placemark> place =
        await placemarkFromCoordinates(pos.latitude, pos.longitude);

    loc.state = place[0].locality ?? "Tidak diketahui";
  }

  void _startLightning() {
    _lightningTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final selected = ref.read(weatherProvider);

      if (selected == "Hujan" && _random.nextBool()) {
        ref.read(lightningProvider.notifier).state = true;

        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            ref.read(lightningProvider.notifier).state = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _titlePulseController.dispose();
    _rainController.dispose();
    _cloudController.dispose();
    _lightningTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedWeather = ref.watch(weatherProvider);
    final currentCity = ref.watch(locationProvider);
    final showLightning = ref.watch(lightningProvider);

    final currentWeather =
        weatherData.firstWhere((item) => item['condition'] == selectedWeather);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ScaleTransition(
          scale: _titlePulseController,
          child: const Text(
            '☀️ Cuaca Hari Ini',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.3,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black54,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
      ),

      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: currentWeather['color'],
        child: Stack(
          children: [
        
            if (selectedWeather == 'Hujan')
              CustomPaint(
                size: Size.infinite,
                painter: RainPainter(_rainController.value),
              ),

            if (selectedWeather == 'Mendung')
              AnimatedBuilder(
                animation: _cloudController,
                builder: (context, _) {
                  return Positioned(
                    top: 100,
                    left: MediaQuery.of(context).size.width *
                        _cloudController.value,
                    child: const Icon(Icons.cloud,
                        size: 200, color: Colors.white70),
                  );
                },
              ),

            if (selectedWeather == 'Hujan')
              AnimatedOpacity(
                opacity: showLightning ? 0.8 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Container(color: Colors.white.withOpacity(0.8)),
              ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "📍 $currentCity",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  
                  WeatherCard(
                    condition: currentWeather['condition'],
                    temperature: currentWeather['temperature'],
                    icon: currentWeather['icon'],
                  ),

                  const SizedBox(height: 30),

                  
                  SizedBox(
                    height: 130,
                    child: Center(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: forecastData.length,
                        itemBuilder: (context, index) {
                          final item = forecastData[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(item['day'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Icon(item['icon'],
                                      color: item['color'], size: 40),
                                  Text(
                                    "${item['condition']} • ${item['temperature']}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: weatherData.map((item) {
                      final isSelected =
                          selectedWeather == item['condition'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: InkWell(
                          onTap: () {
                            ref.read(weatherProvider.notifier).state =
                                item['condition'];
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [item['color'], Colors.white],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.7),
                                        Colors.white.withOpacity(0.3)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Icon(item['icon'],
                                    size: 20,
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.black54),
                                const SizedBox(width: 8),
                                Text(
                                  item['condition'],
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final String condition;
  final String temperature;
  final IconData icon;

  const WeatherCard({
    super.key,
    required this.condition,
    required this.temperature,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 70, color: Colors.black54),
          const SizedBox(height: 10),
          Text(condition,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(temperature, style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

class RainPainter extends CustomPainter {
  final double progress;
  RainPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()..color = Colors.white.withOpacity(0.7)..strokeWidth = 2;
    final random = Random();

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final length = random.nextDouble() * 15 + 10;
      final yStart =
          (random.nextDouble() * size.height + (progress * 200)) % size.height;

      canvas.drawLine(Offset(x, yStart), Offset(x, yStart + length), paint);
    }
  }

  @override
  bool shouldRepaint(covariant RainPainter oldDelegate) => true;
}
