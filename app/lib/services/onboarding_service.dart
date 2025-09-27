import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _hasOnboardedKey = 'hasOnboarded';
  
  /// 온보딩 완료 여부를 확인합니다.
  static Future<bool> hasOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasOnboardedKey) ?? false;
  }
  
  /// 온보딩을 완료로 표시합니다.
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasOnboardedKey, true);
  }
  
  /// 온보딩 상태를 초기화합니다. (테스트용)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasOnboardedKey);
  }
}
