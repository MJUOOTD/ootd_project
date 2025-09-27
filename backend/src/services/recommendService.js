import { getUserProfile } from './userService.js';
import { getCurrentWeather } from './weatherService.js';

// 개인화 점수 = (기본 체감온도 × 개인 감도 계수) + (습도 보정) + (바람 보정) + (상황 가중치)
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

function chooseLayers(personalFeel) {
  // 매우 단순한 스텁 룰셋 (추후 ML/룰 고도화)
  if (personalFeel <= 5) return { top: '히트텍+니트', bottom: '기모 슬랙스', outer: '롱패딩', shoes: '부츠', accessories: ['목도리','장갑'] };
  if (personalFeel <= 12) return { top: '니트', bottom: '슬랙스', outer: '코트', shoes: '부츠', accessories: ['머플러'] };
  if (personalFeel <= 18) return { top: '맨투맨', bottom: '청바지', outer: '가벼운 자켓', shoes: '스니커즈', accessories: [] };
  if (personalFeel <= 24) return { top: '긴팔 티', bottom: '면바지', outer: '카디건', shoes: '스니커즈', accessories: [] };
  if (personalFeel <= 28) return { top: '반팔 티', bottom: '면반바지', outer: '얇은 셔츠', shoes: '샌들/스니커즈', accessories: ['캡모자'] };
  return { top: '민소매/얇은 반팔', bottom: '반바지', outer: '없음', shoes: '샌들', accessories: ['선캡'] };
}

function generateAlternatives(main) {
  // 간단한 변형으로 3개 대안 생성
  const alt1 = { ...main, outer: main.outer === '없음' ? '얇은 셔츠' : '없음' };
  const alt2 = { ...main, accessories: [...(main.accessories||[]), '우산'].slice(0,3) };
  const alt3 = { ...main, shoes: main.shoes === '스니커즈' ? '로퍼' : '스니커즈' };
  return [alt1, alt2, alt3];
}

export async function getRecommendation({ userId, lat, lon, situation }) {
  const profile = getUserProfile(userId);
  if (!profile) throw new Error('User profile not found');
  const weather = await getCurrentWeather(lat, lon);

  const sensitivity = getSensitivityCoeff(profile);
  const personalFeel = computePersonalizedFeel(
    weather.feelsLike,
    weather.humidity,
    weather.windSpeed,
    sensitivity,
    situation
  );

  const main = chooseLayers(personalFeel);
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


