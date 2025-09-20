import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

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
  bool get isLoggedIn => state.currentUser != null;

  // Initialize user provider
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Check if user has completed onboarding
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;
      
      // In a real app, you would check Firebase Auth here
      // For now, we'll use SharedPreferences to simulate user state
      final userData = prefs.getString('userData');
      UserModel? currentUser;
      if (userData != null) {
        // Parse user data from SharedPreferences
        // currentUser = UserModel.fromJson(jsonDecode(userData));
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

  // Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userData');
      await prefs.setBool('isFirstTime', true);
      
      state = state.copyWith(
        currentUser: null,
        isFirstTime: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to logout: ${e.toString()}',
        isLoading: false,
      );
    }
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
final userProviderProvider = StateNotifierProvider<UserProvider, UserState>((ref) {
  return UserProvider();
});
