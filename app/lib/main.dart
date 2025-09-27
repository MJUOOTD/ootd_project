import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_router.dart';
import 'services/service_locator.dart';
import 'services/app_initializer.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/pexels_api_service.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ProviderContainer 생성
  final container = ProviderContainer();
  
  try {
    // AppInitializer를 통한 순서대로 초기화
    await AppInitializer.initialize(ref: container);
  } catch (e) {
    debugPrint('[main] App initialization failed: $e');
    // 초기화 실패해도 앱은 실행 (위치 권한 없이도 사용 가능)
  }
  
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
