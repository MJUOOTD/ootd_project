import { Router } from 'express';
import { getCurrentWeather } from '../services/weatherService.js';

const router = Router();

// GET /api/weather/current?lat=..&lon=..
router.get('/current', async (req, res, next) => {
  try {
    const lat = Number(req.query.lat);
    const lon = Number(req.query.lon);
    const nx = req.query.nx !== undefined ? Number(req.query.nx) : undefined;
    const ny = req.query.ny !== undefined ? Number(req.query.ny) : undefined;
    if (Number.isNaN(lat) || Number.isNaN(lon)) {
      return res.status(400).json({ error: 'lat and lon are required numbers' });
    }
    const data = await getCurrentWeather(lat, lon, { nx, ny });
    res.json(data);
  } catch (err) {
    next(err);
  }
});

export default router;


