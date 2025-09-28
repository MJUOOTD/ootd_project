import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/temperature_settings_model.dart';
import '../services/temperature_settings_service.dart';
import '../services/service_locator.dart';

/// 온도 설정 상태
class TemperatureSettingsState {
  final TemperatureSettings? settings;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  const TemperatureSettingsState({
    this.settings,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  TemperatureSettingsState copyWith({
    TemperatureSettings? settings,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return TemperatureSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  String toString() {
    return 'TemperatureSettingsState('
        'settings: $settings, '
        'isLoading: $isLoading, '
        'error: $error, '
        'isInitialized: $isInitialized'
        ')';
  }
}

/// 온도 설정 서비스 Provider
final temperatureSettingsServiceProvider = Provider<TemperatureSettingsService>((ref) {
  try {
    final service = serviceLocator.temperatureSettingsService;
    return service;
  } catch (e) {
    rethrow;
  }
});

/// 온도 설정 상태 Provider
final temperatureSettingsProvider = StateNotifierProvider<TemperatureSettingsNotifier, TemperatureSettingsState>((ref) {
  return TemperatureSettingsNotifier(ref.read(temperatureSettingsServiceProvider));
});

/// 온도 설정 Notifier
class TemperatureSettingsNotifier extends StateNotifier<TemperatureSettingsState> {
  final TemperatureSettingsService _service;

  TemperatureSettingsNotifier(this._service) : super(const TemperatureSettingsState());

  /// 온도 설정 초기화 (앱 시작 시 호출)
  Future<void> initialize() async {
    if (state.isInitialized || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // 기존 설정이 있는지 확인
      final hasSettings = await _service.hasTemperatureSettings();
      
      if (hasSettings) {
        // 기존 설정 로드
        final settings = await _service.getTemperatureSettings();
        state = state.copyWith(
          settings: settings,
          isLoading: false,
          isInitialized: true,
        );
      } else {
        // 기본 설정으로 초기화
        final defaultSettings = await _service.initializeDefaultSettings();
        state = state.copyWith(
          settings: defaultSettings,
          isLoading: false,
          isInitialized: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isInitialized: true,
      );
    }
  }

  /// 온도 설정 새로고침
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final settings = await _service.getTemperatureSettings();
      state = state.copyWith(
        settings: settings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 온도 설정 업데이트
  Future<void> updateSettings(TemperatureSettings newSettings) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedSettings = await _service.updateTemperatureSettings(newSettings);
      state = state.copyWith(
        settings: updatedSettings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 온도 설정 생성 (초기화)
  Future<void> createSettings(TemperatureSettings settings) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final createdSettings = await _service.createTemperatureSettings(settings);
      state = state.copyWith(
        settings: createdSettings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 온도 설정 삭제
  Future<void> deleteSettings() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _service.deleteTemperatureSettings();
      state = state.copyWith(
        settings: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 기본 설정으로 초기화
  Future<void> resetToDefault() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final defaultSettings = await _service.initializeDefaultSettings();
      state = state.copyWith(
        settings: defaultSettings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 개인화된 체감온도 계산
  double calculatePersonalizedFeelsLike(double baseFeelsLike) {
    if (state.settings == null) {
      return baseFeelsLike; // 설정이 없으면 기본값 반환
    }

    return _service.calculatePersonalizedFeelsLike(
      baseFeelsLike,
      state.settings!,
    );
  }

  /// 특정 필드만 업데이트
  Future<void> updateField({
    double? temperatureSensitivity,
    String? coldTolerance,
    String? heatTolerance,
    int? age,
    String? gender,
    String? activityLevel,
  }) async {
    if (state.settings == null) return;

    final updatedSettings = state.settings!.copyWith(
      temperatureSensitivity: temperatureSensitivity,
      coldTolerance: coldTolerance,
      heatTolerance: heatTolerance,
      age: age,
      gender: gender,
      activityLevel: activityLevel,
      updatedAt: DateTime.now(),
    );

    await updateSettings(updatedSettings);
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 온도 설정이 로드되었는지 확인하는 Provider
final temperatureSettingsLoadedProvider = Provider<bool>((ref) {
  final settingsState = ref.watch(temperatureSettingsProvider);
  return settingsState.isInitialized && settingsState.settings != null;
});

/// 개인화된 체감온도 계산 Provider
final personalizedFeelsLikeProvider = Provider.family<double, double>((ref, baseFeelsLike) {
  final settingsState = ref.watch(temperatureSettingsProvider);
  
  if (settingsState.settings == null) {
    return baseFeelsLike;
  }

  final service = ref.read(temperatureSettingsServiceProvider);
  return service.calculatePersonalizedFeelsLike(
    baseFeelsLike,
    settingsState.settings!,
  );
});
