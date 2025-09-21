import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

// 기상청 API와 관련된 모든 기능을 담당하는 클래스
class WeatherService {
  final String _serviceKey = "d8140efacd45cb2fe91d1ebb391ddf8bd959c68cb63e9003d413ef71938e69e5"; // ⚠️ 여기에 본인의 인증키를 붙여넣으세요!

  // 메인 기능: 현재 위치의 날씨 정보를 가져옴
  Future<WeatherData> getCurrentWeather() async {
    Position position = await _getCurrentLocation();
    Map<String, int> gridCoords = _convertToGrid(position.latitude, position.longitude);
    
    final weatherInfo = await _fetchWeatherFromApi(gridCoords['x']!, gridCoords['y']!);
    
    final temp = weatherInfo['T1H']!;
    final wind = weatherInfo['WSD']!;
    
    final feelsLikeTemp = _calculateFeelsLikeTemp(temp, wind);

    return WeatherData(
      temperature: temp,
      windSpeed: wind,
      feelsLikeTemperature: feelsLikeTemp,
    );
  }

  // API에서 날씨 데이터를 가져오는 내부 함수
  Future<Map<String, double>> _fetchWeatherFromApi(int gridX, int gridY) async {
    final requestTime = DateTime.now().subtract(const Duration(hours: 2));
    final baseDate = "${requestTime.year}${requestTime.month.toString().padLeft(2, '0')}${requestTime.day.toString().padLeft(2, '0')}";
    final baseTime = "${requestTime.hour.toString().padLeft(2, '0')}00";

    final url = Uri.https('apis.data.go.kr', '/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst', {
      'serviceKey': _serviceKey, 'pageNo': '1', 'numOfRows': '1000', 'dataType': 'JSON',
      'base_date': baseDate, 'base_time': baseTime, 'nx': gridX.toString(), 'ny': gridY.toString(),
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['response']['header']['resultCode'] != '00') {
        throw Exception("API 오류: ${data['response']['header']['resultMsg']}");
      }
      final items = data['response']['body']['items']['item'];
      
      String temp = "";
      String wind = "";

      for (var item in items) {
        if (item['category'] == 'T1H') temp = item['obsrValue'];
        if (item['category'] == 'WSD') wind = item['obsrValue'];
      }

      if (temp.isEmpty || wind.isEmpty) throw Exception("기온/풍속 정보를 찾을 수 없습니다.");
      
      return {'T1H': double.parse(temp), 'WSD': double.parse(wind)};
    } else {
      throw Exception("HTTP 요청 실패: Status Code ${response.statusCode}");
    }
  }

  // 위치 정보를 가져오는 내부 함수
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("위치 서비스가 비활성화되었습니다.");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw Exception("위치 권한이 거부되었습니다.");
    }
    if (permission == LocationPermission.deniedForever) throw Exception("위치 권한이 영구적으로 거부되었습니다."); 

    // geolocator 최신 버전에서는 아래와 같이 LocationSettings를 사용합니다.
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    return await Geolocator.getPositionStream(locationSettings: locationSettings).first;
  }

  // 체감온도를 계산하는 내부 함수
  double _calculateFeelsLikeTemp(double temp, double windSpeed) {
    double windSpeedKmh = windSpeed * 3.6;
    if (windSpeedKmh < 1.3) return temp;
    double feelsLike = 13.12 + (0.6215 * temp) - (11.37 * pow(windSpeedKmh, 0.16)) + (0.3965 * pow(windSpeedKmh, 0.16) * temp);
    return double.parse(feelsLike.toStringAsFixed(1));
  }
  
  // 좌표 변환 함수 (이전과 동일)
  Map<String, int> _convertToGrid(double lat, double lon) {
    const double RE = 6371.00877; const double GRID = 5.0; const double SLAT1 = 30.0;
    const double SLAT2 = 60.0; const double OLON = 126.0; const double OLAT = 38.0;
    const int XO = 43; const int YO = 136; final double DEGRAD = pi / 180.0;
    final re = RE / GRID; final slat1 = SLAT1 * DEGRAD; final slat2 = SLAT2 * DEGRAD;
    final olon = OLON * DEGRAD; final olat = OLAT * DEGRAD;
    var sn = tan(pi * 0.25 + slat2 * 0.5) / tan(pi * 0.25 + slat1 * 0.5);
    sn = log(cos(slat1) / cos(slat2)) / log(sn);
    var sf = tan(pi * 0.25 + slat1 * 0.5);
    sf = (pow(sf, sn) * cos(slat1)) / sn;
    var ro = tan(pi * 0.25 + olat * 0.5);
    ro = (re * sf) / pow(ro, sn);
    var ra = tan(pi * 0.25 + (lat) * DEGRAD * 0.5);
    ra = (re * sf) / pow(ra, sn);
    var theta = lon * DEGRAD - olon;
    if (theta > pi) theta -= 2.0 * pi;
    if (theta < -pi) theta += 2.0 * pi;
    theta *= sn;
    final x = (ra * sin(theta) + XO + 0.5).floor();
    final y = (ro - ra * cos(theta) + YO + 0.5).floor();
    return {'x': x, 'y': y};
  }
}