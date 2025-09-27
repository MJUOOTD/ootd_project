import { Router } from 'express';
import usersRouter from './users.js';
import weatherRouter from './weather.js';
import recommendationsRouter from './recommendations.js';
import feedbackRouter from './feedback.js';

const router = Router();

router.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

router.use('/api/users', usersRouter);
router.use('/api/weather', weatherRouter);
router.use('/api/recommendations', recommendationsRouter);
router.use('/api/feedback', feedbackRouter);

export default router;


