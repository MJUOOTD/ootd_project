/**
 * 사용자별 온도 설정 데이터 모델
 * Firestore: users/{userId}/temperatureSettings/main
 */

export class TemperatureSettings {
  constructor({
    temperatureSensitivity = 1.0,  // 0.7 ~ 1.3 (기본값: 1.0)
    coldTolerance = 'normal',      // 'low', 'normal', 'high'
    heatTolerance = 'normal',      // 'low', 'normal', 'high'
    age = null,                    // 나이 (null이면 보정 안함)
    gender = null,                 // 'male', 'female', 'other', null
    activityLevel = 'moderate',    // 'low', 'moderate', 'high'
    createdAt = new Date(),
    updatedAt = new Date()
  } = {}) {
    this.temperatureSensitivity = temperatureSensitivity;
    this.coldTolerance = coldTolerance;
    this.heatTolerance = heatTolerance;
    this.age = age;
    this.gender = gender;
    this.activityLevel = activityLevel;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }

  /**
   * Firestore에서 데이터를 가져와서 객체 생성
   */
  static fromFirestore(data) {
    if (!data) return null;
    
    return new TemperatureSettings({
      temperatureSensitivity: data.temperatureSensitivity || 1.0,
      coldTolerance: data.coldTolerance || 'normal',
      heatTolerance: data.heatTolerance || 'normal',
      age: data.age || null,
      gender: data.gender || null,
      activityLevel: data.activityLevel || 'moderate',
      createdAt: data.createdAt || new Date(),
      updatedAt: data.updatedAt || new Date()
    });
  }

  /**
   * Firestore에 저장할 데이터로 변환
   */
  toFirestore() {
    return {
      temperatureSensitivity: this.temperatureSensitivity,
      coldTolerance: this.coldTolerance,
      heatTolerance: this.heatTolerance,
      age: this.age,
      gender: this.gender,
      activityLevel: this.activityLevel,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt
    };
  }

  /**
   * 설정 유효성 검사
   */
  validate() {
    const errors = [];

    // 온도 감도 검사
    if (this.temperatureSensitivity < 0.7 || this.temperatureSensitivity > 1.3) {
      errors.push('온도 감도는 0.7 ~ 1.3 사이여야 합니다.');
    }

    // 추위/더위 감수성 검사
    const validTolerances = ['low', 'normal', 'high'];
    if (!validTolerances.includes(this.coldTolerance)) {
      errors.push('추위 감수성은 low, normal, high 중 하나여야 합니다.');
    }
    if (!validTolerances.includes(this.heatTolerance)) {
      errors.push('더위 감수성은 low, normal, high 중 하나여야 합니다.');
    }

    // 나이 검사
    if (this.age !== null && (this.age < 0 || this.age > 120)) {
      errors.push('나이는 0 ~ 120 사이여야 합니다.');
    }

    // 성별 검사
    const validGenders = ['male', 'female', 'other', null];
    if (!validGenders.includes(this.gender)) {
      errors.push('성별은 male, female, other, null 중 하나여야 합니다.');
    }

    // 활동량 검사
    const validActivityLevels = ['low', 'moderate', 'high'];
    if (!validActivityLevels.includes(this.activityLevel)) {
      errors.push('활동량은 low, moderate, high 중 하나여야 합니다.');
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }

  /**
   * 기본 설정으로 초기화
   */
  static getDefault() {
    return new TemperatureSettings();
  }

  /**
   * JSON 직렬화를 위한 메서드
   */
  toJSON() {
    return {
      temperatureSensitivity: this.temperatureSensitivity,
      coldTolerance: this.coldTolerance,
      heatTolerance: this.heatTolerance,
      age: this.age,
      gender: this.gender,
      activityLevel: this.activityLevel,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt
    };
  }
}

/**
 * 개인화 보정 계산을 위한 헬퍼 함수들
 */
export class PersonalizationCalculator {
  /**
   * 나이별 보정값 계산
   */
  static getAgeAdjustment(age) {
    if (!age) return 0;
    
    if (age > 65) return 1.5;  // 노년층은 더 춥게 느낌
    if (age < 25) return -1.0; // 젊은층은 덜 춥게 느낌
    return 0;
  }

  /**
   * 성별 보정값 계산
   */
  static getGenderAdjustment(gender) {
    if (!gender) return 0;
    
    switch (gender) {
      case 'female': return 0.8;  // 여성은 더 춥게 느낌
      case 'male': return 0;
      case 'other': return 0.4;   // 중간값
      default: return 0;
    }
  }

  /**
   * 활동량별 보정값 계산
   */
  static getActivityAdjustment(activityLevel) {
    switch (activityLevel) {
      case 'low': return 1.5;     // 활동량 적으면 더 춥게 느낌
      case 'moderate': return 0;
      case 'high': return -2.0;   // 활동량 많으면 덜 춥게 느낌
      default: return 0;
    }
  }

  /**
   * 추위/더위 감수성별 보정값 계산
   */
  static getToleranceAdjustment(coldTolerance, heatTolerance, temperature) {
    let adjustment = 0;
    
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

  /**
   * 전체 개인화 보정값 계산
   */
  static calculatePersonalAdjustment(settings, temperature) {
    const ageAdj = this.getAgeAdjustment(settings.age);
    const genderAdj = this.getGenderAdjustment(settings.gender);
    const activityAdj = this.getActivityAdjustment(settings.activityLevel);
    const toleranceAdj = this.getToleranceAdjustment(
      settings.coldTolerance, 
      settings.heatTolerance, 
      temperature
    );
    
    return ageAdj + genderAdj + activityAdj + toleranceAdj;
  }
}
