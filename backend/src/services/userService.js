// 임시 인메모리 저장소 (MVP 스켈레톤). 차후 Firebase Firestore로 대체 예정.
const userStore = new Map(); // key: userId, value: { profile, preferences, feedback, analytics }

export function upsertUserProfile(userId, profile) {
  const existing = userStore.get(userId) || {};
  const updated = { ...existing, profile: { ...existing.profile, ...profile } };
  userStore.set(userId, updated);
  return updated.profile;
}

export function getUserProfile(userId) {
  const existing = userStore.get(userId);
  return existing?.profile || null;
}

export function _debugReset() {
  userStore.clear();
}


