import { getUserProfile } from './userService.js';
import { getCurrentWeather } from './weatherService.js';
import { TemperatureSettingsService } from './temperatureSettingsService.js';

// 개인화 점수 = (기상청 표준 체감온도 × 개인 감도 계수) + (습도 보정) + (바람 보정) + (상황 가중치)
// feelsLike는 이제 기상청 표준 공식으로 계산된 정확한 체감온도
function computePersonalizedFeel(feelsLike, humidity, windSpeed, sensitivityCoeff, situation) {
  const humidityAdj = humidity > 70 ? 2 : humidity < 30 ? -1 : 0;
  const windAdj = windSpeed > 3 ? -3 : 0;
  const situationAdj = situation === 'commute' ? 1 : situation === 'date' ? -1 : situation === 'workout' ? 3 : 0;
  return feelsLike * sensitivityCoeff + humidityAdj + windAdj + situationAdj;
}

function getSensitivityCoeff(profile) {
  const v = profile?.temperatureSensitivity;
  if (typeof v === 'number' && v >= 0.7 && v <= 1.3) return v;
  return 1.0;
}

function buildCandidatePools(personalFeel, weather = {}, situation = '') {
  // 온도 구간별 후보군 확장
  const pools = {
    top: [], bottom: [], outer: [], shoes: [], accessories: []
  };
  if (personalFeel <= 5) {
    pools.top = ['히트텍+니트', '터틀넥 니트', '후리스'];
    pools.bottom = ['기모 슬랙스', '기모 청바지'];
    pools.outer = ['롱패딩', '다운 파카'];
    pools.shoes = ['부츠', '방수부츠'];
    pools.accessories = ['목도리', '장갑', '니트 비니'];
  } else if (personalFeel <= 12) {
    pools.top = ['니트', '후드티', '가벼운 스웨터'];
    pools.bottom = ['슬랙스', '청바지'];
    pools.outer = ['코트', '패딩 베스트'];
    pools.shoes = ['부츠', '스니커즈'];
    pools.accessories = ['머플러', '비니'];
  } else if (personalFeel <= 18) {
    pools.top = ['맨투맨', '셔츠+티', '경량 니트'];
    pools.bottom = ['청바지', '치노 팬츠'];
    pools.outer = ['가벼운 자켓', '블루종'];
    pools.shoes = ['스니커즈', '로퍼'];
    pools.accessories = [];
  } else if (personalFeel <= 24) {
    pools.top = ['긴팔 티', '얇은 셔츠', '카디건+티'];
    pools.bottom = ['면바지', '린넨 팬츠'];
    pools.outer = ['카디건', '얇은 셔츠'];
    pools.shoes = ['스니커즈', '로퍼'];
    pools.accessories = ['캡모자'];
  } else if (personalFeel <= 28) {
    pools.top = ['반팔 티', '오버셔츠', '폴로 셔츠'];
    pools.bottom = ['면반바지', '린넨 반바지'];
    pools.outer = ['얇은 셔츠', '없음'];
    pools.shoes = ['샌들/스니커즈', '스니커즈'];
    pools.accessories = ['캡모자', '버킷햇'];
  } else {
    pools.top = ['민소매/얇은 반팔', '드라이 티'];
    pools.bottom = ['반바지'];
    pools.outer = ['없음'];
    pools.shoes = ['샌들'];
    pools.accessories = ['선캡', '썬글라스'];
  }

  // 상황 보정(후보 추가/우선순위 영향)
  const s = String(situation || '').toLowerCase();
  if (s === 'work' || s === 'business' || s === 'commute') {
    pools.top = ['셔츠', ...pools.top];
    pools.outer = ['코트', ...pools.outer];
    pools.shoes = ['로퍼', ...pools.shoes];
  } else if (s === 'date') {
    pools.outer = ['레더 자켓', ...pools.outer];
    pools.accessories = ['액세서리', ...pools.accessories];
  } else if (s === 'workout') {
    pools.top = ['드라이 티', ...pools.top];
    pools.bottom = ['트레이닝 팬츠', ...pools.bottom];
    pools.shoes = ['러닝화', ...pools.shoes];
    pools.outer = ['경량 아우터', ...pools.outer];
  }

  // 날씨 보정(비/강풍)
  const isRain = typeof weather?.precipitation === 'number' ? weather.precipitation > 0 : /rain/i.test(String(weather?.condition || ''));
  if (isRain) {
    pools.accessories = ['우산', ...pools.accessories];
    pools.shoes = ['방수화', ...pools.shoes];
  }
  if (typeof weather?.windSpeed === 'number' && weather.windSpeed > 6) {
    pools.outer = ['바람막이', ...pools.outer];
  }
  return pools;
}

