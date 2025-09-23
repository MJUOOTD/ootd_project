import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../widgets/feedback_modal.dart';

class SituationOutfitDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final String rating;
  final List<String> tags;
  final String temperature;
  final String situation;

  const SituationOutfitDetailScreen({
    super.key,
    required this.title,
    required this.rating,
    required this.tags,
    required this.temperature,
    required this.situation,
  });

  @override
  ConsumerState<SituationOutfitDetailScreen> createState() => _SituationOutfitDetailScreenState();
}

class _SituationOutfitDetailScreenState extends ConsumerState<SituationOutfitDetailScreen> {
  String? selectedTemperature;
  bool isLiked = false;

  void _handleTemperatureFeedback(String value) {
    final userState = ref.read(userProvider);
    if (!userState.isLoggedIn) {
      FeedbackModal.show(context);
      return;
    }
    
    setState(() {
      selectedTemperature = value;
    });
    
    // 피드백 저장 (실제로는 서버에 저장)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('온도 피드백이 저장되었습니다: $value'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handlePreferenceFeedback() {
    final userState = ref.read(userProvider);
    if (!userState.isLoggedIn) {
      FeedbackModal.show(context);
      return;
    }
    
    setState(() {
      isLiked = !isLiked;
    });
    
    // 선호도 저장 (실제로는 서버에 저장)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isLiked ? '이 룩을 좋아요에 추가했습니다!' : '좋아요를 취소했습니다.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '뒤로',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Colors.black,
            ),
            onPressed: () {
              setState(() {
                isLiked = !isLiked;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메인 이미지 영역
            Container(
              width: double.infinity,
              height: 400,
              decoration: const BoxDecoration(
                color: Colors.grey,
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.rating,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 룩 정보
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.temperature}℃ 날씨에 어울리는 ${widget.situation} 스타일',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 태그들
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 32),
                  
                  // 온도 피드백 섹션
                  _buildTemperatureFeedbackSection(),
                  const SizedBox(height: 24),
                  
                  // 선호도 피드백 섹션
                  _buildPreferenceFeedbackSection(),
                  const SizedBox(height: 24),
                  
                  // 코디 아이템 섹션
                  _buildOutfitItemsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.thermostat, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                '이 코디는 어떠셨나요?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTemperatureButton(
                  '추워요',
                  Icons.ac_unit,
                  'cold',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTemperatureButton(
                  '딱 좋아요',
                  Icons.wb_sunny,
                  'perfect',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTemperatureButton(
                  '더워요',
                  Icons.local_fire_department,
                  'hot',
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureButton(String text, IconData icon, String value, Color color) {
    final isSelected = selectedTemperature == value;
    return GestureDetector(
      onTap: () => _handleTemperatureFeedback(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.thumb_up, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                '이 룩이 마음에 드시나요?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: _handlePreferenceFeedback,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isLiked ? Colors.blue.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isLiked ? Colors.blue : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      color: isLiked ? Colors.blue : Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isLiked ? '이 룩이 좋아요' : '이 룩이 좋아요',
                      style: TextStyle(
                        fontSize: 14,
                        color: isLiked ? Colors.blue : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitItemsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                '코디 아이템',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '각 아이템을 클릭하면 대체 상품을 볼 수 있어요',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          
          // 아이템 리스트
          _buildOutfitItem('블라우스', '자라', '79,000원', Icons.checkroom, Colors.blue),
          const SizedBox(height: 12),
          _buildOutfitItem('슬랙스', '유니클로', '49,000원', Icons.checkroom, Colors.blue),
          const SizedBox(height: 12),
          _buildOutfitItem('블레이저', 'COS', '189,000원', Icons.checkroom, Colors.brown),
          const SizedBox(height: 12),
          _buildOutfitItem('로퍼', '에잇세컨즈', '89,000원', Icons.shopping_bag, Colors.pink),
          
          const SizedBox(height: 24),
          
          // 쇼핑몰 바로가기
          _buildShoppingMallSection(),
          
          const SizedBox(height: 16),
          
          // 다른 코디 추천받기 버튼
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Text(
                  '다른 코디 추천받기',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitItem(String name, String brand, String price, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  brand,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '구매',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingMallSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.shopping_bag, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            const Text(
              '쇼핑몰 바로가기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text(
                      '쿠팡에서 구매',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Text(
                      '무신사에서 구매',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
