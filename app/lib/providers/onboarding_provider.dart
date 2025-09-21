import 'package:flutter_riverpod/flutter_riverpod.dart';

// Onboarding data model
class OnboardingData {
  final String name;
  final String email;
  final String gender;
  final int age;
  final String temperatureSensitivity;
  final List<String> stylePreferences;

  const OnboardingData({
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.temperatureSensitivity,
    required this.stylePreferences,
  });

  OnboardingData copyWith({
    String? name,
    String? email,
    String? gender,
    int? age,
    String? temperatureSensitivity,
    List<String>? stylePreferences,
  }) {
    return OnboardingData(
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      temperatureSensitivity: temperatureSensitivity ?? this.temperatureSensitivity,
      stylePreferences: stylePreferences ?? this.stylePreferences,
    );
  }

  bool get isBasicInfoComplete => 
      name.isNotEmpty && email.isNotEmpty && gender.isNotEmpty && age > 0;

  bool get isSensitivityComplete => temperatureSensitivity.isNotEmpty;

  bool get isStylePreferencesComplete => stylePreferences.isNotEmpty;

  bool get isComplete => 
      isBasicInfoComplete && isSensitivityComplete && isStylePreferencesComplete;
}

// Onboarding state notifier
class OnboardingNotifier extends StateNotifier<OnboardingData> {
  OnboardingNotifier() : super(const OnboardingData(
    name: '',
    email: '',
    gender: '',
    age: 0,
    temperatureSensitivity: '',
    stylePreferences: [],
  ));

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void updateAge(int age) {
    state = state.copyWith(age: age);
  }

  void updateTemperatureSensitivity(String sensitivity) {
    state = state.copyWith(temperatureSensitivity: sensitivity);
  }

  void updateStylePreferences(List<String> preferences) {
    state = state.copyWith(stylePreferences: preferences);
  }

  void toggleStylePreference(String preference) {
    final currentPreferences = List<String>.from(state.stylePreferences);
    if (currentPreferences.contains(preference)) {
      currentPreferences.remove(preference);
    } else {
      currentPreferences.add(preference);
    }
    state = state.copyWith(stylePreferences: currentPreferences);
  }

  void reset() {
    state = const OnboardingData(
      name: '',
      email: '',
      gender: '',
      age: 0,
      temperatureSensitivity: '',
      stylePreferences: [],
    );
  }
}

// Provider
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingData>((ref) {
  return OnboardingNotifier();
});

// Individual step validation providers
final basicInfoValidationProvider = Provider<bool>((ref) {
  final data = ref.watch(onboardingProvider);
  return data.isBasicInfoComplete;
});

final sensitivityValidationProvider = Provider<bool>((ref) {
  final data = ref.watch(onboardingProvider);
  return data.isSensitivityComplete;
});

final stylePreferencesValidationProvider = Provider<bool>((ref) {
  final data = ref.watch(onboardingProvider);
  return data.isStylePreferencesComplete;
});

final onboardingCompleteProvider = Provider<bool>((ref) {
  final data = ref.watch(onboardingProvider);
  return data.isComplete;
});

