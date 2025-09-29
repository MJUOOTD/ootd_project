import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app_router.dart';
import 'services/service_locator.dart';
import 'services/favorites_service.dart';
import 'theme/app_theme.dart';
import 'services/pexels_api_service.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // ProviderContainer 생성
  final container = ProviderContainer();
  
  await serviceLocator.initialize();
  // Pexels API 키 설정
  PexelsApiService.setApiKey('QwYk7NDUowPtA83vo1RHNYSHCWWnDTd8MNlm8giDiGq8blf1iPAHu1DP');
  // 즐겨찾기 서비스 초기화
  await FavoritesService.initialize();
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const OOTDApp(),
    ),
  );
}

class OOTDApp extends ConsumerWidget {
  const OOTDApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
