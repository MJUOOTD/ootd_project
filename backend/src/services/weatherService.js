import 'dotenv/config';
import fetch from 'node-fetch';
import { getAddressFromCoordinates } from './kakaoService.js';

// ==================== 설정 및 상수 ====================
const CACHE_TTL_MS = 1 * 60 * 1000; // 1분 캐시
const API_TIMEOUT_MS = 10000; // 10초 타임아웃
const OPENWEATHER_BASE_URL = 'https://api.openweathermap.org/data/2.5';

// 메모리 캐시 (Map 기반)
const cache = new Map();

// ==================== 유틸리티 함수 ====================
function getCityNameFromAPI(data) {
  if (data.name) {
    const cityName = data.name;
    const cityMap = {
      'Seoul': '서울', 'Busan': '부산', 'Daegu': '대구', 'Incheon': '인천', 'Gwangju': '광주', 'Daejeon': '대전', 'Ulsan': '울산', 'Sejong': '세종',
      'Suwon': '수원', 'Seongnam': '성남', 'Goyang': '고양', 'Yongin': '용인', 'Bucheon': '부천', 'Chuncheon': '춘천', 'Wonju': '원주',
      'Cheonan': '천안', 'Cheongju': '청주', 'Jeonju': '전주', 'Yeosu': '여수', 'Changwon': '창원', 'Jinju': '진주', 'Pohang': '포항',
      'Gyeongju': '경주', 'Jeju': '제주', 'Seogwipo': '서귀포', 'Icheon-si': '이천', 'Icheon': '이천', 'Anyang': '안양', 'Namyangju': '남양주',
      'Hwaseong': '화성', 'Pyeongtaek': '평택', 'Osan': '오산', 'Siheung': '시흥', 'Gunpo': '군포', 'Uijeongbu': '의정부', 'Hanam': '하남',
      'Gimpo': '김포', 'Yangju': '양주', 'Gwangmyeong': '광명', 'Dongducheon': '동두천', 'Guri': '구리', 'Anseong': '안성', 'Paju': '파주',
      'Yeoju': '여주', 'Yangpyeong': '양평', 'Gapyeong': '가평', 'Yeoncheon': '연천'
    };
    if (cityMap[cityName]) return cityMap[cityName];
    for (const [key, value] of Object.entries(cityMap)) {
      if (cityName.includes(key)) return value;
    }
    if (/[가-힣]/.test(cityName)) return cityName;
    return cityName;
  }
  return '현재 위치';
}

function getDistrictFromAPI(data) {
  if (data.sys && data.sys.country) {
    const countryMap = { 'KR': '대한민국' };
    return countryMap[data.sys.country] || data.sys.country;
  }
  return '대한민국';
}

function getAccurateKoreanAddress(lat, lon, cityName) {
  // 좌표 기반 간이 주소 매핑 (부정확 시 Kakao 결과 사용)
  return { city: cityName, district: null, subLocality: null, province: null };
}

function getWeatherIcon(hour, condition, sunrise = 6, sunset = 18) {
  const isDaytime = hour >= sunrise && hour < sunset;
  const iconSuffix = isDaytime ? 'd' : 'n';
  switch (condition) {
    case 'Clear': return `01${iconSuffix}`;
    case 'Clouds': return `02${iconSuffix}`;
    case 'Rain': return `10${iconSuffix}`;
    case 'Snow': return `13${iconSuffix}`;
    case 'Thunderstorm': return `11${iconSuffix}`;
    case 'Drizzle': return `09${iconSuffix}`;
    case 'Mist':
    case 'Fog': return `50${iconSuffix}`;
    default: return `02${iconSuffix}`;
  }
}

// ==================== API 호출 함수 ====================
async function fetchWithTimeout(url) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), API_TIMEOUT_MS);
  try {
    const response = await fetch(url, { signal: controller.signal, headers: { 'User-Agent': 'OOTD-App/1.0' } });
    clearTimeout(timeoutId);
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(`OpenWeatherMap API error: ${response.status} - ${errorData.message || 'Unknown error'}`);
    }
    return await response.json();
  } catch (error) {
    clearTimeout(timeoutId);
    if (error.name === 'AbortError') throw new Error('API request timeout');
    throw error;
  }
}

