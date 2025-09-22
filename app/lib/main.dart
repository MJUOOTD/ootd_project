import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';
import 'services/pinterest_api_service.dart';

void main() {
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
        title: 'OOTD - Optimal Outfit Tailored by Data',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      ),
    );
  }
}
