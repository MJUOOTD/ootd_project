import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_model.dart';
import '../services/service_locator.dart';
import '../services/favorites_service.dart';
import 'location_permission_provider.dart';

class WeatherState {
  final WeatherModel? currentWeather;
  final List<WeatherModel> forecast;
  final bool isLoading;
  final String? error;
  final bool hasLocationPermission;
  final bool isManualSelection; // 수동 도시 선택 여부
  final double? selectedLatitude; // 수동 선택 위도
  final double? selectedLongitude; // 수동 선택 경도
  final WeatherModel? currentLocationCache; // 최초 위치 기반 캐시

  const WeatherState({
    this.currentWeather,
    this.forecast = const [],
    this.isLoading = false,
    this.error,
    this.hasLocationPermission = false,
    this.isManualSelection = false,
    this.selectedLatitude,
    this.selectedLongitude,
    this.currentLocationCache,
  });

  bool get hasWeather => currentWeather != null;
  
  double get temperature {
    final temp = currentWeather?.temperature ?? 0.0;
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
    bool? hasLocationPermission,
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
      hasLocationPermission: hasLocationPermission ?? this.hasLocationPermission,
      isManualSelection: isManualSelection ?? this.isManualSelection,
      selectedLatitude: selectedLatitude ?? this.selectedLatitude,
      selectedLongitude: selectedLongitude ?? this.selectedLongitude,
      currentLocationCache: currentLocationCache ?? this.currentLocationCache,
    );
  }
}

class WeatherProvider extends StateNotifier<WeatherState> {
  final Ref ref;

  WeatherProvider(this.ref) : super(const WeatherState()) {
    // 위치 권한 상태 반영
    ref.listen<LocationPermissionState>(locationPermissionProvider, (previous, next) {
      _updateLocationPermissionStatus(next.isGranted);
    });
    // 즐겨찾기 변경 리스너 등록
    FavoritesService.addListener(_onFavoritesChanged);
  }

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
      return;
    }
    // 즐겨찾기가 변경되면 날씨 정보 새로고침
    fetchCurrentWeather();
  }

  void _updateLocationPermissionStatus(bool hasPermission) {
    state = state.copyWith(hasLocationPermission: hasPermission);
  }

  Future<void> fetchCurrentWeather({bool force = false}) async {
    // 수동 선택 모드: 선택 좌표 기준으로 갱신 (위치 서비스 호출 안함)
    if (state.isManualSelection && state.selectedLatitude != null && state.selectedLongitude != null) {
      await getWeatherForLocation(state.selectedLatitude!, state.selectedLongitude!);
      return;
    }

    // 2) 위치 서비스 호출 최소화: 첫 1회만 현재 위치를 사용, 이후에는 캐시 좌표로 갱신
    state = state.copyWith(isLoading: true, error: null);

    if (!_didFetchLocationOnce) {
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
        return;
      } catch (e) {
        state = state.copyWith(isLoading: false, error: '현재 위치를 불러올 수 없음');
        return;
      }
    }

    // 3) 두 번째 이후: 현재 가진 좌표(현재 상태 또는 캐시)로만 갱신, 위치 서비스 호출 안함
    final cached = state.currentWeather ?? state.currentLocationCache;
    if (cached?.location != null) {
      final lat = cached!.location.latitude;
      final lon = cached.location.longitude;
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
        state = state.copyWith(isLoading: false, error: '날씨 정보를 갱신할 수 없습니다');
        return;
      }
    }

    // 좌표가 전혀 없으면 첫 위치 호출 시나리오로 대체
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
      state = state.copyWith(isLoading: false, error: '현재 위치를 불러올 수 없음');
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
      state = state.copyWith(forecast: forecast, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: 'Failed to fetch forecast data: ${e.toString()}', isLoading: false);
    }
  }

  Future<void> refreshWeather({bool force = false}) async {
    await fetchCurrentWeather(force: force);
  }

  Future<WeatherModel> getWeatherForLocation(double lat, double lon) async {
    // 수동 선택 중/직후 자동 새로고침 억제 (즐겨찾기 이벤트 등으로 인한 덮어쓰기 방지)
    _suppressAutoRefreshFor(const Duration(seconds: 5));

    state = state.copyWith(
      isLoading: true,
      error: null,
      isManualSelection: true,
      selectedLatitude: lat,
      selectedLongitude: lon,
    );

    try {
      final weather = await serviceLocator.weatherService.getWeatherForLocation(lat, lon, force: true);
      final forecast = await serviceLocator.weatherService.getForecastForLocation(lat, lon);
      state = state.copyWith(
        currentWeather: weather,
        forecast: forecast,
        isLoading: false,
        error: null,
        isManualSelection: true,
        selectedLatitude: lat,
        selectedLongitude: lon,
      );
      return weather;
    } catch (e) {
      state = state.copyWith(error: '선택한 위치의 날씨 정보를 가져올 수 없습니다: ${e.toString()}', isLoading: false);
      rethrow;
    }
  }

  /// 현재 위치 정보를 강제로 새로고침 (더 정확한 위치 정보 획득)
  Future<void> refreshCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 위치 서비스를 통해 더 정확한 위치 정보 획득
      final locationService = serviceLocator.locationService;
      final newLocation = await locationService.getCurrentLocation();
      
      // 새로운 위치로 날씨 정보 가져오기
      final weather = await serviceLocator.weatherService.getWeatherForLocation(
        newLocation.latitude, 
        newLocation.longitude, 
        force: true,
      );
      
      final forecast = await serviceLocator.weatherService.getForecastForLocation(
        newLocation.latitude, 
        newLocation.longitude,
      );
      
      state = state.copyWith(currentWeather: weather, forecast: forecast, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '위치 정보를 새로고침할 수 없습니다: ${e.toString()}',
      );
    }
  }

  void clearWeather() {
    state = const WeatherState();
  }
}

final weatherProvider = StateNotifierProvider<WeatherProvider, WeatherState>((ref) {
  return WeatherProvider(ref);
});