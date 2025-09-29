import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../services/simple_auth_service.dart';
import '../services/service_locator.dart';

class UserState {
  final UserModel? currentUser;
  final bool isLoading;
  final String? error;
  final bool isFirstTime;

  UserState({
    this.currentUser,
    this.isLoading = false,
    this.error,
    this.isFirstTime = true,
  });

  bool get isLoggedIn => currentUser != null;

  UserState copyWith({
    UserModel? currentUser,
    bool? isLoading,
    String? error,
    bool? isFirstTime,
  }) {
    return UserState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }
}

class UserProvider extends StateNotifier<UserState> {
  UserProvider() : super(UserState());

  UserModel? get currentUser => state.currentUser;
  bool get isLoading => state.isLoading;
  String? get error => state.error;
  bool get isFirstTime => state.isFirstTime;

  // Initialize user provider
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Check Firebase Auth state
      final authService = SimpleAuthService.instance;
      final firebaseUser = authService.currentUser;
      
      // Check if user has completed onboarding
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;
      
      UserModel? currentUser;
      
      if (firebaseUser != null) {
        // 1) Firestore 원격 프로필 우선 로드
        try {
          final remote = await serviceLocator.userService.getUserProfile(userId: firebaseUser.uid);
          if (remote != null) {
            currentUser = remote;
          }
        } catch (_) {}

        // 2) 로컬 캐시가 있으면 보조로 사용
        if (currentUser == null) {
          final userData = prefs.getString('userData');
          if (userData != null) {
            try {
              currentUser = UserModel(
                id: firebaseUser.uid,
                name: firebaseUser.displayName ?? 'User',
                email: firebaseUser.email ?? '',
                gender: '남성',
                age: 25,
                bodyType: '보통',
                activityLevel: '보통',
                temperatureSensitivity: TemperatureSensitivity.normal,
                stylePreferences: ['캐주얼', '깔끔한'],
                situationPreferences: {
                  '출근': true,
                  '데이트': true,
                  '운동': false,
                },
                createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
                updatedAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
              );
            } catch (_) {}
          }
        }

        // 3) 여전히 null이면 최소 기본 모델
        currentUser ??= UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          gender: '남성',
          age: 25,
          bodyType: '보통',
          activityLevel: '보통',
          temperatureSensitivity: TemperatureSensitivity.normal,
          stylePreferences: ['캐주얼', '깔끔한'],
          situationPreferences: {
            '출근': true,
            '데이트': true,
            '운동': false,
          },
          createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
          updatedAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
        );
      } else {
        // Firebase user is null, ensure currentUser is also null
        currentUser = null;
      }
      
      state = state.copyWith(
        currentUser: currentUser,
        isFirstTime: isFirstTime,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to initialize user: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // Unified sign-out: Firebase session + local state reset, with auth-state wait
  Future<void> signOutAll() async {
    state = state.copyWith(isLoading: true, error: null);
    Object? signOutError;
    try {
      // Use SimpleAuthService for logout
      final authService = SimpleAuthService.instance;
      await authService.signOut();
      
      // Wait for auth state to change
      try {
        await authService.authState
            .firstWhere((u) => u == null)
            .timeout(const Duration(seconds: 3), onTimeout: () => null);
      } catch (_) {
        // Ignore wait errors; we'll still finalize local state
      }
    } catch (e) {
      signOutError = e;
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userData');
      await prefs.setBool('isFirstTime', true);
      state = UserState(
        currentUser: null,
        isFirstTime: true,
        isLoading: false,
        error: signOutError == null ? null : 'Failed to sign out: ${signOutError.toString()}',
      );
    }
  }

  // Complete onboarding and create user
  Future<void> completeOnboarding(UserModel user) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false);
      await prefs.setString('userData', user.toJson().toString());
      
      // Firebase Auth에서 현재 사용자 ID 가져오기
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // TemperatureSettings 초기화
        final temperatureSettingsInitializer = serviceLocator.temperatureSettingsInitializer;
        await temperatureSettingsInitializer.initializeFromUser(user, currentUser.uid);
        print('[UserProvider] TemperatureSettings initialized for user: ${currentUser.uid}');
      } else {
        print('[UserProvider] No Firebase user found, skipping TemperatureSettings initialization');
      }
      
      state = state.copyWith(
        currentUser: user,
        isFirstTime: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to complete onboarding: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // Update user profile
  Future<void> updateUser(UserModel updatedUser) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newUser = updatedUser.copyWith(updatedAt: DateTime.now());
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', newUser.toJson().toString());

      // Firestore users/{uid} upsert
      final fbUser = fb.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        try {
          await serviceLocator.userService.upsertUserProfile(userId: fbUser.uid, user: newUser);
        } catch (e) {
          // Firestore 저장 실패 시 에러 보관 (UI 알림은 유지)
          state = state.copyWith(error: 'Failed to save profile: ${e.toString()}');
        }

        // TemperatureSettings 재생성/갱신
        try {
          await serviceLocator.temperatureSettingsInitializer.initializeFromUser(newUser, fbUser.uid);
        } catch (e) {
          state = state.copyWith(error: 'Failed to update temperature settings: ${e.toString()}');
        }
      }
      
      state = state.copyWith(
        currentUser: newUser,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update user: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // Update temperature sensitivity
  Future<void> updateTemperatureSensitivity(TemperatureSensitivity sensitivity) async {
    if (state.currentUser == null) return;

    final updatedUser = state.currentUser!.copyWith(
      temperatureSensitivity: sensitivity,
      updatedAt: DateTime.now(),
    );
    
    await updateUser(updatedUser);
  }

  // Update gender
  Future<void> updateGender(String gender) async {
    if (state.currentUser == null) return;

    final updatedUser = state.currentUser!.copyWith(
      gender: gender,
      updatedAt: DateTime.now(),
    );
    
    await updateUser(updatedUser);
  }

  // Update style preferences
  Future<void> updateStylePreferences(List<String> preferences) async {
    if (state.currentUser == null) return;

    final updatedUser = state.currentUser!.copyWith(
      stylePreferences: preferences,
      updatedAt: DateTime.now(),
    );
    
    await updateUser(updatedUser);
  }

  // Update situation preferences
  Future<void> updateSituationPreferences(Map<String, dynamic> preferences) async {
    if (state.currentUser == null) return;

    final updatedUser = state.currentUser!.copyWith(
      situationPreferences: preferences,
      updatedAt: DateTime.now(),
    );
    
    await updateUser(updatedUser);
  }
  // Logout user (alias for signOutAll)
  Future<void> logout() async {
    await signOutAll();
  }

  // Clear user state without Firebase signout (for auth state listener)
  void clearUser() {
    state = UserState(
      currentUser: null,
      isLoading: false,
      error: null,
      isFirstTime: state.isFirstTime,
    );
  }

  // Create a new user for onboarding
  UserModel createUser({
    required String name,
    required String email,
    required String gender,
    required int age,
    required String bodyType,
    required String activityLevel,
    required TemperatureSensitivity temperatureSensitivity,
    required List<String> stylePreferences,
    required Map<String, dynamic> situationPreferences,
  }) {
    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      gender: gender,
      age: age,
      bodyType: bodyType,
      activityLevel: activityLevel,
      temperatureSensitivity: temperatureSensitivity,
      stylePreferences: stylePreferences,
      situationPreferences: situationPreferences,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

}

// Provider for UserProvider
final userProvider = StateNotifierProvider<UserProvider, UserState>((ref) {
  return UserProvider();
});

final authStateProvider = StreamProvider<fb.User?>((ref) {
  return SimpleAuthService.instance.authState;
});

// Firebase 인증 상태 변화를 감지하여 UserProvider 업데이트
final authStateListenerProvider = StreamProvider<void>((ref) {
  return SimpleAuthService.instance.authState.map((user) {
    // 로그인 시에만 UserProvider 초기화 (로그아웃 시에는 initialize 호출하지 않음)
    if (user != null) {
      ref.read(userProvider.notifier).initialize();
    } else {
      // 로그아웃 시에는 사용자 상태만 초기화
      ref.read(userProvider.notifier).clearUser();
    }
    return null;
  });
});
