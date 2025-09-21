import 'package:flutter/material.dart';
import '../models/outfit_data.dart';
import '../models/weather_data.dart';
import '../services/recommendation_service.dart';

// --- UI/UX팀이 집중적으로 작업할 파일 ---
// 백엔드팀이 만든 RecommendationService를 가져와서 사용합니다.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // RecommendationService 객체 생성
  final RecommendationService _recommendationService = RecommendationService();

  // 화면 상태를 관리하는 변수들
  bool _isLoading = false;
  String _statusMessage = "버튼을 눌러 옷차림을 추천받으세요.";
  WeatherData? _weatherData;
  OutfitData? _outfitData;

  // 버튼을 누르면 실행될 함수
  Future<void> _triggerRecommendation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 'test_user'라는 ID로 추천을 요청합니다.
      // 실제 앱에서는 로그인된 사용자의 ID를 넘겨줘야 합니다.
      final result = await _recommendationService.getRecommendation("test_user");

      // 서비스로부터 받은 결과를 화면 상태에 업데이트합니다.
      setState(() {
        _weatherData = result['weather'];
        _outfitData = result['outfit'];
        _statusMessage = "오늘 이런 옷은 어떠세요?";
      });

    } catch (e, s) {
      
      // --- 개발자를 위한 상세 로그 (디버그 콘솔에만 보임) ---
      print('<<<<<<<<<< 오류 발생 >>>>>>>>>>');
      print('오류 타입: ${e.runtimeType}');
      print('오류 내용: $e');
      print('오류 위치 상세 정보:');
      print(s);
      print('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
      // ---

      setState(() {
        _statusMessage = "오류 발생: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OOTD 추천")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- UI/UX팀 연결 지점 1: 로딩 인디케이터 ---
              // _isLoading이 true일 때, 여기에 예쁜 로딩 위젯을 보여주세요.
              if (_isLoading)
                const CircularProgressIndicator(),

              // --- UI/UX팀 연결 지점 2: 상태 메시지 ---
              // 여기에 디자인된 텍스트 위젯을 사용해 _statusMessage를 보여주세요.
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // --- UI/UX팀 연결 지점 3: 결과 카드 ---
              // _weatherData와 _outfitData가 있을 때, 
              // 이 데이터를 사용해 디자인된 결과 카드를 보여주세요.
              if (_weatherData != null && _outfitData != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('현재 기온: ${_weatherData!.temperature}℃ (체감: ${_weatherData!.feelsLikeTemperature}℃)', 
                            style: const TextStyle(fontSize: 20, color: Colors.blueAccent)),
                        const SizedBox(height: 10),
                        Text('상의: ${_outfitData!.top}', style: const TextStyle(fontSize: 24)),
                        Text('하의: ${_outfitData!.bottom}', style: const TextStyle(fontSize: 24)),
                        Text('아우터: ${_outfitData!.outer}', style: const TextStyle(fontSize: 24)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 40),

              // --- UI/UX팀 연결 지점 4: 메인 버튼 ---
              // 이 버튼에 디자인을 적용하고, 로딩 중일 때는 비활성화되도록 해주세요.
              ElevatedButton(
                onPressed: _isLoading ? null : _triggerRecommendation,
                child: const Text("오늘 뭐 입지?"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}