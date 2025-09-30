import 'package:firebase_auth/firebase_auth.dart';

/// Firebase 인증 서비스
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 현재 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  /// 사용자가 로그인되어 있는지 확인
  bool get isLoggedIn => currentUser != null;

  /// Firebase ID 토큰 가져오기
  Future<String?> getIdToken() async {
    final user = currentUser;
    
    if (user == null) {
      return null;
    }
    
    try {
      final token = await user.getIdToken();
      return token;
    } catch (e) {
      return null;
    }
  }

  /// 사용자 ID 가져오기
  String? get userId => currentUser?.uid;

  /// 인증 상태 변경 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 로그인
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 회원가입
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// 이메일 인증 전송
  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// 이메일 인증 상태 확인
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// 사용자 삭제
  Future<void> deleteUser() async {
    final user = currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// 사용자 정보 업데이트
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
    }
  }
}
