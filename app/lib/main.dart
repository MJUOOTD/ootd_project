import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_router.dart';
import 'services/service_locator.dart';
import 'theme/app_theme.dart';
import 'services/pinterest_api_service.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  // Pinterest API 토큰 설정
  PinterestApiService.setAccessToken('pina_AMAUIXYXACCSOBIAGAAL4D4ZPUDHBGIBQBIQDALLUG7QUGPCODGPGIJ6CKB5YUODK277WHXLGEOIA6Y7IQBN3NYH75KLZCYA');
  
  runApp(const OOTDApp());
}

class OOTDApp extends StatelessWidget {
  const OOTDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'OOTD - Optimal Outfit Tailorer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      ),
    );
  }
}
