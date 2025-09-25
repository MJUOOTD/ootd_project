import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final bool isLoggedIn = auth.asData?.value != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: isLoggedIn 
            ? _buildLoggedInView()
            : _buildLoginPromptView(),
      ),
    );
  }

  Widget _buildLoginPromptView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Heart icon with border
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.favorite_outline,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Main message
            const Text(
              '저장함을 사용하려면 로그인하세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Sub message
            Text(
              '마음에 드는 코디를 저장하고\n구매 내역을 관리할 수 있어요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Login/Signup button with gradient
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(239, 107, 141, 252),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Material(
                color:  const Color.fromARGB(239, 107, 141, 252),
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: _navigateToLogin,
                  child: const Center(
                    child: Text(
                      '로그인 / 회원가입',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInView() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '저장함',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '저장한 코디와 구매 내역을 확인하세요',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              // Tab Navigation
              Row(
                children: [
                  _buildTab('저장한 코디', Icons.favorite_outline, 0),
                  const SizedBox(width: 16),
                  _buildTab('장바구니', Icons.shopping_cart_outlined, 1),
                  const SizedBox(width: 16),
                  _buildTab('구매내역', Icons.history, 2),
                ],
              ),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: _buildTabContent(),
        ),
      ],
    );
  }

  Widget _buildTab(String title, IconData icon, int index) {
    final isSelected = _selectedTabIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.black,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildSavedOutfitsContent();
      case 1:
        return _buildCartContent();
      case 2:
        return _buildPurchaseHistoryContent();
      default:
        return _buildSavedOutfitsContent();
    }
  }

  Widget _buildSavedOutfitsContent() {
    // 빈 상태로 표시 (사진과 동일하게)
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '아직 저장한 코디가 없어요',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '마음에 드는 코디를 저장해보세요!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(239, 107, 141, 252),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      // 코디 둘러보기 기능
                    },
                    child: const Center(
                      child: Text(
                        '코디 둘러보기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return const Center(
      child: Text('장바구니 내용'),
    );
  }

  Widget _buildPurchaseHistoryContent() {
    return const Center(
      child: Text('구매내역 내용'),
    );
  }


  void _navigateToLogin() {
    context.pushNamed('login');
  }
}
