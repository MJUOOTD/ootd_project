import { Router } from 'express';
import { applyTemperatureFeedback } from '../services/feedbackService.js';

const router = Router();

// POST /api/feedback
// body: { userId: string, tempFeeling: 'cold'|'hot'|'ok', satisfaction?: 'like'|'dislike' }
router.post('/', (req, res, next) => {
  try {
    const { userId, tempFeeling } = req.body || {};
    if (!userId) return res.status(400).json({ error: 'userId is required' });
    if (!['cold','hot','ok'].includes(tempFeeling)) return res.status(400).json({ error: 'invalid tempFeeling' });
    const updatedProfile = applyTemperatureFeedback(userId, tempFeeling);
    res.status(200).json({ userId, profile: updatedProfile });
  } catch (err) {
    next(err);
  }
});

export default router;


