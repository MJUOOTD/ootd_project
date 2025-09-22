import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../widgets/feedback_modal.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  @override
  void initState() {
    super.initState();
  }

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
        // App Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text(
                '저장함',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.grid_view, color: Color(0xFF333333)),
                onPressed: () {
                  // Toggle between grid and list view
                },
              ),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: _buildSavedOutfitsGrid(),
        ),
      ],
    );
  }

  Widget _buildSavedOutfitsGrid() {
    // Mock saved outfits data for logged in users
    final savedOutfits = [
      {
        'id': '1',
        'title': '캐주얼 위켄드 룩',
        'description': '편안한 주말을 위한 코디',
        'imageUrl': 'https://via.placeholder.com/300x400',
        'isFavorite': true,
        'date': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': '2',
        'title': '비즈니스 캐주얼',
        'description': '깔끔하고 전문적인 룩',
        'imageUrl': 'https://via.placeholder.com/300x400',
        'isFavorite': true,
        'date': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'id': '3',
        'title': '데이트 나이트',
        'description': '우아하고 스타일리시한 코디',
        'imageUrl': 'https://via.placeholder.com/300x400',
        'isFavorite': true,
        'date': DateTime.now().subtract(const Duration(days: 7)),
      },
    ];

    return savedOutfits.isEmpty
        ? _buildEmptyState()
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: savedOutfits.length,
            itemBuilder: (context, index) {
              final outfit = savedOutfits[index];
              return _buildOutfitCard(outfit);
            },
          );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '저장된 코디가 없어요',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '마음에 드는 코디의 하트를 눌러\n저장해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitCard(Map<String, dynamic> outfit) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(outfit['id']),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        outfit['isFavorite'] ? Icons.favorite : Icons.favorite_outline,
                        color: outfit['isFavorite'] ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outfit['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    outfit['description'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(String outfitId) {
    setState(() {
      // Toggle favorite logic here
    });
  }

  void _navigateToLogin() {
    // Show feedback modal instead of navigating
    FeedbackModal.show(context);
  }
}
