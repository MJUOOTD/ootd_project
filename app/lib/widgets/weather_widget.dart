import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ootd_app/providers/weather_provider.dart';
import 'package:ootd_app/models/weather_model.dart';
import '../screens/city_search_screen.dart';

class WeatherWidget extends ConsumerStatefulWidget {
  final WeatherModel? weather;
  final VoidCallback? onRefresh;

  const WeatherWidget({
    super.key,
    this.weather,
    this.onRefresh,
  });

  @override
  ConsumerState<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends ConsumerState<WeatherWidget> {
  bool _hasShownDialog = false;
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherProvider);
    final w = widget.weather ?? state.currentWeather;
    final isLoading = state.isLoading;
    final error = state.error;

    if (isLoading) return _buildSkeleton();
    if (w == null) return _buildEmpty();
    
    // 위치 관련 오류인 경우 안내 메시지 표시
    final hasLocationPermissionError = error != null && 
        (error.contains('현재 위치를 불러올 수 없음') || 
         error.contains('위치 서비스가 비활성화되어 있습니다') ||
         error.contains('위치 권한') || 
         error.contains('permission') || 
         error.contains('Permission') || 
         error.contains('LocationException'));
    
    // 에러가 있지만 날씨 데이터가 있는 경우 (fallback 상황)
    final hasError = error != null && error.isNotEmpty && !hasLocationPermissionError;
    
    // 위치 권한 오류 시 팝업 표시 (한 번만)
    if (hasLocationPermissionError && !_hasShownDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _hasShownDialog = true;
          _showLocationPermissionDialog(context);
        }
      });
    }
    
    return Container(
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.wb_sunny,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '오늘 날씨',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${w.temperature.round()}°C',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showCitySearch(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
        // 현재 위치 표시
        _buildLocationRow(w, hasLocationPermissionError),
          
          
          // 에러 메시지 표시 (fallback 상황)
          if (hasError) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Weather Info
          Row(
            children: [
              // Weather Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getWeatherIcon(w.condition, DateTime.now().hour),
                  size: 32,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(width: 16),
              
              // Weather Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getWeatherConditionKorean(w.condition),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getWeatherMessage(w.temperature),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Weather Details Grid
          Row(
            children: [
              Expanded(
                child: _buildWeatherDetail(
                  Icons.water_drop,
                  '습도',
                  '${w.humidity}%',
                ),
              ),
              Expanded(
                child: _buildWeatherDetail(
                  Icons.air,
                  '바람',
                  '${w.windSpeed.toStringAsFixed(1)}m/s',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Recommendation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getRecommendedOutfit(w.temperature),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
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

  Widget _buildSkeleton() {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
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
      child: const Center(
        child: Column(
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              '날씨 정보를 불러올 수 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition, int hour) {
    // 계절별 일출/일몰 시간 (한국 기준, 월별 근사값)
    final now = DateTime.now();
    final month = now.month;
    final sunriseSunsetTimes = _getSunriseSunsetTimes(month);
    final sunrise = sunriseSunsetTimes['sunrise']!;
    final sunset = sunriseSunsetTimes['sunset']!;
    
    // 현재 시간이 낮인지 밤인지 판단
    final isDaytime = hour >= sunrise && hour < sunset;
    
    print('[WeatherWidget] Weather icon: month=$month, hour=$hour, sunrise=$sunrise, sunset=$sunset, isDaytime=$isDaytime, condition=$condition');
    
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return isDaytime ? Icons.wb_sunny : Icons.nightlight_round; // 낮: 해, 밤: 달
      case 'cloudy':
      case 'partly cloudy':
        return isDaytime ? Icons.wb_cloudy : Icons.cloud; // 낮: 구름, 밤: 구름
      case 'rainy':
      case 'rain':
        return Icons.grain; // 비는 낮/밤 구분 없음
      case 'snowy':
      case 'snow':
        return Icons.ac_unit; // 눈은 낮/밤 구분 없음
      case 'windy':
        return Icons.air; // 바람은 낮/밤 구분 없음
      default:
        return isDaytime ? Icons.wb_sunny : Icons.nightlight_round; // 기본값
    }
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

  String _getWeatherConditionKorean(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return '맑음';
      case 'cloudy':
      case 'partly cloudy':
        return '구름많음';
      case 'rainy':
      case 'rain':
        return '비';
      case 'snowy':
      case 'snow':
        return '눈';
      case 'windy':
        return '바람';
      default:
        return '맑음';
    }
  }

  String _getWeatherMessage(double temperature) {
    if (temperature >= 30) {
      return '매우 더운 날씨입니다';
    } else if (temperature >= 25) {
      return '따뜻한 날씨입니다';
    } else if (temperature >= 20) {
      return '선선한 날씨입니다';
    } else if (temperature >= 15) {
      return '시원한 날씨입니다';
    } else if (temperature >= 10) {
      return '쌀쌀한 날씨입니다';
    } else {
      return '추운 날씨입니다';
    }
  }

  String _getRecommendedOutfit(double temperature) {
    if (temperature >= 30) {
      return '얇은 옷을 입으세요. 반팔, 반바지 추천';
    } else if (temperature >= 25) {
      return '가벼운 옷을 입으세요. 얇은 긴팔, 얇은 바지 추천';
    } else if (temperature >= 20) {
      return '적당한 옷을 입으세요. 긴팔, 긴바지 추천';
    } else if (temperature >= 15) {
      return '가벼운 겉옷을 입으세요. 가디건, 얇은 재킷 추천';
    } else if (temperature >= 10) {
      return '따뜻한 옷을 입으세요. 재킷, 스웨터 추천';
    } else {
      return '두꺼운 옷을 입으세요. 코트, 패딩 추천';
    }
  }

  Widget _buildLocationRow(WeatherModel weather, bool hasLocationPermissionError) {
    print('[WeatherWidget] Location debug:');
    print('[WeatherWidget] - city: "${weather.location.city}"');
    print('[WeatherWidget] - country: "${weather.location.country}"');
    print('[WeatherWidget] - district: "${weather.location.district}"');
    print('[WeatherWidget] - subLocality: "${weather.location.subLocality}"');
    print('[WeatherWidget] - formattedLocation: "${weather.location.formattedLocation}"');
    
    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: Colors.grey[500],
          size: 14,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            hasLocationPermissionError 
                ? '현재 위치를 불러올 수 없음'
                : (weather.location.formattedLocation.isNotEmpty && 
                   weather.location.formattedLocation != '현재 위치' &&
                   weather.location.formattedLocation != 'globe'
                    ? weather.location.formattedLocation 
                    : '위치 정보 없음'),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        // 위치 새로고침 버튼 (중복 방지를 위해 조건부 렌더링)
        if (!hasLocationPermissionError)
          _buildRefreshButton(),
      ],
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      key: const ValueKey('location_refresh_button'),
      child: GestureDetector(
        onTap: _isRefreshing ? null : () async {
          if (_isRefreshing) return;
          
          setState(() {
            _isRefreshing = true;
          });
          
          try {
            print('[WeatherWidget] Location refresh button tapped');
            await ref.read(weatherProvider.notifier).refreshCurrentLocation();
          } finally {
            if (mounted) {
              setState(() {
                _isRefreshing = false;
              });
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _isRefreshing ? Colors.grey[100] : Colors.blue[50],
            borderRadius: BorderRadius.circular(4),
          ),
          child: _isRefreshing 
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                ),
              )
            : Icon(
                Icons.refresh,
                color: Colors.blue[600],
                size: 16,
              ),
        ),
      ),
    );
  }

  void _showCitySearch(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CitySearchScreen(),
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