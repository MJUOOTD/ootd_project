// 웹 환경: 호스트 도메인 기준으로 백엔드 포트 4000 사용
String getDefaultBackendBaseUrl() {
  // 개발 환경에서는 http 고정 (https 페이지에서 http 호출하면 Mixed Content로 차단됨)
  // 로컬 개발: http://localhost:4000
  return 'http://localhost:4000';
}


