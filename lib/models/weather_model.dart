class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;
  final double latitude;
  final double longitude;
  final String iconCode;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.latitude,
    required this.longitude,
    required this.iconCode,
  });

  // Factory constructor pour créer une instance à partir du JSON de l'API
  factory WeatherModel.fromApiJson(Map<String, dynamic> json, String city) {
    return WeatherModel(
      cityName: city,
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      latitude: json['coord']['lat'].toDouble(),
      longitude: json['coord']['lon'].toDouble(),
      iconCode: json['weather'][0]['icon'],
    );
  }

  // Méthode utilitaire pour obtenir l'URL de l'icône météo
  String getIconUrl() {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  // Pour faciliter l'affichage
  @override
  String toString() {
    return '$cityName: ${temperature}°C - $description';
  }
}