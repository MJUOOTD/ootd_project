import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../../models/weather_model.dart';
import '../service_locator.dart';
import '../network/base_url.dart';
import 'weather_service.dart';

/// 최적화된 WeatherService 구현체
/// - KMA API 우선 사용
/// - 백엔드 서버 연동
/// - Mock 데이터 fallback
/// - 단일 캐시 로직
class OptimizedWeatherService implements WeatherService {
  static const Duration _timeout = Duration(seconds: 10);
  static const Duration _cacheTtl = Duration(minutes: 2);
  static final String _defaultBaseUrl = getDefaultBackendBaseUrl();
  
  final String baseUrl;
  WeatherModel? _cachedWeather;
  DateTime? _lastUpdate;

  OptimizedWeatherService({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl;

  @override
  Future<WeatherModel> getCurrentWeather({bool force = false}) async {
    print('[OptimizedWeatherService] Attempting to get current location...');
    final location = await serviceLocator.locationService.getCurrentLocation();
    print('[OptimizedWeatherService] Location obtained: lat=${location.latitude}, lon=${location.longitude}');
    return await _fetchWeatherFromBackend(location.latitude, location.longitude, force: force);
  }

  @override
  Future<WeatherModel> getWeatherForLocation(double latitude, double longitude, {bool force = false}) async {
    return await _fetchWeatherFromBackend(latitude, longitude, force: force);
  }

  /// 백엔드에서 날씨 데이터를 가져오는 메서드
  Future<WeatherModel> _fetchWeatherFromBackend(double latitude, double longitude, {bool force = false}) async {
    // 캐시 확인 (force가 false인 경우)
    if (!force && _isWeatherDataCached()) {
      print('[OptimizedWeatherService] Using cached weather data');
      return _cachedWeather!;
    }

    try {
      // 백엔드 API 호출
      final weather = await _fetchFromBackend(latitude, longitude, force);
      _cacheWeather(weather);
      return weather;
    } catch (e) {
      print('[OptimizedWeatherService] Backend error: $e');
      // API 호출 실패 시 에러를 그대로 전파 (Mock 데이터 사용 안함)
      rethrow;
    }
  }

  @override
  Future<List<WeatherModel>> getForecast() async {
    final location = await serviceLocator.locationService.getCurrentLocation();
    return await getForecastForLocation(location.latitude, location.longitude);
  }

  @override
  Future<List<WeatherModel>> getForecastForLocation(double latitude, double longitude) async {
    try {
      // 백엔드 forecast API 사용
      final uri = Uri.parse('$baseUrl/api/weather/forecast?lat=$latitude&lon=$longitude');
      final response = await http.get(uri).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> forecastList = json.decode(response.body) as List<dynamic>;
        
        return forecastList.map((item) {
          final Map<String, dynamic> forecastItem = item as Map<String, dynamic>;
          return WeatherModel.fromJson(forecastItem);
        }).toList();
      } else {
        throw WeatherException('Forecast API error: ${response.statusCode}', WeatherErrorType.apiError);
      }
    } catch (e) {
      print('[OptimizedWeatherService] Forecast API error: $e');
      // API 호출 실패 시 에러를 그대로 전파 (Mock 데이터 사용 안함)
      rethrow;
    }
  }

  @override
  Future<WeatherModel> getCachedWeather({bool forceRefresh = false}) async {
    if (forceRefresh || !_isWeatherDataCached()) {
      return await getCurrentWeather();
    }
    return _cachedWeather!;
  }

  @override
  Future<void> clearCache() async {
    _cachedWeather = null;
    _lastUpdate = null;
  }

  @override
  bool isWeatherDataCached() => _isWeatherDataCached();

  @override
  DateTime? getLastUpdateTime() => _lastUpdate;

  // Private methods
  Future<WeatherModel> _fetchFromBackend(double lat, double lon, bool force) async {
    // 간단한 서버의 current weather API 사용
    final uri = Uri.parse('$baseUrl/api/weather/current?lat=$lat&lon=$lon');
    
    print('[OptimizedWeatherService] ===== API REQUEST START =====');
    print('[OptimizedWeatherService] Base URL: $baseUrl');
    print('[OptimizedWeatherService] Full URI: $uri');
    print('[OptimizedWeatherService] Coordinates: lat=$lat, lon=$lon');
    print('[OptimizedWeatherService] Force refresh: $force');
    
    try {
      print('[OptimizedWeatherService] Sending HTTP GET request...');
      final response = await http.get(uri).timeout(_timeout);
      
      print('[OptimizedWeatherService] ===== API RESPONSE RECEIVED =====');
      print('[OptimizedWeatherService] Status Code: ${response.statusCode}');
      print('[OptimizedWeatherService] Headers: ${response.headers}');
      print('[OptimizedWeatherService] Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('[OptimizedWeatherService] Parsing JSON response...');
        final Map<String, dynamic> jsonBody = json.decode(response.body) as Map<String, dynamic>;
        print('[OptimizedWeatherService] Parsed JSON: $jsonBody');
        
        print('[OptimizedWeatherService] Creating WeatherModel...');
        final weather = WeatherModel.fromJson(jsonBody);
        print('[OptimizedWeatherService] WeatherModel created: ${weather.temperature}°C, ${weather.condition}');
        print('[OptimizedWeatherService] ===== API REQUEST SUCCESS =====');
        return weather;
      } else {
        print('[OptimizedWeatherService] ===== API REQUEST FAILED =====');
        print('[OptimizedWeatherService] Error Status: ${response.statusCode}');
        print('[OptimizedWeatherService] Error Body: ${response.body}');
        throw WeatherException(
          'Backend error: ${response.statusCode}', 
          WeatherErrorType.apiError, 
          statusCode: response.statusCode
        );
      }
    } catch (e) {
      print('[OptimizedWeatherService] ===== API REQUEST ERROR =====');
      print('[OptimizedWeatherService] Error Type: ${e.runtimeType}');
      print('[OptimizedWeatherService] Error Message: $e');
      print('[OptimizedWeatherService] Error Stack: ${e.toString()}');
      rethrow;
    }
  }

  void _cacheWeather(WeatherModel weather) {
    _cachedWeather = weather;
    _lastUpdate = DateTime.now();
    print('[OptimizedWeatherService] Weather cached: ${weather.temperature}°C');
  }

  bool _isWeatherDataCached() {
    if (_cachedWeather == null || _lastUpdate == null) return false;
    return DateTime.now().difference(_lastUpdate!) < _cacheTtl;
  }

}
