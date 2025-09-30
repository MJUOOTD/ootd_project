import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ootd_app/providers/weather_provider.dart';
import 'package:ootd_app/providers/recommendation_provider.dart';
import 'package:ootd_app/providers/user_provider.dart';
import 'package:go_router/go_router.dart';

import 'package:ootd_app/models/weather_model.dart';
import 'package:ootd_app/models/feedback_model.dart';
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
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherProvider);
    final recState = ref.watch(recommendationProvider);
    final userState = ref.watch(userProvider);
    final w = widget.weather ?? state.currentWeather;
    final isLoading = state.isLoading;
    final error = state.error;

    if (isLoading) return _buildSkeleton();
    if (w == null) return _buildEmpty();
    
    final hasLocationPermissionError = error != null && 
        (error.contains('현재 위치를 불러올 수 없음') || 
         error.contains('위치 서비스가 비활성화되어 있습니다') ||
         error.contains('위치 권한') || 
         error.contains('permission') || 
         error.contains('Permission') || 
         error.contains('LocationException'));
    
    final hasError = error != null && error.isNotEmpty && !hasLocationPermissionError;
    
    // 위치 권한 경고는 홈 화면 상단 배너에서 한 번만 표시하도록 이곳에서는 중복 표시하지 않음
    
    return Stack(
      children: [
        Container(
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
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: Row(
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
                        if (state.isManualSelection)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '수동',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: () async {
                            if (_isRefreshing) return;
                            setState(() => _isRefreshing = true);
                            try {
                              if (widget.onRefresh != null) {
                                widget.onRefresh!();
                              } else {
                                await ref.read(weatherProvider.notifier).refreshWeather();
                              }
                            } finally {
                              if (mounted) setState(() => _isRefreshing = false);
                            }
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Icon(
                              Icons.refresh,
                              size: 16,
                              color: Colors.blue[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 더보기 버튼을 같은 라인에 배치해 정렬
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CitySearchScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F7F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black.withOpacity(0.07)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.more_horiz,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 현재 위치 표시
              _buildLocationRow(w, hasLocationPermissionError, state.isManualSelection),
              
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                            const SizedBox(width: 8),
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
                        const SizedBox(height: 4),
                        Text(
                          '${_getWeatherConditionKorean(w.condition)} · ${_getWeatherMessage(w.temperature)}',
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
                        _buildDynamicRecommendation(recState) ?? _getRecommendedOutfit(w.temperature),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // 작은 온도 피드백 버튼들 (오른쪽, 컴팩트)
                    _tinyFeedbackButton('🥶', () => _handleTinyFeedback(userState, wasTooCold: true)),
                    const SizedBox(width: 6),
                    _tinyFeedbackButton('👌', () => _handleTinyFeedback(userState)),
                    const SizedBox(width: 6),
                    _tinyFeedbackButton('🥵', () => _handleTinyFeedback(userState, wasTooHot: true)),
                  ],
                ),
              ),
            ],
          ),
        ),
        
      ],
    );
  }
  String? _buildDynamicRecommendation(RecommendationProvider recState) {
    final selected = recState.selectedRecommendation;
    if (selected == null) return null;
    final items = selected.outfit.items;
    if (items.isNotEmpty) {
      final main = items.take(3).join(', ');
      return '오늘의 추천: $main';
    }
    if (selected.reason.isNotEmpty) {
      return selected.reason;
    }
    return null;
  }

  // Compact feedback buttons used in the recommendation row
  Widget _tinyFeedbackButton(String emoji, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDDE7F7)),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Future<void> _handleTinyFeedback(UserState userState, {bool wasTooHot = false, bool wasTooCold = false}) async {
    if (!mounted) return;
    if (!userState.isLoggedIn) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('로그인이 필요해요'),
          content: const Text('피드백을 주시면 더 정확한 추천을 받을 수 있어요.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('나중에')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pushNamed('login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(239, 107, 141, 252),
                foregroundColor: Colors.white,
              ),
              child: const Text('로그인하기'),
            ),
          ],
        ),
      );
      return;
    }
    // Save feedback (placeholder)
    final feedback = FeedbackModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userState.currentUser!.id,
      outfitId: 'today_recommendation',
      type: FeedbackType.temperature,
      rating: wasTooHot || wasTooCold ? 2 : 5,
      comment: wasTooHot ? '더웠어요' : wasTooCold ? '추웠어요' : '딱 좋아요',
      timestamp: DateTime.now(),
      metadata: {
        'wasTooHot': wasTooHot,
        'wasTooCold': wasTooCold,
        'context': 'today_recommendation_row',
      },
    );
    // ignore: unused_local_variable
    final _ = feedback; // TODO: integrate with backend feedback service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('온도 피드백이 저장되었습니다.')),
    );
  }

  // 새로 추가: 위치 행 렌더링
  Widget _buildLocationRow(WeatherModel w, bool hasLocationPermissionError, bool isManualSelection) {
    final locationLabel = w.location.formattedLocation;
    return Row(
      children: [
        Icon(Icons.location_on, color: Colors.grey[600], size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            locationLabel,
            style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 새로 추가: 간단한 온도 기반 추천 문구
  String _getRecommendedOutfit(double temperature) {
    if (temperature < 0) {
      return '두꺼운 패딩 + 목도리 + 따뜻한 부츠';
    } else if (temperature < 5) {
      return '패딩 + 니트 + 긴바지';
    } else if (temperature < 10) {
      return '코트 + 스웨터 + 청바지';
    } else if (temperature < 15) {
      return '자켓 + 긴팔 + 슬랙스';
    } else if (temperature < 20) {
      return '가디건 + 긴팔 + 청바지';
    } else if (temperature < 25) {
      return '긴팔 + 반바지 또는 얇은 긴바지';
    } else {
      return '반팔 + 반바지 + 가벼운 신발';
    }
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
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 140,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
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
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('날씨 정보를 불러오는 중입니다...'),
        ],
      ),
    );
  }

  // 이하 기존 보조 메서드들은 그대로 유지
  IconData _getWeatherIcon(String condition, int hour) {
    switch (condition) {
      case 'Clear':
        return hour >= 6 && hour <= 18 ? Icons.wb_sunny : Icons.nightlight_round;
      case 'Clouds':
        return Icons.cloud;
      case 'Rain':
        return Icons.grain;
      case 'Snow':
        return Icons.ac_unit;
      case 'Thunderstorm':
        return Icons.flash_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  String _getWeatherConditionKorean(String condition) {
    switch (condition) {
      case 'Clear':
        return '맑음';
      case 'Clouds':
        return '구름';
      case 'Rain':
        return '비';
      case 'Snow':
        return '눈';
      case 'Thunderstorm':
        return '뇌우';
      default:
        return '대체로 맑음';
    }
  }

  String _getWeatherMessage(double temp) {
    if (temp <= 0) return '매우 추워요, 보온에 신경 쓰세요.';
    if (temp <= 10) return '쌀쌀해요, 겉옷을 챙기세요.';
    if (temp <= 20) return '선선해요, 가벼운 겉옷이 좋아요.';
    if (temp <= 27) return '활동하기 좋은 날씨예요.';
    return '더워요, 수분 섭취를 충분히!';
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[600], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  // 권한 경고 다이얼로그는 홈 상단 배너 또는 검색 화면에서 한 번만 표시
}