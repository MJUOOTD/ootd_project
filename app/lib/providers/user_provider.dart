import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../services/simple_auth_service.dart';

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
        // User is authenticated with Firebase
        final userData = prefs.getString('userData');
        if (userData != null) {
          try {
            // Parse user data from SharedPreferences
            // currentUser = UserModel.fromJson(jsonDecode(userData));
            // For now, create a basic user model
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
          } catch (e) {
            print('Error parsing user data: $e');
            // Create a basic user model if parsing fails
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
          }
        } else {
          // No user data in SharedPreferences, create basic user model
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
        }
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
    print('[signOutAll] Starting logout process...');
    state = state.copyWith(isLoading: true, error: null);
    Object? signOutError;
    try {
      // Use SimpleAuthService for logout
      final authService = SimpleAuthService.instance;
      print('[signOutAll] Calling Firebase signOut...');
      await authService.signOut();
      print('[signOutAll] Firebase signOut completed');
      
      // Wait for auth state to change
      try {
        print('[signOutAll] Waiting for auth state change...');
        await authService.authState
            .firstWhere((u) => u == null)
            .timeout(const Duration(seconds: 3), onTimeout: () => null);
        print('[signOutAll] Auth state changed to null');
      } catch (_) {
        print('[signOutAll] Auth state wait timeout or error');
        // Ignore wait errors; we'll still finalize local state
      }
    } catch (e) {
      print('[signOutAll] Error during logout: $e');
      signOutError = e;
    } finally {
      print('[signOutAll] Finalizing local state...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userData');
      await prefs.setBool('isFirstTime', true);
      state = UserState(
        currentUser: null,
        isFirstTime: true,
        isLoading: false,
        error: signOutError == null ? null : 'Failed to sign out: ${signOutError.toString()}',
      );
      print('[signOutAll] Local state cleared. Current user: ${state.currentUser}');
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
    print('[clearUser] Clearing user state...');
    state = UserState(
      currentUser: null,
      isLoading: false,
      error: null,
      isFirstTime: state.isFirstTime,
    );
    print('[clearUser] User state cleared. Current user: ${state.currentUser}');
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
    print('[authStateListenerProvider] Firebase user changed: ${user?.uid}');
    // 로그인 시에만 UserProvider 초기화 (로그아웃 시에는 initialize 호출하지 않음)
    if (user != null) {
      print('[authStateListenerProvider] User logged in, initializing...');
      ref.read(userProvider.notifier).initialize();
    } else {
      print('[authStateListenerProvider] User logged out, clearing user state...');
      // 로그아웃 시에는 사용자 상태만 초기화
      ref.read(userProvider.notifier).clearUser();
    }
    return null;
  });
});
