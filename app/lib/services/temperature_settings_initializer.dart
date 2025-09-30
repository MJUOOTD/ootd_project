import '../models/temperature_settings_model.dart';
import '../models/user_model.dart';
import 'service_locator.dart';

/// 회원가입 시 TemperatureSettings를 초기화하는 서비스
class TemperatureSettingsInitializer {
  static final TemperatureSettingsInitializer _instance = TemperatureSettingsInitializer._internal();
  factory TemperatureSettingsInitializer() => _instance;
  TemperatureSettingsInitializer._internal();

  /// UserModel을 기반으로 TemperatureSettings를 생성하고 저장
  /// 
  /// [user] 회원가입한 사용자 정보
  /// [userId] Firebase Auth UID
  /// 
  /// Returns: 생성된 TemperatureSettings 객체
  Future<TemperatureSettings?> initializeFromUser(UserModel user, String userId) async {
    try {
      // UserModel에서 TemperatureSettings 생성
      final temperatureSettings = TemperatureSettings.fromUser(user);
      
      // TemperatureSettingsService를 통해 Firestore에 저장
      final temperatureSettingsService = serviceLocator.temperatureSettingsService;
      await temperatureSettingsService.updateTemperatureSettings(temperatureSettings);
      
      print('[TemperatureSettingsInitializer] Successfully initialized temperature settings for user: $userId');
      print('[TemperatureSettingsInitializer] Settings: ${temperatureSettings.toJson()}');
      
      return temperatureSettings;
    } catch (error) {
      print('[TemperatureSettingsInitializer] Failed to initialize temperature settings: $error');
      return null;
    }
  }

  /// 기본 TemperatureSettings 생성 및 저장
  /// 
  /// [userId] Firebase Auth UID
  /// 
  /// Returns: 생성된 TemperatureSettings 객체
  Future<TemperatureSettings?> initializeDefault(String userId) async {
    try {
      // 기본 TemperatureSettings 생성
      final temperatureSettings = TemperatureSettings(
        temperatureSensitivity: 1.0,
        coldTolerance: 'normal',
        heatTolerance: 'normal',
        age: null,
        gender: null,
        activityLevel: 'moderate',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // TemperatureSettingsService를 통해 Firestore에 저장
      final temperatureSettingsService = serviceLocator.temperatureSettingsService;
      await temperatureSettingsService.updateTemperatureSettings(temperatureSettings);
      
      print('[TemperatureSettingsInitializer] Successfully initialized default temperature settings for user: $userId');
      
      return temperatureSettings;
    } catch (error) {
      print('[TemperatureSettingsInitializer] Failed to initialize default temperature settings: $error');
      return null;
    }
  }

  /// 사용자 설정이 이미 존재하는지 확인
  /// 
  /// [userId] Firebase Auth UID
  /// 
  /// Returns: 설정 존재 여부
  Future<bool> hasExistingSettings(String userId) async {
    try {
      final temperatureSettingsService = serviceLocator.temperatureSettingsService;
      await temperatureSettingsService.getTemperatureSettings();
      return true;
    } catch (error) {
      print('[TemperatureSettingsInitializer] Failed to check existing settings: $error');
      return false;
    }
  }
}