function chooseLayers(personalFeel, weather = {}, situation = '') {
  const pools = buildCandidatePools(personalFeel, weather, situation);
  // 간단한 우선순위 선택(각 풀의 첫 요소)
  const top = pools.top[0] || '긴팔 티';
  const bottom = pools.bottom[0] || '면바지';
  const outer = pools.outer[0] || '없음';
  const shoes = pools.shoes[0] || '스니커즈';
  const accessories = clampAccessories(pools.accessories);
  return { top, bottom, outer, shoes, accessories };
}

// 날씨 조건(비/바람/습도/일교차) 보정
function toArray(value) {
  if (Array.isArray(value)) return value;
  if (value === undefined || value === null || value === '') return [];
  return [value];
}

function applyWeatherAdjustments(outfit, weather) {
  const adjusted = { ...outfit, accessories: [...toArray(outfit.accessories)] };

  const isRain = typeof weather?.precipitation === 'number' ? weather.precipitation > 0 : /rain/i.test(String(weather?.condition || ''));
  if (isRain) {
    if (!adjusted.accessories.includes('우산')) adjusted.accessories.push('우산');
    // 신발 보정: 스니커즈면 방수화로 대체
    if (adjusted.shoes === '스니커즈') adjusted.shoes = '방수화';
  }

  // 강풍 보정: 풍속 > 6 m/s 라면 아우터 보수적 선택
  if (typeof weather?.windSpeed === 'number' && weather.windSpeed > 6) {
    if (adjusted.outer === '없음' || adjusted.outer === '얇은 셔츠') adjusted.outer = '바람막이';
  }

  // 고습도 보정: 습도 > 80이면 액세서리 최소화(덜 끼는 방향)
  if (typeof weather?.humidity === 'number' && weather.humidity > 80) {
    adjusted.accessories = adjusted.accessories.filter(a => a !== '머플러');
  }

  return adjusted;
}

// 상황(occasion) 보정: 출근/데이트/운동 등
function applySituationAdjustments(outfit, situation) {
  const adjusted = { ...outfit, accessories: [...toArray(outfit.accessories)] };
  const s = String(situation || '').toLowerCase();
  if (s === 'work' || s === 'business' || s === 'commute') {
    // 포멀화: 아우터/신발 보수적 표현
    if (adjusted.outer === '가벼운 자켓') adjusted.outer = '코트';
    if (adjusted.shoes === '샌들' || adjusted.shoes === '샌들/스니커즈') adjusted.shoes = '스니커즈';
  } else if (s === 'date') {
    if (!adjusted.accessories.includes('액세서리')) adjusted.accessories.push('액세서리');
  } else if (s === 'workout') {
    // 운동은 경량화
    if (adjusted.outer && adjusted.outer !== '없음') adjusted.outer = '경량 아우터';
    adjusted.shoes = '러닝화';
  }
  return adjusted;
}

// 변이(variation) 생성 유틸
function clampAccessories(acc) {
  const set = new Set(toArray(acc));
  // 최대 3개까지 제한
  return Array.from(set).slice(0, 3);
}

function withOuter(outfit, outer) {
  return { ...outfit, outer, accessories: clampAccessories(outfit.accessories) };
}

function withShoes(outfit, shoes) {
  return { ...outfit, shoes, accessories: clampAccessories(outfit.accessories) };
}

function withAccessories(outfit, addList = []) {
  const merged = clampAccessories([...(toArray(outfit.accessories)), ...addList]);
  return { ...outfit, accessories: merged };
}

function withTop(outfit, top) { return { ...outfit, top, accessories: clampAccessories(outfit.accessories) }; }
function withBottom(outfit, bottom) { return { ...outfit, bottom, accessories: clampAccessories(outfit.accessories) }; }

