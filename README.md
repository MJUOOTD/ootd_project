# OOTD - Optimal Outfit Tailorer

날씨와 상황에 맞는 최적의 옷차림을 추천해주는 Flutter 앱입니다.

## 📱 프로젝트 개요

OOTD는 사용자의 위치, 날씨, 개인 선호도, 상황을 고려하여 최적의 옷차림을 추천하는 AI 기반 패션 앱입니다.

### 주요 기능
- 🌤️ 실시간 날씨 기반 옷차림 추천
- 📍 GPS 위치 기반 맞춤형 추천
- 🔥 Firebase 인증 (로그인/회원가입/로그아웃)
- 👤 개인화된 사용자 프로필 및 선호도 설정
- 🎯 상황별 옷차림 추천 (출근, 데이트, 운동 등)
- 💾 추천 옷차림 저장 및 관리
- 🔍 Pexels API를 통한 실제 패션 이미지 제공

## 🛠️ 기술 스택

### Frontend (Flutter)
- **Framework**: Flutter 3.9.2+
- **State Management**: Riverpod 2.4.0
- **Routing**: GoRouter 16.2.1
- **Firebase**: Authentication, Firestore, Analytics
- **Location**: Geolocator, Location services
- **HTTP**: Dio, HTTP
- **UI**: Cached Network Image, Lottie, Flutter SVG

### Backend (Node.js)
- **Runtime**: Node.js 18+
- **Framework**: Express.js 5.1.0
- **Middleware**: CORS, Helmet, Morgan
- **API Documentation**: Swagger
- **Validation**: Zod
- **Environment**: dotenv

## 📋 사전 요구사항

### 개발 환경
- **Flutter SDK**: 3.9.2 이상
- **Dart SDK**: 3.9.2 이상
- **Node.js**: 18.0.0 이상
- **npm**: 8.0.0 이상
- **Git**: 2.0.0 이상

### 플랫폼별 요구사항
- **Android**: Android Studio, Android SDK
- **iOS**: Xcode 14.0+, CocoaPods
- **Web**: Chrome, Firefox, Safari (최신 버전)

## 🚀 설치 및 실행

### 1. 저장소 클론
```bash
git clone https://github.com/MJUOOTD/ootd_project.git
cd ootd_project
```

### 2. Flutter 앱 설정

#### 2.1 Flutter 의존성 설치
```bash
cd app
flutter pub get
```

#### 2.2 Firebase 설정
1. Firebase Console에서 프로젝트 생성
2. Android 앱 등록 (패키지명: `com.example.ootd_app`)
3. `google-services.json` 파일을 `app/android/app/` 폴더에 복사
4. iOS 앱 등록 (번들 ID: `com.example.ootdApp`)
5. `GoogleService-Info.plist` 파일을 `app/ios/Runner/` 폴더에 복사

#### 2.3 Firebase 설정 파일 생성
```bash
# Firebase CLI 설치 (전역)
npm install -g firebase-tools

# Firebase 프로젝트에 로그인
firebase login

# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 설정 파일 생성
flutterfire configure
```

### 3. 백엔드 서버 설정

#### 3.1 Node.js 의존성 설치
```bash
cd backend
npm install
```

#### 3.2 환경 변수 설정
`backend/.env` 파일을 생성하고 다음 내용을 추가:

```env
# 서버 설정
PORT=4000

# 기상청 API 키 (필수)
KMA_SERVICE_KEY=your_kma_api_key_here

# Pexels API 키 (선택사항)
PEXELS_API_KEY=your_pexels_api_key_here

# CORS 설정
CORS_ORIGIN=http://localhost:3000
```

#### 3.3 API 키 발급 방법
1. **기상청 API**: [공공데이터포털](https://data.go.kr)에서 기상청_단기예보 조회서비스 신청
2. **Pexels API**: [Pexels API](https://www.pexels.com/api/)에서 무료 API 키 발급

### 4. 앱 실행

#### 4.1 백엔드 서버 실행
```bash
cd backend
npm run dev
# 또는
npm start
```

#### 4.2 Flutter 앱 실행
```bash
cd app
flutter run
```

#### 4.3 플랫폼별 실행
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# macOS
flutter run -d macos
```

## 📁 프로젝트 구조

```
ootd_project/
├── app/                          # Flutter 앱
│   ├── lib/
│   │   ├── features/            # 기능별 모듈
│   │   │   ├── home/           # 홈 화면
│   │   │   ├── onboarding/     # 온보딩
│   │   │   ├── settings/       # 설정
│   │   │   └── ...
│   │   ├── models/             # 데이터 모델
│   │   ├── providers/          # 상태 관리
│   │   ├── screens/            # 화면
│   │   ├── services/           # 서비스
│   │   ├── widgets/            # 재사용 위젯
│   │   └── theme/              # 테마
│   ├── android/                # Android 설정
│   ├── ios/                    # iOS 설정
│   └── web/                    # Web 설정
├── backend/                     # Node.js 백엔드
│   ├── src/
│   │   ├── routes/             # API 라우트
│   │   ├── services/           # 비즈니스 로직
│   │   ├── middleware/         # 미들웨어
│   │   └── app.js              # Express 앱
│   └── package.json
└── docs/                       # 문서
```

## 🔧 주요 설정

### Android 권한 설정
`app/android/app/src/main/AndroidManifest.xml`에 다음 권한이 설정되어 있습니다:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS 권한 설정
`app/ios/Runner/Info.plist`에 다음 권한이 설정되어 있습니다:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>날씨 기반 옷차림 추천을 위해 위치 정보가 필요합니다.</string>
```

## 🌐 API 엔드포인트

### 날씨 API
- `GET /api/weather/current?lat={lat}&lon={lon}` - 현재 날씨 조회
- `GET /api/weather/forecast?lat={lat}&lon={lon}` - 날씨 예보 조회

### 추천 API
- `GET /api/recommendations/outfit?lat={lat}&lon={lon}&situation={situation}` - 옷차림 추천

### 사용자 API
- `POST /api/users/feedback` - 피드백 전송

## 🐛 문제 해결

### 일반적인 문제들

#### 1. Flutter 의존성 문제
```bash
cd app
flutter clean
flutter pub get
```

#### 2. Firebase 연결 문제
- `google-services.json` 파일이 올바른 위치에 있는지 확인
- Firebase 프로젝트 설정이 올바른지 확인
- 인터넷 연결 상태 확인

#### 3. 위치 권한 문제
- Android: 앱 설정에서 위치 권한 허용
- iOS: 설정 > 개인정보 보호 > 위치 서비스에서 앱 권한 허용

#### 4. 백엔드 서버 연결 문제
- 포트 4000이 사용 중인지 확인
- 환경 변수 설정 확인
- API 키가 올바른지 확인

### 로그 확인
```bash
# Flutter 앱 로그
flutter logs

# 백엔드 서버 로그
cd backend
npm run dev
```

## 📝 개발 가이드

### 코드 스타일
- Dart: `flutter_lints` 규칙 준수
- JavaScript: ESLint 규칙 준수
- 커밋 메시지: Conventional Commits 형식 사용


### 테스트
```bash
# Flutter 테스트
cd app
flutter test

# 백엔드 테스트 
cd backend
npm test
```


## 📞 문의

프로젝트 관련 문의사항이 있으시면 이슈를 생성해 주세요.

---

**OOTD Team**