import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/onboarding_service.dart';
import '../main_navigation.dart';

class WelcomeOnboardingScreen extends StatefulWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  State<WelcomeOnboardingScreen> createState() => _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState extends State<WelcomeOnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _cardsController;
  late AnimationController _ctaController;
  
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconFadeAnimation;
  late List<Animation<double>> _cardAnimations;
  late Animation<double> _ctaFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // 아이콘 애니메이션
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _iconScaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeOut,
    ));
    
    _iconFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // 카드 애니메이션
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _cardAnimations = List.generate(3, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _cardsController,
        curve: Interval(
          index * 0.2,
          0.6 + index * 0.2,
          curve: Curves.easeOut,
        ),
      ));
    });

    // CTA 애니메이션
    _ctaController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _ctaFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _ctaController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() async {
    // 아이콘 애니메이션 시작
    _iconController.forward();
    
    // 카드 애니메이션 시작 (80ms 지연)
    await Future.delayed(const Duration(milliseconds: 80));
    _cardsController.forward();
    
    // CTA 애니메이션 시작 (150ms 지연)
    await Future.delayed(const Duration(milliseconds: 150));
    _ctaController.forward();
  }

  Future<void> _completeOnboarding() async {
    await OnboardingService.completeOnboarding();
    
    if (mounted) {
      // Use GoRouter for navigation
      context.go('/main');
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
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      
                      // 앱 아이콘 카드
                      AnimatedBuilder(
                        animation: _iconController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _iconScaleAnimation.value,
                            child: Opacity(
                              opacity: _iconFadeAnimation.value,
                              child: const AppIconCard(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 앱명 타이틀
                      const Text(
                        'OOTD',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B1D29),
                        ),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // 서브타이틀
                      const Text(
                        '날씨 맞춤 스타일 추천',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1B1D29),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 기능 카드들
                      ...List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _cardsController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, 12 * (1 - _cardAnimations[index].value)),
                              child: Opacity(
                                opacity: _cardAnimations[index].value,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: _buildFeatureCard(index),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              
              // CTA 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedBuilder(
                  animation: _ctaController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - _ctaFadeAnimation.value)),
                      child: Opacity(
                        opacity: _ctaFadeAnimation.value,
                        child: Column(
                          children: [
                            const SizedBox(height: 32),
                            PrimaryCTA(
                              text: '시작하기',
                              onPressed: _completeOnboarding,
                            ),
                            const SizedBox(height: 12),
                            const FooterNote(
                              text: '로그인 없어도 기본 추천을 확인할 수 있어요',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(int index) {
    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.cloud_outlined,
        'title': '실시간 날씨 기반',
        'body': '현재 날씨에 맞는 코디 추천',
        'bgColor': const Color(0xFFE8F0FF),
      },
      {
        'icon': Icons.thermostat_outlined,
        'title': '개인 체온 맞춤',
        'body': '당신만의 온도 감각에 맞춘 추천',
        'bgColor': const Color(0xFFF5E8FF),
      },
      {
        'icon': Icons.person_outline,
        'title': '상황별 추천',
        'body': '출근, 데이트, 운동별 맞춤 스타일',
        'bgColor': const Color(0xFFE9FFE8),
      },
    ];

    final feature = features[index];
    
    return Semantics(
      label: '${feature['title']}, ${feature['body']}',
      button: false,
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // 아이콘 컨테이너
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: feature['bgColor'],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  feature['icon'],
                  size: 28,
                  color: const Color(0xFF6B8DFC),
                ),
              ),
              
              const SizedBox(width: 14),
              
              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      feature['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B1D29),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      feature['body'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF6B7280),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    _cardsController.dispose();
    _ctaController.dispose();
    super.dispose();
  }
}

// 앱 아이콘 카드 위젯
class AppIconCard extends StatelessWidget {
  const AppIconCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'OOTD 앱 아이콘',
      child: Container(
        width: 128,
        height: 128,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B8DFC),
              Color(0xFF6B8DFC)
            ],
          ),
        ),
        child: const Icon(
          Icons.checkroom,
          size: 64,
          color: Colors.white,
        ),
      ),
    );
  }
}

// CTA 버튼 위젯
class PrimaryCTA extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryCTA({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$text, 버튼',
      button: true,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF6B8DFC),
                  Color(0xFF6B8DFC),
                ],
              ),
            ),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 푸터 안내 위젯
class FooterNote extends StatelessWidget {
  final String text;

  const FooterNote({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF6B7280),
        height: 1.3,
      ),
      textAlign: TextAlign.center,
    );
  }
}
