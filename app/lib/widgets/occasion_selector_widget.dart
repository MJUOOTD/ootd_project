import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recommendation_provider.dart';
import '../models/weather_model.dart';
import '../models/user_model.dart';

class OccasionSelectorWidget extends ConsumerStatefulWidget {
  final WeatherModel weather;
  final UserModel user;

  const OccasionSelectorWidget({
    super.key,
    required this.weather,
    required this.user,
  });

  @override
  ConsumerState<OccasionSelectorWidget> createState() => _OccasionSelectorWidgetState();
}

class _OccasionSelectorWidgetState extends ConsumerState<OccasionSelectorWidget> {
  String _selectedOccasion = 'casual';

  final List<Map<String, dynamic>> _occasions = [
    {
      'id': 'casual',
      'name': '캐주얼',
      'icon': Icons.sports_esports,
      'description': '일상적인 외출',
      'color': const Color(0xFF4CAF50),
    },
    {
      'id': 'work',
      'name': '출근',
      'icon': Icons.business,
      'description': '직장 출근',
      'color': const Color(0xFF2196F3),
    },
    {
      'id': 'date',
      'name': '데이트',
      'icon': Icons.favorite,
      'description': '데이트나 모임',
      'color': const Color(0xFFE91E63),
    },
    {
      'id': 'exercise',
      'name': '운동',
      'icon': Icons.fitness_center,
      'description': '운동이나 활동',
      'color': const Color(0xFFFF9800),
    },
    {
      'id': 'formal',
      'name': '정장',
      'icon': Icons.business_center,
      'description': '공식적인 자리',
      'color': const Color(0xFF9C27B0),
    },
    {
      'id': 'travel',
      'name': '여행',
      'icon': Icons.flight,
      'description': '여행이나 휴가',
      'color': const Color(0xFF00BCD4),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '상황별 추천',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF030213),
            ),
          ),
          const SizedBox(height: 12),
          
          // Occasion Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _occasions.length,
              itemBuilder: (context, index) {
                final occasion = _occasions[index];
                final isSelected = _selectedOccasion == occasion['id'];
                
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => _selectOccasion(occasion['id']),
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? occasion['color'] : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? occasion['color'] : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            occasion['icon'],
                            size: 20,
                            color: isSelected ? Colors.white : occasion['color'],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            occasion['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : occasion['color'],
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
          
          const SizedBox(height: 16),
          
          // Generate Recommendations Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generateRecommendations,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('추천 받기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF030213),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectOccasion(String occasionId) {
    setState(() {
      _selectedOccasion = occasionId;
    });
  }

  void _generateRecommendations() async {
    final recommendationProvider = ref.read(recommendationProviderProvider.notifier);
    
    await recommendationProvider.filterByOccasion(
      _selectedOccasion,
      weather: widget.weather,
      user: widget.user,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getOccasionName(_selectedOccasion)} 스타일 추천을 생성했습니다'),
          backgroundColor: const Color(0xFF030213),
        ),
      );
    }
  }

  String _getOccasionName(String occasionId) {
    final occasion = _occasions.firstWhere((o) => o['id'] == occasionId);
    return occasion['name'];
  }
}
