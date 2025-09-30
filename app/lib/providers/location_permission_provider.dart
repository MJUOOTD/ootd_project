import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location/location_service.dart';
import '../services/service_locator.dart';

/// 위치 권한 상태를 관리하는 Provider
class LocationPermissionState {
  final LocationPermissionStatus? status;
  final bool isChecking;
  final String? error;
  final bool hasRequested;

  const LocationPermissionState({
    this.status,
    this.isChecking = false,
    this.error,
    this.hasRequested = false,
  });

  LocationPermissionState copyWith({
    LocationPermissionStatus? status,
    bool? isChecking,
    String? error,
    bool? hasRequested,
  }) {
    return LocationPermissionState(
      status: status ?? this.status,
      isChecking: isChecking ?? this.isChecking,
      error: error ?? this.error,
      hasRequested: hasRequested ?? this.hasRequested,
    );
  }

  bool get isGranted => status == LocationPermissionStatus.granted;
  bool get isDenied => status == LocationPermissionStatus.denied;
  bool get isDeniedForever => status == LocationPermissionStatus.deniedForever;
  bool get isUnknown => status == null;
}

class LocationPermissionProvider extends StateNotifier<LocationPermissionState> {
  final LocationService _locationService;

  LocationPermissionProvider(this._locationService) 
      : super(LocationPermissionState()) {
    // 캐시 제거 - 항상 실제 권한 상태 확인
  }

  /// 위치 권한 상태 확인 및 요청
  Future<void> checkAndRequestPermission() async {
    // 이미 확인 중이면 중복 실행 방지
    if (state.isChecking) return;

    state = state.copyWith(isChecking: true, error: null);

    try {
      // 캐시 무시하고 실제 권한 상태 확인
      // 위치 서비스 활성화 확인
      final isServiceEnabled = await _locationService.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        state = state.copyWith(
          status: LocationPermissionStatus.denied,
          isChecking: false,
          error: '위치 서비스가 비활성화되어 있습니다',
          hasRequested: true,
        );
        return;
      }

      // 현재 권한 상태 확인
      final currentStatus = await _locationService.checkPermissionStatus();
      
      if (currentStatus == LocationPermissionStatus.denied) {
        // 권한이 거부된 경우 요청
        final granted = await _locationService.requestPermission();
        final finalStatus = granted 
            ? LocationPermissionStatus.granted 
            : LocationPermissionStatus.denied;
        
        state = state.copyWith(
          status: finalStatus,
          isChecking: false,
          hasRequested: true,
        );
      } else {
        // 이미 권한이 있거나 영구 거부된 경우
        state = state.copyWith(
          status: currentStatus,
          isChecking: false,
          hasRequested: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: LocationPermissionStatus.denied,
        isChecking: false,
        error: '위치 권한 확인 중 오류가 발생했습니다: ${e.toString()}',
        hasRequested: true,
      );
    }
  }

  /// 권한 상태만 확인 (요청하지 않음)
  Future<void> checkPermissionStatus() async {
    if (state.isChecking) return;

    state = state.copyWith(isChecking: true, error: null);

    try {
      final status = await _locationService.checkPermissionStatus();
      state = state.copyWith(
        status: status,
        isChecking: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: LocationPermissionStatus.denied,
        isChecking: false,
        error: '위치 권한 확인 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  /// 설정 앱 열기
  Future<void> openLocationSettings() async {
    try {
      await _locationService.openLocationSettings();
    } catch (e) {
      state = state.copyWith(
        error: '설정 앱을 열 수 없습니다: ${e.toString()}',
      );
    }
  }

  /// 상태 초기화
  void reset() {
    state = const LocationPermissionState();
  }
}

// Provider 정의
final locationPermissionProvider = StateNotifierProvider<LocationPermissionProvider, LocationPermissionState>((ref) {
  // ServiceLocator에서 LocationService 가져오기
  final locationService = serviceLocator.locationService;
  return LocationPermissionProvider(locationService);
});
