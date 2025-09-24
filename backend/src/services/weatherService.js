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

  // KMA API만 사용
  const kmaKeyRaw = process.env.KMA_SERVICE_KEY || process.env.KMA_API_KEY;
  if (!kmaKeyRaw) {
    throw new Error('KMA_SERVICE_KEY is not configured in .env file');
  }
  const kmaKey = encodeURIComponent(kmaKeyRaw);

  try {
    console.log(`[weather] fetch KMA nx=${nx} ny=${ny} lat=${lat} lon=${lon} force=${force}`);
    const normalized = await fetchKmaUltraNow(kmaKey, nx, ny, lat, lon);
    // Reverse geocoding으로 도시/국가 정보 보강 (best-effort)
    try {
      const place = await reverseGeocode(lat, lon);
      if (place) {
        normalized.location.city = place.city || normalized.location.city;
        normalized.location.country = place.country || normalized.location.country;
        normalized.location.district = place.district || normalized.location.district;
      }
    } catch (_) {
      // geocode 실패는 무시
    }
    cacheSet(key, normalized, DEFAULT_TTL_MS);
    return { ...normalized, cached: false, source: 'kma' };
  } catch (e) {
    console.error('Failed to fetch data from KMA API:', e);
    // 폴백: 캐시가 있으면 캐시 반환, 없으면 정해진 기본값 반환
    if (cached) {
      console.warn('[weather] returning cached due to KMA failure');
      return { ...cached, cached: true, source: cached.source ?? 'cache' };
    }
    console.warn('[weather] returning fallback weather');
    return buildFallback(lat, lon);
  }
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

  // 카테고리 매핑: T1H(기온), REH(습도), WSD(풍속), RN1(강수), VEC(풍향), SKY(하늘상태)
  const map = new Map();
  for (const it of items) {
    map.set(it.category, Number(it.obsrValue));
  }
  const temperature = map.get('T1H');
  const humidity = map.get('REH');
  const windSpeed = map.get('WSD');
  const windDirection = map.get('VEC');
  const precipitation = map.get('RN1');
  const sky = map.get('SKY');

  const condition = skyToCondition(sky);
  // KMA API는 체감온도를 제공하지 않으므로, 현재 기온으로 대체
  const feelsLike = typeof temperature === 'number' ? temperature : undefined;
  const timestamp = items[0]?.baseDate && items[0]?.baseTime
    ? kmaToIso(items[0].baseDate, items[0].baseTime)
    : new Date().toISOString();

  // Flutter WeatherModel에 맞게 데이터 정규화
  return {
    timestamp,
    temperature,
    feelsLike,
    humidity,
    windSpeed,
    windDirection,
    precipitation,
    condition,
    description: condition, // KMA는 상세 설명을 제공하지 않으므로 condition으로 대체
    icon: '', // KMA는 아이콘 정보를 제공하지 않음
    location: {
      latitude: lat,
      longitude: lon,
      city: '', // reverse geocoding으로 보강
      country: '', // reverse geocoding으로 보강
      district: '', // 구 (city_district/borough/state_district/county 등에서 추출)
    },
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

// OpenStreetMap Nominatim을 사용한 간단한 reverse geocoding
async function reverseGeocode(lat, lon) {
  const params = new URLSearchParams({
    format: 'jsonv2',
    lat: String(lat),
    lon: String(lon),
    'accept-language': 'ko'
  });
  const url = `https://nominatim.openstreetmap.org/reverse?${params.toString()}`;
  const resp = await fetch(url, {
    headers: {
      'User-Agent': 'project2-weather/1.0 (contact: dev@example.com)'
    },
    // 5초 타임아웃 래핑
  });
  if (!resp.ok) return null;
  const j = await resp.json();
  const addr = j.address || {};
  const city = addr.city || addr.town || addr.village || addr.county || '';
  const country = (addr.country_code ? String(addr.country_code).toUpperCase() : '') || addr.country || '';
  // 구 후보 필드 우선순위: city_district > borough > state_district > county > district
  const district = addr.city_district || addr.borough || addr.state_district || addr.county || addr.district || '';
  return { city, country, district };
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
    },
    source: 'fallback',
    cached: false,
  };
}


