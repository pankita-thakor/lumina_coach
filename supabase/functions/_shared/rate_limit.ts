/** Best-effort in-memory limiter (resets on cold start). */
const buckets = new Map<string, { n: number; reset: number }>();
const WINDOW_MS = 60_000;
const MAX_PER_WINDOW = 60;

export function rateLimitHit(userId: string, fn: string): boolean {
  const key = `${userId}:${fn}`;
  const now = Date.now();
  const b = buckets.get(key);
  if (!b || now > b.reset) {
    buckets.set(key, { n: 1, reset: now + WINDOW_MS });
    return false;
  }
  b.n += 1;
  if (b.n > MAX_PER_WINDOW) return true;
  return false;
}
