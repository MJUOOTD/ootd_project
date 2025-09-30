/**
 * Error Handling Middleware
 * 
 * 주요 기능:
 * - 통합 에러 처리 및 로깅
 * - 클라이언트 친화적인 에러 응답
 * - 보안을 고려한 에러 정보 노출 제한
 * - 개발/프로덕션 환경별 에러 처리
 */

/**
 * 에러 타입 분류
 */
const ErrorTypes = {
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  API_ERROR: 'API_ERROR',
  NETWORK_ERROR: 'NETWORK_ERROR',
  AUTHENTICATION_ERROR: 'AUTHENTICATION_ERROR',
  AUTHORIZATION_ERROR: 'AUTHORIZATION_ERROR',
  NOT_FOUND: 'NOT_FOUND',
  RATE_LIMIT_ERROR: 'RATE_LIMIT_ERROR',
  INTERNAL_ERROR: 'INTERNAL_ERROR'
};

/**
 * 에러 타입 결정
 * @param {Error} error - 에러 객체
 * @returns {string} 에러 타입
 */
function determineErrorType(error) {
  if (error.name === 'ValidationError') return ErrorTypes.VALIDATION_ERROR;
  if (error.message.includes('API')) return ErrorTypes.API_ERROR;
  if (error.message.includes('timeout') || error.message.includes('network')) return ErrorTypes.NETWORK_ERROR;
  if (error.message.includes('permission') || error.message.includes('unauthorized')) return ErrorTypes.AUTHENTICATION_ERROR;
  if (error.message.includes('forbidden')) return ErrorTypes.AUTHORIZATION_ERROR;
  if (error.message.includes('not found')) return ErrorTypes.NOT_FOUND;
  if (error.message.includes('rate limit')) return ErrorTypes.RATE_LIMIT_ERROR;
  return ErrorTypes.INTERNAL_ERROR;
}

/**
 * HTTP 상태 코드 결정
 * @param {string} errorType - 에러 타입
 * @returns {number} HTTP 상태 코드
 */
function getHttpStatusCode(errorType) {
  const statusCodeMap = {
    [ErrorTypes.VALIDATION_ERROR]: 400,
    [ErrorTypes.API_ERROR]: 502,
    [ErrorTypes.NETWORK_ERROR]: 503,
    [ErrorTypes.AUTHENTICATION_ERROR]: 401,
    [ErrorTypes.AUTHORIZATION_ERROR]: 403,
    [ErrorTypes.NOT_FOUND]: 404,
    [ErrorTypes.RATE_LIMIT_ERROR]: 429,
    [ErrorTypes.INTERNAL_ERROR]: 500
  };
  
  return statusCodeMap[errorType] || 500;
}

/**
 * 클라이언트 친화적인 에러 메시지 생성
 * @param {Error} error - 에러 객체
 * @param {string} errorType - 에러 타입
 * @returns {string} 사용자 친화적인 메시지
 */
function getClientFriendlyMessage(error, errorType) {
  const messageMap = {
    [ErrorTypes.VALIDATION_ERROR]: '입력 데이터가 올바르지 않습니다.',
    [ErrorTypes.API_ERROR]: '외부 서비스에서 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
    [ErrorTypes.NETWORK_ERROR]: '네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인해주세요.',
    [ErrorTypes.AUTHENTICATION_ERROR]: '인증이 필요합니다.',
    [ErrorTypes.AUTHORIZATION_ERROR]: '접근 권한이 없습니다.',
    [ErrorTypes.NOT_FOUND]: '요청한 리소스를 찾을 수 없습니다.',
    [ErrorTypes.RATE_LIMIT_ERROR]: '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.',
    [ErrorTypes.INTERNAL_ERROR]: '서버 내부 오류가 발생했습니다. 관리자에게 문의해주세요.'
  };
  
  return messageMap[errorType] || '알 수 없는 오류가 발생했습니다.';
}

/**
 * 에러 로깅
 * @param {Error} error - 에러 객체
 * @param {Object} req - Express request 객체
 * @param {string} errorType - 에러 타입
 */
function logError(error, req, errorType) {
  const logData = {
    timestamp: new Date().toISOString(),
    errorType,
    message: error.message,
    stack: error.stack,
    url: req.originalUrl,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    body: req.body,
    query: req.query,
    params: req.params
  };
  
  // 개발 환경에서는 상세 로그, 프로덕션에서는 간소화된 로그
  if (process.env.NODE_ENV === 'development') {
    console.error('[ERROR]', JSON.stringify(logData, null, 2));
  } else {
    console.error(`[ERROR] ${errorType}: ${error.message} - ${req.method} ${req.originalUrl}`);
  }
}

/**
 * Express 에러 핸들링 미들웨어
 * @param {Error} error - 에러 객체
 * @param {Object} req - Express request 객체
 * @param {Object} res - Express response 객체
 * @param {Function} next - Express next 함수
 */
export function errorHandler(error, req, res, next) {
  // 이미 응답이 전송된 경우
  if (res.headersSent) {
    return next(error);
  }
  
  const errorType = determineErrorType(error);
  const statusCode = getHttpStatusCode(errorType);
  const clientMessage = getClientFriendlyMessage(error, errorType);
  
  // 에러 로깅
  logError(error, req, errorType);
  
  // 클라이언트 응답 구성
  const response = {
    error: {
      type: errorType,
      message: clientMessage,
      timestamp: new Date().toISOString(),
      requestId: req.id || 'unknown'
    }
  };
  
  // 개발 환경에서는 추가 디버그 정보 포함
  if (process.env.NODE_ENV === 'development') {
    response.error.details = {
      originalMessage: error.message,
      stack: error.stack
    };
  }
  
  res.status(statusCode).json(response);
}

/**
 * 404 Not Found 핸들러
 * @param {Object} req - Express request 객체
 * @param {Object} res - Express response 객체
 * @param {Function} next - Express next 함수
 */
export function notFoundHandler(req, res, next) {
  const error = new Error(`Route not found: ${req.method} ${req.originalUrl}`);
  error.statusCode = 404;
  next(error);
}

/**
 * 비동기 함수 에러 래퍼
 * @param {Function} fn - 비동기 함수
 * @returns {Function} 래핑된 함수
 */
export function asyncHandler(fn) {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

/**
 * 에러 타입 상수 내보내기
 */
export { ErrorTypes };