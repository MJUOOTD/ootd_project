#lib 구조

lib/
├── models/                  # 데이터 형태를 정의하는 파일들
│   ├── user_profile.dart
│   ├── weather_data.dart
│   └── outfit_data.dart
│
├── services/                # 실제 동작을 처리하는 파일들
│   ├── weather_service.dart   # 날씨 API 연동 담당
│   ├── firestore_service.dart # Firestore 연동 담당
│   └── recommendation_service.dart # 추천 알고리즘 담당
│
├── screens/                 # 화면 UI를 담당하는 파일들
│   └── home_screen.dart
│
└── main.dart                # 앱 시작점