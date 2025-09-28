import admin from 'firebase-admin';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Firebase Admin SDK 초기화
let firebaseApp;

try {
  // Firebase 서비스 계정 키 파일 경로
  // 프로덕션에서는 환경변수로 관리하는 것이 좋습니다
  const serviceAccountPath = join(__dirname, '../../firebase-service-account-key.json');
  
  // 서비스 계정 키 파일이 있는지 확인
  try {
    const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf8'));
    
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      // Firestore 데이터베이스 URL (선택사항)
      // databaseURL: "https://your-project-id-default-rtdb.firebaseio.com"
    });
  } catch (fileError) {
    // 서비스 계정 키 파일이 없는 경우 환경변수 사용
    // 환경변수에서 Firebase 설정 가져오기
    const serviceAccount = {
      type: "service_account",
      project_id: process.env.FIREBASE_PROJECT_ID,
      private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
      private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      client_email: process.env.FIREBASE_CLIENT_EMAIL,
      client_id: process.env.FIREBASE_CLIENT_ID,
      auth_uri: "https://accounts.google.com/o/oauth2/auth",
      token_uri: "https://oauth2.googleapis.com/token",
      auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
      client_x509_cert_url: `https://www.googleapis.com/robot/v1/metadata/x509/${process.env.FIREBASE_CLIENT_EMAIL}`
    };
    
    if (!serviceAccount.project_id) {
      throw new Error('Firebase environment variables not set');
    }
    
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
  }
} catch (error) {
  console.error('❌ Firebase Admin SDK initialization failed:', error.message);
  process.exit(1);
}

// Firestore 인스턴스 내보내기
export const db = admin.firestore();

// Firebase Auth 인스턴스 내보내기
export const auth = admin.auth();

// Firebase Admin 인스턴스 내보내기 (필요시)
export { admin };

// Firestore 설정
db.settings({
  // 타임스탬프를 자동으로 변환하지 않도록 설정
  timestampsInSnapshots: true
});

export default firebaseApp;
