import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';  
import 'dart:math';

// API로부터 받은 날씨 정보를 담을 간단한 데이터 클래스
class WeatherData {
  final double temperature;
  // 나중에 풍속, 습도 등 다른 데이터도 여기에 추가할 수 있습니다.

  WeatherData({required this.temperature});
}

// Firestore로부터 받은 옷차림 정보를 담을 간단한 데이터 클래스
class OutfitData {
  final String top;
  final String bottom;

  OutfitData({required this.top, required this.bottom});
}


class FinalPrototypeScreen extends StatefulWidget {
  const FinalPrototypeScreen({super.key});

  @override
  State<FinalPrototypeScreen> createState() => _FinalPrototypeScreenState();
}

class _FinalPrototypeScreenState extends State<FinalPrototypeScreen> {
  // 화면의 상태를 관리하는 변수들
  bool _isLoading = false; // 현재 로딩 중인지 여부
  String _statusMessage = "버튼을 눌러 옷차림을 추천받으세요.";
  WeatherData? _weatherData;
  OutfitData? _outfitData;

  // --- 모든 로직을 순차적으로 실행하는 메인 함수 ---
  Future<void> getWeatherAndOutfit() async {
    // 1. 로딩 시작: 버튼을 비활성화하고 상태 메시지 변경
    setState(() {
      _isLoading = true;
      _statusMessage = "현재 위치를 확인하고 있습니다...";
      _weatherData = null;
      _outfitData = null;
    });

    try {
      // 2. 위치 정보 가져오기 (geolocator)
      Position position = await _getCurrentLocation();
      setState(() {
        _statusMessage = "위치 확인 완료!\n실시간 날씨를 조회합니다...";
      });

      // 3. 날씨 정보 가져오기 (기상청 API)
      WeatherData weather = await _fetchWeather(position.latitude, position.longitude);
      setState(() {
        _weatherData = weather;
        _statusMessage = "날씨 확인 완료!\n옷차림을 추천하고 있습니다...";
      });

      // 4. 옷차림 정보 가져오기 (Firestore)
      OutfitData outfit = await _fetchOutfit(weather.temperature);
      setState(() {
        _outfitData = outfit;
        _statusMessage = "오늘 이런 옷은 어떠세요?";
      });

    } catch (e) {
      // 어느 단계에서든 오류가 발생하면 메시지 표시
      setState(() {
        _statusMessage = "오류 발생: ${e.toString()}";
      });
    } finally {
      // 모든 과정이 끝나면(성공하든 실패하든) 로딩 상태 해제
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- 개별 기능 함수들 ---

  // 위치 정보를 가져오는 함수
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("위치 서비스가 비활성화되었습니다.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("위치 권한이 거부되었습니다.");
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception("위치 권한이 영구적으로 거부되었습니다.");
    } 

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // 위도, 경도를 받아 날씨를 가져오는 함수
  Future<WeatherData> _fetchWeather(double lat, double lon) async {
    final gridCoords = _convertToGrid(lat, lon);
    final gridX = gridCoords['x'].toString();
    final gridY = gridCoords['y'].toString();

    final requestTime = DateTime.now().subtract(const Duration(hours: 2));
    final baseDate = "${requestTime.year}${requestTime.month.toString().padLeft(2, '0')}${requestTime.day.toString().padLeft(2, '0')}";
    final baseTime = "${requestTime.hour.toString().padLeft(2, '0')}00";

    const serviceKey = "d8140efacd45cb2fe91d1ebb391ddf8bd959c68cb63e9003d413ef71938e69e5"; // ⚠️ 여기에 본인의 인증키를 붙여넣으세요!

    final url = Uri.https('apis.data.go.kr', '/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst', {
      'serviceKey': serviceKey, 'pageNo': '1', 'numOfRows': '1000', 'dataType': 'JSON',
      'base_date': baseDate, 'base_time': baseTime, 'nx': gridX, 'ny': gridY,
    });

    final response = await http.get(url);

    print("response:  "+response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['response']['header']['resultCode'] != '00') {
        throw Exception("API 오류: ${data['response']['header']['resultMsg']}");
      }
      if (data['response']['body'] == null || data['response']['body']['items'] == null) {
        throw Exception("데이터 없음: 해당 시간의 관측 정보가 없습니다.");
      }
      final items = data['response']['body']['items']['item'];
      String temperature = "N/A";
      for (var item in items) {
        if (item['category'] == 'T1H') {
          temperature = item['obsrValue'];
          break;
        }
      }
      if (temperature == "N/A") throw Exception("기온 정보를 찾을 수 없습니다.");
      return WeatherData(temperature: double.parse(temperature));
    } else {
      throw Exception("HTTP 요청 실패: Status Code ${response.statusCode}");
    }
  }

  // 기온을 받아 옷차림을 가져오는 함수
  Future<OutfitData> _fetchOutfit(double temperature) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('outfit_rules')
        .where('min_temp', isLessThanOrEqualTo: temperature)
        .where('max_temp', isGreaterThanOrEqualTo: temperature)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      return OutfitData(top: data['top'], bottom: data['bottom']);
    } else {
      throw Exception("이 날씨에 맞는 옷 추천 정보를 찾을 수 없습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("최종 프로토타입")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. 상태 메시지 표시
              if (_isLoading)
                const CircularProgressIndicator(), // 로딩 중일 때는 동그란 아이콘
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 2. 날씨 및 옷차림 결과 표시
              if (_weatherData != null && _outfitData != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('현재 기온: ${_weatherData!.temperature}℃', style: const TextStyle(fontSize: 20, color: Colors.blueAccent)),
                        const SizedBox(height: 10),
                        Text('상의 추천: ${_outfitData!.top}', style: const TextStyle(fontSize: 24)),
                        Text('하의 추천: ${_outfitData!.bottom}', style: const TextStyle(fontSize: 24)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 40),

              // 3. 실행 버튼
              ElevatedButton(
                // 로딩 중일 때는 버튼 비활성화
                onPressed: _isLoading ? null : getWeatherAndOutfit,
                child: const Text("현재 위치로 옷 추천받기"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 위도/경도를 기상청 격자 좌표로 변환하는 함수 (수정할 필요 없음) ---
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