import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_model.dart';
import '../services/service_locator.dart';
import '../services/favorites_service.dart';
import '../services/location/location_service.dart';

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
  double get temperature {
    final temp = currentWeather?.temperature ?? 0.0;
    // 온도 범위 검사 (-50°C ~ 60°C) - 유효하지 않은 값은 0으로 처리
    if (temp < -50 || temp > 60) return 0.0;
    return temp;
  }
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
  WeatherProvider() : super(WeatherState()) {
    // 즐겨찾기 변경 리스너 등록
    FavoritesService.addListener(_onFavoritesChanged);
  }

  void _onFavoritesChanged() {
    // 즐겨찾기가 변경되면 날씨 정보 새로고침
    fetchCurrentWeather();
  }

  Future<void> fetchCurrentWeather({bool force = false}) async {
    print('[WeatherProvider] ===== FETCH WEATHER START =====');
    print('[WeatherProvider] Force refresh: $force');
    print('[WeatherProvider] Current state: isLoading=${state.isLoading}, hasWeather=${state.currentWeather != null}');
    
    // 강제로 새로고침하도록 설정
    force = true;
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('[WeatherProvider] Fetching current weather...');
      
      // 1. 현재 위치 기반 날씨 정보 시도 (최우선)
      try {
        print('[WeatherProvider] ===== ATTEMPTING CURRENT LOCATION =====');
        print('[WeatherProvider] Attempting to get current location weather...');
        final weather = await serviceLocator.weatherService.getCurrentWeather(force: force);
        print('[WeatherProvider] Successfully got weather from current location');
        print('[WeatherProvider] Weather location: ${weather.location.city}, ${weather.location.country}');
        print('[WeatherProvider] Weather coordinates: lat=${weather.location.latitude}, lon=${weather.location.longitude}');
        print('[WeatherProvider] Weather source: ${weather.source}');
        print('[WeatherProvider] Weather cached: ${weather.cached}');
        
        print('[WeatherProvider] Getting forecast data...');
        final forecast = await serviceLocator.weatherService.getForecast();
        print('[WeatherProvider] Successfully got forecast data');
        
        print('[WeatherProvider] Fetched weather data from current location: temperature=${weather.temperature}°C, condition=${weather.condition}');
        print('[WeatherProvider] Weather location: lat=${weather.location.latitude}, lon=${weather.location.longitude}');
        print('[WeatherProvider] Fetched forecast data: ${forecast.length} items');
        
        print('[WeatherProvider] Updating state with weather data...');
        state = state.copyWith(currentWeather: weather, forecast: forecast, isLoading: false);
        print('[WeatherProvider] ===== FETCH WEATHER SUCCESS =====');
        return;
      } catch (locationError) {
        print('[WeatherProvider] ===== CURRENT LOCATION FAILED =====');
        print('[WeatherProvider] Location error: $locationError');
        print('[WeatherProvider] Error type: ${locationError.runtimeType}');
        
        // 위치 권한 오류인 경우 에러 상태로 설정하고 fallback 제거
        if (locationError is LocationException) {
          print('[WeatherProvider] LocationException detected: ${locationError.message}');
          state = state.copyWith(
            isLoading: false,
            error: '현재 위치를 불러올 수 없음'
          );
          return;
        } else if (locationError.toString().contains('permission') || 
                   locationError.toString().contains('Permission') ||
                   locationError.toString().contains('LocationException')) {
          print('[WeatherProvider] Location permission error detected');
          state = state.copyWith(
            isLoading: false,
            error: '현재 위치를 불러올 수 없음'
          );
          return;
        }
        
        // 2. 즐겨찾기 도시가 있는지 확인
        final favorites = FavoritesService.favorites;
        if (favorites.isNotEmpty) {
          print('[WeatherProvider] Using favorite city: ${favorites.first.placeName}');
          final favoriteWeather = await serviceLocator.weatherService.getWeatherForLocation(
            favorites.first.latitude, 
            favorites.first.longitude, 
            force: force
          );
          final favoriteForecast = await serviceLocator.weatherService.getForecastForLocation(
            favorites.first.latitude, 
            favorites.first.longitude
          );
          print('[WeatherProvider] Fetched weather for favorite city: temperature=${favoriteWeather.temperature}°C, condition=${favoriteWeather.condition}');
          state = state.copyWith(
            currentWeather: favoriteWeather, 
            forecast: favoriteForecast, 
            isLoading: false,
            error: null
          );
          return;
        }
        
        // 3. 기본 위치 fallback 제거 - 에러 상태로 유지
        print('[WeatherProvider] No fallback - location permission required');
        state = state.copyWith(
          isLoading: false,
          error: '현재 위치를 불러올 수 없음'
        );
      }
    } catch (e) {
      print('[WeatherProvider] Error fetching weather: $e');
      
      // 위치 권한 오류인 경우 에러 상태로 설정 (fallback 제거)
      if (e is LocationException) {
        print('[WeatherProvider] LocationException detected: ${e.message}');
        state = state.copyWith(
          isLoading: false,
          error: '현재 위치를 불러올 수 없음'
        );
        return;
      } else if (e.toString().contains('permission') || 
                 e.toString().contains('Permission') ||
                 e.toString().contains('LocationException')) {
        print('[WeatherProvider] Location permission error detected');
        state = state.copyWith(
          isLoading: false,
          error: '현재 위치를 불러올 수 없음'
        );
        return;
      }
      
      String errorMessage = '날씨 정보를 가져올 수 없습니다. 도시 검색을 통해 원하는 지역의 날씨를 확인하세요.';
      if (e.toString().contains('network')) {
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
    await fetchCurrentWeather(force: force);
  }

  Future<WeatherModel> getWeatherForLocation(double lat, double lon) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final weather = await serviceLocator.weatherService.getWeatherForLocation(lat, lon);
      final forecast = await serviceLocator.weatherService.getForecastForLocation(lat, lon);
      print('[WeatherProvider] Fetched weather for selected location: temperature=${weather.temperature}°C, condition=${weather.condition}');
      print('[WeatherProvider] Location: lat=$lat, lon=$lon');
      state = state.copyWith(currentWeather: weather, forecast: forecast, isLoading: false, error: null);
      return weather;
    } catch (e) {
      print('[WeatherProvider] Error fetching weather for location: $e');
      state = state.copyWith(error: '선택한 위치의 날씨 정보를 가져올 수 없습니다: ${e.toString()}', isLoading: false);
      rethrow;
    }
  }

  void clearWeather() {
    state = WeatherState();
  }
}

final weatherProvider = StateNotifierProvider<WeatherProvider, WeatherState>((ref) {
  return WeatherProvider();
});