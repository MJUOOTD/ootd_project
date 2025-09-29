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
  final bool isManualSelection; // 사용자가 도시를 수동 선택했는지 여부
  final double? selectedLatitude; // 수동 선택한 위도
  final double? selectedLongitude; // 수동 선택한 경도
  final WeatherModel? currentLocationCache; // 처음 위치 기반으로 받은 날씨 캐시

  WeatherState({
    this.currentWeather,
    this.forecast = const [],
    this.isLoading = false,
    this.error,
    this.isManualSelection = false,
    this.selectedLatitude,
    this.selectedLongitude,
    this.currentLocationCache,
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
    bool? isManualSelection,
    double? selectedLatitude,
    double? selectedLongitude,
    WeatherModel? currentLocationCache,
  }) {
    return WeatherState(
      currentWeather: currentWeather ?? this.currentWeather,
      forecast: forecast ?? this.forecast,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isManualSelection: isManualSelection ?? this.isManualSelection,
      selectedLatitude: selectedLatitude ?? this.selectedLatitude,
      selectedLongitude: selectedLongitude ?? this.selectedLongitude,
      currentLocationCache: currentLocationCache ?? this.currentLocationCache,
    );
  }
}

class WeatherProvider extends StateNotifier<WeatherState> {
  WeatherProvider() : super(WeatherState()) {
    // 즐겨찾기 변경 리스너 등록
    FavoritesService.addListener(_onFavoritesChanged);
  }

  // 도시 수동 선택 직후 자동 새로고침(현재 위치 재조회)로 덮어쓰는 것을 방지하기 위한 억제 타이머
  DateTime? _suppressAutoRefreshUntil;
  bool _didFetchLocationOnce = false; // 위치 서비스 1회만 호출

  bool _isAutoRefreshSuppressed() {
    if (_suppressAutoRefreshUntil == null) return false;
    return DateTime.now().isBefore(_suppressAutoRefreshUntil!);
  }

  void _suppressAutoRefreshFor(Duration duration) {
    _suppressAutoRefreshUntil = DateTime.now().add(duration);
  }

  void _onFavoritesChanged() {
    // 수동 도시 선택 직후에는 자동 새로고침을 건너뜀
    if (_isAutoRefreshSuppressed()) {
      print('[WeatherProvider] Auto-refresh suppressed due to manual selection. Skipping refresh.');
      return;
    }
    // 즐겨찾기가 변경되면 날씨 정보 새로고침
    fetchCurrentWeather();
  }

