import 'package:flutter/material.dart';
import 'detail_screen.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _progress = 0.0;
  int _messageIndex = 0;
  List<WeatherModel>? _weatherData;
  String? _errorMessage;

  final List<String> _messages = [
    'Nous téléchargeons  les données…',
    'C’est presque fini…',
    'Plus que quelques secondes avant d’avoir le résultat…',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..addListener(() {
      setState(() => _progress = _controller.value);
    });

    _controller.forward();
    _startMessageRotation();
    _loadWeatherData();
  }

  void _startMessageRotation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _controller.value < 1.0) {
        setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
        _startMessageRotation();
      }
    });
  }

  Future<void> _loadWeatherData() async {
    try {
      final data = await WeatherService.fetchAllCities();

      if (mounted) {
        setState(() => _weatherData = data);

        // Attendre la fin de l'animation
        await Future.delayed(const Duration(seconds: 15 - 5));

        if (mounted && _weatherData != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                weatherData: _weatherData!,
                onReset: _reset,
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erreur de chargement: $e');
    }
  }

  void _reset() {
    setState(() {
      _progress = 0.0;
      _messageIndex = 0;
      _weatherData = null;
      _errorMessage = null;
    });
    _controller.reset();
    _controller.forward();
    _loadWeatherData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chargement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity, // Prend toute la largeur
        height: double.infinity, // Prend toute la hauteur
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage != null) ...[
              Icon(Icons.error, size: 50, color: Colors.red[400]),
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _reset,
                child: const Text('Réessayer'),
              ),
            ] else ...[
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _messages[_messageIndex],
                  key: ValueKey(_messageIndex),
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}