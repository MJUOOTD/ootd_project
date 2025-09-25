import 'package:flutter/material.dart';

class HourlyRecommendationWidget extends StatelessWidget {
  const HourlyRecommendationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '시간별 추천',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              '옷차림을 체감온도 기준으로 제공하고 있습니다.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),

            const SizedBox(height: 16),

            // 가로 스크롤 시간대 카드
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 8, // 현재 시간부터 8시간
                itemBuilder: (context, index) {
                  final displayHour = (now.hour + index) % 24;
                  final timeSlot = _getTimeSlot(displayHour);
                  final weatherEmoji = _getWeatherEmoji(displayHour);
                  final recommendation = _getRecommendation(displayHour);
                  final temperature = _getTemperature(displayHour);

                  return Container(
                    width: 80,
                    height: 100,
                    margin: const EdgeInsets.only(right: 16),
                    child: InkWell(
                      onTap: () => _showAlternativeOptions(context, displayHour),
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            index == 0 ? '지금' : timeSlot,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weatherEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: Text(
                              recommendation,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$temperature°',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 스크롤 힌트
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.keyboard_arrow_left, color: Colors.grey[400], size: 16),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.keyboard_arrow_right, color: Colors.grey[400], size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeSlot(int hour) {
    final displayHour = hour % 24;
    return '${displayHour.toString().padLeft(2, '0')}:00';
  }

  String _getWeatherEmoji(int hour) {
    // 실제 날씨 이모티콘 반환 (비, 맑음, 눈 등) - 데모용
    const weatherConditions = [
      '☔', // 비
      '🌞', // 맑음
      '❄', // 눈
      '⛅', // 구름
      '🌧', // 소나기
      '🌤', // 맑음
      '☁', // 흐림
      '🌦', // 소나기
    ];
    final weatherIndex = hour % weatherConditions.length;
    return weatherConditions[weatherIndex];
  }

  String _getRecommendation(int hour) {
    // 시간대별 추천 옷차림 (데모용)
    return '반팔티';
  }

  int _getTemperature(int hour) {
    // 간단 체감온도 데모
    final h = hour % 24;
    if (h < 6) return 22;
    if (h < 12) return 24;
    if (h < 18) return 26;
    return 25;
  }

  void _showAlternativeOptions(BuildContext context, int hour) {
    final timeSlot = hour == DateTime.now().hour ? '지금' : _getTimeSlot(hour);
    final weatherEmoji = _getWeatherEmoji(hour);
    final temperature = _getTemperature(hour);
    final currentRecommendation = _getRecommendation(hour);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('👕', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        '$timeSlot 추천 대체 옷차림',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Current recommendation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$timeSlot 기본 추천',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(weatherEmoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Text(
                          '$currentRecommendation - $temperature℃',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Alternative options
              const Text(
                '다른 옷차림 옵션',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              
              ..._getAlternativeOptionsWithDetails(hour).map(
                (option) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Text(option.icon, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  option.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Bottom tip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '체온 민감도와 개인 취향에 따라 선택하세요',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
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

  List<String> _getAlternativeOptions(int hour) {
    final weatherEmoji = _getWeatherEmoji(hour);

    if (weatherEmoji == '☔' || weatherEmoji == '🌧' || weatherEmoji == '🌦') {
      return ['우산', '레인부츠', '방수재킷'];
    } else if (weatherEmoji == '❄') {
      return ['목도리', '장갑', '두꺼운 코트'];
    } else if (weatherEmoji == '🌞' || weatherEmoji == '🌤') {
      return ['모자', '자외선차단제', '시원한 옷'];
    } else if (weatherEmoji == '⛅' || weatherEmoji == '☁') {
      return ['가디건', '스웨터', '야상'];
    } else {
      return ['편한 옷', '실용적 옷차림', '계절 옷'];
    }
  }

  List<AlternativeOption> _getAlternativeOptionsWithDetails(int hour) {
    final weatherEmoji = _getWeatherEmoji(hour);

    if (weatherEmoji == '☔' || weatherEmoji == '🌧' || weatherEmoji == '🌦') {
      return [
        AlternativeOption('☔', '우산', '비를 막아주는 필수 아이템'),
        AlternativeOption('👢', '레인부츠', '물에 젖지 않는 신발'),
        AlternativeOption('🧥', '방수재킷', '완전 방수 기능의 외투'),
      ];
    } else if (weatherEmoji == '❄') {
      return [
        AlternativeOption('🧣', '목도리', '목을 따뜻하게 보호'),
        AlternativeOption('🧤', '장갑', '손을 따뜻하게 유지'),
        AlternativeOption('🧥', '두꺼운 코트', '추위를 막는 보온 외투'),
      ];
    } else if (weatherEmoji == '🌞' || weatherEmoji == '🌤') {
      return [
        AlternativeOption('👕', '얇은 긴팔', '시원하고 가벼운 재질'),
        AlternativeOption('👗', '민소매', '더 시원한 착용감'),
        AlternativeOption('👔', '린넨 셔츠', '통기성이 좋은 소재'),
      ];
    } else if (weatherEmoji == '⛅' || weatherEmoji == '☁') {
      return [
        AlternativeOption('🧥', '가디건', '간편한 보온 아이템'),
        AlternativeOption('👕', '스웨터', '따뜻하고 편안한 착용감'),
        AlternativeOption('🧥', '야상', '활동하기 좋은 외투'),
      ];
    } else {
      return [
        AlternativeOption('👕', '얇은 긴팔', '시원하고 가벼운 재질'),
        AlternativeOption('👗', '민소매', '더 시원한 착용감'),
        AlternativeOption('👔', '린넨 셔츠', '통기성이 좋은 소재'),
      ];
    }
  }
}

class AlternativeOption {
  final String icon;
  final String name;
  final String description;

  AlternativeOption(this.icon, this.name, this.description);
}
