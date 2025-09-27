import { Router } from 'express';
import { getUserProfile, upsertUserProfile } from '../services/userService.js';

const router = Router();

// GET /api/users/:userId/profile
router.get('/:userId/profile', (req, res) => {
  const { userId } = req.params;
  const profile = getUserProfile(userId);
  if (!profile) return res.status(404).json({ error: 'Profile not found' });
  res.json({ userId, profile });
});

// POST /api/users/:userId/profile
router.post('/:userId/profile', (req, res) => {
  const { userId } = req.params;
  const { name, gender, age, temperatureSensitivity } = req.body || {};

  // 간단 검증 (MVP). 차후 zod/celebrate로 강화
  if (typeof userId !== 'string' || !userId) {
    return res.status(400).json({ error: 'Invalid userId' });
  }
  if (temperatureSensitivity !== undefined && typeof temperatureSensitivity !== 'number') {
    return res.status(400).json({ error: 'temperatureSensitivity must be number' });
  }

  const profile = upsertUserProfile(userId, { name, gender, age, temperatureSensitivity });
  res.status(201).json({ userId, profile });
});

export default router;


