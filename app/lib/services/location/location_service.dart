import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' hide Location;
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

  /// Get location stream for continuous updates
  Stream<Location> getLocationStream();

  /// Check if location has changed significantly
  bool hasLocationChanged(Location oldLocation, Location newLocation, {double thresholdMeters = 100});
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
      print('[RealLocationService] ===== LOCATION REQUEST START =====');
      print('[RealLocationService] Starting location request...');
      
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      print('[RealLocationService] Location service enabled: $serviceEnabled');
      if (!serviceEnabled) {
        print('[RealLocationService] Location service is DISABLED!');
        throw LocationException(
          'Location services are disabled. Please enable location services.',
          LocationErrorType.serviceDisabled,
        );
      }

      // Check permission status
      LocationPermissionStatus permissionStatus = await checkPermissionStatus();
      print('[RealLocationService] Permission status: $permissionStatus');
      
      if (permissionStatus == LocationPermissionStatus.denied) {
        print('[RealLocationService] Requesting permission...');
        bool granted = await requestPermission();
        print('[RealLocationService] Permission granted: $granted');
        if (!granted) {
          // 권한이 거부되었지만 다시 한번 확인
          LocationPermissionStatus recheckStatus = await checkPermissionStatus();
          print('[RealLocationService] Recheck permission status: $recheckStatus');
          if (recheckStatus == LocationPermissionStatus.denied) {
            throw LocationException(
              'Location permission denied. Please grant location permission.',
              LocationErrorType.permissionDenied,
            );
          }
        }
      }

      if (permissionStatus == LocationPermissionStatus.deniedForever) {
        print('[RealLocationService] Permission permanently denied, opening settings...');
        await openLocationSettings();
        throw LocationException(
          'Location permission permanently denied. Please enable in settings.',
          LocationErrorType.permissionDenied,
        );
      }

      // Get current position with high accuracy
      print('[RealLocationService] Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 30),
        forceAndroidLocationManager: false,
      );

      print('[RealLocationService] Position obtained: lat=${position.latitude}, lon=${position.longitude}');

      // 역지오코딩을 사용하여 정확한 주소 정보 가져오기
      String cityName = 'Current Location';
      String countryName = 'Unknown';
      
      try {
        print('[RealLocationService] Starting reverse geocoding...');
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          print('[RealLocationService] Placemark data: ${place.toString()}');
          
          // 도시명 우선순위: locality > subLocality > administrativeArea
          cityName = place.locality ?? 
                    place.subLocality ?? 
                    place.administrativeArea ?? 
                    'Current Location';
          
          // 국가명
          countryName = place.country ?? 'Unknown';
          
          // 한국의 경우 한국어로 표시
          if (countryName == 'South Korea' || countryName == '대한민국') {
            countryName = '대한민국';
            // 한국 주요 도시 한국어 표시
            if (cityName == 'Seoul' || cityName == '서울특별시') {
              cityName = '서울';
            } else if (cityName == 'Busan' || cityName == '부산광역시') {
              cityName = '부산';
            } else if (cityName == 'Daegu' || cityName == '대구광역시') {
              cityName = '대구';
            } else if (cityName == 'Incheon' || cityName == '인천광역시') {
              cityName = '인천';
            } else if (cityName == 'Gwangju' || cityName == '광주광역시') {
              cityName = '광주';
            } else if (cityName == 'Daejeon' || cityName == '대전광역시') {
              cityName = '대전';
            } else if (cityName == 'Ulsan' || cityName == '울산광역시') {
              cityName = '울산';
            } else if (cityName == 'Sejong' || cityName == '세종특별자치시') {
              cityName = '세종';
            }
          }
          
          print('[RealLocationService] Reverse geocoding result: $cityName, $countryName');
        } else {
          print('[RealLocationService] No placemarks found, using coordinates');
          cityName = 'Current Location';
          countryName = 'Unknown';
        }
      } catch (e) {
        print('[RealLocationService] Reverse geocoding failed: $e');
        // 역지오코딩 실패 시 좌표 기반으로 fallback
        cityName = 'Current Location';
        countryName = 'Unknown';
      }

      print('[RealLocationService] Final location: $cityName, $countryName');
      print('[RealLocationService] Coordinates: lat=${position.latitude}, lon=${position.longitude}');
      print('[RealLocationService] Accuracy: ${position.accuracy}m');
      print('[RealLocationService] Altitude: ${position.altitude}m');
      print('[RealLocationService] ===== LOCATION REQUEST SUCCESS =====');

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        city: cityName,
        country: countryName,
      );
    } catch (e) {
      print('[RealLocationService] ===== LOCATION REQUEST FAILED =====');
      print('[RealLocationService] Error getting location: $e');
      print('[RealLocationService] Error type: ${e.runtimeType}');
      print('[RealLocationService] Error stack: ${e.toString()}');
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

      // 역지오코딩을 사용하여 정확한 주소 정보 가져오기
      String cityName = 'Current Location';
      String countryName = 'Unknown';
      
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          
          // 도시명 우선순위: locality > subLocality > administrativeArea
          cityName = place.locality ?? 
                    place.subLocality ?? 
                    place.administrativeArea ?? 
                    'Current Location';
          
          // 국가명
          countryName = place.country ?? 'Unknown';
          
          // 한국의 경우 한국어로 표시
          if (countryName == 'South Korea' || countryName == '대한민국') {
            countryName = '대한민국';
            // 한국 주요 도시 한국어 표시
            if (cityName == 'Seoul' || cityName == '서울특별시') {
              cityName = '서울';
            } else if (cityName == 'Busan' || cityName == '부산광역시') {
              cityName = '부산';
            } else if (cityName == 'Daegu' || cityName == '대구광역시') {
              cityName = '대구';
            } else if (cityName == 'Incheon' || cityName == '인천광역시') {
              cityName = '인천';
            } else if (cityName == 'Gwangju' || cityName == '광주광역시') {
              cityName = '광주';
            } else if (cityName == 'Daejeon' || cityName == '대전광역시') {
              cityName = '대전';
            } else if (cityName == 'Ulsan' || cityName == '울산광역시') {
              cityName = '울산';
            } else if (cityName == 'Sejong' || cityName == '세종특별자치시') {
              cityName = '세종';
            }
          }
        }
      } catch (e) {
        print('[RealLocationService] Reverse geocoding failed in getLocationWithAccuracy: $e');
        cityName = 'Current Location';
        countryName = 'Unknown';
      }

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        city: cityName,
        country: countryName,
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

  @override
  Stream<Location> getLocationStream() async* {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // 10미터 이상 이동 시에만 업데이트
    );

    await for (final position in Geolocator.getPositionStream(locationSettings: locationSettings)) {
      // 역지오코딩을 사용하여 정확한 주소 정보 가져오기
      String cityName = 'Current Location';
      String countryName = 'Unknown';
      
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          
          // 도시명 우선순위: locality > subLocality > administrativeArea
          cityName = place.locality ?? 
                    place.subLocality ?? 
                    place.administrativeArea ?? 
                    'Current Location';
          
          // 국가명
          countryName = place.country ?? 'Unknown';
          
          // 한국의 경우 한국어로 표시
          if (countryName == 'South Korea' || countryName == '대한민국') {
            countryName = '대한민국';
            // 한국 주요 도시 한국어 표시
            if (cityName == 'Seoul' || cityName == '서울특별시') {
              cityName = '서울';
            } else if (cityName == 'Busan' || cityName == '부산광역시') {
              cityName = '부산';
            } else if (cityName == 'Daegu' || cityName == '대구광역시') {
              cityName = '대구';
            } else if (cityName == 'Incheon' || cityName == '인천광역시') {
              cityName = '인천';
            } else if (cityName == 'Gwangju' || cityName == '광주광역시') {
              cityName = '광주';
            } else if (cityName == 'Daejeon' || cityName == '대전광역시') {
              cityName = '대전';
            } else if (cityName == 'Ulsan' || cityName == '울산광역시') {
              cityName = '울산';
            } else if (cityName == 'Sejong' || cityName == '세종특별자치시') {
              cityName = '세종';
            }
          }
        }
      } catch (e) {
        print('[RealLocationService] Reverse geocoding failed in stream: $e');
        cityName = 'Current Location';
        countryName = 'Unknown';
      }

      yield Location(
        latitude: position.latitude,
        longitude: position.longitude,
        city: cityName,
        country: countryName,
      );
    }
  }

  @override
  bool hasLocationChanged(Location oldLocation, Location newLocation, {double thresholdMeters = 100}) {
    final distance = Geolocator.distanceBetween(
      oldLocation.latitude,
      oldLocation.longitude,
      newLocation.latitude,
      newLocation.longitude,
    );
    return distance > thresholdMeters;
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

