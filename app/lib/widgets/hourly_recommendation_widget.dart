import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';
import '../screens/city_search_screen.dart';

class HourlyRecommendationWidget extends ConsumerStatefulWidget {
  const HourlyRecommendationWidget({super.key});

  @override
  ConsumerState<HourlyRecommendationWidget> createState() => _HourlyRecommendationWidgetState();
}

class _HourlyRecommendationWidgetState extends ConsumerState<HourlyRecommendationWidget> {
  bool _hasShownDialog = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weatherState = ref.watch(weatherProvider);
    final forecast = weatherState.forecast;
    final error = weatherState.error;
    
    // 위치 권한이 없는 경우 안내 메시지 표시
    final hasLocationPermissionError = error != null && 
        (error.contains('현재 위치를 불러올 수 없음') || error.contains('위치 권한') || error.contains('permission') || error.contains('Permission') || error.contains('LocationException'));

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

            // 위치 권한이 없는 경우 팝업 표시
            if (hasLocationPermissionError) ...[
              // 위치 권한 오류 시 팝업 표시 (한 번만)
              if (!_hasShownDialog) 
                Builder(
                  builder: (context) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _hasShownDialog = true;
                        });
                        _showLocationPermissionDialog(context);
                      }
                    });
                    return const SizedBox.shrink();
                  },
                ),
              // 위치 권한 오류 시 빈 컨테이너 표시
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '현재 위치를 불러올 수 없음',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // 가로 스냅 스크롤 (카드 단위)
              SizedBox(
                height: 120,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.28), // 카드가 살짝 보이도록
                  padEnds: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: forecast.isNotEmpty ? forecast.length : 24,
                  itemBuilder: (context, index) {
                    if (forecast.isNotEmpty && index < forecast.length) {
                      final weather = forecast[index];
                      final weatherTime = weather.timestamp;
                      final displayHour = weatherTime.hour;
                      final displayMinute = weatherTime.minute;
                      final timeSlot = _getTimeSlotWithDate(weatherTime, displayHour, displayMinute);
                      final weatherEmoji = _getWeatherEmojiFromCondition(weather.condition, displayHour);
                      final recommendation = _getRecommendationFromTemperature(weather.temperature);
                      final temperature = weather.temperature.round();
                      return _buildHourlyCard(
                        context,
                        timeSlot,
                        weatherEmoji,
                        recommendation,
                        temperature,
                        displayHour,
                        weather.isCurrent,
                      );
                    } else {
                      final displayHour = (now.hour + index) % 24;
                      final timeSlot = _getTimeSlot(displayHour);
                      final weatherEmoji = _getWeatherEmoji(displayHour);
                      final recommendation = _getRecommendation(displayHour);
                      final temperature = _getTemperature(displayHour);
                      return _buildHourlyCard(
                        context,
                        timeSlot,
                        weatherEmoji,
                        recommendation,
                        temperature,
                        displayHour,
                        false,
                      );
                    }
                  },
                ),
              ),
            ],

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

  Widget _buildHourlyCard(
    BuildContext context,
    String timeSlot,
    String weatherEmoji,
    String recommendation,
    int temperature,
    int displayHour,
    bool isCurrent,
  ) {
    return Container(
      width: 80,
      height: 120,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () => _showAlternativeOptions(context, displayHour),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isCurrent ? '지금' : timeSlot,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              weatherEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              recommendation,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              '$temperature°',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeSlot(int hour, [int? minute]) {
    final displayHour = hour % 24;
    if (minute != null) {
      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
    return '${displayHour.toString().padLeft(2, '0')}:00';
  }

  String _getTimeSlotWithDate(DateTime weatherTime, int hour, int minute) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weatherDay = DateTime(weatherTime.year, weatherTime.month, weatherTime.day);
    
    final displayHour = hour % 24;
    final timeString = '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    
    // 날짜 차이 계산
    final dayDifference = weatherDay.difference(today).inDays;
    
    if (dayDifference == 0) {
      return timeString; // 오늘
    } else if (dayDifference == 1) {
      return '내일\n$timeString';
    } else if (dayDifference == 2) {
      return '모레\n$timeString';
    } else {
      return '${weatherTime.month}/${weatherTime.day}\n$timeString';
    }
  }


  String _getWeatherEmojiFromCondition(String condition, int hour) {
    // 계절별 일출/일몰 시간 (한국 기준, 월별 근사값)
    final now = DateTime.now();
    final month = now.month;
    
    // 월별 일출/일몰 시간 (한국 기준)
    final sunriseSunsetTimes = _getSunriseSunsetTimes(month);
    final sunrise = sunriseSunsetTimes['sunrise']!;
    final sunset = sunriseSunsetTimes['sunset']!;
    
    // 현재 시간이 낮인지 밤인지 판단
    final isDaytime = hour >= sunrise && hour < sunset;
    
    print('[HourlyWidget] Weather icon: month=$month, hour=$hour, sunrise=$sunrise, sunset=$sunset, isDaytime=$isDaytime, condition=$condition');
    
    // 시간대별 아이콘 맵
    final dayIconMap = {
      'Clear': '☀️',        // 낮 맑음: 해
      'Clouds': '⛅',       // 낮 구름
      'Rain': '🌦️',        // 낮 비
      'Snow': '🌨️',        // 낮 눈
      'Thunderstorm': '⛈️', // 낮 뇌우
      'Fog': '🌫️',         // 낮 안개
    };
    
    final nightIconMap = {
      'Clear': '🌙',        // 밤 맑음: 달
      'Clouds': '☁️',       // 밤 구름
      'Rain': '🌧️',        // 밤 비
      'Snow': '❄️',        // 밤 눈
      'Thunderstorm': '⛈️', // 밤 뇌우
      'Fog': '🌫️',         // 밤 안개
    };
    
    final iconMap = isDaytime ? dayIconMap : nightIconMap;
    return iconMap[condition] ?? (isDaytime ? '🌤️' : '🌙');
  }

  // 월별 일출/일몰 시간 반환 (한국 기준)
  Map<String, int> _getSunriseSunsetTimes(int month) {
    switch (month) {
      case 1:  // 1월
        return {'sunrise': 7, 'sunset': 17};
      case 2:  // 2월
        return {'sunrise': 7, 'sunset': 18};
      case 3:  // 3월
        return {'sunrise': 6, 'sunset': 18};
      case 4:  // 4월
        return {'sunrise': 6, 'sunset': 19};
      case 5:  // 5월
        return {'sunrise': 5, 'sunset': 19};
      case 6:  // 6월
        return {'sunrise': 5, 'sunset': 20};
      case 7:  // 7월
        return {'sunrise': 5, 'sunset': 20};
      case 8:  // 8월
        return {'sunrise': 6, 'sunset': 19};
      case 9:  // 9월
        return {'sunrise': 6, 'sunset': 18};
      case 10: // 10월
        return {'sunrise': 6, 'sunset': 18};
      case 11: // 11월
        return {'sunrise': 7, 'sunset': 17};
      case 12: // 12월
        return {'sunrise': 7, 'sunset': 17};
      default:
        return {'sunrise': 6, 'sunset': 18}; // 기본값
    }
  }

  String _getRecommendationFromTemperature(double temperature) {
    if (temperature < 0) return '패딩';
    if (temperature < 5) return '코트';
    if (temperature < 10) return '자켓';
    if (temperature < 15) return '가디건';
    if (temperature < 20) return '긴팔';
    if (temperature < 25) return '반팔';
    return '민소매';
  }

  // 기존 mock 데이터 메서드들 (fallback용)
  String _getWeatherEmoji(int hour) {
    const weatherConditions = [
      '☔', '🌞', '❄', '⛅', '🌧', '🌤', '☁', '🌦',
    ];
    final weatherIndex = hour % weatherConditions.length;
    return weatherConditions[weatherIndex];
  }

  String _getRecommendation(int hour) {
    return '반팔티';
  }

  int _getTemperature(int hour) {
    final h = hour % 24;
    if (h < 6) return 22;
    if (h < 12) return 24;
    if (h < 18) return 26;
    return 25;
  }

  void _showAlternativeOptions(BuildContext context, int hour) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${hour.toString().padLeft(2, '0')}:00 옷차림 옵션'),
            const SizedBox(height: 16),
            const Text('추가 옵션들이 여기에 표시됩니다.'),
          ],
        ),
      ),
    );
  }

  void _showLocationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.location_off,
                color: Colors.orange[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('위치 정보 필요'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '현재 위치 정보를 가져올 수 없어 정확한 날씨 정보 제공이 어렵습니다.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '위치 검색 버튼을 눌러 원하는 위치의 날씨를 확인하거나, 설정에서 위치 권한을 확인해주세요.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 위치 검색 화면으로 이동
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CitySearchScreen(),
                  ),
                );
              },
              child: const Text('위치 검색'),
            ),
          ],
        );
      },
    );
  }
}