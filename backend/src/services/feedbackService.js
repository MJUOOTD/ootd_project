import { getUserProfile, upsertUserProfile } from './userService.js';

// tempFeeling: 'cold' | 'hot' | 'ok'
// 간단 규칙: cold→+0.05, hot→-0.05, ok→0. 0.7~1.3 범위 클램프
export function applyTemperatureFeedback(userId, tempFeeling) {
  const profile = getUserProfile(userId);
  if (!profile) throw new Error('User profile not found');
  const delta = tempFeeling === 'cold' ? 0.05 : tempFeeling === 'hot' ? -0.05 : 0;
  const current = typeof profile.temperatureSensitivity === 'number' ? profile.temperatureSensitivity : 1.0;
  const next = clamp(current + delta, 0.7, 1.3);
  const updated = upsertUserProfile(userId, { temperatureSensitivity: Number(next.toFixed(2)) });
  return updated;
}

function clamp(v, min, max) {
  return Math.min(max, Math.max(min, v));
}