function generateAlternatives(main) {
  // 6~8개 변이 생성 (중복 제거)
  const base = { ...main, accessories: clampAccessories(main.accessories) };
  const candidates = [
    withOuter(base, base.outer === '없음' ? '얇은 셔츠' : '없음'),
    withAccessories(base, ['우산']),
    withShoes(base, base.shoes === '스니커즈' ? '로퍼' : '스니커즈'),
    withTop(base, base.top === '긴팔 티' ? '맨투맨' : '긴팔 티'),
    withBottom(base, base.bottom === '면바지' ? '청바지' : '면바지'),
    withAccessories(base, ['모자']),
    withOuter(base, base.outer === '카디건' ? '가벼운 자켓' : '카디건'),
    withShoes(base, '부츠')
  ];

  // 중복 제거 키(top|bottom|outer|shoes|acc_sorted)
  const seen = new Set();
  const unique = [];
  for (const c of candidates) {
    const accKey = clampAccessories(c.accessories).sort().join(',');
    const key = `${c.top}|${c.bottom}|${c.outer}|${c.shoes}|${accKey}`;
    if (!seen.has(key)) {
      seen.add(key);
      unique.push(c);
    }
  }
  // 최대 8개까지 반환
  return unique.slice(0, 8);
}

// 코멘트 템플릿 생성
function buildReason(weather, situation) {
  const parts = [];
  const temp = Number(weather?.feelsLike ?? weather?.temperature ?? 0);
  if (temp < 10) parts.push('쌀쌀한 기온에 대비한 보온 레이어링');
  else if (temp > 25) parts.push('따뜻한 날씨에 맞춘 통기성 좋은 조합');
  else parts.push('간절기에도 무난한 범용 코디');
  if (/rain/i.test(String(weather?.condition)) || Number(weather?.precipitation) > 0) parts.push('비 소식에 대비');
  const s = String(situation || '').toLowerCase();
  if (s === 'work' || s === 'business' || s === 'commute') parts.push('단정한 인상 유지');
  if (s === 'date') parts.push('과하지 않은 포인트로 깔끔한 인상');
  if (s === 'workout') parts.push('활동성 중심의 경량 구성');
  return parts.join(' · ');
}

function buildTips(weather, situation) {
  const tips = [];
  const temp = Number(weather?.feelsLike ?? weather?.temperature ?? 0);
  if (temp < 12) tips.push('실내외 온도 차를 고려해 얇은 아우터를 챙기세요');
  if (temp > 26) tips.push('통기성 좋은 소재(코튼/린넨)를 권장합니다');
  if (/rain/i.test(String(weather?.condition)) || Number(weather?.precipitation) > 0) tips.push('우산이나 방수 아이템을 준비하세요');
  const s = String(situation || '').toLowerCase();
  if (s === 'date') tips.push('액세서리는 1~2개로 과하지 않게 포인트를 주세요');
  if (s === 'work') tips.push('무채색 위주의 조합이 안정적입니다');
  if (s === 'workout') tips.push('러닝화/흡습 소재 상의를 추천합니다');
  return tips.slice(0, 4);
}

export async function getRecommendation({ userId, lat, lon, situation }) {
  let profile = getUserProfile(userId);
  // 비로그인/프로필 없음: 게스트 기본 프로필로 폴백
  if (!profile) {
    profile = { temperatureSensitivity: 1.0 };
  }
  // weather 서비스는 userId가 있을 때 개인화 체감온도를 이미 반영
  const weather = await getCurrentWeather(lat, lon, { userId });

  // 사용자 온도설정 조회 (있다면 weather의 개인화와 중복되지 않게 감도계수는 1.0으로 고정)
  let sensitivity = getSensitivityCoeff(profile);
  try {
    const settings = await TemperatureSettingsService.getSettings(userId);
    if (settings && typeof settings.temperatureSensitivity === 'number') {
      sensitivity = 1.0;
    }
  } catch (_) {
    // 설정 조회 실패는 무시하고 프로필 기반 계수 사용
  }
  const personalFeel = computePersonalizedFeel(
    weather.feelsLike,
    weather.humidity,
    weather.windSpeed,
    sensitivity,
    situation
  );

  let main = chooseLayers(personalFeel);
  // 추가 보정: 날씨/상황 반영 (기존 룰에 최소 변경)
  main = applyWeatherAdjustments(main, weather);
  const sanitizedSituation = typeof situation === 'string' ? situation : '';
  main = applySituationAdjustments(main, sanitizedSituation);
  const alternatives = generateAlternatives(main);

  return {
    userId,
    situation,
    weather,
    personalFeel,
    sensitivity,
    recommendedOutfit: main,
    alternatives
  };
}


