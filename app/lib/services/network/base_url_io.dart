import 'dart:io';

// 모바일/데스크톱 (IO) 환경: Android 에뮬레이터 예외 처리
String getDefaultBackendBaseUrl() {
  if (Platform.isAndroid) return 'http://10.0.2.2:4000';
  return 'http://localhost:4000';
}


