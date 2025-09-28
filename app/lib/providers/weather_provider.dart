import '../models/weather_model.dart';
import '../services/service_locator.dart';
import 'location_permission_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeatherState {
  final WeatherModel? currentWeather;
  final List<WeatherModel> forecast;
  final bool isLoading;
  final String? error;
  final bool hasLocationPermission;

  const WeatherState({
    this.currentWeather,
    this.forecast = const [],
    this.isLoading = false,
    this.error,
    this.hasLocationPermission = false,
  });

  WeatherState copyWith({
    WeatherModel? currentWeather,
    List<WeatherModel>? forecast,
    bool? isLoading,
    String? error,
    bool? hasLocationPermission,
  }) {
    return WeatherState(
      currentWeather: currentWeather ?? this.currentWeather,
      forecast: forecast ?? this.forecast,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasLocationPermission: hasLocationPermission ?? this.hasLocationPermission,
    );
  }

  bool get hasWeather => currentWeather != null;
}

class WeatherProvider extends StateNotifier<WeatherState> {
  final Ref ref;

  WeatherProvider(this.ref) : super(const WeatherState()) {
    // LocationPermissionProvider 상태 변화 감지
    ref.listen<LocationPermissionState>(locationPermissionProvider, (previous, next) {
      _updateLocationPermissionStatus(next.isGranted);
    });
  }

  WeatherModel? get currentWeather => state.currentWeather;
  List<WeatherModel> get forecast => state.forecast;
  bool get isLoading => state.isLoading;
  String? get error => state.error;
  bool get hasWeather => state.hasWeather;
  bool get hasLocationPermission => state.hasLocationPermission;

  void _updateLocationPermissionStatus(bool hasPermission) {
    state = state.copyWith(hasLocationPermission: hasPermission);
  }

  Future<void> fetchCurrentWeather({bool force = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 현재 위치로 날씨 정보 가져오기
      final weather = await serviceLocator.weatherService.getCurrentWeather(force: force);
      
      
      state = state.copyWith(
        currentWeather: weather,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      // 위치 권한 관련 에러인 경우 서울로 날씨 가져오기
      if (e.toString().contains('Location') || e.toString().contains('permission')) {
        try {
          // 서울 좌표로 날씨 정보 가져오기
          final seoulWeather = await serviceLocator.weatherService.getWeatherForLocation(37.5665, 126.9780);
          state = state.copyWith(
            currentWeather: seoulWeather,
            isLoading: false,
            error: null, // 에러 없이 서울 날씨 표시
          );
        } catch (seoulError) {
          // 서울 날씨도 실패한 경우 에러 표시
          state = state.copyWith(
            isLoading: false,
            error: '날씨 정보를 가져올 수 없습니다.',
          );
        }
      } else {
        // 기타 에러
        String errorMessage = 'Failed to fetch weather data: ${e.toString()}';
        if (e.toString().contains('network')) {
          errorMessage = '네트워크 연결을 확인해주세요.';
        }
        state = state.copyWith(
          isLoading: false,
          error: errorMessage,
        );
      }
    }
  }

  Future<void> fetchForecast() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 위치 권한 확인
      if (!state.hasLocationPermission) {
        state = state.copyWith(
          isLoading: false,
          error: '위치 권한이 필요합니다. 설정에서 위치 권한을 허용해주세요.',
        );
        return;
      }

      // 백엔드 forecast 미구현: 현재값 1개로 대체
      final forecast = await serviceLocator.weatherService.getForecast();
      state = state.copyWith(
        forecast: forecast,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch forecast data: ${e.toString()}',
      );
    }
  }

  Future<void> refreshWeather({bool force = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // 현재 위치로 날씨 정보 가져오기
      final weather = await serviceLocator.weatherService.getCurrentWeather(force: force);
      state = state.copyWith(
        currentWeather: weather,
        forecast: [weather],
        isLoading: false,
        error: null,
      );
    } catch (e) {
      // 위치 권한 관련 에러인 경우 서울로 날씨 가져오기
      if (e.toString().contains('Location') || e.toString().contains('permission')) {
        try {
          // 서울 좌표로 날씨 정보 가져오기
          final seoulWeather = await serviceLocator.weatherService.getWeatherForLocation(37.5665, 126.9780);
          state = state.copyWith(
            currentWeather: seoulWeather,
            forecast: [seoulWeather],
            isLoading: false,
            error: null, // 에러 없이 서울 날씨 표시
          );
        } catch (seoulError) {
          // 서울 날씨도 실패한 경우 에러 표시
          state = state.copyWith(
            isLoading: false,
            error: '날씨 정보를 가져올 수 없습니다.',
          );
        }
      } else {
        // 기타 에러
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to refresh weather: ${e.toString()}',
        );
      }
    }
  }

  Future<WeatherModel> getWeatherForLocation(double lat, double lon) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final weather = await serviceLocator.weatherService.getWeatherForLocation(lat, lon);
      state = state.copyWith(
        currentWeather: weather,
        isLoading: false,
        error: null,
      );
      return weather;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch weather for location: ${e.toString()}',
      );
      rethrow;
    }
  }

  void clearWeather() {
    state = state.copyWith(
      currentWeather: null,
      forecast: const [],
      error: null,
    );
  }
}

// Provider 정의
final weatherProvider = StateNotifierProvider<WeatherProvider, WeatherState>((ref) {
  return WeatherProvider(ref);
});