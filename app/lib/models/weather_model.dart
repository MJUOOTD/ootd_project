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
  final String? source; // e.g., 'kma'
  final bool? cached;   // whether response came from cache

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
    this.source,
    this.cached,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }
    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? (double.tryParse(v)?.round() ?? 0);
      return 0;
    }
    String asString(dynamic v) => v == null ? '' : v.toString();

    final ts = json['timestamp'];
    final DateTime parsedTs = ts is String && ts.isNotEmpty
        ? (DateTime.tryParse(ts) ?? DateTime.now())
        : DateTime.now();

    return WeatherModel(
      temperature: asDouble(json['temperature']),
      feelsLike: asDouble(json['feelsLike']),
      humidity: asInt(json['humidity']),
      windSpeed: asDouble(json['windSpeed']),
      windDirection: asInt(json['windDirection']),
      precipitation: asDouble(json['precipitation']),
      condition: asString(json['condition']),
      description: asString(json['description']),
      icon: asString(json['icon']),
      timestamp: parsedTs,
      location: Location.fromJson(json['location'] ?? {}),
      source: json['source'],
      cached: json['cached'],
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
      'source': source,
      'cached': cached,
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
  final String? district;     // 구
  final String? subLocality;  // 동

  Location({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    this.district,
    this.subLocality,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      district: json['district'],
      subLocality: json['subLocality'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
      'district': district,
      'subLocality': subLocality,
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
