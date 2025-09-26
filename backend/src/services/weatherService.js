import { cacheGet, cacheSet } from './cache.js';
import fetch from 'node-fetch';
import { toGrid } from './kmaGrid.js';

// TODO: 기상청 API 연동. 현재는 스텁 데이터 + 캐시만 제공
const DEFAULT_TTL_MS = 5 * 60 * 1000; // 5분

export async function getCurrentWeather(lat, lon, opts = {}) {
  if (typeof lat !== 'number' || typeof lon !== 'number') {
    throw new Error('lat/lon must be numbers');
  }
  let nx = typeof opts.nx === 'number' ? opts.nx : undefined;
  let ny = typeof opts.ny === 'number' ? opts.ny : undefined;
  if (!nx || !ny) {
    const g = toGrid(lat, lon);
    nx = g.nx; ny = g.ny;
  }
  const key = `wx:${lat.toFixed(3)}:${lon.toFixed(3)}:${nx ?? 'x'}:${ny ?? 'y'}`;
  const force = opts.force === true;
  const cached = cacheGet(key);
  if (!force && cached) {
    console.log(`[weather] cache hit key=${key}`);
    return { ...cached, cached: true };
  }

  const kmaKeyRaw = process.env.KMA_SERVICE_KEY || process.env.KMA_API_KEY;
  if (!kmaKeyRaw) {
    throw new Error('KMA_SERVICE_KEY is not configured in .env file');
  }
  const kmaKey = kmaKeyRaw;

  try {
    console.log(`[weather] fetch KMA nx=${nx} ny=${ny} lat=${lat} lon=${lon} force=${force}`);

    // KMA API 호출(초단기실황)을 8~10초 내로 제한
    const kmaPromise = fetchKmaUltraNow(kmaKey, nx, ny, lat, lon);
    const timeoutPromise = new Promise((_, reject) =>
      setTimeout(() => reject(new Error('KMA API timeout')), 10000)
    );
    const normalized = await Promise.race([kmaPromise, timeoutPromise]);

    // Reverse geocoding 동기 수행(짧은 타임아웃으로 실사용 표시 개선)
    try {
      const place = await reverseGeocode(lat, lon);
      if (place) {
        normalized.location.city = place.city || normalized.location.city;
        normalized.location.country = place.country || normalized.location.country;
        normalized.location.district = place.district || normalized.location.district;
        normalized.location.subLocality = place.subLocality || normalized.location.subLocality;
      }
    } catch (_) {}

    cacheSet(key, normalized, DEFAULT_TTL_MS);
    return { ...normalized, cached: false, source: 'kma' };
  } catch (e) {
    console.error('Failed to fetch data from KMA API:', e);
    if (cached) {
      console.warn('[weather] returning cached due to KMA failure');
      return { ...cached, cached: true, source: cached.source ?? 'cache' };
    }
    console.warn('[weather] returning fallback weather');
    return buildFallback(lat, lon);
  }
}

