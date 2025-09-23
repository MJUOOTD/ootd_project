import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';

class SettingsState {
  final String? selectedGender;
  final String? selectedSensitivity;
  final bool isLoading;
  final String? error;

  SettingsState({
    this.selectedGender,
    this.selectedSensitivity,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    String? selectedGender,
    String? selectedSensitivity,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      selectedGender: selectedGender ?? this.selectedGender,
      selectedSensitivity: selectedSensitivity ?? this.selectedSensitivity,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SettingsProvider extends StateNotifier<SettingsState> {
  SettingsProvider() : super(SettingsState());

  String? get selectedGender => state.selectedGender;
  String? get selectedSensitivity => state.selectedSensitivity;
  bool get isLoading => state.isLoading;
  String? get error => state.error;

  // Initialize with user data
  void initialize(UserModel? user) {
    if (user != null) {
      state = state.copyWith(
        selectedGender: user.gender,
        selectedSensitivity: user.temperatureSensitivity.level,
      );
    }
  }

  // Update gender selection
  void updateGender(String? gender) {
    state = state.copyWith(selectedGender: gender);
  }

  // Update sensitivity selection
  void updateSensitivity(String? sensitivity) {
    state = state.copyWith(selectedSensitivity: sensitivity);
  }

  // Check if form has changes
  bool hasChanges(UserModel? user) {
    if (user == null) return false;
    return state.selectedGender != user.gender || 
           state.selectedSensitivity != user.temperatureSensitivity.level;
  }

  // Check if form is valid
  bool get isValid => state.selectedGender != null && state.selectedSensitivity != null;

  // Reset form to user data
  void reset(UserModel? user) {
    if (user != null) {
      state = state.copyWith(
        selectedGender: user.gender,
        selectedSensitivity: user.temperatureSensitivity.level,
        error: null,
      );
    } else {
      state = state.copyWith(
        selectedGender: null,
        selectedSensitivity: null,
        error: null,
      );
    }
  }

  // Convert sensitivity level to TemperatureSensitivity object
  TemperatureSensitivity _convertSensitivityToModel(String level) {
    switch (level) {
      case 'low':
        return TemperatureSensitivity(
          coldSensitivity: 0.5,
          heatSensitivity: 0.5,
          level: 'low',
        );
      case 'high':
        return TemperatureSensitivity(
          coldSensitivity: -0.5,
          heatSensitivity: -0.5,
          level: 'high',
        );
      case 'normal':
      default:
        return TemperatureSensitivity(
          coldSensitivity: 0.0,
          heatSensitivity: 0.0,
          level: 'normal',
        );
    }
  }

  // Get updated user model with new settings
  UserModel? getUpdatedUser(UserModel? currentUser) {
    if (currentUser == null || !isValid) return null;

    return currentUser.copyWith(
      gender: state.selectedGender!,
      temperatureSensitivity: _convertSensitivityToModel(state.selectedSensitivity!),
      updatedAt: DateTime.now(),
    );
  }
}

// Provider for SettingsProvider
final settingsProviderProvider = StateNotifierProvider<SettingsProvider, SettingsState>((ref) {
  return SettingsProvider();
});
