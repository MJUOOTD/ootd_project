// 플랫폼별 기본 백엔드 베이스 URL 제공 (웹/모바일 안전)

import 'base_url_stub.dart'
  if (dart.library.html) 'base_url_web.dart'
  if (dart.library.io) 'base_url_io.dart' as impl;

String getDefaultBackendBaseUrl() => impl.getDefaultBackendBaseUrl();


