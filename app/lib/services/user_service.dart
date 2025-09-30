import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// 사용자 프로필을 Firestore users/{uid}에 저장/갱신하는 서비스
class UserService {
  UserService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// users/{uid} 문서를 upsert한다.
  Future<void> upsertUserProfile({
    required String userId,
    required UserModel user,
  }) async {
    final docRef = _firestore.collection('users').doc(userId);
    final data = {
      'name': user.name,
      'email': user.email,
      'gender': user.gender,
      'age': user.age,
      'bodyType': user.bodyType,
      'activityLevel': user.activityLevel,
      'temperatureSensitivity': user.temperatureSensitivity.name,
      'stylePreferences': user.stylePreferences,
      'situationPreferences': user.situationPreferences,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
    };

    await docRef.set(data, SetOptions(merge: true));
  }

  /// users/{uid} 문서를 조회한다. 없으면 null 반환.
  Future<UserModel?> getUserProfile({
    required String userId,
  }) async {
    final docRef = _firestore.collection('users').doc(userId);
    final snap = await docRef.get();
    if (!snap.exists) return null;
    final data = snap.data() as Map<String, dynamic>;

    // temperatureSensitivity 저장 포맷: enum name 문자열
    TemperatureSensitivity sensitivity = TemperatureSensitivity.normal;
    final raw = data['temperatureSensitivity'];
    if (raw is String) {
      switch (raw) {
        case 'veryCold':
          sensitivity = TemperatureSensitivity.veryCold; break;
        case 'cold':
          sensitivity = TemperatureSensitivity.cold; break;
        case 'normal':
          sensitivity = TemperatureSensitivity.normal; break;
        case 'hot':
          sensitivity = TemperatureSensitivity.hot; break;
        case 'veryHot':
          sensitivity = TemperatureSensitivity.veryHot; break;
      }
    }

    return UserModel(
      id: userId,
      name: (data['name'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      gender: (data['gender'] ?? '') as String,
      age: (data['age'] ?? 0) as int,
      bodyType: (data['bodyType'] ?? '') as String,
      activityLevel: (data['activityLevel'] ?? '보통') as String,
      temperatureSensitivity: sensitivity,
      stylePreferences: List<String>.from(data['stylePreferences'] ?? const <String>[]),
      situationPreferences: Map<String, dynamic>.from(data['situationPreferences'] ?? const <String, dynamic>{}),
      createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}


