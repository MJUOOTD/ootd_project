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
  final bool isCurrent; // whether this is the current time forecast

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
    this.isCurrent = false,
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
      isCurrent: json['isCurrent'] ?? false,
    );
  }

  // factory WeatherModel.fromJson(Map<String, dynamic> json) {
  //   return WeatherModel(
  //     temperature: (json['temperature'] ?? 0.0).toDouble(),
  //     feelsLike: (json['feelsLike'] ?? 0.0).toDouble(),
  //     humidity: json['humidity'] ?? 0,
  //     windSpeed: (json['windSpeed'] ?? 0.0).toDouble(),
  //     windDirection: json['windDirection'] ?? 0,
  //     precipitation: (json['precipitation'] ?? 0.0).toDouble(),
  //     condition: json['condition'] ?? '',
  //     description: json['description'] ?? '',
  //     icon: json['icon'] ?? '',
  //     timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
  //     location: Location.fromJson(json['location'] ?? {}),
  //   );
  // }

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
      'isCurrent': isCurrent,
    };
  }

  // Calculate adjusted temperature based on user sensitivity
  double getAdjustedTemperature(TemperatureSensitivity sensitivity) {
    double adjustment = 0.0;
    
    switch (sensitivity) {
      case TemperatureSensitivity.veryCold:
        adjustment = -4.0; // Feel much colder
        break;
      case TemperatureSensitivity.cold:
        adjustment = -2.0; // Feel colder
        break;
      case TemperatureSensitivity.normal:
        adjustment = 0.0; // No adjustment
        break;
      case TemperatureSensitivity.hot:
        adjustment = 2.0; // Feel hotter
        break;
      case TemperatureSensitivity.veryHot:
        adjustment = 4.0; // Feel much hotter
        break;
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
  final String? district;     // 구/군
  final String? subLocality;  // 동/리
  final String? province;     // 시/도

  Location({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    this.district,
    this.subLocality,
    this.province,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      district: json['district'],
      subLocality: json['subLocality'],
      province: json['province'],
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
      'province': province,
    };
  }

  // Get formatted location string with accurate Korean address system
  String get formattedLocation {
    List<String> parts = [];
    
    // "globe"나 부정확한 값들을 필터링
    if (city.isNotEmpty && city != 'globe' && city != 'Unknown' && city != 'Current Location') {
      parts.add(city);
    }
    if (district != null && 
        district!.isNotEmpty && 
        district != 'globe' && 
        district != 'Unknown') {
      parts.add(district!);
    }
    if (subLocality != null && 
        subLocality!.isNotEmpty && 
        subLocality != 'globe' && 
        subLocality != 'Unknown') {
      parts.add(subLocality!);
    }
    
    // 위치 정보가 없거나 부정확한 경우 기본값 반환
    if (parts.isEmpty) {
      return '현재 위치';
    }
    
    return parts.join(' ');
  }
}

enum WeatherCategory {
  cold,    // < 5°C
  cool,    // 5-15°C
  mild,    // 15-25°C
  hot,     // > 25°C
  rainy,   // precipitation > 0.1mm
}

enum WeatherErrorType {
  networkError,
  apiError,
  invalidApiKey,
  locationError,
  parseError,
  cacheError,
  unknown,
}

class WeatherException implements Exception {
  final String message;
  final WeatherErrorType type;
  final int? statusCode;

  WeatherException(this.message, this.type, {this.statusCode});

  @override
  String toString() => 'WeatherException: $message (Type: $type)';
}
