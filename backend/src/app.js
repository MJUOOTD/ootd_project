import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { v4 as uuidv4 } from 'uuid';
import router from './routes/index.js';
import { errorHandler, notFoundHandler } from './middleware/error.js';
import swaggerUi from 'swagger-ui-express';
import swaggerSpec from './swagger.js';

/**
 * Express 애플리케이션 설정
 * 
 * 주요 기능:
 * - 보안 미들웨어 설정
 * - CORS 정책 구성
 * - 요청 로깅 및 ID 생성
 * - API 문서화 (Swagger)
 * - 에러 핸들링
 */

const app = express();

// ==================== 보안 미들웨어 ====================

// Helmet: 보안 헤더 설정
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  crossOriginEmbedderPolicy: false
}));

// CORS: Cross-Origin Resource Sharing 설정
app.use(cors({
  origin: true, // 모든 origin 허용 (개발 환경)
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// ==================== 요청 처리 미들웨어 ====================

// 요청 ID 생성 (로깅 및 추적용)
app.use((req, res, next) => {
  req.id = uuidv4();
  next();
});

// JSON 파싱 (크기 제한 설정)
app.use(express.json({ 
  limit: '10mb',
  verify: (req, res, buf) => {
    try {
      JSON.parse(buf);
    } catch (e) {
      res.status(400).json({ error: 'Invalid JSON' });
      throw new Error('Invalid JSON');
    }
  }
}));

// URL 인코딩 파싱
app.use(express.urlencoded({ 
  extended: true, 
  limit: '10mb' 
}));

// ==================== 로깅 미들웨어 ====================

// Morgan: HTTP 요청 로깅
const morganFormat = process.env.NODE_ENV === 'production' 
  ? 'combined' 
  : 'dev';

app.use(morgan(morganFormat, {
  skip: (req, res) => {
    // 헬스체크 요청은 로그에서 제외
    return req.url === '/health' || req.url === '/api/health';
  }
}));

// ==================== API 문서화 ====================

// Swagger UI 설정
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'OOTD API Documentation',
  swaggerOptions: {
    persistAuthorization: true,
    displayRequestDuration: true
  }
}));

// ==================== 라우팅 ====================

// API 라우터
app.use('/', router);

// ==================== 에러 핸들링 ====================

// 404 핸들러 (모든 라우트 이후에 위치)
app.use(notFoundHandler);

// 전역 에러 핸들러 (모든 미들웨어 이후에 위치)
app.use(errorHandler);

// ==================== 서버 시작 로그 ====================

// 서버 시작 시 환경 정보 로그
app.on('listening', () => {
  console.log('🚀 OOTD Backend Server Started');
  console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🌐 Port: ${process.env.PORT || 4000}`);
  console.log(`📚 API Docs: http://localhost:${process.env.PORT || 4000}/api-docs`);
  console.log(`🔍 Health Check: http://localhost:${process.env.PORT || 4000}/health`);
});

export default app;