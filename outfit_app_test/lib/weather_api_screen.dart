import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class WeatherApiScreen extends StatefulWidget {
  const WeatherApiScreen({super.key});

  @override
  State<WeatherApiScreen> createState() => _WeatherApiScreenState();
}

class _WeatherApiScreenState extends State<WeatherApiScreen> {
  String _weatherMessage = "버튼을 눌러 현재 기온을 확인하세요.";

  Future<void> _fetchWeather() async {
    setState(() {
      _weatherMessage = "위치 정보를 가져오는 중...";
    });

    try {
      // --- ▼▼▼ 테스트를 위해 위치 정보와 좌표 변환 부분을 잠시 비활성화(주석 처리)합니다 ▼▼▼ ---
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final gridCoords = _convertToGrid(position.latitude, position.longitude);
      final gridX = gridCoords['x'].toString();
      final gridY = gridCoords['y'].toString();
      
      // --- ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲ ---

      // --- ▼▼▼ 서울 시청의 격자 좌표를 고정값으로 사용합니다 ▼▼▼ ---
      // final gridX = '60';
      // final gridY = '127';
      // --- ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲ ---

      setState(() {
        _weatherMessage = "고정 좌표(서울 시청)\nX: $gridX, Y: $gridY\n\n날씨 정보를 요청합니다...";
      });
      
      // --- ⚠️ 시간 계산 로직 수정: 1시간 전 -> 2시간 전 ---
      // API 데이터 생성 시간을 고려하여, 가장 안정적으로 데이터가 보장되는 '2시간 전'으로 조회합니다.
      final requestTime = DateTime.now().subtract(const Duration(hours: 2));
      final baseDate = "${requestTime.year}${requestTime.month.toString().padLeft(2, '0')}${requestTime.day.toString().padLeft(2, '0')}";
      final baseTime = "${requestTime.hour.toString().padLeft(2, '0')}00";
      // --- 수정 끝 ---
      
      const serviceKey = "d8140efacd45cb2fe91d1ebb391ddf8bd959c68cb63e9003d413ef71938e69e5"; // ⚠️ 여기에 본인의 인증키를 붙여넣으세요!

      final url = Uri.https('apis.data.go.kr', '/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst', {
        'serviceKey': serviceKey,
        'pageNo': '1',
        'numOfRows': '1000',
        'dataType': 'JSON',
        'base_date': baseDate,
        'base_time': baseTime,
        'nx': gridX,
        'ny': gridY,
      });

      final response = await http.get(url);
      
      // --- 디버깅을 위한 print문 (문제 해결 후 지워도 됩니다) ---
      print('요청 URL: $url');
      print('서버 응답 내용: ${response.body}');
      // ---

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['response']['header']['resultCode'] != '00') {
           setState(() {
            _weatherMessage = "API 오류: ${data['response']['header']['resultMsg']}";
          });
          return;
        }
        
        if (data['response']['body'] == null || data['response']['body']['items'] == null) {
          setState(() {
            _weatherMessage = "데이터 없음: 해당 시간($baseTime)의 관측 정보가 없습니다.";
          });
          return;
        }

        final items = data['response']['body']['items']['item'];

        String temperature = "N/A";
        for (var item in items) {
          if (item['category'] == 'T1H') {
            temperature = item['obsrValue'];
            break;
          }
        }
        setState(() {
          _weatherMessage = "요청 성공!\n현재 기온은 $temperature℃ 입니다.";
        });
      } else {
        setState(() {
          _weatherMessage = "HTTP 요청 실패: Status Code ${response.statusCode}";
        });
      }

    } catch (e) {
      setState(() {
        _weatherMessage = "처리 중 오류 발생: ${e.toString()}";
      });
    }
  }

  Map<String, int> _convertToGrid(double lat, double lon) {
    const double RE = 6371.00877;
    const double GRID = 5.0;
    const double SLAT1 = 30.0;
    const double SLAT2 = 60.0;
    const double OLON = 126.0;
    const double OLAT = 38.0;
    const int XO = 43;
    const int YO = 136;
    final double DEGRAD = pi / 180.0;
    final re = RE / GRID;
    final slat1 = SLAT1 * DEGRAD;
    final slat2 = SLAT2 * DEGRAD;
    final olon = OLON * DEGRAD;
    final olat = OLAT * DEGRAD;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("기상청 API 연동 연습")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_weatherMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchWeather,
                child: const Text("현재 위치 기온 가져오기"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}