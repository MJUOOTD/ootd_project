import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ootd_app/providers/weather_provider.dart';
import 'package:ootd_app/models/weather_model.dart';
// removed unused: weather_model import not needed after using internal _HourlyItem

class HourlyRecommendationWidget extends ConsumerWidget {
  const HourlyRecommendationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);
    final List<_HourlyItem> hourly = _build3HourSlotsFromForecast(weatherState);

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
                itemCount: hourly.length,
                itemBuilder: (context, index) {
                  final item = hourly[index];
                  final dt = item.time;
                  final displayHour = dt.hour;
                  final now = DateTime.now();
                  final alignedNow = DateTime(now.year, now.month, now.day, now.hour - (now.hour % 3));
                  final isNow = dt.year == alignedNow.year && dt.month == alignedNow.month && dt.day == alignedNow.day && dt.hour == alignedNow.hour;
                  final timeSlot = _formatTimeSlot(dt);
                  final icon = _materialIconFromCondition(item.condition);
                  final recommendation = _getRecommendation(dt.hour);
                  final String temperatureText = item.temperature.toStringAsFixed(1);

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
                            isNow ? '지금' : timeSlot,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(icon, size: 20, color: Colors.grey[800]),
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
                            '$temperatureText°',
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

  List<_HourlyItem> _build3HourSlotsFromForecast(dynamic weatherState) {
    final List<WeatherModel> forecast = (weatherState.forecast as List).cast<WeatherModel>();
    if (forecast.length >= 2) {
      // 정상 예보: 상위 8개 사용
      return forecast.take(8).map<_HourlyItem>((m) => _HourlyItem(time: m.timestamp, temperature: m.temperature, condition: m.condition)).toList();
    }
    // 예보가 0~1개여도 최소 8칸 보장: 기준 시각부터 3시간씩 증가
    final now = DateTime.now();
    final WeatherModel? current = weatherState.currentWeather as WeatherModel?;
    final DateTime aligned = DateTime(now.year, now.month, now.day, now.hour - (now.hour % 3));
    final double temp = forecast.isNotEmpty ? forecast.first.temperature : (current?.temperature ?? 22.0);
    final String cond = forecast.isNotEmpty ? forecast.first.condition : (current?.condition ?? 'Clear');
    return List.generate(8, (i) {
      final t = aligned.add(Duration(hours: 3 * i));
      return _HourlyItem(
        time: t,
        temperature: temp,
        condition: cond,
      );
    });
  }

  String _formatTimeSlot(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _emojiFromCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '🌞';
      case 'clouds':
      case 'overcast':
        return '⛅';
      case 'rain':
        return '🌧';
      case 'snow':
        return '❄';
      case 'thunderstorm':
        return '⛈';
      case 'mist':
      case 'fog':
        return '🌫';
      default:
        return '☁';
    }
  }

  IconData _materialIconFromCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
      case 'overcast':
        return Icons.cloud;
      case 'rain':
        return Icons.umbrella;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'mist':
      case 'fog':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
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

class _HourlyItem {
  final DateTime time;
  final double temperature;
  final String condition;

  _HourlyItem({required this.time, required this.temperature, required this.condition});
}
