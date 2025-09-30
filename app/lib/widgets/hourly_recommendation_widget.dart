import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
// Removed popup navigation dependency to avoid cross-page dialogs

class HourlyRecommendationWidget extends ConsumerStatefulWidget {
  const HourlyRecommendationWidget({super.key});

  @override
  ConsumerState<HourlyRecommendationWidget> createState() => _HourlyRecommendationWidgetState();
}

class _HourlyRecommendationWidgetState extends ConsumerState<HourlyRecommendationWidget> {

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weatherState = ref.watch(weatherProvider);
    final forecast = weatherState.forecast;
    final userState = ref.watch(userProvider);
    final tempSensitivity = userState.currentUser?.temperatureSensitivity ?? TemperatureSensitivity.normal;
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
              children: const [
                Text(
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

            // 위치 권한이 없는 경우: 팝업 없이 간단한 자리표시만
            if (hasLocationPermissionError) ...[
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
                      final effectiveTemp = _applySensitivity(weather.feelsLike != 0 ? weather.feelsLike : weather.temperature, tempSensitivity);
                      final recData = _buildBackendStyleRecommendationForTemp(effectiveTemp);
                      final recommendation = recData.shortLabel;
                      final temperature = effectiveTemp.round();
                      return _buildHourlyCard(
                        context,
                        timeSlot,
                        weatherEmoji,
                        recommendation,
                        temperature,
                        displayHour,
                        weather.isCurrent,
                        recData: recData,
                      );
                    } else {
                      final displayHour = (now.hour + index) % 24;
                      final timeSlot = _getTimeSlot(displayHour);
                      final weatherEmoji = _getWeatherEmoji(displayHour);
                      final temperature = _getTemperature(displayHour);
                      final effectiveTemp = _applySensitivity(temperature.toDouble(), tempSensitivity);
                      final recData = _buildBackendStyleRecommendationForTemp(effectiveTemp);
                      final recommendation = recData.shortLabel;
                      return _buildHourlyCard(
                        context,
                        timeSlot,
                        weatherEmoji,
                        recommendation,
                        effectiveTemp.round(),
                        displayHour,
                        false,
                        recData: recData,
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
    {required _RecData recData}
  ) {
    return Container(
      width: 80,
      height: 120,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () => _showAlternativeOptions(context, displayHour, temperature.toDouble(), recData),
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
    // Deprecated in favor of backend-style mapping, keep as fallback
    if (temperature < 0) return '패딩';
    if (temperature < 5) return '코트';
    if (temperature < 10) return '자켓';
    if (temperature < 15) return '가디건';
    if (temperature < 20) return '긴팔';
    if (temperature < 25) return '반팔';
    return '민소매';
  }

  // 사용자 체감 민감도 반영 (WeatherModel.getAdjustedTemperature와 유사하게 적용)
  double _applySensitivity(double feelsLike, TemperatureSensitivity sensitivity) {
    switch (sensitivity) {
      case TemperatureSensitivity.veryCold:
        return feelsLike - 4.0;
      case TemperatureSensitivity.cold:
        return feelsLike - 2.0;
      case TemperatureSensitivity.normal:
        return feelsLike;
      case TemperatureSensitivity.hot:
        return feelsLike + 2.0;
      case TemperatureSensitivity.veryHot:
        return feelsLike + 4.0;
    }
  }

  // 백엔드 recommendService.js의 구간/품목 규칙을 단순화하여 반영
  _RecData _buildBackendStyleRecommendationForTemp(double personalFeel) {
    List<String> top = [];
    List<String> bottom = [];
    List<String> outer = [];
    List<String> shoes = [];
    List<String> accessories = [];

    if (personalFeel <= 5) {
      top = ['히트텍+니트', '터틀넥 니트', '후리스'];
      bottom = ['기모 슬랙스', '기모 청바지'];
      outer = ['롱패딩', '다운 파카'];
      shoes = ['부츠', '방수부츠'];
      accessories = ['목도리', '장갑', '니트 비니'];
    } else if (personalFeel <= 12) {
      top = ['니트', '후드티', '가벼운 스웨터'];
      bottom = ['슬랙스', '청바지'];
      outer = ['코트', '패딩 베스트'];
      shoes = ['부츠', '스니커즈'];
      accessories = ['머플러', '비니'];
    } else if (personalFeel <= 18) {
      top = ['맨투맨', '셔츠+티', '경량 니트'];
      bottom = ['청바지', '치노 팬츠'];
      outer = ['가벼운 자켓', '블루종'];
      shoes = ['스니커즈', '로퍼'];
      accessories = [];
    } else if (personalFeel <= 24) {
      top = ['긴팔 티', '얇은 셔츠', '카디건+티'];
      bottom = ['면바지', '린넨 팬츠'];
      outer = ['카디건', '얇은 셔츠'];
      shoes = ['스니커즈', '로퍼'];
      accessories = ['캡모자'];
    } else if (personalFeel <= 28) {
      top = ['반팔 티', '오버셔츠', '폴로 셔츠'];
      bottom = ['면반바지', '린넨 반바지'];
      outer = ['얇은 셔츠', '없음'];
      shoes = ['샌들/스니커즈', '스니커즈'];
      accessories = ['캡모자', '버킷햇'];
    } else {
      top = ['민소매/얇은 반팔', '드라이 티'];
      bottom = ['반바지'];
      outer = ['없음'];
      shoes = ['샌들'];
      accessories = ['선캡', '썬글라스'];
    }

    // 카드에 표시할 짧은 라벨: outer 우선, 없으면 top
    final String shortLabel = (outer.isNotEmpty && outer.first != '없음')
        ? outer.first
        : (top.isNotEmpty ? top.first : '추천');

    // 대체 옵션: 각 카테고리에서 1~2개씩 뽑아 목록 구성
    final List<String> alternatives = [
      if (outer.isNotEmpty) outer.first,
      if (top.isNotEmpty) top.first,
      if (bottom.isNotEmpty) bottom.first,
      if (shoes.isNotEmpty) shoes.first,
      ...accessories.take(2),
    ].where((e) => e.isNotEmpty && e != '없음').toList();

    // 기본 추천 상세 텍스트
    final String baseDetail = [
      if (outer.isNotEmpty && outer.first != '없음') outer.first,
      if (top.isNotEmpty) top.first,
      if (bottom.isNotEmpty) bottom.first,
      if (shoes.isNotEmpty) shoes.first,
    ].join(' · ');

    return _RecData(shortLabel: shortLabel, baseDetail: baseDetail, alternatives: alternatives);
  }

  // 기존 mock 데이터 메서드들 (fallback용)
  String _getWeatherEmoji(int hour) {
    const weatherConditions = [
      '☔', '🌞', '❄', '⛅', '🌧', '🌤', '☁', '🌦',
    ];
    final weatherIndex = hour % weatherConditions.length;
    return weatherConditions[weatherIndex];
  }

  // removed unused _getRecommendation

  int _getTemperature(int hour) {
    final h = hour % 24;
    if (h < 6) return 22;
    if (h < 12) return 24;
    if (h < 18) return 26;
    return 25;
  }

  void _showAlternativeOptions(BuildContext context, int hour, double temperature, _RecData recData) {
    final weatherState = ref.read(weatherProvider);
    final w = (weatherState.forecast.isNotEmpty)
        ? weatherState.forecast.first
        : weatherState.currentWeather;

    if (w == null) {
      return;
    }

    // 시간대 텍스트 생성
    final timeLabel = '${hour.toString().padLeft(2, '0')}시 추천 대체 옷차림';

    // 백엔드 스타일 규칙 기반(민감도 반영된 personalFeel로 이미 계산됨)
    final String baseRec = recData.baseDetail.isNotEmpty ? recData.baseDetail : _getRecommendationFromTemperature(temperature);
    final List<String> alternatives = recData.alternatives.isNotEmpty
        ? recData.alternatives
        : _buildAlternativeItemsForTemp(temperature);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.checkroom, color: Color(0xFF4F46E5)),
                      const SizedBox(width: 8),
                      Text(timeLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [
                        Text('기본 추천', style: TextStyle(fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 8),
                      Text('$baseRec · ${temperature.round()}°C', style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('다른 옷차림 옵션', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...alternatives.map((item) => _alternativeItemTile(item)).toList(),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('체온 민감도와 개인 취향에 따라 선택하세요', style: TextStyle(color: Color(0xFF8D6E63))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> _buildAlternativeItemsForTemp(double temp) {
    // 간단한 로컬 규칙: 서버 기본 추천을 보완하는 대체 아이템 3~4개 구성
    if (temp < 5) return ['숏패딩', '터틀넥 니트', '보온 레깅스'];
    if (temp < 10) return ['코트', '니트', '기모 팬츠'];
    if (temp < 15) return ['가디건', '긴팔 티', '청바지'];
    if (temp < 20) return ['셔츠', '얇은 가디건', '면바지'];
    if (temp < 25) return ['반팔 티', '린넨 셔츠', '치노 팬츠'];
    return ['민소매', '반바지', '샌들'];
  }

  Widget _alternativeItemTile(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFF4F46E5), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }

  // Popup removed to avoid showing on other tabs via IndexedStack
}

class _RecData {
  final String shortLabel; // 카드에 표시할 간단 라벨
  final String baseDetail; // 다이얼로그 상단 기본 조합 문자열
  final List<String> alternatives; // 대체 아이템 리스트

  _RecData({
    required this.shortLabel,
    required this.baseDetail,
    required this.alternatives,
  });
}