// 단기예보(3시간 간격) 조회
export async function getForecast3h(lat, lon) {
  // 빠른 응답 우선: 4초 안에 못 받으면 즉시 폴백
  const { nx, ny } = toGrid(lat, lon);
  const kmaKeyRaw = process.env.KMA_SERVICE_KEY || process.env.KMA_API_KEY;
  if (!kmaKeyRaw) return { location: { latitude: lat, longitude: lon }, intervals: [], source: 'forecast-fallback' };
  const serviceKey = kmaKeyRaw;

  async function fetchForecastLoop() {
    let attempt = 0;
    let { baseDate, baseTime } = computeKmaVilageBase();
    while (attempt < 6) {
      const params = new URLSearchParams({
        serviceKey,
        pageNo: '1',
        numOfRows: '200',
        dataType: 'JSON',
        base_date: baseDate,
        base_time: baseTime,
        nx: String(nx),
        ny: String(ny)
      });
      const url = `https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?${params.toString()}`;
      const resp = await fetch(url);
      if (!resp.ok) throw new Error(`KMA forecast error: ${resp.status}`);
      const j = await resp.json();
      const resultCode = j?.response?.header?.resultCode;
      if (resultCode && resultCode !== '00') {
        const resultMsg = j?.response?.header?.resultMsg || 'KMA forecast error';
        throw new Error(`KMA forecast response error: ${resultCode} ${resultMsg}`);
      }
      const items = j?.response?.body?.items?.item || [];
      if (Array.isArray(items) && items.length > 0) {
        return normalizeVilage(items, lat, lon);
      }
      const prev = stepBackVilageBase(baseDate, baseTime);
      baseDate = prev.baseDate; baseTime = prev.baseTime;
      attempt += 1;
    }
    // 초단기예보 폴백
    const ultra = await fetchKmaUltraSrtFcst(serviceKey, nx, ny, lat, lon).catch(() => null);
    if (ultra && ultra.length > 0) return normalizeUltraTo3h(ultra, lat, lon);
    return { location: { latitude: lat, longitude: lon }, intervals: [], source: 'kma-forecast' };
  }

  const timeout = new Promise((_, reject) => setTimeout(() => reject(new Error('forecast-timeout')), 4000));
  try {
    return await Promise.race([fetchForecastLoop(), timeout]);
  } catch (_) {
    // 최종 폴백: 현재 시각 기준 8개 슬롯을 비워서 반환(클라이언트는 현재값으로 대체 가능)
    return { location: { latitude: lat, longitude: lon }, intervals: [], source: 'forecast-timeout' };
  }
}

function normalizeVilage(items, lat, lon) {
  // 카테고리: TMP(기온), POP(강수확률), PCP(강수량), SKY(하늘상태), REH(습도), WSD(풍속)
  const byTime = new Map();
  for (const it of items) {
    const key = `${it.fcstDate}${it.fcstTime}`;
    if (!byTime.has(key)) byTime.set(key, {});
    const bucket = byTime.get(key);
    bucket.fcstDate = it.fcstDate;
    bucket.fcstTime = it.fcstTime;
    bucket[it.category] = it.fcstValue;
  }
  const result = [];
  for (const [_key, v] of byTime.entries()) {
    const hh = Number(String(v.fcstTime).slice(0,2));
    if (hh % 3 !== 0) continue;
    const condition = skyToCondition(Number(v.SKY));
    result.push({
      timestamp: kmaToIso(v.fcstDate, v.fcstTime),
      // 기온: 단기예보는 T3H(3시간 기온)를 우선 사용, 없으면 TMP
      temperature: parseFloat((v.T3H ?? v.TMP ?? v.TEM ?? '0').toString()),
      humidity: Number(v.REH) || 0,
      windSpeed: Number(v.WSD) || 0,
      // 강수량: '강수없음', '1.0mm', '1.0~4.0mm' 등 처리
      precipitation: (() => {
        const raw = (v.PCP ?? '0').toString();
        if (raw.includes('강수없음')) return 0;
        const m = raw.match(/-?\d+(?:\.\d+)?/);
        return m ? parseFloat(m[0]) : 0;
      })(),
      condition,
    });
  }
  // 현재 시각 이후(현재 포함)만 남기고 오름차순 정렬
  const now = new Date();
  const aligned = new Date(now.getFullYear(), now.getMonth(), now.getDate(), Math.floor(now.getHours()/3)*3, 0, 0);
  const filtered = result
    .filter(r => new Date(r.timestamp) >= aligned)
    .sort((a,b) => (new Date(a.timestamp)) - (new Date(b.timestamp)));
  return { location: { latitude: lat, longitude: lon }, intervals: filtered.slice(0, 8), source: 'kma-forecast' };
}

