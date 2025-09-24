import 'user_model.dart';

class WeatherModel {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final double precipitation;
  final String condition;
  final String description;
  final String icon;
  final DateTime timestamp;
  final Location location;

  WeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.precipitation,
    required this.condition,
    required this.description,
    required this.icon,
    required this.timestamp,
    required this.location,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      feelsLike: (json['feelsLike'] ?? 0.0).toDouble(),
      humidity: json['humidity'] ?? 0,
      windSpeed: (json['windSpeed'] ?? 0.0).toDouble(),
      windDirection: json['windDirection'] ?? 0,
      precipitation: (json['precipitation'] ?? 0.0).toDouble(),
      condition: json['condition'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      location: Location.fromJson(json['location'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'precipitation': precipitation,
      'condition': condition,
      'description': description,
      'icon': icon,
      'timestamp': timestamp.toIso8601String(),
      'location': location.toJson(),
    };
  }

  // Calculate adjusted temperature based on user sensitivity
  double getAdjustedTemperature(TemperatureSensitivity sensitivity) {
    double adjustment = 0.0;
    
    // Cold sensitivity adjustment
    if (sensitivity.coldSensitivity < 0) {
      adjustment += sensitivity.coldSensitivity * 2; // Feel colder
    }
    
    // Heat sensitivity adjustment  
    if (sensitivity.heatSensitivity < 0) {
      adjustment += sensitivity.heatSensitivity * 2; // Feel hotter
    }
    
    return temperature + adjustment;
  }

  // Get weather category for outfit recommendations
  WeatherCategory getWeatherCategory() {
    if (precipitation > 0.1) {
      return WeatherCategory.rainy;
    } else if (temperature < 5) {
      return WeatherCategory.cold;
    } else if (temperature < 15) {
      return WeatherCategory.cool;
    } else if (temperature < 25) {
      return WeatherCategory.mild;
    } else {
      return WeatherCategory.hot;
    }
  }
}

class Location {
  final double latitude;
  final double longitude;
  final String city;
  final String country;

  Location({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      city: json['city'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
    };
  }
}

enum WeatherCategory {
  cold,    // < 5°C
  cool,    // 5-15°C
  mild,    // 15-25°C
  hot,     // > 25°C
  rainy,   // precipitation > 0.1mm
}
