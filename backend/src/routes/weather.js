import { Router } from 'express';
import { getCurrentWeather } from '../services/weatherService.js';
import { firebaseAuth } from '../middleware/firebaseAuth.js';

const router = Router();

// GET /api/weather/current?lat=..&lon=..
router.get('/current', async (req, res, next) => {
  try {
    const lat = Number(req.query.lat);
    const lon = Number(req.query.lon);
    const nx = req.query.nx !== undefined ? Number(req.query.nx) : undefined;
    const ny = req.query.ny !== undefined ? Number(req.query.ny) : undefined;
    const force = req.query.force === 'true' || req.query.force === '1';
    if (Number.isNaN(lat) || Number.isNaN(lon)) {
      return res.status(400).json({ error: 'lat and lon are required numbers' });
    }
    
    // 선택적 인증: Authorization 헤더가 있으면 인증 시도
    let userId = null;
    if (req.headers.authorization) {
      try {
        // Firebase 인증 미들웨어를 수동으로 호출
        await new Promise((resolve, reject) => {
          firebaseAuth(req, res, (err) => {
            if (err) reject(err);
            else resolve();
          });
        });
        userId = req.userId || null;
      } catch (authError) {
        // 인증 실패시 무시하고 기본 날씨만 제공
        console.warn('Authentication failed, providing basic weather data:', authError.message);
      }
    }
    
    const data = await getCurrentWeather(lat, lon, { nx, ny, force, userId });
    res.json(data);
  } catch (err) {
    next(err);
  }
});

export default router;


