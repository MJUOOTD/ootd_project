import { Router } from 'express';
import { getCurrentWeather, getForecast3h } from '../services/weatherService.js';

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
    
    console.log(`[weather] API request: lat=${lat}, lon=${lon}, force=${force}`);
    const startTime = Date.now();
    
    const data = await getCurrentWeather(lat, lon, { nx, ny, force });
    
    const duration = Date.now() - startTime;
    console.log(`[weather] API response time: ${duration}ms`);
    
    res.json(data);
  } catch (err) {
    console.error('[weather] API error:', err);
    next(err);
  }
});

// GET /api/weather/test - 빠른 테스트용 엔드포인트
router.get('/test', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Weather API is working',
    timestamp: new Date().toISOString(),
    test: true
  });
});

export default router;

// GET /api/weather/forecast?lat=..&lon=..
router.get('/forecast', async (req, res, next) => {
  try {
    const lat = Number(req.query.lat);
    const lon = Number(req.query.lon);
    if (Number.isNaN(lat) || Number.isNaN(lon)) {
      return res.status(400).json({ error: 'lat and lon are required numbers' });
    }
    const data = await getForecast3h(lat, lon);
    res.json(data);
  } catch (err) {
    next(err);
  }
});


