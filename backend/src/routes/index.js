import { Router } from 'express';
import usersRouter from './users.js';
import weatherRouter from './weather.js';
import recommendationsRouter from './recommendations.js';
import feedbackRouter from './feedback.js';
import temperatureSettingsRouter from './temperatureSettings.js';
import kakaoRouter from './kakao.js';

const router = Router();

router.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

router.use('/api/users', usersRouter);
router.use('/api/weather', weatherRouter);
router.use('/api/recommendations', recommendationsRouter);
router.use('/api/feedback', feedbackRouter);
router.use('/api/temperature-settings', temperatureSettingsRouter);
router.use('/api/kakao', kakaoRouter);

export default router;


