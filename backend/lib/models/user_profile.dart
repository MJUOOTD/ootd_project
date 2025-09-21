// 사용자의 프로필 정보를 담을 클래스
class UserProfile {
  final String uid; // 사용자 고유 ID
  // 1: 추위를 많이 탐, 2: 보통, 3: 더위를 많이 탐
  final int thermalSensitivity; 

  UserProfile({required this.uid, this.thermalSensitivity = 2});

  // Firestore 데이터를 UserProfile 객체로 변환
  factory UserProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      thermalSensitivity: data['thermalSensitivity'] ?? 2,
    );
  }
}