import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = 'YOUR_API_KEY'; // Replace with actual API key
  
  // Get current weather for user's location
  static Future<WeatherModel> getCurrentWeather() async {
    try {
      // Get current position
      Position position = await _getCurrentPosition();
      
      // Make API call
      final url = Uri.parse(
        '$_baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseWeatherData(data, position);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockWeatherData();
    }
  }

  // Get weather for specific location
  static Future<WeatherModel> getWeatherForLocation(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final position = Position(
          latitude: lat,
          longitude: lon,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        return _parseWeatherData(data, position);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      return _getMockWeatherData();
    }
  }

  // Get 5-day forecast
  static Future<List<WeatherModel>> getForecast() async {
    try {
      Position position = await _getCurrentPosition();
      
      final url = Uri.parse(
        '$_baseUrl/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseForecastData(data, position);
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      return [_getMockWeatherData()];
    }
  }

  static Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  static WeatherModel _parseWeatherData(Map<String, dynamic> data, Position position) {
    return WeatherModel(
      temperature: data['main']['temp'].toDouble(),
      feelsLike: data['main']['feels_like'].toDouble(),
      humidity: data['main']['humidity'],
      windSpeed: data['wind']['speed'].toDouble(),
      windDirection: data['wind']['deg'] ?? 0,
      precipitation: data['rain']?['1h']?.toDouble() ?? 0.0,
      condition: data['weather'][0]['main'],
      description: data['weather'][0]['description'],
      icon: data['weather'][0]['icon'],
      timestamp: DateTime.now(),
      location: Location(
        latitude: position.latitude,
        longitude: position.longitude,
        city: data['name'] ?? 'Unknown',
        country: data['sys']['country'] ?? 'Unknown',
      ),
    );
  }

  static List<WeatherModel> _parseForecastData(Map<String, dynamic> data, Position position) {
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
          latitude: position.latitude,
          longitude: position.longitude,
          city: data['city']['name'] ?? 'Unknown',
          country: data['city']['country'] ?? 'Unknown',
        ),
      ));
    }
    
    return forecast;
  }

  // Mock data for development
  static WeatherModel _getMockWeatherData() {
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
      location: Location(
        latitude: 37.5665,
        longitude: 126.9780,
        city: 'Seoul',
        country: 'KR',
      ),
    );
  }
}