  Future<void> fetchCurrentWeather({bool force = false}) async {
    print('[WeatherProvider] ===== FETCH WEATHER START =====');
    print('[WeatherProvider] Force refresh: $force');
    print('[WeatherProvider] Current state: isLoading=${state.isLoading}, hasWeather=${state.currentWeather != null}');
    
    // 1) 수동 선택 모드: 선택 좌표 기준으로 갱신 (위치 서비스 호출 안함)
    if (state.isManualSelection && state.selectedLatitude != null && state.selectedLongitude != null) {
      print('[WeatherProvider] Manual selection active. Skipping current-location refresh and using selected city.');
      await getWeatherForLocation(state.selectedLatitude!, state.selectedLongitude!);
      return;
    }

    // 2) 위치 서비스 호출 최소화: 첫 1회만 현재 위치를 사용, 이후에는 캐시 좌표로 갱신
    state = state.copyWith(isLoading: true, error: null);

    if (!_didFetchLocationOnce) {
      print('[WeatherProvider] First-time location fetch. Using current location service.');
      try {
        final weather = await serviceLocator.weatherService.getCurrentWeather(force: true);
        final forecast = await serviceLocator.weatherService.getForecast();
        _didFetchLocationOnce = true;
        state = state.copyWith(
          currentWeather: weather,
          forecast: forecast,
          isLoading: false,
          error: null,
          currentLocationCache: weather,
          isManualSelection: false,
        );
        print('[WeatherProvider] First location fetch success. Cached current location weather.');
        return;
      } catch (e) {
        print('[WeatherProvider] First-time location fetch failed: $e');
        state = state.copyWith(isLoading: false, error: '현재 위치를 불러올 수 없음');
        return;
      }
    }

    // 3) 두 번째 이후: 현재 가진 좌표(현재 상태 또는 캐시)로만 갱신, 위치 서비스 호출 안함
    final cached = state.currentWeather ?? state.currentLocationCache;
    if (cached?.location != null) {
      final lat = cached!.location.latitude;
      final lon = cached.location.longitude;
      print('[WeatherProvider] Refreshing by last known coordinates: lat=$lat, lon=$lon');
      try {
        final weather = await serviceLocator.weatherService.getWeatherForLocation(lat, lon, force: true);
        final forecast = await serviceLocator.weatherService.getForecastForLocation(lat, lon);
        state = state.copyWith(
          currentWeather: weather,
          forecast: forecast,
          isLoading: false,
          error: null,
          // 유지: 수동 선택 아님
          isManualSelection: false,
        );
        return;
      } catch (e) {
        print('[WeatherProvider] Refresh by last known coordinates failed: $e');
        state = state.copyWith(isLoading: false, error: '날씨 정보를 갱신할 수 없습니다');
        return;
      }
    }

    // 좌표가 전혀 없으면 첫 위치 호출 시나리오로 대체
    print('[WeatherProvider] No known coordinates, falling back to initial location fetch');
    try {
      final weather = await serviceLocator.weatherService.getCurrentWeather(force: true);
      final forecast = await serviceLocator.weatherService.getForecast();
      _didFetchLocationOnce = true;
      state = state.copyWith(
        currentWeather: weather,
        forecast: forecast,
        isLoading: false,
        error: null,
        currentLocationCache: weather,
        isManualSelection: false,
      );
    } catch (e) {
      print('[WeatherProvider] Initial fallback location fetch failed: $e');
      state = state.copyWith(isLoading: false, error: '현재 위치를 불러올 수 없음');
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
    print('[WeatherProvider] ===== GET WEATHER FOR LOCATION START =====');
    print('[WeatherProvider] Coordinates: lat=$lat, lon=$lon');
    
    // 수동 선택 중/직후 자동 새로고침 억제 (즐겨찾기 이벤트 등으로 인한 덮어쓰기 방지)
    _suppressAutoRefreshFor(const Duration(seconds: 5));

    state = state.copyWith(
      isLoading: true,
      error: null,
      isManualSelection: true,
      selectedLatitude: lat,
      selectedLongitude: lon,
    );
    print('[WeatherProvider] State updated: isLoading=true');

    try {
      print('[WeatherProvider] Fetching current weather for location...');
      final weather = await serviceLocator.weatherService.getWeatherForLocation(lat, lon, force: true);
      print('[WeatherProvider] Current weather fetched: temperature=${weather.temperature}°C, condition=${weather.condition}');
      print('[WeatherProvider] Weather location: ${weather.location.city}, ${weather.location.country}');
      
      print('[WeatherProvider] Fetching forecast for location...');
      final forecast = await serviceLocator.weatherService.getForecastForLocation(lat, lon);
      print('[WeatherProvider] Forecast fetched: ${forecast.length} items');
      
      print('[WeatherProvider] Updating state with new weather data...');
      state = state.copyWith(
        currentWeather: weather,
        forecast: forecast,
        isLoading: false,
        error: null,
        isManualSelection: true,
        selectedLatitude: lat,
        selectedLongitude: lon,
      );
      print('[WeatherProvider] State updated: currentWeather=${state.currentWeather?.temperature}°C, forecast=${state.forecast.length} items');
      print('[WeatherProvider] ===== GET WEATHER FOR LOCATION SUCCESS =====');
      
      return weather;
    } catch (e) {
      print('[WeatherProvider] ===== GET WEATHER FOR LOCATION ERROR =====');
      print('[WeatherProvider] Error fetching weather for location: $e');
      state = state.copyWith(error: '선택한 위치의 날씨 정보를 가져올 수 없습니다: ${e.toString()}', isLoading: false);
      print('[WeatherProvider] State updated: error=${state.error}');
      rethrow;
    }
  }

  /// 현재 위치 정보를 강제로 새로고침 (더 정확한 위치 정보 획득)
  Future<void> refreshCurrentLocation() async {
    print('[WeatherProvider] ===== REFRESH CURRENT LOCATION =====');
    print('[WeatherProvider] Forcing location refresh for more accurate data...');
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 위치 서비스를 통해 더 정확한 위치 정보 획득
      final locationService = serviceLocator.locationService;
      final newLocation = await locationService.getCurrentLocation();
      
      print('[WeatherProvider] New location obtained: ${newLocation.city}, ${newLocation.country}');
      print('[WeatherProvider] Coordinates: lat=${newLocation.latitude}, lon=${newLocation.longitude}');
      
      // 새로운 위치로 날씨 정보 가져오기
      final weather = await serviceLocator.weatherService.getWeatherForLocation(
        newLocation.latitude, 
        newLocation.longitude, 
        force: true
      );
      
      final forecast = await serviceLocator.weatherService.getForecastForLocation(
        newLocation.latitude, 
        newLocation.longitude
      );
      
      print('[WeatherProvider] Weather updated with new location: ${weather.location.city}');
      state = state.copyWith(currentWeather: weather, forecast: forecast, isLoading: false);
      print('[WeatherProvider] ===== REFRESH CURRENT LOCATION SUCCESS =====');
    } catch (e) {
      print('[WeatherProvider] ===== REFRESH CURRENT LOCATION FAILED =====');
      print('[WeatherProvider] Error refreshing location: $e');
      state = state.copyWith(
        isLoading: false,
        error: '위치 정보를 새로고침할 수 없습니다: ${e.toString()}'
      );
    }
  }

  void clearWeather() {
    state = WeatherState();
  }
}

final weatherProvider = StateNotifierProvider<WeatherProvider, WeatherState>((ref) {
  return WeatherProvider();
});