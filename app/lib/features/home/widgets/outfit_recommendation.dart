import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/home_providers.dart';
import '../../../theme/app_theme.dart';
import '../../../services/pinterest_api_service.dart';

class OutfitRecommendation extends ConsumerStatefulWidget {
  const OutfitRecommendation({super.key});

  @override
  ConsumerState<OutfitRecommendation> createState() => _OutfitRecommendationState();
}

class _OutfitRecommendationState extends ConsumerState<OutfitRecommendation> {
  String _selectedSituation = '출근';

  final List<SituationOption> _situations = [
    SituationOption('출근', '💼', Colors.brown),
    SituationOption('데이트', '💕', Colors.pink),
    SituationOption('운동', '💪', Colors.orange),
    SituationOption('여행', '✈️', Colors.blue),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(isLoadingProvider);

    if (isLoading) {
      return _buildLoadingCard(theme);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppTheme.borderRadiusAll,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
              Text(
            '상황별 추천',
                style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '오늘 어떤 상황인가요?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),

          // Situation filters
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _situations.length,
              itemBuilder: (context, index) {
                final situation = _situations[index];
                final isSelected = _selectedSituation == situation.name;
                
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSituation = situation.name;
                      });
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? situation.color.withOpacity(0.1) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? situation.color : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
            children: [
                          Text(
                            situation.icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            situation.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? situation.color : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Outfit grid
          _buildOutfitGrid(theme),
        ],
      ),
    );
  }

  Widget _buildOutfitGrid(ThemeData theme) {
    return FutureBuilder<List<OutfitCard>>(
      future: _getOutfitsForSituation(_selectedSituation),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingGrid(theme);
        }
        
        if (snapshot.hasError) {
          return _buildErrorGrid(theme);
        }
        
        final outfits = snapshot.data ?? [];
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: outfits.length,
          itemBuilder: (context, index) {
            final outfit = outfits[index];
            return _buildOutfitCard(outfit, theme);
          },
        );
      },
    );
  }

  Widget _buildLoadingGrid(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildErrorGrid(ThemeData theme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('코디를 불러올 수 없습니다'),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitCard(OutfitCard outfit, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Image
              Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: outfit.imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: outfit.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Text(
                              outfit.imageEmoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          outfit.imageEmoji,
                          style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),
            // Content
              Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          outfit.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      outfit.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Tags
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: outfit.tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }

  Future<List<OutfitCard>> _getOutfitsForSituation(String situation) async {
    // 현재는 더미 데이터 사용 (Pinterest API 연동 준비 중)
    print('상황별 추천 로딩: $situation');
    await Future.delayed(const Duration(milliseconds: 500)); // 로딩 시뮬레이션
    return _getMockOutfitsForSituation(situation);
  }

  List<OutfitCard> _getMockOutfitsForSituation(String situation) {
    switch (situation) {
      case '출근':
        return [
          OutfitCard('👩‍💼', 4.8, '프로페셔널 룩', ['프로페셔널', '깔끔한'],
            imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=400&fit=crop&auto=format'),
          OutfitCard('👔', 4.6, '비즈니스 캐주얼', ['프로페셔널', '깔끔한'],
            imageUrl: 'https://images.unsplash.com/photo-1594938298605-cd2d7e3b8b2a?w=300&h=400&fit=crop&auto=format'),
          OutfitCard('👨‍💼', 4.7, '모던 오피스 룩', ['프로페셔널', '깔끔한'],
            imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&h=400&fit=crop&auto=format'),
          OutfitCard('👩‍💻', 4.5, '엘레강트 워크웨어', ['프로페셔널', '깔끔한'],
            imageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=300&h=400&fit=crop&auto=format'),
        ];
      case '데이트':
        return [
          OutfitCard('💃', 4.9, '로맨틱 드레스', ['우아한', '로맨틱'],
            imageUrl: 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=300&h=400&fit=crop&auto=format'),
          OutfitCard('👗', 4.7, '캐주얼 데이트', ['편안한', '스타일리시'],
            imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=300&h=400&fit=crop&auto=format'),
          OutfitCard('👔', 4.8, '클래식 정장', ['우아한', '클래식'],
            imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=400&fit=crop&auto=format'),
          OutfitCard('👕', 4.6, '캐주얼 룩', ['편안한', '트렌디'],
            imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c172c3db64?w=300&h=400&fit=crop&auto=format'),
        ];
      case '운동':
        return [
          OutfitCard('🏃‍♀️', 4.8, '러닝 룩', ['편안한', '기능성'],
            imageUrl: 'https://images.unsplash.com/photo-1544966503-7cc4a7b1bc8f?w=300&h=400&fit=crop&auto=format'),
          OutfitCard('💪', 4.7, '헬스장 룩', ['편안한', '기능성'],
            imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=400&fit=crop&auto=format'),
          OutfitCard('🧘‍♀️', 4.6, '요가 룩', ['편안한', '자연스러운'],
            imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=300&h=400&fit=crop&auto=format'),
          OutfitCard('⚽', 4.9, '스포츠 룩', ['편안한', '기능성'],
            imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=400&fit=crop&auto=format'),
        ];
      case '여행':
        return [
          OutfitCard('✈️', 4.8, '여행 룩', ['편안한', '실용적'],
            imageUrl: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=300&h=400&fit=crop&auto=format'),
          OutfitCard('🎒', 4.7, '백패킹 룩', ['편안한', '실용적'],
            imageUrl: 'https://images.unsplash.com/photo-1506905925346-14b5e4c4b4b4?w=300&h=400&fit=crop&auto=format'),
          OutfitCard('📸', 4.9, '포토 룩', ['스타일리시', '인스타그램'],
            imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=300&h=400&fit=crop&auto=format'),
          OutfitCard('🌍', 4.6, '어드벤처 룩', ['편안한', '실용적'],
            imageUrl: 'https://images.unsplash.com/photo-1506905925346-14b5e4c4b4b4?w=300&h=400&fit=crop&auto=format'),
        ];
      default:
        return [];
    }
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppTheme.borderRadiusAll,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 16,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildLoadingItem(theme),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLoadingItem(theme),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLoadingItem(theme),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingItem(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withOpacity(0.1),
        borderRadius: AppTheme.borderRadiusAll,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 10,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }

}

class SituationOption {
  final String name;
  final String icon;
  final Color color;

  SituationOption(this.name, this.icon, this.color);
}

class OutfitCard {
  final String imageEmoji;
  final double rating;
  final String title;
  final List<String> tags;
  final String? imageUrl; // 실제 이미지 URL
  final String? link; // Pinterest 링크

  OutfitCard(
    this.imageEmoji, 
    this.rating, 
    this.title, 
    this.tags, {
    this.imageUrl,
    this.link,
  });

  // API 연동을 위한 JSON 파싱 메서드
  factory OutfitCard.fromJson(Map<String, dynamic> json) {
    return OutfitCard(
      json['imageEmoji'] ?? '👕',
      (json['rating'] ?? 4.0).toDouble(),
      json['title'] ?? '코디',
      List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'],
      link: json['link'],
    );
  }

  // API 전송을 위한 JSON 변환 메서드
  Map<String, dynamic> toJson() {
    return {
      'imageEmoji': imageEmoji,
      'rating': rating,
      'title': title,
      'tags': tags,
      'imageUrl': imageUrl,
      'link': link,
    };
  }
}

