# API 설정 가이드

## 현재 상황
- **KMA API**: 시스템 점검 중 (사용 불가)
- **OpenWeatherMap API**: 키가 유효하지 않음

## 해결 방법

### 1. OpenWeatherMap API 키 발급

1. [OpenWeatherMap](https://openweathermap.org/api) 방문
2. "Sign Up" 클릭하여 계정 생성
3. 로그인 후 "API keys" 섹션으로 이동
4. "Create key" 클릭하여 새 API 키 생성
5. 생성된 API 키를 복사

### 2. .env 파일 수정

```bash
# /backend/.env 파일에서 다음 라인을 수정:
OPENWEATHER_API_KEY=실제_발급받은_API_키_여기에_입력
```

### 3. 서버 재시작

```bash
cd backend
pkill -f "node src/server.js"
npm start
```

### 4. 테스트

```bash
curl -X GET "http://localhost:4000/api/weather/current?lat=37.5665&lon=126.9780&force=true"
```

## 예상 결과

API 키가 올바르게 설정되면:
- KMA API 실패 → OpenWeatherMap API 자동 사용
- 실제 날씨 데이터 반환
- `"source": "openweathermap"` 표시

## 무료 API 제한사항

- OpenWeatherMap 무료 계정: 월 1,000,000 호출 제한
- KMA API: 무료, 제한 없음 (점검 중일 때만 사용 불가)
