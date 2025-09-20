import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isFirstTime = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFirstTime => _isFirstTime;
  bool get isLoggedIn => _currentUser != null;

  // Initialize user provider
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      // Check if user has completed onboarding
      final prefs = await SharedPreferences.getInstance();
      _isFirstTime = prefs.getBool('isFirstTime') ?? true;
      
      // In a real app, you would check Firebase Auth here
      // For now, we'll use SharedPreferences to simulate user state
      final userData = prefs.getString('userData');
      if (userData != null) {
        // Parse user data from SharedPreferences
        // _currentUser = UserModel.fromJson(jsonDecode(userData));
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize user: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Complete onboarding and create user
  Future<void> completeOnboarding(UserModel user) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = user;
      _isFirstTime = false;
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false);
      await prefs.setString('userData', user.toJson().toString());
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to complete onboarding: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<void> updateUser(UserModel updatedUser) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = updatedUser.copyWith(updatedAt: DateTime.now());
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', _currentUser!.toJson().toString());
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to update user: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Update temperature sensitivity
  Future<void> updateTemperatureSensitivity(TemperatureSensitivity sensitivity) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      temperatureSensitivity: sensitivity,
      updatedAt: DateTime.now(),
    );
    
    await updateUser(updatedUser);
  }

  // Update gender
  Future<void> updateGender(String gender) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      gender: gender,
      updatedAt: DateTime.now(),
    );
    
    await updateUser(updatedUser);
  }

  // Update style preferences
  Future<void> updateStylePreferences(List<String> preferences) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      stylePreferences: preferences,
      updatedAt: DateTime.now(),
    );
    
    await updateUser(updatedUser);
  }

  // Update situation preferences
  Future<void> updateSituationPreferences(Map<String, dynamic> preferences) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      situationPreferences: preferences,
      updatedAt: DateTime.now(),
    );
    
    await updateUser(updatedUser);
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);

    try {
      _currentUser = null;
      _isFirstTime = true;
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userData');
      await prefs.setBool('isFirstTime', true);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to logout: ${e.toString()}');
    } finally {
      _setLoading(false);
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
}
