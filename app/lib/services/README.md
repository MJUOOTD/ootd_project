# Services Architecture

This directory contains the service layer implementation for the OOTD app, following the interface segregation principle and dependency inversion principle.

## Architecture Overview

The service layer is designed with clean architecture principles:

- **Interfaces**: Define contracts for service implementations
- **Mock Implementations**: Provide development/testing implementations
- **Service Locator**: Manages dependency injection and service lifecycle

## Service Interfaces

### LocationService (`location/location_service.dart`)

Handles GPS and location permission functionality (UC-002):

- Permission request and management
- Current location retrieval
- Location service availability checks
- Error handling for location-related issues

**TODO**: Implement with geolocator package
- Add geolocator dependency to pubspec.yaml
- Implement permission handling with proper error states
- Add location accuracy and timeout configurations

### WeatherService (`weather/weather_service.dart`)

Handles weather data retrieval (UC-005):

- Current weather data for user location
- Weather forecast data
- Location-based weather queries
- Caching and offline support

**TODO**: Implement with OpenWeather API
- Add http package dependency to pubspec.yaml
- Implement OpenWeather API integration
- Add API key management and configuration
- Implement proper error handling and retry logic

## Usage

### Basic Usage

```dart
// Get service instances
final locationService = serviceLocator.locationService;
final weatherService = serviceLocator.weatherService;

// Get current location
final location = await locationService.getCurrentLocation();

// Get current weather
final weather = await weatherService.getCurrentWeather();
```

### Error Handling

```dart
try {
  final weather = await weatherService.getCurrentWeather();
  // Handle weather data
} on WeatherException catch (e) {
  // Handle weather-specific errors
  switch (e.type) {
    case WeatherErrorType.networkError:
      // Handle network issues
      break;
    case WeatherErrorType.invalidApiKey:
      // Handle API key issues
      break;
    // ... other error types
  }
} on LocationException catch (e) {
  // Handle location-specific errors
  switch (e.type) {
    case LocationErrorType.permissionDenied:
      // Handle permission issues
      break;
    case LocationErrorType.serviceDisabled:
      // Handle service disabled
      break;
    // ... other error types
  }
}
```

## Migration from Legacy Services

The existing `weather_service.dart` is marked as deprecated and contains TODO comments for migration to the new interface-based architecture.

### Migration Steps

1. **Replace direct service calls**:
   ```dart
   // Old way
   final weather = await WeatherService.getCurrentWeather();
   
   // New way
   final weather = await serviceLocator.weatherService.getCurrentWeather();
   ```

2. **Update error handling**:
   ```dart
   // Old way
   try {
     final weather = await WeatherService.getCurrentWeather();
   } catch (e) {
     // Generic error handling
   }
   
   // New way
   try {
     final weather = await serviceLocator.weatherService.getCurrentWeather();
   } on WeatherException catch (e) {
     // Specific error handling
   }
   ```

3. **Use dependency injection**:
   ```dart
   // Inject services in constructors
   class WeatherProvider {
     final WeatherService _weatherService;
     
     WeatherProvider(this._weatherService);
   }
   ```

## Future Enhancements

- **Dependency Injection**: Replace ServiceLocator with GetIt or similar framework
- **Caching**: Implement persistent caching for weather data
- **Offline Support**: Add offline data storage and sync
- **Rate Limiting**: Implement API rate limiting and request throttling
- **Background Updates**: Add background weather data updates
- **Analytics**: Add service usage analytics and monitoring
