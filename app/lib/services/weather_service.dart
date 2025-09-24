import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
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
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather?q={CITY}&appid={API_KEY}&units=metric&lang=kr';
  static const String _apiKey = '8c0dfc3837648d4d8eb0282057f1d3a2'; // Replace with actual API key
  
  // Get current weather for user's location
  static Future<WeatherModel> getCurrentWeather() async {
    try {
      // Use the new location service
      final locationService = RealLocationService();
      final location = await locationService.getCurrentLocation();
      
      // Make API call to backend server
      final url = Uri.parse(
        'http://localhost:4000/api/weather/current?lat=${location.latitude}&lon=${location.longitude}'
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
      // Return mock data for development
      return _getMockWeatherData();
    }
  }

  // Get weather for specific location
  static Future<WeatherModel> getWeatherForLocation(double lat, double lon) async {
    try {
      // Make API call to backend server
      final url = Uri.parse(
        'http://localhost:4000/api/weather/current?lat=$lat&lon=$lon'
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
      return _getMockWeatherData();
    }
  }

  // Get 5-day forecast
  static Future<List<WeatherModel>> getForecast() async {
    try {
      // TODO: Replace with new WeatherService interface
      // final weatherService = GetIt.instance<weather_interface.WeatherService>();
      // return await weatherService.getForecast();
      
      // Use the new location service
      final locationService = RealLocationService();
      final location = await locationService.getCurrentLocation();
      
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
      return [_getMockWeatherData()];
    }
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

  static WeatherModel _parseWeatherDataFromLocation(Map<String, dynamic> data, Location location) {
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
        latitude: location.latitude,
        longitude: location.longitude,
        city: data['name'] ?? location.city,
        country: data['sys']['country'] ?? location.country,
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
