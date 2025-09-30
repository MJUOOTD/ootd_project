import 'dart:io';

// 모바일/데스크톱 (IO) 환경: Android 에뮬레이터 예외 처리
String getDefaultBackendBaseUrl() {
  if (Platform.isAndroid) {
    // Android 에뮬레이터에서 호스트 머신 접근
    return 'https://ootd-project-backend.onrender.com';
  } else if (Platform.isIOS) {
    // iOS 시뮬레이터에서 localhost 사용
    return 'https://ootd-project-backend.onrender.com';
  } else {
    // macOS, Windows, Linux 데스크톱
    return 'https://ootd-project-backend.onrender.com';
  }
}


