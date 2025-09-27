import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../firebase_options.dart';
import 'service_locator.dart';
import 'pexels_api_service.dart';
import '../providers/location_permission_provider.dart';
import '../providers/user_provider.dart';

/// 앱 초기화를 관리하는 클래스
/// 
/// 앱 시작 시 필요한 모든 서비스를 올바른 순서로 초기화합니다.
/// 1. Firebase 초기화
/// 2. 위치 권한 확인 (가장 먼저)
/// 3. 기타 서비스 초기화
class AppInitializer {
  static bool _isInitialized = false;
  static String? _initializationError;

  /// 앱 초기화 상태
  static bool get isInitialized => _isInitialized;
  static String? get initializationError => _initializationError;

  /// 앱 초기화 실행
  /// 
  /// [ref] - Riverpod ProviderContainer 참조
  /// [skipLocationPermission] - 위치 권한 확인을 건너뛸지 여부 (테스트용)
  static Future<void> initialize({
    required ProviderContainer ref,
    bool skipLocationPermission = false,
  }) async {
    if (_isInitialized) return;

    try {
      print('[AppInitializer] Starting app initialization...');

      // 1. Firebase 초기화
      await _initializeFirebase();

      // 2. 위치 권한 확인 (가장 먼저)
      if (!skipLocationPermission) {
        await _initializeLocationPermission(ref);
      }

      // 3. 기타 서비스 초기화
      await _initializeServices();

      // 4. UserProvider 초기화
      await _initializeUserProvider(ref);

      _isInitialized = true;
      print('[AppInitializer] App initialization completed successfully');
    } catch (e) {
      _initializationError = e.toString();
      print('[AppInitializer] App initialization failed: $e');
      rethrow;
    }
  }

  /// Firebase 초기화
  static Future<void> _initializeFirebase() async {
    print('[AppInitializer] Initializing Firebase...');
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Web에서 세션 지속성 설정
    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.SESSION);
    }

    // 디버그용 인증 상태 리스너
    FirebaseAuth.instance.authStateChanges().listen((user) {
      debugPrint('[authStateChanges] user: ${user?.uid}');
    });

    print('[AppInitializer] Firebase initialized successfully');
  }

  /// 위치 권한 초기화
  static Future<void> _initializeLocationPermission(ProviderContainer ref) async {
    print('[AppInitializer] Initializing location permission...');
    
    try {
      final locationPermissionNotifier = ref.read(locationPermissionProvider.notifier);
      await locationPermissionNotifier.checkAndRequestPermission();
      
      final status = ref.read(locationPermissionProvider).status;
      print('[AppInitializer] Location permission status: $status');
    } catch (e) {
      print('[AppInitializer] Location permission initialization failed: $e');
      // 위치 권한 실패해도 앱은 계속 실행
    }
  }

  /// 기타 서비스 초기화
  static Future<void> _initializeServices() async {
    print('[AppInitializer] Initializing services...');
    
    // ServiceLocator 초기화
    await serviceLocator.initialize();
    
    // Pexels API 키 설정
    PexelsApiService.setApiKey('QwYk7NDUowPtA83vo1RHNYSHCWWnDTd8MNlm8giDiGq8blf1iPAHu1DP');
    
    print('[AppInitializer] Services initialized successfully');
  }

  /// UserProvider 초기화
  static Future<void> _initializeUserProvider(ProviderContainer ref) async {
    print('[AppInitializer] Initializing UserProvider...');
    
    try {
      await ref.read(userProvider.notifier).initialize();
      print('[AppInitializer] UserProvider initialized successfully');
    } catch (e) {
      print('[AppInitializer] UserProvider initialization failed: $e');
    }
  }

  /// 초기화 상태 리셋 (테스트용)
  static void reset() {
    _isInitialized = false;
    _initializationError = null;
  }

  /// 위치 권한 상태 확인
  static Future<bool> isLocationPermissionGranted(ProviderContainer ref) async {
    try {
      final state = ref.read(locationPermissionProvider);
      return state.isGranted;
    } catch (e) {
      print('[AppInitializer] Error checking location permission: $e');
      return false;
    }
  }

  /// 위치 권한 재요청
  static Future<void> requestLocationPermission(ProviderContainer ref) async {
    try {
      final locationPermissionNotifier = ref.read(locationPermissionProvider.notifier);
      await locationPermissionNotifier.checkAndRequestPermission();
    } catch (e) {
      print('[AppInitializer] Error requesting location permission: $e');
    }
  }
}
