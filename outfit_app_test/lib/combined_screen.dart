import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CombinedScreen extends StatefulWidget {
  const CombinedScreen({super.key});

  @override
  State<CombinedScreen> createState() => _CombinedScreenState();
}

class _CombinedScreenState extends State<CombinedScreen> {
  String _statusMessage = "버튼을 눌러 추천을 받아보세요.";
  String _top = "";
  String _bottom = "";

  void _getOutfitForCurrentLocation() async {
    setState(() {
      _statusMessage = "현재 위치를 확인하는 중...";
      _top = "";
      _bottom = "";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _statusMessage = "오류: 위치 서비스가 비활성화되었습니다."; });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _statusMessage = "오류: 위치 권한이 거부되었습니다."; });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() { _statusMessage = "오류: 위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 권한을 허용해주세요."; });
        return;
      } 

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _statusMessage = "위치 확인 완료!\n\n날씨 정보를 기반으로 옷을 추천합니다...";
      });

      int currentTemp = 15; // 실제로는 날씨 API 결과값을 사용해야 합니다.

      final snapshot = await FirebaseFirestore.instance
          .collection('outfit_rules')
          .where('min_temp', isLessThanOrEqualTo: currentTemp)
          .where('max_temp', isGreaterThanOrEqualTo: currentTemp)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          _statusMessage = "오늘 이런 옷은 어떠세요?";
          _top = data['top'];
          _bottom = data['bottom'];
        });
      } else {
        setState(() {
          _statusMessage = "이 날씨에 맞는 옷 추천 정보를 찾을 수 없습니다.";
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "오류 발생: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("위치 + Firestore 연동 테스트")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_statusMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (_top.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('상의 추천: $_top', style: const TextStyle(fontSize: 24)),
                        Text('하의 추천: $_bottom', style: const TextStyle(fontSize: 24)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _getOutfitForCurrentLocation,
                child: const Text("현재 위치로 옷 추천받기"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}