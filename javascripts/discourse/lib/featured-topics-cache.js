const CACHE_TTL_MS = 60_000;
const sessionCaches = new WeakMap();

function requestKey(request, userId) {
  const params = Object.entries(request.params ?? {}).sort(([left], [right]) =>
    left.localeCompare(right)
  );

  return JSON.stringify([userId ?? null, request.filter, params]);
}

function cacheFor(session, now) {
  let cache = sessionCaches.get(session);

  if (!cache) {
    cache = new Map();
    sessionCaches.set(session, cache);
  }

  for (const [key, entry] of cache) {
    if (entry.expiresAt <= now) {
      cache.delete(key);
    }
  }

  return cache;
}

export async function findCachedFeaturedTopicList({
  request,
  session,
  store,
  userId,
}) {
  const now = Date.now();
  const cache = cacheFor(session, now);
  const key = requestKey(request, userId);
  const cached = cache.get(key);

  if (cached) {
    return cached.promise;
  }

  const promise = store.findFiltered("topicList", request);
  cache.set(key, { expiresAt: now + CACHE_TTL_MS, promise });

  try {
    return await promise;
  } catch (error) {
    if (cache.get(key)?.promise === promise) {
      cache.delete(key);
    }
    throw error;
  }
}
