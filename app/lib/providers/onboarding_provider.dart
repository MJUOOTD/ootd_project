import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class OnboardingState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  OnboardingState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  // Convenience getters
  String get name => user?.name ?? '';
  String get email => user?.email ?? '';
  int get age => user?.age ?? 0;
  String get gender => user?.gender ?? '';

  OnboardingState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class OnboardingProvider extends StateNotifier<OnboardingState> {
  OnboardingProvider() : super(OnboardingState());

  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Update individual fields
  void updateName(String name) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(name: name);
      state = state.copyWith(user: updatedUser);
    }
  }

  void updateEmail(String email) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(email: email);
      state = state.copyWith(user: updatedUser);
    }
  }

  void updateGender(String gender) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(gender: gender);
      state = state.copyWith(user: updatedUser);
    }
  }

  void updateAge(int age) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(age: age);
      state = state.copyWith(user: updatedUser);
    }
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingProvider, OnboardingState>((ref) {
  return OnboardingProvider();
});