async function fetchCurrentWeather(lat, lon) {
  const apiKey = process.env.OPENWEATHER_API_KEY;
  if (!apiKey) throw new Error('OPENWEATHER_API_KEY is not configured');
  const url = `${OPENWEATHER_BASE_URL}/weather?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric&lang=kr`;
  return await fetchWithTimeout(url);
}

async function fetchWeatherForecast(lat, lon) {
  const apiKey = process.env.OPENWEATHER_API_KEY;
  if (!apiKey) throw new Error('OPENWEATHER_API_KEY is not configured');
  const url = `${OPENWEATHER_BASE_URL}/forecast?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric&lang=kr`;
  return await fetchWithTimeout(url);
}

// ==================== 데이터 변환 ====================
async function transformWeatherData(data, lat, lon) {
  const now = new Date();
  const koreaTime = new Date(now.getTime() + (9 * 60 * 60 * 1000));
  const currentHour = koreaTime.getHours();

  let locationInfo = { city: 'Unknown', country: '대한민국', district: null, subLocality: null, province: null };
  try {
    const kakaoResult = await getAddressFromCoordinates(lat, lon);
    if (kakaoResult) {
      locationInfo = {
        city: kakaoResult.placeName || 'Unknown',
        country: '대한민국',
        district: kakaoResult.districtName || null,
        subLocality: null,
        province: kakaoResult.placeName || null
      };
    } else {
      const cityName = getCityNameFromAPI(data);
      const country = getDistrictFromAPI(data);
      const addressInfo = getAccurateKoreanAddress(lat, lon, cityName);
      locationInfo = { city: addressInfo.city, country, district: addressInfo.district, subLocality: addressInfo.subLocality, province: addressInfo.province };
    }
  } catch (error) {
    const cityName = getCityNameFromAPI(data);
    const country = getDistrictFromAPI(data);
    const addressInfo = getAccurateKoreanAddress(lat, lon, cityName);
    locationInfo = { city: addressInfo.city, country, district: addressInfo.district, subLocality: addressInfo.subLocality, province: addressInfo.province };
  }

  const sunrise = new Date(data.sys.sunrise * 1000);
  const sunset = new Date(data.sys.sunset * 1000);
  const sunriseHour = sunrise.getHours();
  const sunsetHour = sunset.getHours();

  return {
    timestamp: now.toISOString(),
    temperature: Math.round(data.main.temp),
    feelsLike: Math.round(data.main.feels_like),
    humidity: data.main.humidity,
    windSpeed: data.wind.speed,
    windDirection: data.wind.deg || 0,
    precipitation: data.rain?.['1h'] || data.snow?.['1h'] || 0,
    condition: data.weather[0].main,
    description: data.weather[0].description,
    icon: getWeatherIcon(currentHour, data.weather[0].main, sunriseHour, sunsetHour),
    location: { latitude: lat, longitude: lon, ...locationInfo },
    source: 'openweathermap',
    cached: false,
    isCurrent: true
  };
}