function computeKmaVilageBase() {
  // 기준시각: 02,05,08,11,14,17,20,23 중 현재 시각 이전의 가장 최근값
  const now = new Date();
  const slots = [2,5,8,11,14,17,20,23];
  let hh = now.getHours();
  let dd = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  let baseHour = 23;
  for (let i = slots.length - 1; i >= 0; i--) {
    if (hh >= slots[i]) { baseHour = slots[i]; break; }
  }
  if (hh < 2) { // 전일 23시
    dd = new Date(dd.getTime() - 24*60*60*1000);
    baseHour = 23;
  }
  const yyyy = dd.getFullYear();
  const mm = String(dd.getMonth()+1).padStart(2,'0');
  const day = String(dd.getDate()).padStart(2,'0');
  const baseDate = `${yyyy}${mm}${day}`;
  const baseTime = String(baseHour).padStart(2,'0') + '00';
  return { baseDate, baseTime };
}

function stepBackVilageBase(baseDate, baseTime) {
  const yyyy = Number(baseDate.slice(0,4));
  const mm = Number(baseDate.slice(4,6));
  const dd = Number(baseDate.slice(6,8));
  const hh = Number(baseTime.slice(0,2));
  const d = new Date(yyyy, mm-1, dd, hh, 0);
  d.setHours(d.getHours() - 3);
  const y = d.getFullYear();
  const m = String(d.getMonth()+1).padStart(2,'0');
  const day = String(d.getDate()).padStart(2,'0');
  const h = String(d.getHours()).padStart(2,'0');
  return { baseDate: `${y}${m}${day}`, baseTime: `${h}00` };
}

// 초단기예보(ultra short forecast, 30분 간격) 호출
async function fetchKmaUltraSrtFcst(serviceKey, nx, ny, lat, lon) {
  const { baseDate, baseTime } = computeKmaBase();
  const params = new URLSearchParams({
    serviceKey,
    pageNo: '1',
    numOfRows: '200',
    dataType: 'JSON',
    base_date: baseDate,
    base_time: baseTime,
    nx: String(nx),
    ny: String(ny)
  });
  const url = `https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst?${params.toString()}`;
  const resp = await fetch(url);
  if (!resp.ok) throw new Error(`KMA ultra forecast error: ${resp.status}`);
  const j = await resp.json();
  const resultCode = j?.response?.header?.resultCode;
  if (resultCode && resultCode !== '00') {
    const resultMsg = j?.response?.header?.resultMsg || 'KMA ultra forecast error';
    throw new Error(`KMA ultra forecast response error: ${resultCode} ${resultMsg}`);
  }
  const items = j?.response?.body?.items?.item || [];
  return items;
}

function normalizeUltraTo3h(items, lat, lon) {
  // 항목들을 시간키로 묶고 필요한 카테고리 추출(T1H, SKY, REH, WSD, RN1)
  const byTime = new Map();
  for (const it of items) {
    const key = `${it.fcstDate}${it.fcstTime}`;
    if (!byTime.has(key)) byTime.set(key, {});
    const b = byTime.get(key);
    b.fcstDate = it.fcstDate; b.fcstTime = it.fcstTime;
    b[it.category] = it.fcstValue;
  }
  // 현재 시각 정렬 후 3시간 간격만 샘플링(가장 가까운 시각 채택)
  const all = [];
  for (const [, v] of byTime.entries()) {
    const ts = kmaToIso(v.fcstDate, v.fcstTime);
    all.push({
      timestamp: ts,
      temperature: parseFloat((v.T1H ?? '0').toString()),
      humidity: Number(v.REH) || 0,
      windSpeed: parseFloat((v.WSD ?? '0').toString()) || 0,
      precipitation: parseFloat((v.RN1 ?? '0').toString()) || 0,
      condition: skyToCondition(Number(v.SKY)),
    });
  }
  all.sort((a,b) => (new Date(a.timestamp)) - (new Date(b.timestamp)));
  const now = new Date();
  const aligned = new Date(now.getFullYear(), now.getMonth(), now.getDate(), Math.floor(now.getHours()/3)*3, 0, 0);
  // 타깃 8개 시각 생성
  const targets = Array.from({length: 8}).map((_,i)=>new Date(aligned.getTime()+i*3*60*60*1000));
  const intervals = [];
  for (const t of targets) {
    const pick = pickNearest(all, t);
    if (pick) intervals.push(pick);
  }
  return { location: { latitude: lat, longitude: lon }, intervals, source: 'kma-ultra-forecast' };
}

