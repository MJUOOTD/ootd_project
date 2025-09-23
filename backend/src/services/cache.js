// 간단한 TTL 인메모리 캐시. 추후 Redis로 교체 가능.
const store = new Map(); // key -> { value, expiresAt }

export function cacheGet(key) {
  const hit = store.get(key);
  if (!hit) return null;
  if (hit.expiresAt && hit.expiresAt < Date.now()) {
    store.delete(key);
    return null;
  }
  return hit.value;
}

export function cacheSet(key, value, ttlMs) {
  const expiresAt = ttlMs ? Date.now() + ttlMs : undefined;
  store.set(key, { value, expiresAt });
}

export function cacheClear() {
  store.clear();
}


