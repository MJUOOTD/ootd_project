# Weather API 사용 가이드

## 개요
실시간 날씨 정보와 단기 예보를 제공하는 REST API입니다.

## 설치 및 실행

### 1. 의존성 설치
```bash
npm install
```

### 2. 환경 변수 설정
`.env` 파일을 생성하고 OpenWeatherMap API 키를 설정하세요:
```
OPENWEATHER_API_KEY=your_openweather_api_key_here
PORT=3000
NODE_ENV=development
```

### 3. 서버 실행
```bash
# 개발 모드
npm run dev

# 프로덕션 모드
npm start
```

## API 엔드포인트

### GET /weather
현재 날씨 정보와 시간별 예보를 조회합니다.

#### 요청 파라미터
- `lat` (required): 위도 (latitude)
- `lon` (required): 경도 (longitude)

#### 요청 예시
```
GET /weather?lat=37.27&lon=127.45
```

#### 응답 형식
```json
{
  "current": {
    "temp": 14,
    "feels_like": 13,
    "condition": "Clear",
    "humidity": 75,
    "wind_speed": 0.5
  },
  "forecast": [
    {
      "time": "23:00",
      "temp": 13,
      "condition": "Clear",
      "precipitation_prob": 10
    },
    {
      "time": "00:00",
      "temp": 12,
      "condition": "Clear",
      "precipitation_prob": 10
    },
    {
      "time": "01:00",
      "temp": 12,
      "condition": "Clear",
      "precipitation_prob": 5
    }
  ]
}
```

#### 응답 필드 설명

**current (현재 날씨)**
- `temp`: 현재 기온 (섭씨, °C)
- `feels_like`: 체감 온도 (섭씨, °C)
- `condition`: 날씨 상태 (Clear, Clouds, Rain 등)
- `humidity`: 습도 (%)
- `wind_speed`: 풍속 (m/s)

**forecast (시간별 예보)**
- `time`: 예보 시간 (HH:MM 형식)
- `temp`: 예상 기온 (섭씨, °C)
- `condition`: 날씨 상태
- `precipitation_prob`: 강수 확률 (%)

#### 에러 응답
```json
{
  "error": "Missing required parameters",
  "message": "latitude (lat) and longitude (lon) are required"
}
```

## 테스트

### cURL로 테스트
```bash
# 서울시청 좌표로 테스트
curl "http://localhost:3000/weather?lat=37.5665&lon=126.9780"

# 부산시청 좌표로 테스트
curl "http://localhost:3000/weather?lat=35.1796&lon=129.0756"
```

### JavaScript로 테스트
```javascript
fetch('http://localhost:3000/weather?lat=37.5665&lon=126.9780')
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error('Error:', error));
```

## 주요 기능

1. **위치 기반 데이터 조회**: 위도/경도로 정확한 위치의 날씨 정보 제공
2. **실시간 현재 날씨**: 기온, 체감온도, 날씨상태, 습도, 풍속 제공
3. **시간별 예보**: 현재 시간부터 3시간 이후까지의 상세 예보
4. **한국 시간 기준**: UTC+9 시간대 기준으로 데이터 제공
5. **에러 처리**: 상세한 에러 메시지와 HTTP 상태 코드 제공
6. **입력 검증**: 좌표 유효성 검사 및 필수 파라미터 검증

## 기술 스택

- **Node.js**: JavaScript 런타임
- **Express**: 웹 프레임워크
- **OpenWeatherMap API**: 날씨 데이터 소스
- **node-fetch**: HTTP 클라이언트
- **dotenv**: 환경 변수 관리
