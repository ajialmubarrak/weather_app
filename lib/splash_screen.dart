import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), 
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

  
    Timer(const Duration(seconds: 5), () {
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

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  String selectedWeather = 'Cerah';

  final List<Map<String, dynamic>> weatherData = [
    {
      'condition': 'Cerah',
      'temperature': '30°C',
      'icon': Icons.wb_sunny,
      'color': const Color.fromARGB(255, 255, 226, 40),
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
      'color': Colors.grey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentWeather = weatherData.firstWhere(
      (item) => item['condition'] == selectedWeather,
    );

    return Scaffold(
      appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  centerTitle: true,
  title: const Text(
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

      extendBodyBehindAppBar: true,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: currentWeather['color'],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WeatherCard(
                condition: currentWeather['condition'],
                temperature: currentWeather['temperature'],
                icon: currentWeather['icon'],
              ),
              const SizedBox(height: 30),
              Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: weatherData.map((item) {
    final bool isSelected = selectedWeather == item['condition'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedWeather = item['condition'];
          });
        },
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [item['color'], Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.white.withOpacity(0.7), Colors.white.withOpacity(0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: item['color'].withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Icon(item['icon'], size: 20, color: isSelected ? Colors.black : Colors.black54),
              const SizedBox(width: 8),
              Text(
                item['condition'],
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 70, color: Colors.black54),
          const SizedBox(height: 10),
          Text(
            condition,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            temperature,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

