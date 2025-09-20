import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class LayeringGuideWidget extends StatelessWidget {
  final WeatherModel weather;

  const LayeringGuideWidget({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final layeringInfo = _getLayeringInfo(weather);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF030213).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.layers,
                  color: Color(0xFF030213),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '레이어링 가이드',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF030213),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Layering Steps
          ...layeringInfo['steps'].map<Widget>((step) => 
            _buildLayeringStep(step)
          ).toList(),
          
          const SizedBox(height: 16),
          
          // Tips
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF030213).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF030213),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    layeringInfo['tip'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF030213),
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

  Widget _buildLayeringStep(Map<String, dynamic> step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF030213),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step['order'].toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['item'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF030213),
                  ),
                ),
                if (step['description'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    step['description'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getLayeringInfo(WeatherModel weather) {
    final feelsLike = weather.feelsLike;
    
    // 체감온도 기준으로 레이어링 결정
    final adjustedTemp = feelsLike;
    
    if (adjustedTemp <= 0) {
      return {
        'steps': [
          {'order': 1, 'item': '내의 (기모)', 'description': '보온성이 좋은 내의'},
          {'order': 2, 'item': '니트/스웨터', 'description': '두꺼운 니트나 스웨터'},
          {'order': 3, 'item': '패딩/코트', 'description': '방풍 기능이 있는 외투'},
          {'order': 4, 'item': '목도리/장갑', 'description': '추위 방지 액세서리'},
        ],
        'tip': '추운 날씨에는 여러 겹의 옷을 입어 체온을 유지하세요.',
      };
    } else if (adjustedTemp <= 10) {
      return {
        'steps': [
          {'order': 1, 'item': '긴팔 티셔츠', 'description': '기본 상의'},
          {'order': 2, 'item': '니트/가디건', 'description': '보온용 중간 옷'},
          {'order': 3, 'item': '자켓/코트', 'description': '외출용 외투'},
        ],
        'tip': '온도 변화에 대비해 벗고 입기 쉬운 옷을 선택하세요.',
      };
    } else if (adjustedTemp <= 20) {
      return {
        'steps': [
          {'order': 1, 'item': '긴팔 티셔츠', 'description': '기본 상의'},
          {'order': 2, 'item': '가디건/얇은 자켓', 'description': '선택적 중간 옷'},
        ],
        'tip': '아침저녁과 낮의 온도 차이를 고려하세요.',
      };
    } else if (adjustedTemp <= 25) {
      return {
        'steps': [
          {'order': 1, 'item': '반팔/긴팔', 'description': '기본 상의'},
          {'order': 2, 'item': '얇은 가디건', 'description': '선택적 겉옷'},
        ],
        'tip': '실내외 온도 차이에 대비하세요.',
      };
    } else {
      return {
        'steps': [
          {'order': 1, 'item': '반팔 티셔츠', 'description': '시원한 상의'},
          {'order': 2, 'item': '얇은 셔츠', 'description': '선택적 겉옷'},
        ],
        'tip': '통풍이 잘 되는 소재를 선택하세요.',
      };
    }
  }
}
