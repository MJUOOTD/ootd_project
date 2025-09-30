import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import '../../../models/weather_model.dart';
import '../kakao_api_service.dart';

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
      print('[RealLocationService] Initial permission status: $permissionStatus');
      
      if (permissionStatus == LocationPermissionStatus.denied) {
        print('[RealLocationService] Requesting permission...');
        bool granted = await requestPermission();
        print('[RealLocationService] Permission granted: $granted');
        
        // 권한 요청 후 상태를 다시 확인
        permissionStatus = await checkPermissionStatus();
        print('[RealLocationService] Permission status after request: $permissionStatus');
        
        if (permissionStatus == LocationPermissionStatus.denied) {
          throw LocationException(
            'Location permission denied. Please grant location permission.',
            LocationErrorType.permissionDenied,
          );
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

      // 최종 권한 상태 확인
      if (permissionStatus != LocationPermissionStatus.granted) {
        print('[RealLocationService] Permission not granted, current status: $permissionStatus');
        throw LocationException(
          'Location permission not granted. Current status: $permissionStatus',
          LocationErrorType.permissionDenied,
        );
      }

      // Get current position with high accuracy and validation
      print('[RealLocationService] Getting current position with accuracy validation...');
      final position = await _getAccuratePosition();

      print('[RealLocationService] Position obtained: lat=${position.latitude}, lon=${position.longitude}');

      // 역지오코딩을 사용하여 정확한 주소 정보 가져오기
      String cityName = 'Current Location';
      String countryName = 'Unknown';
      String? district;
      String? subLocality;
      String? province;
      List<Placemark> placemarks = [];
      
      // 1. 백엔드 Kakao API를 사용한 역지오코딩 시도 (더 정확함)
      try {
        print('[RealLocationService] Starting backend Kakao API reverse geocoding...');
        final kakaoResult = await KakaoApiService.getAddressFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        if (kakaoResult != null) {
          print('[RealLocationService] ===== BACKEND KAKAO API RESULT =====');
          print('[RealLocationService] Coordinates: lat=${position.latitude}, lon=${position.longitude}');
          print('[RealLocationService] - placeName: "${kakaoResult.placeName}"');
          print('[RealLocationService] - addressName: "${kakaoResult.addressName}"');
          print('[RealLocationService] - cityName: "${kakaoResult.cityName}"');
          print('[RealLocationService] - districtName: "${kakaoResult.districtName}"');
          print('[RealLocationService] - roadAddressName: "${kakaoResult.roadAddressName}"');
          
          // 백엔드에서 이미 처리된 데이터를 우선 사용
          // placeName이 더 정확한 도시명일 가능성이 높음
          String primaryCityName = kakaoResult.placeName.isNotEmpty ? kakaoResult.placeName : kakaoResult.cityName;
          
          print('[RealLocationService] Selected primary city name: "$primaryCityName"');
          
          // Kakao API 결과에서 위치 정보 추출 및 유효성 검증
          if (_isValidLocationData(primaryCityName, kakaoResult.addressName)) {
            cityName = primaryCityName;
            district = kakaoResult.districtName.isNotEmpty ? kakaoResult.districtName : null;
            countryName = '대한민국'; // Kakao API는 한국 내에서만 사용
            print('[RealLocationService] ✅ Valid backend Kakao API location data found: $cityName');
          } else {
            print('[RealLocationService] ❌ Invalid backend Kakao API location data, using fallback');
            throw Exception('Invalid location data from backend Kakao API');
          }
          
          print('[RealLocationService] Final result: $cityName, $countryName');
          print('[RealLocationService] ======================================');
        } else {
          print('[RealLocationService] Backend Kakao API returned null, trying geocoding package...');
          throw Exception('Backend Kakao API returned null');
        }
      } catch (e) {
        print('[RealLocationService] Backend Kakao API failed: $e, trying geocoding package...');
        
        // 2. Kakao API 실패 시 geocoding 패키지 사용 (fallback)
        try {
          print('[RealLocationService] Starting geocoding package reverse geocoding...');
          placemarks = await placemarkFromCoordinates(
            position.latitude, 
            position.longitude
          );
          
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks.first;
            print('[RealLocationService] Placemark data: ${place.toString()}');
            print('[RealLocationService] - locality: "${place.locality}"');
            print('[RealLocationService] - subLocality: "${place.subLocality}"');
            print('[RealLocationService] - administrativeArea: "${place.administrativeArea}"');
            print('[RealLocationService] - country: "${place.country}"');
            print('[RealLocationService] - name: "${place.name}"');
            print('[RealLocationService] - thoroughfare: "${place.thoroughfare}"');
            
            // 도시명 우선순위: administrativeArea > subLocality > locality (globe 문제 해결)
            // "globe"나 부정확한 값들을 필터링
            String? tempCityName;
            if (place.administrativeArea != null && 
                place.administrativeArea!.isNotEmpty && 
                place.administrativeArea != 'globe' &&
                place.administrativeArea != 'Unknown') {
              tempCityName = place.administrativeArea;
            } else if (place.subLocality != null && 
                       place.subLocality!.isNotEmpty && 
                       place.subLocality != 'globe' &&
                       place.subLocality != 'Unknown') {
              tempCityName = place.subLocality;
            } else if (place.locality != null && 
                       place.locality!.isNotEmpty && 
                       place.locality != 'globe' &&
                       place.locality != 'Unknown') {
              tempCityName = place.locality;
            }
            
            cityName = tempCityName ?? 'Current Location';
            district = place.subLocality;
            subLocality = place.thoroughfare;
            province = place.administrativeArea;
            
            // 국가명
            countryName = place.country ?? 'Unknown';
            
            // 국가명 설정
            if (countryName == 'South Korea' || countryName == '대한민국') {
              countryName = '대한민국';
            }
            
            print('[RealLocationService] Geocoding package result: $cityName, $countryName');
          } else {
            print('[RealLocationService] No placemarks found, using coordinates');
            cityName = 'Current Location';
            countryName = 'Unknown';
          }
        } catch (e) {
          print('[RealLocationService] Geocoding package also failed: $e');
          // 모든 역지오코딩 실패 시 좌표 기반으로 fallback
          cityName = 'Current Location';
          countryName = 'Unknown';
        }
      }

      print('[RealLocationService] Final location: $cityName, $countryName');
      print('[RealLocationService] District: $district, SubLocality: $subLocality, Province: $province');
      print('[RealLocationService] Coordinates: lat=${position.latitude}, lon=${position.longitude}');
      print('[RealLocationService] Accuracy: ${position.accuracy}m');
      print('[RealLocationService] Altitude: ${position.altitude}m');
      print('[RealLocationService] ===== LOCATION REQUEST SUCCESS =====');

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        city: cityName,
        country: countryName,
        district: district,
        subLocality: subLocality,
        province: province,
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
      print('[RealLocationService] Initial permission status (accuracy): $permissionStatus');
      
      if (permissionStatus == LocationPermissionStatus.denied) {
        print('[RealLocationService] Requesting permission (accuracy)...');
        bool granted = await requestPermission();
        print('[RealLocationService] Permission granted (accuracy): $granted');
        
        // 권한 요청 후 상태를 다시 확인
        permissionStatus = await checkPermissionStatus();
        print('[RealLocationService] Permission status after request (accuracy): $permissionStatus');
        
        if (permissionStatus == LocationPermissionStatus.denied) {
          throw LocationException(
            'Location permission denied. Please grant location permission.',
            LocationErrorType.permissionDenied,
          );
        }
      }

      if (permissionStatus == LocationPermissionStatus.deniedForever) {
        print('[RealLocationService] Permission permanently denied (accuracy), opening settings...');
        await openLocationSettings();
        throw LocationException(
          'Location permission permanently denied. Please enable in settings.',
          LocationErrorType.permissionDenied,
        );
      }

      // 최종 권한 상태 확인
      if (permissionStatus != LocationPermissionStatus.granted) {
        print('[RealLocationService] Permission not granted (accuracy), current status: $permissionStatus');
        throw LocationException(
          'Location permission not granted. Current status: $permissionStatus',
          LocationErrorType.permissionDenied,
        );
      }

      // Get current position with specific accuracy and validation
      print('[RealLocationService] Getting current position with accuracy validation (accuracy method)...');
      final position = await _getAccuratePosition();

      // 역지오코딩을 사용하여 정확한 주소 정보 가져오기
      String cityName = 'Current Location';
      String countryName = 'Unknown';
      String? district;
      String? subLocality;
      String? province;
      List<Placemark> placemarks = [];
      
      // 1. Kakao API를 사용한 역지오코딩 시도 (더 정확함)
      try {
        print('[RealLocationService] Starting Kakao API reverse geocoding (accuracy)...');
        final kakaoResult = await KakaoApiService.getAddressFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        if (kakaoResult != null) {
          print('[RealLocationService] Kakao API result (accuracy): ${kakaoResult.toString()}');
          print('[RealLocationService] - placeName: "${kakaoResult.placeName}"');
          print('[RealLocationService] - addressName: "${kakaoResult.addressName}"');
          print('[RealLocationService] - cityName: "${kakaoResult.cityName}"');
          print('[RealLocationService] - districtName: "${kakaoResult.districtName}"');
          
          // Kakao API 결과에서 위치 정보 추출 및 유효성 검증
          if (_isValidLocationData(kakaoResult.cityName, kakaoResult.addressName)) {
            cityName = kakaoResult.cityName;
            district = kakaoResult.districtName.isNotEmpty ? kakaoResult.districtName : null;
            countryName = '대한민국'; // Kakao API는 한국 내에서만 사용
            print('[RealLocationService] Valid Kakao API location data found (accuracy)');
          } else {
            print('[RealLocationService] Invalid Kakao API location data (accuracy), using fallback');
            throw Exception('Invalid location data from Kakao API');
          }
          
          // 백엔드에서 이미 처리된 도시명을 그대로 사용
          
          print('[RealLocationService] Kakao API reverse geocoding result (accuracy): $cityName, $countryName');
        } else {
          print('[RealLocationService] Kakao API returned null (accuracy), trying geocoding package...');
          throw Exception('Kakao API returned null');
        }
      } catch (e) {
        print('[RealLocationService] Kakao API failed (accuracy): $e, trying geocoding package...');
        
        // 2. Kakao API 실패 시 geocoding 패키지 사용 (fallback)
        try {
          print('[RealLocationService] Starting geocoding package reverse geocoding (accuracy)...');
          placemarks = await placemarkFromCoordinates(
            position.latitude, 
            position.longitude
          );
          
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks.first;
            print('[RealLocationService] Placemark data (accuracy): ${place.toString()}');
            print('[RealLocationService] - locality: "${place.locality}"');
            print('[RealLocationService] - subLocality: "${place.subLocality}"');
            print('[RealLocationService] - administrativeArea: "${place.administrativeArea}"');
            print('[RealLocationService] - country: "${place.country}"');
            
            // 도시명 우선순위: administrativeArea > subLocality > locality (globe 문제 해결)
            // "globe"나 부정확한 값들을 필터링
            String? tempCityName;
            if (place.administrativeArea != null && 
                place.administrativeArea!.isNotEmpty && 
                place.administrativeArea != 'globe' &&
                place.administrativeArea != 'Unknown') {
              tempCityName = place.administrativeArea;
            } else if (place.subLocality != null && 
                       place.subLocality!.isNotEmpty && 
                       place.subLocality != 'globe' &&
                       place.subLocality != 'Unknown') {
              tempCityName = place.subLocality;
            } else if (place.locality != null && 
                       place.locality!.isNotEmpty && 
                       place.locality != 'globe' &&
                       place.locality != 'Unknown') {
              tempCityName = place.locality;
            }
            
            cityName = tempCityName ?? 'Current Location';
            district = place.subLocality;
            subLocality = place.thoroughfare;
            province = place.administrativeArea;
            
            // 국가명
            countryName = place.country ?? 'Unknown';
            
            // 국가명 설정
            if (countryName == 'South Korea' || countryName == '대한민국') {
              countryName = '대한민국';
            }
            
            print('[RealLocationService] Geocoding package result (accuracy): $cityName, $countryName');
          } else {
            print('[RealLocationService] No placemarks found (accuracy), using coordinates');
            cityName = 'Current Location';
            countryName = 'Unknown';
          }
        } catch (e) {
          print('[RealLocationService] Geocoding package also failed (accuracy): $e');
          // 모든 역지오코딩 실패 시 좌표 기반으로 fallback
          cityName = 'Current Location';
          countryName = 'Unknown';
        }
      }

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        city: cityName,
        country: countryName,
        district: district,
        subLocality: subLocality,
        province: province,
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

  // 정확한 위치 정보를 얻기 위한 메서드 (여러 번 시도 및 정확도 검증)
  Future<Position> _getAccuratePosition() async {
    const int maxAttempts = 3;
    const double minAccuracy = 100.0; // 최소 정확도 (미터)
    const Duration timeout = Duration(seconds: 15);
    
    Position? bestPosition;
    double bestAccuracy = double.infinity;
    
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      print('[RealLocationService] GPS attempt $attempt/$maxAttempts');
      
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: timeout,
          forceAndroidLocationManager: false,
        );
        
        print('[RealLocationService] Attempt $attempt: lat=${position.latitude}, lon=${position.longitude}, accuracy=${position.accuracy}m');
        
        // 정확도가 개선되었는지 확인
        if (position.accuracy < bestAccuracy) {
          bestPosition = position;
          bestAccuracy = position.accuracy;
          print('[RealLocationService] Better accuracy found: ${position.accuracy}m');
        }
        
        // 충분한 정확도를 얻었으면 즉시 반환
        if (position.accuracy <= minAccuracy) {
          print('[RealLocationService] Sufficient accuracy achieved: ${position.accuracy}m');
          return position;
        }
        
        // 마지막 시도가 아니면 잠시 대기
        if (attempt < maxAttempts) {
          print('[RealLocationService] Waiting before next attempt...');
          await Future.delayed(const Duration(seconds: 2));
        }
        
      } catch (e) {
        print('[RealLocationService] GPS attempt $attempt failed: $e');
        if (attempt == maxAttempts) {
          rethrow;
        }
      }
    }
    
    // 최선의 위치 반환 (정확도가 부족해도)
    if (bestPosition != null) {
      print('[RealLocationService] Using best available position: accuracy=${bestPosition.accuracy}m');
      return bestPosition;
    }
    
    throw LocationException(
      'Failed to get accurate location after $maxAttempts attempts',
      LocationErrorType.timeout,
    );
  }

  // 위치 데이터 유효성 검증
  bool _isValidLocationData(String cityName, String addressName) {
    // 빈 값 체크
    if (cityName.isEmpty || addressName.isEmpty) {
      return false;
    }
    
    // 부정확한 값들 필터링
    final invalidValues = [
      'Unknown', 'Unknown Location', 'Unknown Address', 
      'globe', 'Current Location', 'N/A', 'null'
    ];
    
    if (invalidValues.contains(cityName) || invalidValues.contains(addressName)) {
      return false;
    }
    
    // 한국 주소 패턴 검증 (시/도, 구/군 형태)
    final addressParts = addressName.split(' ');
    if (addressParts.length < 2) {
      return false;
    }
    
    // 기본 한국 지역 키워드 (백엔드에서 더 정확한 검증 수행)
    final koreanKeywords = ['시', '도', '특별시', '광역시', '자치시', '자치도'];
    
    // 첫 번째 부분이 한국의 시/도인지 확인 (키워드 기반)
    final firstPart = addressParts[0];
    if (!koreanKeywords.any((keyword) => firstPart.contains(keyword))) {
      return false;
    }
    
    return true;
  }
}

