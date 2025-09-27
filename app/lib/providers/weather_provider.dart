import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_model.dart';
import '../services/service_locator.dart';

class WeatherState {
  final WeatherModel? currentWeather;
  final List<WeatherModel> forecast;
  final bool isLoading;
  final String? error;

  WeatherState({
    this.currentWeather,
    this.forecast = const [],
    this.isLoading = false,
    this.error,
  });

  bool get hasWeather => currentWeather != null;
  
  // Convenience getters for easier access
  double get temperature => currentWeather?.temperature ?? 0.0;
  String get condition => currentWeather?.condition ?? '';
  String get conditionIcon => currentWeather?.icon ?? '';
  int get humidity => currentWeather?.humidity ?? 0;
  double get windSpeed => currentWeather?.windSpeed ?? 0.0;
  Location? get location => currentWeather?.location;
  DateTime get lastUpdated => currentWeather?.timestamp ?? DateTime.now();

  WeatherState copyWith({
    WeatherModel? currentWeather,
    List<WeatherModel>? forecast,
    bool? isLoading,
    String? error,
  }) {
    return WeatherState(
      currentWeather: currentWeather ?? this.currentWeather,
      forecast: forecast ?? this.forecast,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class WeatherProvider extends StateNotifier<WeatherState> {
  WeatherProvider() : super(WeatherState());

  Future<void> fetchCurrentWeather({bool force = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final weather = await serviceLocator.weatherService.getCurrentWeather(force: force);
      state = state.copyWith(currentWeather: weather, isLoading: false);
    } catch (e) {
      // More specific error messages for location-related issues
      String errorMessage = 'Failed to fetch weather data: ${e.toString()}';
      if (e.toString().contains('Location')) {
        errorMessage = '위치 정보를 가져올 수 없습니다. 위치 권한을 확인해주세요.';
      } else if (e.toString().contains('permission')) {
        errorMessage = '위치 권한이 필요합니다. 설정에서 위치 권한을 허용해주세요.';
      } else if (e.toString().contains('network')) {
        errorMessage = '네트워크 연결을 확인해주세요.';
      }
      state = state.copyWith(error: errorMessage, isLoading: false);
    }
  }

  Future<void> fetchForecast() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 백엔드 forecast 미구현: 현재값 1개로 대체
      final forecast = await serviceLocator.weatherService.getForecast();
      state = state.copyWith(forecast: forecast, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: 'Failed to fetch forecast data: ${e.toString()}', isLoading: false);
    }
  }

  Future<void> refreshWeather({bool force = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final weather = await serviceLocator.weatherService.getCurrentWeather(force: force);
      state = state.copyWith(
        currentWeather: weather,
        forecast: [weather],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to refresh weather: ${e.toString()}', isLoading: false);
    }
  }

  Future<WeatherModel> getWeatherForLocation(double lat, double lon) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final weather = await serviceLocator.weatherService.getWeatherForLocation(lat, lon);
      state = state.copyWith(currentWeather: weather, isLoading: false);
      return weather;
    } catch (e) {
      state = state.copyWith(error: 'Failed to fetch weather for location: ${e.toString()}', isLoading: false);
      rethrow;
    }
  }

  void clearWeather() {
    state = WeatherState();
  }

  // Alias for fetchCurrentWeather
  Future<void> loadData({bool force = false}) async {
    await fetchCurrentWeather(force: force);
  }

  // Alias for refreshWeather
  Future<void> refresh({bool force = false}) async {
    await refreshWeather(force: force);
  }
}

final weatherProvider = StateNotifierProvider<WeatherProvider, WeatherState>((ref) {
  return WeatherProvider();
});
