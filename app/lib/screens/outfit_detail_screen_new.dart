import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OutfitDetailScreenNew extends StatelessWidget {
  final String situation;
  
  const OutfitDetailScreenNew({super.key, required this.situation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$situation 룩 상세'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 룩 이미지 영역
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getSituationIcon(),
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '$situation 룩 이미지',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.favorite_border,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 룩 설명
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$situation 룩 추천',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getSituationDescription(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 아이템 리스트
                        ..._getOutfitItems().map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.black,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 스타일 팁
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFFFFB300),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '스타일 팁',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getStyleTip(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 하단 피드백 섹션
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  '이 코디는 어떠셨나요?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFeedbackButton('🥶', '추워요', () => _showLoginPrompt(context)),
                    _buildFeedbackButton('👌', '딱 좋아요', () => _showLoginPrompt(context)),
                    _buildFeedbackButton('🥵', '더워요', () => _showLoginPrompt(context)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  '이 룩이 마음에 드시나요?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLoginPrompt(context),
                    icon: const Text('👍'),
                    label: const Text('이 룩이 좋아요'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton(String emoji, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.black,
            ),
            SizedBox(width: 8),
            Text('로그인이 필요해요'),
          ],
        ),
        content: const Text(
          '피드백을 주시면 더 정확한 추천을 받을 수 있어요',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Use go_router route name to navigate
              // ignore: use_build_context_synchronously
              context.pushNamed('login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(239, 107, 141, 252),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('로그인하기'),
          ),
        ],
      ),
    );
  }

  IconData _getSituationIcon() {
    switch (situation) {
      case '출근':
        return Icons.business;
      case '데이트':
        return Icons.favorite;
      case '운동':
        return Icons.sports;
      case '여행':
        return Icons.flight;
      default:
        return Icons.checkroom;
    }
  }

  String _getSituationDescription() {
    switch (situation) {
      case '출근':
        return '업무 환경에 적합한 깔끔하고 전문적인 룩을 추천해드려요. 상황에 맞는 적절한 격식과 개성을 동시에 표현할 수 있는 스타일링입니다.';
      case '데이트':
        return '특별한 순간을 위한 로맨틱하고 세련된 룩을 제안해드려요. 상대방에게 좋은 인상을 남길 수 있는 매력적인 스타일링입니다.';
      case '운동':
        return '활동적인 하루를 위한 편안하고 기능적인 운동복을 추천해드려요. 움직임이 많은 상황에 최적화된 스포츠웨어입니다.';
      case '여행':
        return '여행지에서의 편안함과 스타일을 동시에 잡을 수 있는 룩을 제안해드려요. 긴 이동시간에도 편안하고 어디서든 멋진 사진을 찍을 수 있는 스타일링입니다.';
      default:
        return '상황에 맞는 최적의 룩을 추천해드려요.';
    }
  }

  List<String> _getOutfitItems() {
    switch (situation) {
      case '출근':
        return [
          '정장 또는 블레이저',
          '깔끔한 셔츠 또는 블라우스',
          '슬랙스 또는 스커트',
          '구두 또는 로퍼',
          '가방 (토트백 또는 서류가방)',
        ];
      case '데이트':
        return [
          '원피스 또는 세련된 상의',
          '스커트 또는 청바지',
          '힐 또는 앵클부츠',
          '가방 (크로스백 또는 토트백)',
          '액세서리 (목걸이, 귀걸이)',
        ];
      case '운동':
        return [
          '기능성 운동 상의',
          '편안한 운동 바지',
          '운동화',
          '스포츠 브라',
          '수건과 물병',
        ];
      case '여행':
        return [
          '편안한 상의 (티셔츠, 블라우스)',
          '편한 바지 (청바지, 슬랙스)',
          '운동화 또는 플랫슈즈',
          '가방 (백팩 또는 크로스백)',
          '자외선 차단제와 선글라스',
        ];
      default:
        return ['상의', '하의', '신발', '가방'];
    }
  }

  String _getStyleTip() {
    switch (situation) {
      case '출근':
        return '깔끔한 색상 조합을 선택하고, 과도한 액세서리는 피하세요. 상의는 꼭 맞는 사이즈로, 하의는 적당한 길이를 유지하는 것이 중요해요.';
      case '데이트':
        return '상대방의 취향을 고려하되, 본인의 개성도 살리세요. 과하지 않은 액세서리로 포인트를 주고, 편안하면서도 매력적인 스타일을 추천해요.';
      case '운동':
        return '흡수성이 좋은 소재를 선택하고, 활동량에 맞는 적절한 크기를 선택하세요. 운동화는 발에 꼭 맞는 사이즈로, 부상을 방지할 수 있어요.';
      case '여행':
        return '여러 벌을 레이어링할 수 있는 아이템들을 선택하세요. 색상은 조화롭게, 소재는 구김 방지가 잘 되는 것을 추천해요.';
      default:
        return '상황에 맞는 적절한 스타일링을 선택하세요.';
    }
  }
}
