import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../../models/weather_model.dart';
import '../service_locator.dart';
import '../network/base_url.dart';
import 'weather_service.dart';

/// Backend 연동 기반 WeatherService 구현
class BackendWeatherService implements WeatherService {
  static const Duration _timeout = Duration(seconds: 8);
  static final String _defaultBaseUrl = getDefaultBackendBaseUrl();
  final String baseUrl;

  BackendWeatherService({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl;

  @override
  Future<WeatherModel> getCurrentWeather({bool force = false}) async {
    final location = await serviceLocator.locationService.getCurrentLocation();
    return getWeatherForLocation(location.latitude, location.longitude, force: force);
  }

  @override
  Future<WeatherModel> getWeatherForLocation(double latitude, double longitude, {bool force = false}) async {
    final uri = Uri.parse('$baseUrl/api/weather/current?lat=$latitude&lon=$longitude${force ? '&force=true' : ''}');
    try {
      final resp = await http.get(uri).timeout(_timeout);
      if (resp.statusCode != 200) {
        throw WeatherException('Backend error: ${resp.statusCode}', WeatherErrorType.apiError, statusCode: resp.statusCode);
      }
      final Map<String, dynamic> jsonBody = json.decode(resp.body) as Map<String, dynamic>;
      return WeatherModel.fromJson(jsonBody);
    } on TimeoutException {
      return _fallback(latitude, longitude, reason: 'timeout');
    } catch (_) {
      return _fallback(latitude, longitude, reason: 'network');
    }
  }

  @override
  Future<List<WeatherModel>> getForecast() async {
    // 백엔드 forecast 미구현: 현재값으로 대체
    final current = await getCurrentWeather();
    return [current];
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
}

WeatherModel _fallback(double lat, double lon, {String reason = ''}) {
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
      city: 'Seoul',
      country: 'KR',
    ),
  );
}
