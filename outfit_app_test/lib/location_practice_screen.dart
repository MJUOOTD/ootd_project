import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPracticeScreen extends StatefulWidget {
  const LocationPracticeScreen({super.key});

  @override
  State<LocationPracticeScreen> createState() => _LocationPracticeScreenState();
}

class _LocationPracticeScreenState extends State<LocationPracticeScreen> {
  // 위치 정보를 표시할 변수
  String _locationMessage = "아직 위치 정보 없음";

  // 위치 정보를 가져오는 핵심 로직 함수
  void _getCurrentLocation() async {
    setState(() {
      _locationMessage = "위치 정보 불러오는 중...";
    });

    try {
      // 1. 위치 서비스 활성화 여부 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationMessage = "오류: 위치 서비스가 비활성화되었습니다.";
        });
        return;
      }

      // 2. 위치 권한 확인 및 요청
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationMessage = "오류: 위치 권한이 거부되었습니다.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
            _locationMessage = "오류: 위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 권한을 허용해주세요.";
        });
        return;
      } 

      // 3. 권한이 허용되면, 현재 위치(좌표) 가져오기
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
);
      Position position = await Geolocator.getPositionStream(
        locationSettings: locationSettings
      ).first;

      // 4. 화면에 위도와 경도 표시
      setState(() {
        _locationMessage = "위도: ${position.latitude}\n경도: ${position.longitude}";
      });

    } catch (e) {
      setState(() {
        _locationMessage = "오류 발생: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("위치 정보 연습")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _locationMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text("현재 위치 가져오기"),
            ),
          ],
        ),
      ),
    );
  }
}