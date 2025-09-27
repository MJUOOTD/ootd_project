import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 단일 파일 Firebase ID/비밀번호 인증 서비스
/// - ID는 내부적으로 가상 이메일(id@local.login)로 매핑하여 Firebase Auth를 사용합니다.
/// - 회원가입 시 Firestore `users` 컬렉션에 최소 정보(id, uid, createdAt, updatedAt)를 저장합니다.
/// - 비밀번호는 Firestore에 저장하지 않습니다.
class SimpleAuthService {
  SimpleAuthService._internal();

  static final SimpleAuthService instance = SimpleAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 명시적 초기화(선택) - main.dart에서 이미 초기화됨
  Future<void> initialize() async {
    // main.dart에서 이미 초기화되므로 추가 작업 불필요
  }

  String _idToEmail(String userId) {
    final normalized = userId.trim().toLowerCase();
    return '$normalized@local.login';
  }

  /// 회원가입: (id, password)
  /// - ID 중복 체크 후 Firebase Auth 생성
  /// - 생성 성공 시 Firestore `users/{uid}` 문서를 병합 저장
  Future<UserCredential> signUp({required String userId, required String password}) async {
    // ID 중복 체크
    final existingUser = await _checkUserIdExists(userId);
    if (existingUser) {
      throw Exception('이미 사용 중인 아이디입니다.');
    }
    
    final email = _idToEmail(userId);

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final now = FieldValue.serverTimestamp();

    await _db.collection('users').doc(uid).set(
      <String, Object?>{
        'id': userId,
        'uid': uid,
        'createdAt': now,
        'updatedAt': now,
      },
      SetOptions(merge: true),
    );

    return credential;
  }

  /// ID 중복 체크
  Future<bool> _checkUserIdExists(String userId) async {
    final querySnapshot = await _db
        .collection('users')
        .where('id', isEqualTo: userId)
        .limit(1)
        .get();
    
    return querySnapshot.docs.isNotEmpty;
  }

  /// 로그인: (id, password)
  /// - 존재하지 않거나 비밀번호가 틀리면 FirebaseAuthException(code: user-not-found | wrong-password)
  Future<UserCredential> signIn({required String userId, required String password}) async {
    final email = _idToEmail(userId);
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// 별칭: UI에서 쓰기 쉬운 네이밍
  Future<UserCredential> login({required String id, required String password}) {
    return signIn(userId: id, password: password);
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 별칭: UI에서 쓰기 쉬운 네이밍
  Future<void> logout() => signOut();

  /// 현재 로그인 사용자 반환(없으면 null)
  User? get currentUser => _auth.currentUser;

  /// 로그인 여부
  Future<bool> isSignedIn() async {
    return _auth.currentUser != null;
  }

  /// 별칭: 로그인 여부 체크
  Future<bool> isUserLoggedIn() => isSignedIn();

  /// 현재 사용자 UID 반환(없으면 null)
  String? get currentUserId => _auth.currentUser?.uid;

  /// 인증 상태 스트림 (UI 연동용)
  Stream<User?> get authState => _auth.authStateChanges();

  /// 별칭: 회원가입 UI에서 쓰기 쉬운 네이밍
  Future<UserCredential> register({required String id, required String password}) {
    return signUp(userId: id, password: password);
  }
}


