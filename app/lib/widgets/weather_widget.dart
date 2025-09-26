import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/location/location_service.dart';

class WeatherWidget extends StatefulWidget {
  final WeatherModel weather;
  final VoidCallback? onRefresh;

  const WeatherWidget({
    super.key,
    required this.weather,
    this.onRefresh,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  bool _isLocationPermissionGranted = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      final locationService = RealLocationService();
      final permissionStatus = await locationService.checkPermissionStatus();
      
      setState(() {
        _isLocationPermissionGranted = permissionStatus == LocationPermissionStatus.granted;
      });
    } catch (e) {
      setState(() {
        _isLocationPermissionGranted = false;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      final locationService = RealLocationService();
      final granted = await locationService.requestPermission();
      
      setState(() {
        _isLocationPermissionGranted = granted;
      });
    } catch (e) {
      setState(() {
        _isLocationPermissionGranted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              Icon(
                Icons.ac_unit,
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
              const Spacer(),
              if (widget.onRefresh != null)
                GestureDetector(
                  onTap: widget.onRefresh,
                  child: Icon(
                    Icons.refresh,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: _isLocationPermissionGranted 
                    ? Colors.blue[600] 
                    : Colors.orange[600],
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                widget.weather.location.formattedLocation,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Main weather info
          Row(
            children: [
              // Weather icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.wb_sunny,
                  color: Colors.orange[600],
                  size: 40,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Temperature and condition
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${widget.weather.temperature.round()}°C',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      _getWeatherConditionKorean(widget.weather.condition),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Recommendation section
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getWeatherMessage(),
                    style: TextStyle(
                      color: const Color.fromARGB(255, 133, 133, 136),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Weather Details
          Row(
            children: [
              Expanded(
                child: _buildWeatherDetail(
                  icon: Icons.water_drop,
                  label: '습도',
                  value: '${widget.weather.humidity}%',
                  color: const Color.fromARGB(255, 148, 188, 222),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildWeatherDetail(
                  icon: Icons.air,
                  label: '바람',
                  value: '${widget.weather.windSpeed.toStringAsFixed(1)}m/s',
                  color: const Color.fromARGB(255, 93, 118, 132),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          // Today's recommended outfit
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.checkroom,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '오늘의 추천 착장',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getRecommendedOutfit(widget.weather.temperature),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          
          // Location permission action button
          if (!_isLocationPermissionGranted) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _requestLocationPermission,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '위치 권한 허용하기',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }


  String _getWeatherConditionKorean(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '맑음';
      case 'clouds':
        return '구름';
      case 'rain':
        return '비';
      case 'snow':
        return '눈';
      case 'thunderstorm':
        return '뇌우';
      case 'mist':
      case 'fog':
        return '안개';
      default:
        return '구름';
    }
  }

  String _getWeatherMessage() {
    final temp = widget.weather.temperature;
    
    if (temp < 10) {
      return "오늘은 쌀쌀해요. 따뜻한 겉옷을 챙기세요!";
    } else if (temp < 20) {
      return "시원한 날씨네요. 가벼운 겉옷을 준비하세요!";
    } else if (temp < 30) {
      return "따뜻한 날씨예요. 편안한 옷차림이 좋겠어요!";
    } else {
      return "더운 날씨네요. 시원한 옷차림을 추천해요!";
    }
  }

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
}
