import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: userState.isLoggedIn 
            ? _buildLoggedInView()
            : _buildLoginPromptView(),
      ),
    );
  }

  Widget _buildLoginPromptView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80), // 하단 네비게이션 바 공간 확보
        child: Column(
          children: [
        // 상단 헤더
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '마이',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '개인 정보와 서비스를 관리하세요',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
        
        // 로그인 유도 섹션
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 프로필 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '로그인하고 더 많은 서비스를 이용하세요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '개인 맞춤 추천과 저장 기능을 사용할 수 있어요',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // 로그인 버튼
              Container(
                width: double.infinity,
                height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(239, 107, 141, 252),
                borderRadius: BorderRadius.circular(25),
              ),
                child: Material(
                  color: const Color.fromARGB(239, 107, 141, 252),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: _navigateToLogin,
                    child: const Center(
                      child: Text(
                        '로그인 / 회원가입',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 메뉴 항목들
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMenuItem(
                context,
                icon: Icons.help_outline,
                title: '고객센터',
                onTap: () => _showComingSoon(context, '고객센터'),
              ),
              _buildDivider(),
              _buildMenuItem(
                context,
                icon: Icons.chat_bubble_outline,
                title: '1:1 문의내역',
                onTap: () => _showComingSoon(context, '1:1 문의내역'),
              ),
              _buildDivider(),
              _buildMenuItem(
                context,
                icon: Icons.notifications_outlined,
                title: '공지사항',
                onTap: () => _showComingSoon(context, '공지사항'),
              ),
            ],
          ),
        ),
        ],
        ),
      ),
    );
  }

  void _navigateToLogin() {
    context.pushNamed('login');
  }

  void _handleLogout() async {
    final userProviderNotifier = ref.read(userProvider.notifier);
    await userProviderNotifier.logout();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그아웃되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
      // 메인페이지로 이동
      context.go('/');
    }
  }

  Widget _buildLoggedInView() {
    final userState = ref.watch(userProvider);
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80), // 하단 네비게이션 바 공간 확보
        child: Column(
          children: [
            // App Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    '마이 페이지',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Column(
          children: [
            // 프로필 섹션
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 프로필 사진
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[100],
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                          color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 사용자 이름
                  Text(
                    userState.currentUser?.name ?? '사용자',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 이메일
                  Text(
                    userState.currentUser?.email ?? 'user@example.com',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                    ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 메뉴 섹션
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                        icon: Icons.person_outline,
                        title: '프로필 수정',
                        onTap: () => _showComingSoon(context, '프로필 수정'),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        context,
                        icon: Icons.favorite_outline,
                        title: '좋아요한 옷',
                        onTap: () => _showComingSoon(context, '좋아요한 옷'),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        context,
                        icon: Icons.history,
                        title: '추천 기록',
                        onTap: () => _showComingSoon(context, '추천 기록'),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        context,
                        icon: Icons.settings_outlined,
                        title: '설정',
                        onTap: () => _showComingSoon(context, '설정'),
                      ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
                // 앱 정보 섹션
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                      _buildMenuItem(
                        context,
                        icon: Icons.info_outline,
                        title: '앱 정보',
                        onTap: () => _showAppInfo(context),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        context,
                        icon: Icons.help_outline,
                        title: '도움말',
                        onTap: () => _showComingSoon(context, '도움말'),
                      ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
                
                // 로그아웃 버튼
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('로그아웃'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
                icon,
              size: 24,
                color: Colors.black,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey[200],
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('준비 중인 기능입니다.\n빠른 시일 내에 제공해드릴게요!'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OOTD - Optimal Outfit Tailored by Data'),
            SizedBox(height: 8),
            Text('버전: 1.0.0'),
            SizedBox(height: 8),
            Text('날씨 기반 맞춤형 옷차림 추천 앱'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}