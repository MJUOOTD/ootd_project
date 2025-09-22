import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/location/location_service.dart';

class WeatherWidget extends StatefulWidget {
  final WeatherModel weather;

  const WeatherWidget({
    super.key,
    required this.weather,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  bool _isLocationPermissionGranted = true;
  String _locationStatus = '';

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
        if (!_isLocationPermissionGranted) {
          _locationStatus = '위치 권한이 필요합니다';
        } else {
          _locationStatus = '현재 위치 기반 날씨';
        }
      });
    } catch (e) {
      setState(() {
        _isLocationPermissionGranted = false;
        _locationStatus = '위치 정보를 가져올 수 없습니다';
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      final locationService = RealLocationService();
      final granted = await locationService.requestPermission();
      
      setState(() {
        _isLocationPermissionGranted = granted;
        if (granted) {
          _locationStatus = '현재 위치 기반 날씨';
        } else {
          _locationStatus = '위치 권한이 거부되었습니다';
        }
      });
    } catch (e) {
      setState(() {
        _isLocationPermissionGranted = false;
        _locationStatus = '위치 권한 요청 실패';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF030213),
            const Color(0xFF030213).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: _isLocationPermissionGranted 
                              ? Colors.green 
                              : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.weather.location.city,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.weather.location.country,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _locationStatus,
                      style: TextStyle(
                        color: _isLocationPermissionGranted 
                            ? Colors.green.withOpacity(0.8)
                            : Colors.orange.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getWeatherIcon(widget.weather.condition),
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Temperature
          Row(
            children: [
              Text(
                '${widget.weather.temperature.round()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.weather.description.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Feels like ${widget.weather.feelsLike.round()}°',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Weather Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherDetail(
                icon: Icons.water_drop,
                label: 'Humidity',
                value: '${widget.weather.humidity}%',
              ),
              _buildWeatherDetail(
                icon: Icons.air,
                label: 'Wind',
                value: '${widget.weather.windSpeed.toStringAsFixed(1)} m/s',
              ),
              _buildWeatherDetail(
                icon: Icons.opacity,
                label: 'Rain',
                value: widget.weather.precipitation > 0 
                    ? '${widget.weather.precipitation.toStringAsFixed(1)} mm'
                    : 'None',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Weather recommendation message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getWeatherMessage(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.4,
              ),
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
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'mist':
      case 'fog':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  String _getWeatherMessage() {
    final temp = widget.weather.temperature;
    
    if (temp < 10) {
      return "오늘은 쌀쌀해요, 따뜻한 겉옷을 챙기세요!";
    } else if (temp < 20) {
      return "시원한 날씨네요, 가벼운 겉옷을 준비하세요!";
    } else if (temp < 30) {
      return "따뜻한 날씨예요, 편안한 옷차림이 좋겠어요!";
    } else {
      return "더운 날씨네요, 시원한 옷차림을 추천해요!";
    }
  }
}
