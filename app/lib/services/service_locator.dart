import 'location/location_service.dart';
import 'weather/weather_service.dart';

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

  /// Get location service instance
  LocationService get locationService {
    _locationService ??= MockLocationService();
    return _locationService!;
  }

  /// Get weather service instance
  WeatherService get weatherService {
    _weatherService ??= MockWeatherService();
    return _weatherService!;
  }

  /// Initialize all services
  /// This method should be called during app startup
  Future<void> initialize() async {
    // TODO: Implement proper service initialization
    // - Register services with dependency injection framework
    // - Initialize services in correct order
    // - Handle service initialization errors
    // - Add service health checks
    
    // For now, just create mock instances
    _locationService = MockLocationService();
    _weatherService = MockWeatherService();
  }

  /// Reset all services (useful for testing)
  void reset() {
    _locationService = null;
    _weatherService = null;
  }

  /// Check if all required services are available
  bool get isInitialized => _locationService != null && _weatherService != null;
}

/// Global service locator instance
final ServiceLocator serviceLocator = ServiceLocator();
