import 'location/location_service.dart';
import 'weather/weather_service.dart';
import 'weather/optimized_weather_service.dart';
import 'temperature_settings_service.dart';
import 'temperature_settings_initializer.dart';
import 'user_service.dart';
import 'auth_service.dart';

/// Service locator for dependency injection
/// 
/// This class manages service instances and provides a centralized way
/// to access services throughout the application.
/// 
/// TODO: Implement proper dependency injection
/// - Add get_it package dependency to pubspec.yaml
/// - Replace this simple implementation with GetIt or similar DI framework
/// - Add service registration and lazy loading
/// - Add service lifecycle management
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Service instances
  LocationService? _locationService;
  WeatherService? _weatherService;
  TemperatureSettingsService? _temperatureSettingsService;
  TemperatureSettingsInitializer? _temperatureSettingsInitializer;
  AuthService? _authService;
  UserService? _userService;

  /// Get location service instance
  LocationService get locationService {
    _locationService ??= RealLocationService();
    return _locationService!;
  }

  /// Get weather service instance
  WeatherService get weatherService {
    _weatherService ??= OptimizedWeatherService();
    return _weatherService!;
  }

  /// Get temperature settings service instance
  TemperatureSettingsService get temperatureSettingsService {
    _temperatureSettingsService ??= TemperatureSettingsService();
    return _temperatureSettingsService!;
  }

  /// Get temperature settings initializer instance
  TemperatureSettingsInitializer get temperatureSettingsInitializer {
    _temperatureSettingsInitializer ??= TemperatureSettingsInitializer();
    return _temperatureSettingsInitializer!;
  }

  /// Get user service instance
  UserService get userService {
    _userService ??= UserService();
    return _userService!;
  }

  /// Get auth service instance
  AuthService get authService {
    _authService ??= AuthService();
    return _authService!;
  }

  /// Initialize all services
  /// This method should be called during app startup
  Future<void> initialize() async {
    // Register real implementations
    _locationService = RealLocationService();
    _weatherService = OptimizedWeatherService();
    _temperatureSettingsService = TemperatureSettingsService();
    _temperatureSettingsInitializer = TemperatureSettingsInitializer();
    _authService = AuthService();
    _userService = UserService();
  }

  /// Reset all services (useful for testing)
  void reset() {
    _locationService = null;
    _weatherService = null;
    _temperatureSettingsService = null;
    _temperatureSettingsInitializer = null;
    _authService = null;
    _userService = null;
  }

  /// Check if all required services are available
  bool get isInitialized => 
      _locationService != null && 
      _weatherService != null &&
      _temperatureSettingsService != null &&
      _temperatureSettingsInitializer != null &&
      _authService != null &&
      _userService != null;
}

/// Global service locator instance
final ServiceLocator serviceLocator = ServiceLocator();
