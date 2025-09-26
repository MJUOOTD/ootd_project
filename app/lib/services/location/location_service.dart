import 'package:geolocator/geolocator.dart';
import '../../../models/weather_model.dart';

/// Location service interface for handling GPS and location permissions
/// 
/// This interface abstracts location-related functionality including:
/// - Permission request and management (UC-002)
/// - Current location retrieval
/// - Location service availability checks
/// 
/// TODO: Implement with geolocator package
/// - Add geolocator dependency to pubspec.yaml
/// - Implement permission handling with proper error states
/// - Add location accuracy and timeout configurations
/// - Implement background location updates if needed
abstract class LocationService {
  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled();

  /// Check current location permission status
  Future<LocationPermissionStatus> checkPermissionStatus();

  /// Request location permission from user
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestPermission();

  /// Get current location coordinates
  /// Throws [LocationException] if permission denied or service unavailable
  Future<Location> getCurrentLocation();

  /// Get location with specific accuracy requirements
  /// [desiredAccuracy] - desired accuracy in meters
  /// [timeout] - maximum time to wait for location
  Future<Location> getLocationWithAccuracy({
    double desiredAccuracy = 10.0,
    Duration timeout = const Duration(seconds: 10),
  });

  /// Check if location permission is permanently denied
  bool isPermissionPermanentlyDenied(LocationPermissionStatus status);

  /// Open device location settings
  Future<void> openLocationSettings();
}

/// Location permission status enum
enum LocationPermissionStatus {
  denied,           // Permission not granted
  granted,          // Permission granted
  deniedForever,    // Permission permanently denied
  restricted,       // Permission restricted by system
}

/// Location exception for location-related errors
class LocationException implements Exception {
  final String message;
  final LocationErrorType type;

  const LocationException(this.message, this.type);

  @override
  String toString() => 'LocationException: $message';
}

/// Types of location errors
enum LocationErrorType {
  permissionDenied,
  serviceDisabled,
  timeout,
  networkError,
  unknown,
}

/// Real implementation of LocationService using geolocator
class RealLocationService implements LocationService {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermissionStatus> checkPermissionStatus() async {
    final permission = await Geolocator.checkPermission();
    return _convertPermissionStatus(permission);
  }

  @override
  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission != LocationPermission.denied;
  }

  @override
  Future<Location> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException(
          'Location services are disabled. Please enable location services.',
          LocationErrorType.serviceDisabled,
        );
      }

      // Check permission status
      LocationPermissionStatus permissionStatus = await checkPermissionStatus();
      if (permissionStatus == LocationPermissionStatus.denied) {
        bool granted = await requestPermission();
        if (!granted) {
          throw LocationException(
            'Location permission denied. Please grant location permission.',
            LocationErrorType.permissionDenied,
          );
        }
      }

      if (permissionStatus == LocationPermissionStatus.deniedForever) {
        throw LocationException(
          'Location permission permanently denied. Please enable in settings.',
          LocationErrorType.permissionDenied,
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Reverse geocoding은 백엔드에서 처리하므로 도시/국가는 비워 둠
      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        city: '',
        country: '',
        district: '',
        subLocality: '',
      );
    } catch (e) {
      if (e is LocationException) {
        rethrow;
      }
      throw LocationException(
        'Failed to get current location: ${e.toString()}',
        LocationErrorType.unknown,
      );
    }
  }

  @override
  Future<Location> getLocationWithAccuracy({
    double desiredAccuracy = 10.0,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException(
          'Location services are disabled. Please enable location services.',
          LocationErrorType.serviceDisabled,
        );
      }

      // Check permission status
      LocationPermissionStatus permissionStatus = await checkPermissionStatus();
      if (permissionStatus == LocationPermissionStatus.denied) {
        bool granted = await requestPermission();
        if (!granted) {
          throw LocationException(
            'Location permission denied. Please grant location permission.',
            LocationErrorType.permissionDenied,
          );
        }
      }

      if (permissionStatus == LocationPermissionStatus.deniedForever) {
        throw LocationException(
          'Location permission permanently denied. Please enable in settings.',
          LocationErrorType.permissionDenied,
        );
      }

      // Get current position with specific accuracy
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: timeout,
      );

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        city: '',
        country: '',
        district: '',
        subLocality: '',
      );
    } catch (e) {
      if (e is LocationException) {
        rethrow;
      }
      throw LocationException(
        'Failed to get current location: ${e.toString()}',
        LocationErrorType.unknown,
      );
    }
  }

  @override
  bool isPermissionPermanentlyDenied(LocationPermissionStatus status) {
    return status == LocationPermissionStatus.deniedForever;
  }

  @override
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Helper method to convert geolocator permission to our enum
  LocationPermissionStatus _convertPermissionStatus(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionStatus.granted;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.restricted;
    }
  }
}

/// Mock implementation of LocationService for development
class MockLocationService implements LocationService {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return true; // Mock: always enabled
  }

  @override
  Future<LocationPermissionStatus> checkPermissionStatus() async {
    return LocationPermissionStatus.granted; // Mock: always granted
  }

  @override
  Future<bool> requestPermission() async {
    return true; // Mock: always granted
  }

  @override
  Future<Location> getCurrentLocation() async {
    // Mock data for development
    return Location(
      latitude: 37.5665,
      longitude: 126.9780,
      city: '',
      country: '',
      district: '',
      subLocality: '',
    );
  }

  @override
  Future<Location> getLocationWithAccuracy({
    double desiredAccuracy = 10.0,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // Mock data for development
    return Location(
      latitude: 37.5665,
      longitude: 126.9780,
      city: '',
      country: '',
      district: '',
      subLocality: '',
    );
  }

  @override
  bool isPermissionPermanentlyDenied(LocationPermissionStatus status) {
    return status == LocationPermissionStatus.deniedForever;
  }

  @override
  Future<void> openLocationSettings() async {
    throw UnimplementedError('openLocationSettings not implemented in mock');
  }
}
