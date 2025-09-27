import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/onboarding_service.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final hasOnboarded = await OnboardingService.hasOnboarded();
      
      if (mounted) {
        if (hasOnboarded) {
          // 온보딩을 완료한 경우 메인 화면으로 이동
          context.go('/main');
        } else {
          // 온보딩을 완료하지 않은 경우 온보딩 화면으로 이동
          context.go('/onboarding');
        }
      }
    } catch (e) {
      // 에러 발생 시 메인 화면으로 이동
      if (mounted) {
        context.go('/main');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7F9FE),
              Colors.white,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 아이콘
              SizedBox(
                width: 80,
                height: 80,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF5B6CFF),
                        Color(0xFF7C3AED),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.style_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'OOTD',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1D29),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '날씨 맞춤 스타일 추천',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B6CFF)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}