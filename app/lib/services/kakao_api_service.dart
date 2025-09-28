import 'dart:convert';
import 'package:http/http.dart' as http;
import 'network/base_url.dart';

/// 카카오 API를 사용한 장소 검색 서비스 (백엔드 API 사용)
class KakaoApiService {
  static String get _baseUrl => '${getDefaultBackendBaseUrl()}/api/kakao';

  /// 도시명으로 장소 검색
  static Future<List<PlaceInfo>> searchPlaces(String query) async {
    try {
      final uri = Uri.parse('$_baseUrl/search?query=${Uri.encodeComponent(query)}');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['data'] ?? [];
        
        return results.map((item) => PlaceInfo.fromJson(item)).toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception('Backend API error: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('[KakaoApiService] Error searching places: $e');
      rethrow;
    }
  }

  /// 좌표로 주소 검색 (역지오코딩)
  static Future<PlaceInfo?> getAddressFromCoordinates(double lat, double lon) async {
    try {
      final uri = Uri.parse('$_baseUrl/address?lat=$lat&lon=$lon');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic>? result = data['data'];
        
        if (result != null) {
          return PlaceInfo.fromJson(result);
        }
      }
      return null;
    } catch (e) {
      print('[KakaoApiService] Error getting address: $e');
      return null;
    }
  }
}

/// 장소 정보 클래스
class PlaceInfo {
  final String id;
  final String placeName;
  final String addressName;
  final String roadAddressName;
  final String categoryName;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? placeUrl;

  PlaceInfo({
    required this.id,
    required this.placeName,
    required this.addressName,
    required this.roadAddressName,
    required this.categoryName,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.placeUrl,
  });

  factory PlaceInfo.fromJson(Map<String, dynamic> json) {
    return PlaceInfo(
      id: json['id'] ?? '',
      placeName: json['place_name'] ?? '',
      addressName: json['address_name'] ?? '',
      roadAddressName: json['road_address_name'] ?? '',
      categoryName: json['category_name'] ?? '',
      latitude: double.tryParse(json['y'] ?? '0') ?? 0.0,
      longitude: double.tryParse(json['x'] ?? '0') ?? 0.0,
      phone: json['phone'],
      placeUrl: json['place_url'],
    );
  }

  factory PlaceInfo.fromCoordJson(Map<String, dynamic> json, double lat, double lon) {
    return PlaceInfo(
      id: '',
      placeName: json['address']['address_name'] ?? '',
      addressName: json['address']['address_name'] ?? '',
      roadAddressName: json['road_address']['address_name'] ?? '',
      categoryName: '',
      latitude: lat,
      longitude: lon,
    );
  }

  /// 도시명만 추출 (시/도 단위)
  String get cityName {
    final parts = addressName.split(' ');
    if (parts.length >= 2) {
      return parts[1]; // 시/도
    }
    return placeName;
  }

  /// 구/군명 추출
  String get districtName {
    final parts = addressName.split(' ');
    if (parts.length >= 3) {
      return parts[2]; // 구/군
    }
    return '';
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeName': placeName,
      'addressName': addressName,
      'roadAddressName': roadAddressName,
      'categoryName': categoryName,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'placeUrl': placeUrl,
    };
  }

  @override
  String toString() {
    return '$placeName ($addressName)';
  }
}
