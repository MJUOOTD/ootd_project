import '../models/user_model.dart';

/// TemperatureSensitivity와 temperatureSensitivity 간의 변환을 담당하는 유틸리티 클래스
class TemperatureConverter {
  /// TemperatureSensitivity enum을 temperatureSensitivity double로 변환
  /// 
  /// 변환 규칙:
  /// - veryCold: 0.7 (매우 추위에 민감)
  /// - cold: 0.85 (추위에 민감)
  /// - normal: 1.0 (보통)
  /// - hot: 1.15 (더위에 민감)
  /// - veryHot: 1.3 (매우 더위에 민감)
  static double convertToTemperatureSensitivity(TemperatureSensitivity sensitivity) {
    switch (sensitivity) {
      case TemperatureSensitivity.veryCold:
        return 0.7;
      case TemperatureSensitivity.cold:
        return 0.85;
      case TemperatureSensitivity.normal:
        return 1.0;
      case TemperatureSensitivity.hot:
        return 1.15;
      case TemperatureSensitivity.veryHot:
        return 1.3;
    }
  }

  /// temperatureSensitivity double을 TemperatureSensitivity enum으로 변환
  static TemperatureSensitivity convertFromTemperatureSensitivity(double sensitivity) {
    if (sensitivity <= 0.75) {
      return TemperatureSensitivity.veryCold;
    } else if (sensitivity <= 0.9) {
      return TemperatureSensitivity.cold;
    } else if (sensitivity <= 1.1) {
      return TemperatureSensitivity.normal;
    } else if (sensitivity <= 1.25) {
      return TemperatureSensitivity.hot;
    } else {
      return TemperatureSensitivity.veryHot;
    }
  }

  /// UserModel의 다른 필드들을 TemperatureSettings에 맞게 변환
  static Map<String, dynamic> convertUserToTemperatureSettings(UserModel user) {
    return {
      'temperatureSensitivity': convertToTemperatureSensitivity(user.temperatureSensitivity),
      'coldTolerance': _convertActivityLevelToTolerance(user.activityLevel, 'cold'),
      'heatTolerance': _convertActivityLevelToTolerance(user.activityLevel, 'heat'),
      'age': user.age,
      'gender': _convertGender(user.gender),
      'activityLevel': _convertActivityLevel(user.activityLevel),
    };
  }

  /// 활동량을 추위/더위 감수성으로 변환
  static String _convertActivityLevelToTolerance(String activityLevel, String type) {
    switch (activityLevel) {
      case '낮음':
      case 'low':
        return 'low'; // 활동량이 낮으면 추위/더위에 민감
      case '보통':
      case 'moderate':
        return 'normal';
      case '높음':
      case 'high':
        return 'high'; // 활동량이 높으면 추위/더위에 강함
      default:
        return 'normal';
    }
  }

  /// 성별을 TemperatureSettings 형식으로 변환
  static String? _convertGender(String gender) {
    switch (gender) {
      case '남성':
        return 'male';
      case '여성':
        return 'female';
      case '기타':
        return 'other';
      default:
        return null;
    }
  }

  /// 활동량을 TemperatureSettings 형식으로 변환
  static String _convertActivityLevel(String activityLevel) {
    switch (activityLevel) {
      case '낮음':
        return 'low';
      case '보통':
        return 'moderate';
      case '높음':
        return 'high';
      default:
        return 'moderate';
    }
  }
}
