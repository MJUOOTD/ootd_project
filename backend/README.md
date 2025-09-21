# lib 구조

| 경로 (Path) | 역할 | 세부 설명 |
| :--- | :--- | :--- |
| **`lib/`** | **(루트)** | **앱의 모든 Dart 코드가 포함된 기본 폴더** |
| 📁 `models/` | 데이터 모델 | 앱에서 사용하는 데이터의 형태(클래스)를 정의합니다. |
| 📄 `user_profile.dart` | 유저 프로필 모델 | 사용자의 프로필 정보를 담는 클래스입니다. |
| 📄 `weather_data.dart` | 날씨 데이터 모델 | 날씨 API로부터 받은 데이터를 담는 클래스입니다. |
| 📄 `outfit_data.dart`| 옷 데이터 모델 | 옷 정보를 담는 클래스입니다. |
| 📁 `services/` | 서비스 로직 | API 연동, 데이터베이스 처리 등 실제 앱의 동작을 담당합니다. |
| 📄 `weather_service.dart`| 날씨 서비스 | 외부 날씨 API와 통신하여 날씨 정보를 가져옵니다. |
| 📄 `firestore_service.dart`| Firestore 서비스 | Firebase Firestore 데이터베이스와 통신합니다. |
| 📄 `recommendation_service.dart`| 추천 서비스 | 날씨와 유저 정보 기반으로 옷을 추천하는 알고리즘을 처리합니다. |
| 📁 `screens/` | UI 화면 | 사용자에게 보여지는 각 화면의 UI를 구성합니다. |
| 📄 `home_screen.dart` | 홈 화면 | 앱의 메인 화면 UI입니다. |
| 📄 `main.dart` | 앱 시작점 | 앱이 가장 먼저 실행되는 시작점 파일입니다. |
