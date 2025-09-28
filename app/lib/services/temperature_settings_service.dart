import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/temperature_settings_model.dart';
import 'service_locator.dart';

/// 온도 설정 API 서비스
class TemperatureSettingsService {
  static const String _baseUrl = 'http://localhost:4000/api/temperature-settings';
  
  /// HTTP 헤더 생성 (Firebase ID 토큰 포함)
  Future<Map<String, String>> _getHeaders() async {
    try {
      final authService = serviceLocator.authService;
      
      if (authService == null) {
        throw Exception('AuthService가 초기화되지 않았습니다. 앱을 재시작해주세요.');
      }
      
      if (!authService.isLoggedIn) {
        throw Exception('사용자가 로그인되어 있지 않습니다. 먼저 로그인해주세요.');
      }
      
      final token = await authService.getIdToken();
      
      if (token == null) {
        throw Exception('Firebase 인증 토큰을 가져올 수 없습니다. 로그인 상태를 확인해주세요.');
      }
      
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      rethrow;
    }
  }

  /// 사용자 온도 설정 조회
  Future<TemperatureSettings> getTemperatureSettings() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TemperatureSettings.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
      } else {
        throw Exception('온도 설정을 가져오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('온도 설정 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자 온도 설정 생성 (초기화)
  Future<TemperatureSettings> createTemperatureSettings(
    TemperatureSettings settings,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: json.encode(settings.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return TemperatureSettings.fromJson(data);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception('잘못된 입력 데이터: ${errorData['message']}');
      } else if (response.statusCode == 401) {
        throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
      } else {
        throw Exception('온도 설정 생성에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('온도 설정 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자 온도 설정 업데이트
  Future<TemperatureSettings> updateTemperatureSettings(
    TemperatureSettings settings,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(_baseUrl),
        headers: headers,
        body: json.encode(settings.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TemperatureSettings.fromJson(data);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception('잘못된 입력 데이터: ${errorData['message']}');
      } else if (response.statusCode == 401) {
        throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
      } else {
        throw Exception('온도 설정 업데이트에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('온도 설정 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자 온도 설정 삭제
  Future<void> deleteTemperatureSettings() async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse(_baseUrl),
        headers: headers,
      );

      if (response.statusCode == 204) {
        return; // 성공
      } else if (response.statusCode == 401) {
        throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
      } else {
        throw Exception('온도 설정 삭제에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('온도 설정 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 기본 설정으로 초기화
  Future<TemperatureSettings> initializeDefaultSettings() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/initialize'),
        headers: headers,
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return TemperatureSettings.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
      } else {
        throw Exception('기본 설정 초기화에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('기본 설정 초기화 중 오류가 발생했습니다: $e');
    }
  }

  /// 온도 설정이 존재하는지 확인
  Future<bool> hasTemperatureSettings() async {
    try {
      await getTemperatureSettings();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 개인화된 체감온도 계산
  double calculatePersonalizedFeelsLike(
    double baseFeelsLike,
    TemperatureSettings settings,
  ) {
    // 기본 체감온도에 개인화 보정 적용
    final personalAdjustment = PersonalizationCalculator.calculatePersonalAdjustment(
      settings,
      baseFeelsLike,
    );
    
    return baseFeelsLike + personalAdjustment;
  }
}
