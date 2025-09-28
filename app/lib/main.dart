import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_router.dart';
import 'services/service_locator.dart';
import 'services/favorites_service.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/pexels_api_service.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
  // 즉시성 우선이면 SESSION 권장, 완전 일시적이면 NONE도 가능
  await FirebaseAuth.instance.setPersistence(Persistence.SESSION);
}
  //디버그용
  FirebaseAuth.instance.authStateChanges().listen((user) {
    debugPrint('[authStateChanges] user: ${user?.uid}');
  });
  
  await serviceLocator.initialize();
  // Pexels API 키 설정
  PexelsApiService.setApiKey('QwYk7NDUowPtA83vo1RHNYSHCWWnDTd8MNlm8giDiGq8blf1iPAHu1DP');
  // 즐겨찾기 서비스 초기화
  await FavoritesService.initialize();
  
  runApp(
    ProviderScope(
      child: const OOTDApp(),
    ),
  );
}

class OOTDApp extends ConsumerStatefulWidget {
  const OOTDApp({super.key});

  @override
  ConsumerState<OOTDApp> createState() => _OOTDAppState();
}

class _OOTDAppState extends ConsumerState<OOTDApp> {
  @override
  void initState() {
    super.initState();
    // UserProvider 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Firebase 인증 상태 변화를 감지하여 UserProvider 업데이트
    ref.listen(authStateListenerProvider, (previous, next) {
      // authStateListenerProvider가 자동으로 UserProvider를 업데이트함
    });

    return MaterialApp.router(
      title: 'OOTD - Optimal Outfit Tailorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
