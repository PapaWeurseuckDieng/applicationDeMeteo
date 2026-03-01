import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String apiKey = 'b506afccb413321376f6a46a982b660f'; // Remplace par ta clé OpenWeather
  static const List<String> cities = ['Dakar', 'Paris', 'New York', 'Tokyo', 'Thies'];

  static Future<WeatherModel> fetchCityWeather(String city) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return WeatherModel.fromApiJson(json.decode(response.body), city);
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Problème de connexion: $e');
    }
  }

  static Future<List<WeatherModel>> fetchAllCities() async {
    List<WeatherModel> results = [];

    for (String city in cities) {
      try {
        final weather = await fetchCityWeather(city);
        results.add(weather);
        await Future.delayed(const Duration(seconds: 1)); // Pause pour pas surcharger l'API
      } catch (e) {
        print('Erreur pour $city: $e');
        // On continue avec les autres villes même si une échoue
      }
    }

    return results;
  }
}