async function transformForecastData(data, lat, lon) {
  const now = new Date();
  const koreaTime = new Date(now.getTime() + (9 * 60 * 60 * 1000));
  const currentHour = koreaTime.getUTCHours();
  const currentMinute = koreaTime.getUTCMinutes();

  let locationInfo = { city: 'Unknown', country: '대한민국', district: null, subLocality: null, province: null };
  try {
    const kakaoResult = await getAddressFromCoordinates(lat, lon);
    if (kakaoResult) {
      locationInfo = { city: kakaoResult.placeName || 'Unknown', country: '대한민국', district: kakaoResult.districtName || null, subLocality: null, province: '경기도' };
    } else {
      const firstItem = data.list[0];
      const cityName = getCityNameFromAPI(firstItem);
      const country = getDistrictFromAPI(firstItem);
      const addressInfo = getAccurateKoreanAddress(lat, lon, cityName);
      locationInfo = { city: addressInfo.city, country, district: addressInfo.district, subLocality: addressInfo.subLocality, province: addressInfo.province };
    }
  } catch (error) {
    const firstItem = data.list[0];
    const cityName = getCityNameFromAPI(firstItem);
    const country = getDistrictFromAPI(firstItem);
    const addressInfo = getAccurateKoreanAddress(lat, lon, cityName);
    locationInfo = { city: addressInfo.city, country, district: addressInfo.district, subLocality: addressInfo.subLocality, province: addressInfo.province };
  }

  const sunriseHour = 6;
  const sunsetHour = 18;

  const allForecasts = data.list
    .map(item => {
      const itemTime = new Date(item.dt * 1000);
      const itemKoreaTime = new Date(itemTime.getTime() + (9 * 60 * 60 * 1000));
      const itemHour = itemKoreaTime.getUTCHours();
      const itemMinute = itemKoreaTime.getUTCMinutes();
      const currentTimeInMinutes = currentHour * 60 + currentMinute;
      const itemTimeInMinutes = itemHour * 60 + itemMinute;
      const timeDiff = itemTimeInMinutes - currentTimeInMinutes;
      return { ...item, koreaTime: itemKoreaTime, hour: itemHour, minute: itemMinute, timeDiff, isCurrent: false };
    })
    .sort((a, b) => a.koreaTime - b.koreaTime);

  let closestIndex = 0;
  let minTimeDiff = Math.abs(allForecasts[0].timeDiff);
  for (let i = 1; i < allForecasts.length; i++) {
    const timeDiff = Math.abs(allForecasts[i].timeDiff);
    if (timeDiff < minTimeDiff) { minTimeDiff = timeDiff; closestIndex = i; }
  }
  if (minTimeDiff <= 90) allForecasts[closestIndex].isCurrent = true;

  const maxForecasts = Math.min(40, allForecasts.length);
  const filteredAndSorted = allForecasts.slice(0, maxForecasts);

  return filteredAndSorted.map(item => {
    const itemTime = new Date(item.dt * 1000);
    const itemKoreaTime = new Date(itemTime.getTime() + (9 * 60 * 60 * 1000));
    const itemHour = itemKoreaTime.getUTCHours();
    return {
      temperature: Math.round(item.main.temp),
      feelsLike: Math.round(item.main.feels_like),
      humidity: item.main.humidity,
      windSpeed: item.wind.speed,
      windDirection: item.wind.deg || 0,
      precipitation: item.rain?.['3h'] || item.snow?.['3h'] || 0,
      condition: item.weather[0].main,
      description: item.weather[0].description,
      icon: getWeatherIcon(itemHour, item.weather[0].main, sunriseHour, sunsetHour),
      timestamp: itemKoreaTime.toISOString(),
      isCurrent: item.isCurrent,
      location: { latitude: lat, longitude: lon, ...locationInfo }
    };
  });
}

// ==================== 캐시 ====================
function getCachedData(key, isArray = false) {
  const cached = cache.get(key);
  if (cached && Date.now() - cached.timestamp < CACHE_TTL_MS) {
    if (isArray) return cached.data;
    return { ...cached.data, cached: true };
  }
  return null;
}

function setCachedData(key, data) {
  cache.set(key, { data, timestamp: Date.now() });
}

// ==================== 공개 API ====================
export async function getCurrentWeather(lat, lon, options = {}) {
  if (typeof lat !== 'number' || typeof lon !== 'number') {
    throw new Error('lat and lon must be numbers');
  }
  if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
    throw new Error('Invalid coordinates: lat must be -90 to 90, lon must be -180 to 180');
  }
  const cacheKey = `current_${lat}_${lon}`;
  if (!options.force) {
    const cached = getCachedData(cacheKey);
    if (cached) return cached;
  }
  const data = await fetchCurrentWeather(lat, lon);
  const transformed = await transformWeatherData(data, lat, lon);
  setCachedData(cacheKey, transformed);
  return transformed;
}

export async function getWeatherForecast(lat, lon) {
  if (typeof lat !== 'number' || typeof lon !== 'number') {
    throw new Error('lat and lon must be numbers');
  }
  if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
    throw new Error('Invalid coordinates: lat must be -90 to 90, lon must be -180 to 180');
  }
  const cacheKey = `forecast_${lat}_${lon}`;
  const cached = getCachedData(cacheKey, true);
  if (cached) return cached;
  const data = await fetchWeatherForecast(lat, lon);
  const transformed = await transformForecastData(data, lat, lon);
  setCachedData(cacheKey, transformed);
  return transformed;
}

export function clearCache() {
  cache.clear();
}

export function getCacheStats() {
  return { size: cache.size, maxAge: CACHE_TTL_MS, entries: Array.from(cache.keys()) };
}