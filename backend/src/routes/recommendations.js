import { Router } from 'express';
import { getRecommendation } from '../services/recommendService.js';

const router = Router();

// GET /api/recommendations?userId=..&lat=..&lon=..&situation=commute|date|workout
router.get('/', async (req, res, next) => {
  try {
    const userId = String(req.query.userId || '');
    const lat = Number(req.query.lat);
    const lon = Number(req.query.lon);
    const situation = String(req.query.situation || '');

    if (!userId) return res.status(400).json({ error: 'userId is required' });
    if (Number.isNaN(lat) || Number.isNaN(lon)) return res.status(400).json({ error: 'lat/lon are required numbers' });
    if (!['commute','date','workout','daily','travel','business'].includes(situation)) {
      return res.status(400).json({ error: 'invalid situation' });
    }

    const result = await getRecommendation({ userId, lat, lon, situation });
    res.json(result);
  } catch (err) {
    next(err);
  }
});

export default router;