function pickNearest(list, targetDate) {
  let best = null; let bestDiff = Infinity;
  for (const x of list) {
    const d = Math.abs(new Date(x.timestamp) - targetDate);
    if (d < bestDiff) { bestDiff = d; best = x; }
  }
  return best;
}
// KMA 초단기실황(getUltraSrtNcst) 호출 → 표준화
async function fetchKmaUltraNow(serviceKey, nx, ny, lat, lon) {
  // 최대 3회 시도: 현재 기준시각 → -30분 → -60분
  let attempt = 0;
  let cur = computeKmaBase();
  let lastError;
  while (attempt < 3) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 8000); // 8초 타임아웃
    try {
      const params = new URLSearchParams({
        serviceKey: serviceKey,
        pageNo: '1',
        numOfRows: '100',
        dataType: 'JSON',
        base_date: cur.baseDate,
        base_time: cur.baseTime,
        nx: String(nx),
        ny: String(ny)
      });
      const url = `https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?${params.toString()}`;
      console.log(`[weather] KMA request attempt=${attempt + 1} base=${cur.baseDate} ${cur.baseTime}`);
      const resp = await fetch(url, { signal: controller.signal });
      clearTimeout(timeout);
      if (!resp.ok) {
        throw new Error(`KMA error: ${resp.status}`);
      }
      const j = await resp.json();
      const resultCode = j?.response?.header?.resultCode;
      if (resultCode && resultCode !== '00') {
        const resultMsg = j?.response?.header?.resultMsg || 'KMA error';
        throw new Error(`KMA response error: ${resultCode} ${resultMsg}`);
      }
      const items = j?.response?.body?.items?.item || [];
      if (!Array.isArray(items) || items.length === 0) {
        throw new Error('KMA empty items');
      }

      // 카테고리 매핑: T1H(기온), REH(습도), WSD(풍속), RN1(강수), VEC(풍향), SKY(하늘상태)
      const map = new Map();
      for (const it of items) {
        const raw = it.obsrValue;
        const val = (raw === '-' || raw === null || raw === undefined) ? null : Number(raw);
        map.set(it.category, Number.isFinite(val) ? val : null);
      }
      const temperature = map.get('T1H');
      const humidity = map.get('REH');
      const windSpeed = map.get('WSD');
      const windDirection = map.get('VEC');
      const precipitation = map.get('RN1');
      const sky = map.get('SKY');

      const condition = skyToCondition(sky);
      const feelsLike = typeof temperature === 'number' ? temperature : undefined;
      const timestamp = items[0]?.baseDate && items[0]?.baseTime
        ? kmaToIso(items[0].baseDate, items[0].baseTime)
        : new Date().toISOString();

      return {
        timestamp,
        temperature,
        feelsLike,
        humidity,
        windSpeed,
        windDirection,
        precipitation,
        condition,
        description: condition,
        icon: '',
        location: {
          latitude: lat,
          longitude: lon,
          city: '',
          country: '',
          district: '',
          subLocality: '',
        },
      };
    } catch (e) {
      clearTimeout(timeout);
      lastError = e;
      console.warn(`[weather] KMA attempt ${attempt + 1} failed: ${e?.message || e}`);
      // 다음 시도: 기준시각을 30분 더 과거로 이동
      cur = stepBack30(cur);
      attempt += 1;
    }
  }
  throw lastError || new Error('KMA fetch failed');
}

function skyToCondition(sky) {
  if (sky === 1) return 'Clear';
  if (sky === 3) return 'Clouds';
  if (sky === 4) return 'Overcast';
  return 'Unknown';
}

