import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/outfit_data.dart';
import '../models/user_profile.dart';
import '../models/weather_data.dart';

// Firestore와 관련된 모든 기능을 담당하는 클래스
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 특정 사용자의 프로필 정보를 가져오는 기능
  Future<UserProfile> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserProfile.fromFirestore(doc.data()!, uid);
    }
    // 만약 프로필이 없으면 기본값으로 생성
    return UserProfile(uid: uid); 
  }

  // 체감온도에 맞는 옷차림 규칙을 가져오는 기능
  Future<OutfitData> getOutfitRule(double feelsLikeTemp) async {
    final snapshot = await _db.collection('outfit_rules')
        .where('min_temp', isLessThanOrEqualTo: feelsLikeTemp)
        .where('max_temp', isGreaterThanOrEqualTo: feelsLikeTemp)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return OutfitData.fromFirestore(snapshot.docs.first.data());
    } else {
      throw Exception("해당 체감온도에 맞는 옷차림 규칙이 없습니다.");
    }
  }

  // 피드백을 저장하는 기능 (향후 확장)
  Future<void> saveFeedback({
    required String uid, 
    required WeatherData weather, 
    required OutfitData outfit, 
    required String feedback, // "추웠다", "더웠다", "적당했다"
  }) async {
    await _db.collection('feedback').add({
      'uid': uid,
      'feelsLikeTemp': weather.feelsLikeTemperature,
      'recommended_top': outfit.top,
      'feedback': feedback,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}