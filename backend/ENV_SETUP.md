# 환경변수 설정 가이드

## ⚠️ 보안 주의사항

**절대로 실제 API 키를 코드나 Git 저장소에 커밋하지 마세요!**

- `.env` 파일은 `.gitignore`에 포함되어 Git에서 제외됩니다
- API 키가 노출되면 보안상 심각한 문제가 발생할 수 있습니다
- 팀원들과 공유할 때는 `.env.example` 파일을 사용하세요

## OpenWeatherMap API 설정

1. [OpenWeatherMap](https://openweathermap.org/api)에서 무료 API 키를 발급받으세요.

2. 백엔드 루트 디렉토리(`/backend`)에 `.env` 파일을 생성하세요:

```bash
# OpenWeatherMap API Key
OPENWEATHER_API_KEY=your_actual_api_key_here

# KMA API (기존)
KMA_API_KEY=your_kma_api_key_here

# Server Configuration
PORT=3000
NODE_ENV=development
```

3. **중요**: `your_actual_api_key_here`를 실제 API 키로 교체하세요.

## .env 파일 생성 방법

```bash
# 백엔드 디렉토리로 이동
cd backend

# .env 파일 생성
touch .env

# 파일 편집 (실제 API 키 입력)
nano .env
```

## API 키 없이 테스트하기

API 키가 없는 경우에도 서버는 정상 작동합니다:
- Mock 데이터를 사용하여 개발/테스트 가능
- 실제 날씨 데이터는 API 키 설정 후 사용 가능

## 동작 방식

- **1차**: KMA API 시도
- **2차**: KMA API 실패 시 OpenWeatherMap API로 자동 fallback
- **3차**: 모든 API 실패 시 Mock 데이터 사용

## 테스트

서버 실행 후 다음 엔드포인트로 테스트할 수 있습니다:

```bash
# 현재 날씨 조회
GET http://localhost:3000/api/weather/current?lat=37.5665&lon=126.9780

# 강제 새로고침
GET http://localhost:3000/api/weather/current?lat=37.5665&lon=126.9780&force=true
```

## 로그 확인

서버 로그에서 다음 메시지들을 확인할 수 있습니다:

- `[weather] KMA API server unreachable, trying OpenWeatherMap API`
- `[OpenWeatherMap] Requesting: ...`
- `[weather] All APIs failed, using mock data`
