import 'package:flutter/foundation.dart';
import '../../../models/user_model.dart';

class SettingsProvider with ChangeNotifier {
  String? _selectedGender;
  String? _selectedSensitivity;
  bool _isLoading = false;
  String? _error;

  String? get selectedGender => _selectedGender;
  String? get selectedSensitivity => _selectedSensitivity;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with user data
  void initialize(UserModel? user) {
    if (user != null) {
      _selectedGender = user.gender;
      _selectedSensitivity = user.temperatureSensitivity.level;
    }
    notifyListeners();
  }

  // Update gender selection
  void updateGender(String? gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  // Update sensitivity selection
  void updateSensitivity(String? sensitivity) {
    _selectedSensitivity = sensitivity;
    notifyListeners();
  }

  // Check if form has changes
  bool hasChanges(UserModel? user) {
    if (user == null) return false;
    return _selectedGender != user.gender || 
           _selectedSensitivity != user.temperatureSensitivity.level;
  }

  // Check if form is valid
  bool get isValid => _selectedGender != null && _selectedSensitivity != null;

  // Reset form to user data
  void reset(UserModel? user) {
    if (user != null) {
      _selectedGender = user.gender;
      _selectedSensitivity = user.temperatureSensitivity.level;
    } else {
      _selectedGender = null;
      _selectedSensitivity = null;
    }
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
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
      gender: _selectedGender!,
      temperatureSensitivity: _convertSensitivityToModel(_selectedSensitivity!),
      updatedAt: DateTime.now(),
    );
  }
}
