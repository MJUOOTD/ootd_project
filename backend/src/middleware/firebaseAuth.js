import { auth } from '../config/firebase.js';

/**
 * Firebase 인증 미들웨어
 * Authorization 헤더에서 Firebase ID 토큰을 검증하고 사용자 정보를 req.userId에 설정
 */
export const firebaseAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: '인증이 필요합니다. 다시 로그인 해주세요.' });
    }

    const idToken = authHeader.split('Bearer ')[1];

    // Firebase ID 토큰 검증
    const decodedToken = await auth.verifyIdToken(idToken);
    
    // 사용자 ID를 req.userId에 설정
    req.userId = decodedToken.uid;
    req.user = decodedToken; // 전체 사용자 정보도 저장
    
    next();
  } catch (error) {
    return res.status(401).json({ 
      error: '인증이 필요합니다. 다시 로그인 해주세요.',
      details: error.message 
    });
  }
};
