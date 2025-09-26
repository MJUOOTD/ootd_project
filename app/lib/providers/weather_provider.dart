import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../services/service_locator.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeatherProvider with ChangeNotifier {
  WeatherModel? _currentWeather;
  List<WeatherModel> _forecast = [];
  bool _isLoading = false;
  String? _error;

  WeatherModel? get currentWeather => _currentWeather;
  List<WeatherModel> get forecast => _forecast;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasWeather => _currentWeather != null;

  Future<void> fetchCurrentWeather({bool force = false}) async {
    print('WeatherProvider: fetchCurrentWeather called, force=$force');
    _setLoading(true);
    _clearError();

    try {
      _currentWeather = await serviceLocator.weatherService.getCurrentWeather(force: force);
      print('WeatherProvider: weather data received: temperature=${_currentWeather?.temperature}, condition=${_currentWeather?.condition}');
      print('WeatherProvider: weather source: ${_currentWeather?.source}, cached: ${_currentWeather?.cached}');
      notifyListeners();
    } catch (e) {
      print('WeatherProvider: error fetching weather: $e');
      // More specific error messages for location-related issues
      String errorMessage = 'Failed to fetch weather data: ${e.toString()}';
      if (e.toString().contains('Location')) {
        errorMessage = '위치 정보를 가져올 수 없습니다. 위치 권한을 확인해주세요.';
      } else if (e.toString().contains('permission')) {
        errorMessage = '위치 권한이 필요합니다. 설정에서 위치 권한을 허용해주세요.';
      } else if (e.toString().contains('network')) {
        errorMessage = '네트워크 연결을 확인해주세요.';
      }
      _setError(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchForecast() async {
    // 예보 실패는 UI를 막지 않음 (비차단 처리)
    try {
      final result = await serviceLocator.weatherService.getForecast();
      _forecast = result;
      notifyListeners();
    } catch (e) {
      // 조용히 로그만 남기고, 현재 날씨 카드만 표시되도록 유지
      if (kDebugMode) {
        print('fetchForecast ignored error: $e');
      }
    }
  }

  Future<void> refreshWeather({bool force = false}) async {
    _setLoading(true);
    _clearError();
    try {
      _currentWeather = await serviceLocator.weatherService.getCurrentWeather(force: force);
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh weather: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<WeatherModel> getWeatherForLocation(double lat, double lon) async {
    _setLoading(true);
    _clearError();

    try {
      final weather = await serviceLocator.weatherService.getWeatherForLocation(lat, lon);
      _currentWeather = weather;
      notifyListeners();
      return weather;
    } catch (e) {
      _setError('Failed to fetch weather for location: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearWeather() {
    _currentWeather = null;
    _forecast.clear();
    _clearError();
    notifyListeners();
  }
}

final weatherProvider = ChangeNotifierProvider((ref) => WeatherProvider());
