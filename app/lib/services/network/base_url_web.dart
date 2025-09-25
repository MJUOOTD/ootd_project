// 웹 환경: 호스트 도메인 기준으로 백엔드 포트 4000 사용
String getDefaultBackendBaseUrl() {
  final loc = Uri.base;
  final host = loc.host.isEmpty ? 'localhost' : loc.host;
  final scheme = loc.scheme.isEmpty ? 'http' : loc.scheme;
  return '$scheme://$host:4000';
}


