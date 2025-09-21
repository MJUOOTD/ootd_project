import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

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

  Future<void> fetchCurrentWeather() async {
    _setLoading(true);
    _clearError();

    try {
      _currentWeather = await WeatherService.getCurrentWeather();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch weather data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchForecast() async {
    _setLoading(true);
    _clearError();

    try {
      _forecast = await WeatherService.getForecast();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch forecast data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshWeather() async {
    await Future.wait([
      fetchCurrentWeather(),
      fetchForecast(),
    ]);
  }

  Future<WeatherModel> getWeatherForLocation(double lat, double lon) async {
    _setLoading(true);
    _clearError();

    try {
      final weather = await WeatherService.getWeatherForLocation(lat, lon);
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
