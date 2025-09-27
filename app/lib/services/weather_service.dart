import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import 'location/location_service.dart';

/// Legacy WeatherService implementation
/// 
/// This class maintains backward compatibility while the new interface-based
/// architecture is being implemented. It will be deprecated in favor of
/// the new WeatherService interface.
/// 
/// TODO: Migrate to new WeatherService interface
/// - Replace direct usage with dependency injection
/// - Remove this legacy implementation
/// - Update all consumers to use the new interface
@Deprecated('Use the new WeatherService interface instead')
class WeatherService {
  static const String _apiKey = '8c0dfc3837648d4d8eb0282057f1d3a2'; // Replace with actual API key
  
  // Get current weather for user's location
  static Future<WeatherModel> getCurrentWeather() async {
    Location? location;
    try {
      // Use the new location service
      final locationService = RealLocationService();
      location = await locationService.getCurrentLocation();
      
      // Make API call to backend server
      // Use localhost for web, 10.0.2.2 for Android emulator
      final baseUrl = kIsWeb ? 'http://localhost:4000' : 'http://10.0.2.2:4000';
      final url = Uri.parse(
        '$baseUrl/api/weather/current?lat=${location.latitude}&lon=${location.longitude}'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseWeatherDataFromBackend(data, location);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Weather API error: $e');
      print('Error type: ${e.runtimeType}');
      if (e is http.ClientException) {
        print('HTTP Client Exception: ${e.message}');
      }
      // Return mock data for development with actual location
      return _getMockWeatherData(location);
    }
  }

  // Get weather for specific location
  static Future<WeatherModel> getWeatherForLocation(double lat, double lon) async {
    try {
      // Make API call to backend server
      // Use localhost for web, 10.0.2.2 for Android emulator
      final baseUrl = kIsWeb ? 'http://localhost:4000' : 'http://10.0.2.2:4000';
      final url = Uri.parse(
        '$baseUrl/api/weather/current?lat=$lat&lon=$lon'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = Location(
          latitude: lat,
          longitude: lon,
          city: data['location']?['city'] ?? 'Unknown',
          country: data['location']?['country'] ?? 'Unknown',
        );
        return _parseWeatherDataFromBackend(data, location);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      // Create location from lat/lon for mock data
      final location = Location(
        latitude: lat,
        longitude: lon,
        city: 'Current Location',
        country: 'Unknown',
      );
      return _getMockWeatherData(location);
    }
  }

  // Get 5-day forecast
  static Future<List<WeatherModel>> getForecast() async {
    Location? location;
    try {
      // TODO: Replace with new WeatherService interface
      // final weatherService = GetIt.instance<weather_interface.WeatherService>();
      // return await weatherService.getForecast();
      
      // Use the new location service
      final locationService = RealLocationService();
      location = await locationService.getCurrentLocation();
      
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${location.latitude}&lon=${location.longitude}&appid=$_apiKey&units=metric&lang=kr'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseForecastDataFromLocation(data, location);
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      print('Forecast API error: $e');
      return [_getMockWeatherData(location)];
    }
  }



  static WeatherModel _parseWeatherDataFromBackend(Map<String, dynamic> data, Location location) {
    return WeatherModel(
      temperature: data['temperature']?.toDouble() ?? 0.0,
      feelsLike: data['feelsLike']?.toDouble() ?? 0.0,
      humidity: data['humidity']?.toInt() ?? 0,
      windSpeed: data['windSpeed']?.toDouble() ?? 0.0,
      windDirection: data['windDirection']?.toInt() ?? 0,
      precipitation: data['precipitation']?.toDouble() ?? 0.0,
      condition: data['condition'] ?? 'Unknown',
      description: data['description'] ?? 'Unknown',
      icon: data['icon'] ?? '',
      timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
      location: Location(
        latitude: location.latitude,
        longitude: location.longitude,
        city: data['location']?['city'] ?? location.city,
        country: data['location']?['country'] ?? location.country,
        district: data['location']?['district'],
      ),
    );
  }


  static List<WeatherModel> _parseForecastDataFromLocation(Map<String, dynamic> data, Location location) {
    List<WeatherModel> forecast = [];
    
    for (var item in data['list']) {
      forecast.add(WeatherModel(
        temperature: item['main']['temp'].toDouble(),
        feelsLike: item['main']['feels_like'].toDouble(),
        humidity: item['main']['humidity'],
        windSpeed: item['wind']['speed'].toDouble(),
        windDirection: item['wind']['deg'] ?? 0,
        precipitation: item['rain']?['3h']?.toDouble() ?? 0.0,
        condition: item['weather'][0]['main'],
        description: item['weather'][0]['description'],
        icon: item['weather'][0]['icon'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
        location: Location(
          latitude: location.latitude,
          longitude: location.longitude,
          city: data['city']['name'] ?? location.city,
          country: data['city']['country'] ?? location.country,
        ),
      ));
    }
    
    return forecast;
  }

  // Mock data for development - use actual GPS coordinates
  static WeatherModel _getMockWeatherData([Location? actualLocation]) {
    // Use actual location if provided, otherwise use Seoul as fallback
    Location location;
    if (actualLocation != null) {
      // Try to get city name from coordinates
      final cityName = _getCityNameFromCoordinates(actualLocation.latitude, actualLocation.longitude);
      location = Location(
        latitude: actualLocation.latitude,
        longitude: actualLocation.longitude,
        city: cityName,
        country: 'KR',
        district: _getDistrictFromCoordinates(actualLocation.latitude, actualLocation.longitude),
      );
    } else {
      location = Location(
        latitude: 37.5665,
        longitude: 126.9780,
        city: 'Seoul',
        country: 'KR',
      );
    }
    
    return WeatherModel(
      temperature: 22.0,
      feelsLike: 24.0,
      humidity: 65,
      windSpeed: 3.2,
      windDirection: 180,
      precipitation: 0.0,
      condition: 'Clear',
      description: 'clear sky',
      icon: '01d',
      timestamp: DateTime.now(),
      location: location,
    );
  }

  // Simple reverse geocoding for Korean cities
  static String _getCityNameFromCoordinates(double lat, double lon) {
    // Major Korean cities with approximate coordinates
    final cities = [
      {'name': 'Seoul', 'lat': 37.5665, 'lon': 126.9780, 'tolerance': 0.5},
      {'name': 'Busan', 'lat': 35.1796, 'lon': 129.0756, 'tolerance': 0.5},
      {'name': 'Incheon', 'lat': 37.4563, 'lon': 126.7052, 'tolerance': 0.3},
      {'name': 'Daegu', 'lat': 35.8714, 'lon': 128.6014, 'tolerance': 0.4},
      {'name': 'Daejeon', 'lat': 36.3504, 'lon': 127.3845, 'tolerance': 0.4},
      {'name': 'Gwangju', 'lat': 35.1595, 'lon': 126.8526, 'tolerance': 0.4},
      {'name': 'Ulsan', 'lat': 35.5384, 'lon': 129.3114, 'tolerance': 0.4},
      {'name': 'Sejong', 'lat': 36.4800, 'lon': 127.2890, 'tolerance': 0.3},
      {'name': 'Gyeonggi', 'lat': 37.4138, 'lon': 127.5183, 'tolerance': 0.8},
      {'name': 'Gangwon', 'lat': 37.8228, 'lon': 128.1555, 'tolerance': 1.0},
      {'name': 'Chungbuk', 'lat': 36.8, 'lon': 127.7, 'tolerance': 0.8},
      {'name': 'Chungnam', 'lat': 36.5184, 'lon': 126.8000, 'tolerance': 0.8},
      {'name': 'Jeonbuk', 'lat': 35.7175, 'lon': 127.1530, 'tolerance': 0.8},
      {'name': 'Jeonnam', 'lat': 34.8679, 'lon': 126.9910, 'tolerance': 0.8},
      {'name': 'Gyeongbuk', 'lat': 36.4919, 'lon': 128.8889, 'tolerance': 0.8},
      {'name': 'Gyeongnam', 'lat': 35.4606, 'lon': 128.2132, 'tolerance': 0.8},
      {'name': 'Jeju', 'lat': 33.4996, 'lon': 126.5312, 'tolerance': 0.5},
    ];

    for (final city in cities) {
      final cityLat = city['lat'] as double;
      final cityLon = city['lon'] as double;
      final tolerance = city['tolerance'] as double;
      
      final latDiff = (lat - cityLat).abs();
      final lonDiff = (lon - cityLon).abs();
      if (latDiff <= tolerance && lonDiff <= tolerance) {
        return city['name'] as String;
      }
    }

    // If no city matches, return coordinates
    return '${lat.toStringAsFixed(3)}, ${lon.toStringAsFixed(3)}';
  }

  // Get district name for Seoul area
  static String? _getDistrictFromCoordinates(double lat, double lon) {
    // Seoul districts (simplified)
    if (lat >= 37.4 && lat <= 37.7 && lon >= 126.7 && lon <= 127.2) {
      if (lat >= 37.5 && lat <= 37.6 && lon >= 126.9 && lon <= 127.1) {
        return '강남구';
      } else if (lat >= 37.5 && lat <= 37.6 && lon >= 126.7 && lon <= 126.9) {
        return '마포구';
      } else if (lat >= 37.6 && lat <= 37.7 && lon >= 126.9 && lon <= 127.1) {
        return '성북구';
      } else if (lat >= 37.4 && lat <= 37.5 && lon >= 126.9 && lon <= 127.1) {
        return '서초구';
      }
      return '서울';
    }
    return null;
  }
}
