import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ootd_app/providers/weather_provider.dart';
import 'package:ootd_app/models/weather_model.dart';

class WeatherWidget extends ConsumerWidget {
  final WeatherModel? weather;
  final VoidCallback? onRefresh;

  const WeatherWidget({
    super.key,
    this.weather,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherProvider);
    final w = weather ?? state.currentWeather;
    final isLoading = state.isLoading;

    if (isLoading) return _buildSkeleton();
    if (w == null) return _buildEmpty();
    
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${w.temperature.round()}°C',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  // 체감온도 표시 (항상 표시)
                  Text(
                    '체감 ${w.feelsLike.round()}°C',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 현재 위치 표시
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.grey[500],
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                w.location.formattedLocation.isNotEmpty 
                    ? w.location.formattedLocation 
                    : '위치 정보 없음',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
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
                  _getWeatherIcon(w.condition),
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

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'cloudy':
      case 'partly cloudy':
        return Icons.wb_cloudy;
      case 'rainy':
      case 'rain':
        return Icons.grain;
      case 'snowy':
      case 'snow':
        return Icons.ac_unit;
      case 'windy':
        return Icons.air;
      default:
        return Icons.wb_sunny;
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
}