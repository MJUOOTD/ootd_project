/// 사용자 온도 설정 모델
class TemperatureSettings {
  final double temperatureSensitivity; // 0.7 ~ 1.3
  final String coldTolerance; // 'low', 'normal', 'high'
  final String heatTolerance; // 'low', 'normal', 'high'
  final int? age; // null이면 보정 안함
  final String? gender; // 'male', 'female', 'other', null
  final String activityLevel; // 'low', 'moderate', 'high'
  final DateTime createdAt;
  final DateTime updatedAt;

  const TemperatureSettings({
    this.temperatureSensitivity = 1.0,
    this.coldTolerance = 'normal',
    this.heatTolerance = 'normal',
    this.age,
    this.gender,
    this.activityLevel = 'moderate',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore에서 데이터를 가져와서 객체 생성
  factory TemperatureSettings.fromFirestore(Map<String, dynamic> data) {
    return TemperatureSettings(
      temperatureSensitivity: (data['temperatureSensitivity'] ?? 1.0).toDouble(),
      coldTolerance: data['coldTolerance'] ?? 'normal',
      heatTolerance: data['heatTolerance'] ?? 'normal',
      age: data['age'],
      gender: data['gender'],
      activityLevel: data['activityLevel'] ?? 'moderate',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore에 저장할 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'temperatureSensitivity': temperatureSensitivity,
      'coldTolerance': coldTolerance,
      'heatTolerance': heatTolerance,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// JSON에서 객체 생성
  factory TemperatureSettings.fromJson(Map<String, dynamic> json) {
    return TemperatureSettings(
      temperatureSensitivity: (json['temperatureSensitivity'] ?? 1.0).toDouble(),
      coldTolerance: json['coldTolerance'] ?? 'normal',
      heatTolerance: json['heatTolerance'] ?? 'normal',
      age: json['age'],
      gender: json['gender'],
      activityLevel: json['activityLevel'] ?? 'moderate',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// DateTime 파싱 헬퍼 메서드
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    if (dateValue is DateTime) {
      return dateValue;
    }
    
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        print('[TemperatureSettings] DateTime parse error: $e');
        return DateTime.now();
      }
    }
    
    // Firestore Timestamp 객체인 경우
    if (dateValue is Map && dateValue.containsKey('_seconds')) {
      try {
        final seconds = dateValue['_seconds'] as int;
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      } catch (e) {
        print('[TemperatureSettings] Firestore timestamp parse error: $e');
        return DateTime.now();
      }
    }
    
    print('[TemperatureSettings] Unknown date format: $dateValue');
    return DateTime.now();
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'temperatureSensitivity': temperatureSensitivity,
      'coldTolerance': coldTolerance,
      'heatTolerance': heatTolerance,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 설정 복사 (일부 필드만 변경)
  TemperatureSettings copyWith({
    double? temperatureSensitivity,
    String? coldTolerance,
    String? heatTolerance,
    int? age,
    String? gender,
    String? activityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TemperatureSettings(
      temperatureSensitivity: temperatureSensitivity ?? this.temperatureSensitivity,
      coldTolerance: coldTolerance ?? this.coldTolerance,
      heatTolerance: heatTolerance ?? this.heatTolerance,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 기본 설정으로 초기화
  factory TemperatureSettings.defaultSettings() {
    final now = DateTime.now();
    return TemperatureSettings(
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 설정 유효성 검사
  ValidationResult validate() {
    final errors = <String>[];

    // 온도 감도 검사
    if (temperatureSensitivity < 0.7 || temperatureSensitivity > 1.3) {
      errors.add('온도 감도는 0.7 ~ 1.3 사이여야 합니다.');
    }

    // 추위/더위 감수성 검사
    const validTolerances = ['low', 'normal', 'high'];
    if (!validTolerances.contains(coldTolerance)) {
      errors.add('추위 감수성은 low, normal, high 중 하나여야 합니다.');
    }
    if (!validTolerances.contains(heatTolerance)) {
      errors.add('더위 감수성은 low, normal, high 중 하나여야 합니다.');
    }

    // 나이 검사
    if (age != null && (age! < 0 || age! > 120)) {
      errors.add('나이는 0 ~ 120 사이여야 합니다.');
    }

    // 성별 검사
    const validGenders = ['male', 'female', 'other', null];
    if (!validGenders.contains(gender)) {
      errors.add('성별은 male, female, other, null 중 하나여야 합니다.');
    }

    // 활동량 검사
    const validActivityLevels = ['low', 'moderate', 'high'];
    if (!validActivityLevels.contains(activityLevel)) {
      errors.add('활동량은 low, moderate, high 중 하나여야 합니다.');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  @override
  String toString() {
    return 'TemperatureSettings('
        'sensitivity: $temperatureSensitivity, '
        'coldTolerance: $coldTolerance, '
        'heatTolerance: $heatTolerance, '
        'age: $age, '
        'gender: $gender, '
        'activityLevel: $activityLevel'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TemperatureSettings &&
        other.temperatureSensitivity == temperatureSensitivity &&
        other.coldTolerance == coldTolerance &&
        other.heatTolerance == heatTolerance &&
        other.age == age &&
        other.gender == gender &&
        other.activityLevel == activityLevel;
  }

  @override
  int get hashCode {
    return Object.hash(
      temperatureSensitivity,
      coldTolerance,
      heatTolerance,
      age,
      gender,
      activityLevel,
    );
  }
}

/// 유효성 검사 결과
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errors: $errors)';
  }
}

/// 개인화 보정 계산을 위한 헬퍼 클래스
class PersonalizationCalculator {
  /// 나이별 보정값 계산
  static double getAgeAdjustment(int? age) {
    if (age == null) return 0;
    
    if (age > 65) return 1.5;  // 노년층은 더 춥게 느낌
    if (age < 25) return -1.0; // 젊은층은 덜 춥게 느낌
    return 0;
  }

  /// 성별 보정값 계산
  static double getGenderAdjustment(String? gender) {
    if (gender == null) return 0;
    
    switch (gender) {
      case 'female': return 0.8;  // 여성은 더 춥게 느낌
      case 'male': return 0;
      case 'other': return 0.4;   // 중간값
      default: return 0;
    }
  }

  /// 활동량별 보정값 계산
  static double getActivityAdjustment(String activityLevel) {
    switch (activityLevel) {
      case 'low': return 1.5;     // 활동량 적으면 더 춥게 느낌
      case 'moderate': return 0;
      case 'high': return -2.0;   // 활동량 많으면 덜 춥게 느낌
      default: return 0;
    }
  }

  /// 추위/더위 감수성별 보정값 계산
  static double getToleranceAdjustment(
    String coldTolerance,
    String heatTolerance,
    double temperature,
  ) {
    double adjustment = 0;
    
    // 추위 감수성 (저온에서)
    if (temperature < 15) {
      switch (coldTolerance) {
        case 'low': adjustment += 2.0;    // 추위에 민감
        case 'normal': adjustment += 0;
        case 'high': adjustment -= 1.0;   // 추위에 강함
      }
    }
    
    // 더위 감수성 (고온에서)
    if (temperature > 25) {
      switch (heatTolerance) {
        case 'low': adjustment += 1.5;    // 더위에 민감
        case 'normal': adjustment += 0;
        case 'high': adjustment -= 1.0;   // 더위에 강함
      }
    }
    
    return adjustment;
  }

  /// 전체 개인화 보정값 계산
  static double calculatePersonalAdjustment(
    TemperatureSettings settings,
    double temperature,
  ) {
    final ageAdj = getAgeAdjustment(settings.age);
    final genderAdj = getGenderAdjustment(settings.gender);
    final activityAdj = getActivityAdjustment(settings.activityLevel);
    final toleranceAdj = getToleranceAdjustment(
      settings.coldTolerance,
      settings.heatTolerance,
      temperature,
    );
    
    return ageAdj + genderAdj + activityAdj + toleranceAdj;
  }
}
