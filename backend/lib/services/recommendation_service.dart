import '../models/outfit_data.dart';
import '../models/user_profile.dart';
import '../models/weather_data.dart';
import 'firestore_service.dart';
import 'weather_service.dart';

// 앱의 핵심 추천 알고리즘을 담당하는 클래스
class RecommendationService {
  // 다른 서비스들을 부품처럼 사용 (의존성 주입)
  final WeatherService _weatherService = WeatherService();
  final FirestoreService _firestoreService = FirestoreService();

  // 메인 기능: 사용자 ID를 받아 최종 옷차림을 추천
  Future<Map<String, dynamic>> getRecommendation(String uid) async {
    // 1. 날씨 정보 가져오기
    WeatherData weatherData = await _weatherService.getCurrentWeather();

    // 2. 사용자 프로필 정보 가져오기
    UserProfile userProfile = await _firestoreService.getUserProfile(uid);

    // 3. 체감온도에 사용자의 체온 감도를 반영하여 '최종 조정 온도' 계산
    // 예: 추위를 많이 타는 사람은 체감온도를 3도 더 낮게 느낌
    double adjustedTemp = weatherData.feelsLikeTemperature;
    if (userProfile.thermalSensitivity == 1) { // 추위 많이 탐
      adjustedTemp -= 3;
    } else if (userProfile.thermalSensitivity == 3) { // 더위 많이 탐
      adjustedTemp += 3;
    }

    // 4. 최종 조정 온도를 기준으로 Firestore에서 옷차림 규칙 조회
    OutfitData outfitData = await _firestoreService.getOutfitRule(adjustedTemp);
    
    // 5. 화면에 보여줄 모든 데이터를 한 번에 반환
    return {
      'weather': weatherData,
      'outfit': outfitData,
    };
  }
}