function computeKmaBase() {
  // 초단기실황 기준시각: 매시 40분 이후 최신 시각. 안전하게 현재시각 - 60분 후 가장 가까운 30분 단위로 설정
  const now = new Date();
  const t = new Date(now.getTime() - 60 * 60000);
  const hh = String(t.getHours()).padStart(2, '0');
  const mm = t.getMinutes();
  const rounded = mm >= 30 ? '30' : '00';
  const baseTime = `${hh}${rounded}`;
  const yyyy = t.getFullYear();
  const mm2 = String(t.getMonth() + 1).padStart(2, '0');
  const dd2 = String(t.getDate()).padStart(2, '0');
  const baseDate = `${yyyy}${mm2}${dd2}`;
  return { baseDate, baseTime };
}

function stepBack30(base) {
  const yyyy = Number(base.baseDate.slice(0, 4));
  const mm = Number(base.baseDate.slice(4, 6));
  const dd = Number(base.baseDate.slice(6, 8));
  const hh = Number(base.baseTime.slice(0, 2));
  const min = Number(base.baseTime.slice(2, 4));
  const d = new Date(yyyy, mm - 1, dd, hh, min);
  d.setMinutes(d.getMinutes() - 30);
  const ny = d.getFullYear();
  const nm = String(d.getMonth() + 1).padStart(2, '0');
  const nd = String(d.getDate()).padStart(2, '0');
  const nh = String(d.getHours()).padStart(2, '0');
  const nmin = d.getMinutes() >= 30 ? '30' : '00';
  return { baseDate: `${ny}${nm}${nd}`, baseTime: `${nh}${nmin}` };
}

function kmaToIso(baseDate, baseTime) {
  const yyyy = baseDate.slice(0, 4);
  const mm = baseDate.slice(4, 6);
  const dd = baseDate.slice(6, 8);
  const hh = baseTime.slice(0, 2);
  const min = baseTime.slice(2, 4);
  return new Date(`${yyyy}-${mm}-${dd}T${hh}:${min}:00+09:00`).toISOString();
}

// OpenStreetMap Nominatim을 사용한 간단한 reverse geocoding
async function reverseGeocode(lat, lon) {
  const params = new URLSearchParams({
    format: 'jsonv2',
    lat: String(lat),
    lon: String(lon),
    'accept-language': 'ko'
  });
  const url = `https://nominatim.openstreetmap.org/reverse?${params.toString()}`;
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 3000); // 3초 타임아웃
  let resp;
  try {
    resp = await fetch(url, {
      headers: {
        'User-Agent': 'project2-weather/1.0 (contact: dev@example.com)'
      },
      signal: controller.signal,
    });
  } catch (_) {
    clearTimeout(timeout);
    return null;
  }
  clearTimeout(timeout);
  if (!resp.ok) return null;
  const j = await resp.json();
  const addr = j.address || {};
  const city = addr.city || addr.town || addr.village || addr.county || '';
  const country = (addr.country_code ? String(addr.country_code).toUpperCase() : '') || addr.country || '';
  // 구 후보 필드 우선순위: city_district > borough > state_district > county > district
  const district = addr.city_district || addr.borough || addr.state_district || addr.county || addr.district || '';
  // 동 후보 필드 우선순위: suburb > neighbourhood > quarter > village > hamlet
  const subLocality = addr.suburb || addr.neighbourhood || addr.quarter || addr.village || addr.hamlet || '';
  return { city, country, district, subLocality };
}

function buildFallback(lat, lon) {
  const nowIso = new Date().toISOString();
  return {
    timestamp: nowIso,
    temperature: 22,
    feelsLike: 22,
    humidity: 60,
    windSpeed: 2,
    windDirection: 0,
    precipitation: 0,
    condition: 'Clear',
    description: 'fallback',
    icon: '',
    location: {
      latitude: lat,
      longitude: lon,
      city: '',
      country: '',
      district: '',
      subLocality: '',
    },
    source: 'fallback',
    cached: false,
  };
}


