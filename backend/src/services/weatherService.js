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
  const cached = cacheGet(key);
  if (cached) return { ...cached, cached: true };

  // 1) KMA 우선 사용 (키가 있고 nx,ny가 주어진 경우)
  const kmaKeyRaw = process.env.KMA_SERVICE_KEY || process.env.KMA_API_KEY;
  const kmaKey = kmaKeyRaw ? encodeURIComponent(kmaKeyRaw) : undefined;
  if (kmaKey && nx && ny) {
    try {
      const normalized = await fetchKmaUltraNow(kmaKey, nx, ny, lat, lon);
      cacheSet(key, normalized, DEFAULT_TTL_MS);
      return { ...normalized, cached: false, source: 'kma' };
    } catch (e) {
      // KMA 실패 시 다음 소스로 폴백
    }
  }

  // 2) OpenWeather 사용
  const apiKey = process.env.OPENWEATHER_API_KEY;
  if (!apiKey) {
    // 키 없으면 스텁 유지
    const now = new Date().toISOString();
    const stub = {
      timestamp: now,
      location: { lat, lon },
      temp: 24.0,
      feelsLike: 25.5,
      humidity: 62,
      windSpeed: 2.1,
      condition: 'Clouds'
    };
    cacheSet(key, stub, DEFAULT_TTL_MS);
    return { ...stub, cached: false, source: 'stub' };
  }

  const url = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric`;
  const resp = await fetch(url);
  if (!resp.ok) {
    throw new Error(`OpenWeather error: ${resp.status}`);
  }
  const data = await resp.json();
  // 표준화
  const normalized = {
    timestamp: new Date(data.dt * 1000).toISOString(),
    location: { lat, lon },
    temp: data.main?.temp,
    feelsLike: data.main?.feels_like,
    humidity: data.main?.humidity,
    windSpeed: data.wind?.speed,
    condition: data.weather?.[0]?.main || 'Unknown'
  };
  cacheSet(key, normalized, DEFAULT_TTL_MS);
  return { ...normalized, cached: false, source: 'openweather' };
}

// KMA 초단기실황(getUltraSrtNcst) 호출 → 표준화
async function fetchKmaUltraNow(serviceKey, nx, ny, lat, lon) {
  const { baseDate, baseTime } = computeKmaBase();
  const params = new URLSearchParams({
    serviceKey: decodeURIComponent(serviceKey),
    pageNo: '1',
    numOfRows: '100',
    dataType: 'JSON',
    base_date: baseDate,
    base_time: baseTime,
    nx: String(nx),
    ny: String(ny)
  });
  const url = `https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?${params.toString()}`;
  const resp = await fetch(url);
  if (!resp.ok) {
    throw new Error(`KMA error: ${resp.status}`);
  }
  const j = await resp.json();
  const items = j?.response?.body?.items?.item || [];

  // 카테고리 매핑: T1H(기온), REH(습도), WSD(풍속), RN1(강수), SKY(하늘상태)
  const map = new Map();
  for (const it of items) {
    map.set(it.category, Number(it.obsrValue));
  }
  const temp = map.get('T1H');
  const humidity = map.get('REH');
  const windSpeed = map.get('WSD');
  const sky = map.get('SKY');

  const condition = skyToCondition(sky);
  const feelsLike = typeof temp === 'number' ? temp : undefined; // 단순화
  const tm = items[0]?.baseDate && items[0]?.baseTime
    ? kmaToIso(items[0].baseDate, items[0].baseTime)
    : new Date().toISOString();

  return {
    timestamp: tm,
    location: { lat, lon },
    temp,
    feelsLike,
    humidity,
    windSpeed,
    condition
  };
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

function kmaToIso(baseDate, baseTime) {
  const yyyy = baseDate.slice(0, 4);
  const mm = baseDate.slice(4, 6);
  const dd = baseDate.slice(6, 8);
  const hh = baseTime.slice(0, 2);
  const min = baseTime.slice(2, 4);
  return new Date(`${yyyy}-${mm}-${dd}T${hh}:${min}:00+09:00`).toISOString();
}


