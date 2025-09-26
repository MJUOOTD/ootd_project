import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../../../models/weather_model.dart';
import '../service_locator.dart';
import '../network/base_url.dart';
import 'weather_service.dart';

/// Backend 연동 기반 WeatherService 구현
class BackendWeatherService implements WeatherService {
  static const Duration _timeout = Duration(seconds: 3);
  static final String _defaultBaseUrl = getDefaultBackendBaseUrl();
  final String baseUrl;

  BackendWeatherService({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl {
    print('BackendWeatherService initialized with baseUrl: $baseUrl');
  }

  @override
  Future<WeatherModel> getCurrentWeather({bool force = false}) async {
    final location = await serviceLocator.locationService.getCurrentLocation();
    return getWeatherForLocation(location.latitude, location.longitude, force: force);
  }

  @override
  Future<WeatherModel> getWeatherForLocation(double latitude, double longitude, {bool force = false}) async {
    final uri = Uri.parse('$baseUrl/api/weather/current?lat=$latitude&lon=$longitude${force ? '&force=true' : ''}');
    print('Weather API request: $uri');
    
    try {
      final resp = await http.get(uri).timeout(_timeout);
      print('Weather API response status: ${resp.statusCode}');
      print('Weather API response body: ${resp.body}');
      
      if (resp.statusCode != 200) {
        print('Weather API error: HTTP ${resp.statusCode}');
        return _fallback(latitude, longitude, reason: 'http_${resp.statusCode}');
      }
      
      final Map<String, dynamic> jsonBody = json.decode(resp.body) as Map<String, dynamic>;
      
      // 서버 응답을 WeatherModel 형식으로 변환
      final weather = WeatherModel(
        temperature: (jsonBody['temperature'] ?? 0).toDouble(),
        feelsLike: (jsonBody['feelsLike'] ?? jsonBody['temperature'] ?? 0).toDouble(),
        humidity: (jsonBody['humidity'] ?? 0) as int,
        windSpeed: (jsonBody['windSpeed'] ?? 0).toDouble(),
        windDirection: (jsonBody['windDirection'] ?? 0) as int,
        precipitation: (jsonBody['precipitation'] ?? 0).toDouble(),
        condition: (jsonBody['condition'] ?? 'Unknown').toString(),
        description: (jsonBody['description'] ?? jsonBody['condition'] ?? 'Unknown').toString(),
        icon: (jsonBody['icon'] ?? '').toString(),
        timestamp: jsonBody['timestamp'] != null 
            ? DateTime.parse(jsonBody['timestamp'] as String)
            : DateTime.now(),
        location: Location(
          latitude: latitude,
          longitude: longitude,
          city: jsonBody['location']?['city'] ?? '',
          country: jsonBody['location']?['country'] ?? '',
          district: jsonBody['location']?['district'],
          subLocality: jsonBody['location']?['subLocality'],
        ),
        source: jsonBody['source'],
        cached: jsonBody['cached'],
      );
      
      print('Parsed weather data: temperature=${weather.temperature}, condition=${weather.condition}');
      return weather;
    } on TimeoutException {
      print('Weather API timeout after ${_timeout.inSeconds} seconds');
      return _fallback(latitude, longitude, reason: 'timeout');
    } on FormatException catch (e) {
      print('Weather API JSON parse error: $e');
      return _fallback(latitude, longitude, reason: 'parse_error');
    } catch (e) {
      print('Weather API error: $e');
      return _fallback(latitude, longitude, reason: 'network_error');
    }
  }

  @override
  Future<List<WeatherModel>> getForecast() async {
    final location = await serviceLocator.locationService.getCurrentLocation();
    final uri = Uri.parse('$baseUrl/api/weather/forecast?lat=${location.latitude}&lon=${location.longitude}');
    final resp = await http.get(uri).timeout(_timeout);
    if (resp.statusCode != 200) {
      // 실패 시 현재값 하나로 대체
      final current = await getCurrentWeather();
      return [current];
    }
    final Map<String, dynamic> j = json.decode(resp.body) as Map<String, dynamic>;
    final List<dynamic> intervals = (j['intervals'] as List<dynamic>? ) ?? [];
    final List<WeatherModel> out = [];
    for (final it in intervals) {
      out.add(WeatherModel(
        temperature: (it['temperature'] ?? 0).toDouble(),
        feelsLike: (it['temperature'] ?? 0).toDouble(),
        humidity: (it['humidity'] ?? 0) as int,
        windSpeed: (it['windSpeed'] ?? 0).toDouble(),
        windDirection: 0,
        precipitation: (it['precipitation'] ?? 0).toDouble(),
        condition: (it['condition'] ?? '').toString(),
        description: (it['condition'] ?? '').toString(),
        icon: '',
        timestamp: DateTime.parse(it['timestamp'] as String),
        location: Location(
          latitude: location.latitude,
          longitude: location.longitude,
          city: '',
          country: '',
          district: '',
          subLocality: '',
        ),
      ));
    }
    return out.isEmpty ? [await getCurrentWeather()] : out;
  }

  @override
  Future<List<WeatherModel>> getForecastForLocation(double latitude, double longitude) async {
    // 백엔드 forecast 미구현: 현재값으로 대체
    final current = await getWeatherForLocation(latitude, longitude);
    return [current];
  }

  WeatherModel? _cached;
  DateTime? _lastUpdate;
  static const Duration _cacheTtl = Duration(minutes: 5);

  @override
  Future<WeatherModel> getCachedWeather({bool forceRefresh = false}) async {
    if (!forceRefresh && _cached != null && _lastUpdate != null) {
      final fresh = DateTime.now().difference(_lastUpdate!) < _cacheTtl;
      if (fresh) return _cached!;
    }
    final current = await getCurrentWeather();
    _cached = current;
    _lastUpdate = DateTime.now();
    return current;
  }

  @override
  Future<void> clearCache() async {
    _cached = null;
    _lastUpdate = null;
  }

  @override
  bool isWeatherDataCached() {
    if (_cached == null || _lastUpdate == null) return false;
    return DateTime.now().difference(_lastUpdate!) < _cacheTtl;
  }

  @override
  DateTime? getLastUpdateTime() => _lastUpdate;

  /// 네트워크 연결 테스트
  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('$baseUrl/api/health');
      final resp = await http.get(uri).timeout(const Duration(seconds: 5));
      print('Connection test: ${resp.statusCode}');
      return resp.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}

WeatherModel _fallback(double lat, double lon, {String reason = ''}) {
  print('Using fallback weather data, reason: $reason');
  return WeatherModel(
    temperature: 22.0,
    feelsLike: 22.0,
    humidity: 60,
    windSpeed: 2.0,
    windDirection: 0,
    precipitation: 0.0,
    condition: 'Clear',
    description: reason.isNotEmpty ? 'fallback:$reason' : 'fallback',
    icon: '01d',
    timestamp: DateTime.now(),
    location: Location(
      latitude: lat,
      longitude: lon,
      city: '현재 위치',
      country: 'KR',
      district: '',
      subLocality: '',
    ),
    source: 'fallback',
    cached: false,
  );
}
