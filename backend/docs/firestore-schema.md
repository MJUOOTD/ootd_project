# Firestore 데이터베이스 스키마

## 📊 컬렉션 구조

### 1. 사용자 온도 설정
```
users/{userId}/temperatureSettings/main
```

#### 필드 설명
| 필드명 | 타입 | 범위/옵션 | 설명 |
|--------|------|-----------|------|
| `temperatureSensitivity` | number | 0.7 ~ 1.3 | 온도 감도 계수 (기본값: 1.0) |
| `coldTolerance` | string | 'low', 'normal', 'high' | 추위 감수성 (기본값: 'normal') |
| `heatTolerance` | string | 'low', 'normal', 'high' | 더위 감수성 (기본값: 'normal') |
| `age` | number | 0 ~ 120, null | 나이 (null이면 보정 안함) |
| `gender` | string | 'male', 'female', 'other', null | 성별 (null이면 보정 안함) |
| `activityLevel` | string | 'low', 'moderate', 'high' | 활동량 (기본값: 'moderate') |
| `createdAt` | timestamp | - | 생성일시 |
| `updatedAt` | timestamp | - | 수정일시 |

#### 예시 데이터
```json
{
  "temperatureSensitivity": 1.2,
  "coldTolerance": "low",
  "heatTolerance": "normal",
  "age": 30,
  "gender": "female",
  "activityLevel": "moderate",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

## 🔒 보안 규칙

### Firestore 보안 규칙
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자별 온도 설정 - 본인만 접근 가능
    match /users/{userId}/temperatureSettings/{document} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 📈 개인화 보정값 계산

### 나이별 보정
- **65세 이상**: +1.5°C (더 춥게 느낌)
- **25세 미만**: -1.0°C (덜 춥게 느낌)
- **25-65세**: 0°C (보정 없음)

### 성별별 보정
- **여성**: +0.8°C (더 춥게 느낌)
- **남성**: 0°C (보정 없음)
- **기타**: +0.4°C (중간값)

### 활동량별 보정
- **낮음**: +1.5°C (더 춥게 느낌)
- **보통**: 0°C (보정 없음)
- **높음**: -2.0°C (덜 춥게 느낌)

### 추위/더위 감수성별 보정
#### 추위 감수성 (기온 < 15°C)
- **낮음**: +2.0°C (추위에 민감)
- **보통**: 0°C (보정 없음)
- **높음**: -1.0°C (추위에 강함)

#### 더위 감수성 (기온 > 25°C)
- **낮음**: +1.5°C (더위에 민감)
- **보통**: 0°C (보정 없음)
- **높음**: -1.0°C (더위에 강함)

## 🧮 최종 체감온도 계산 공식

```
최종 체감온도 = (기상청 표준 체감온도 × 온도 감도 계수) + 개인화 보정값

개인화 보정값 = 나이보정 + 성별보정 + 활동량보정 + 감수성보정
```

## 📝 사용 예시

### 1. 설정 저장
```javascript
const settings = new TemperatureSettings({
  temperatureSensitivity: 1.1,
  coldTolerance: 'low',
  age: 28,
  gender: 'female',
  activityLevel: 'moderate'
});

await db.collection('users')
  .doc(userId)
  .collection('temperatureSettings')
  .doc('main')
  .set(settings.toFirestore());
```

### 2. 설정 조회
```javascript
const doc = await db.collection('users')
  .doc(userId)
  .collection('temperatureSettings')
  .doc('main')
  .get();

const settings = TemperatureSettings.fromFirestore(doc);
```

### 3. 개인화 체감온도 계산
```javascript
const baseFeelsLike = calculateKMAFeelsLike(temperature, humidity, windSpeed);
const personalAdjustment = PersonalizationCalculator.calculatePersonalAdjustment(
  settings, 
  temperature
);
const finalFeelsLike = baseFeelsLike + personalAdjustment;
```
