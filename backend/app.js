// backend/app.js
const express = require("express");
const axios = require("axios");
const app = express();
app.use(express.json());

// 기상청 API 키 (공공데이터포털에서 발급받은 값으로 교체하세요)
const SERVICE_KEY = "YOUR_API_KEY";

// 옷차림 추천 함수 (앞에서 작성한 것 그대로 사용)
function recommendOutfit(weather, user) {
  const adjustedTemp = weather.feels_like + user.temp_bias;
  let outfit = [];

  if (adjustedTemp >= 30) outfit.push("반팔", "반바지", "린넨 소재");
  else if (adjustedTemp >= 25) outfit.push("반팔", "얇은 셔츠", "반바지");
  else if (adjustedTemp >= 20) outfit.push("긴팔 티셔츠", "가디건", "얇은 바람막이");
  else if (adjustedTemp >= 15) outfit.push("니트", "얇은 자켓", "가디건");
  else if (adjustedTemp >= 10) outfit.push("자켓", "트렌치코트", "맨투맨");
  else if (adjustedTemp >= 5) outfit.push("코트", "가죽자켓", "두꺼운 니트");
  else if (adjustedTemp >= 0) outfit.push("두꺼운 코트", "패딩", "목도리");
  else outfit.push("두꺼운 패딩", "장갑", "목도리", "모자");

  if (weather.precipitation > 0 || weather.rain_probability > 50) {
    outfit.push("우산", "방수 신발/자켓");
  }
  if (weather.humidity >= 80 && adjustedTemp >= 20) {
    outfit.push("통풍 좋은 소재");
  }
  if (weather.wind_speed >= 7) {
    outfit.push("바람막이");
  }
  if (weather.status === "snow") {
    outfit.push("부츠", "장갑");
  }

  return outfit;
}

// 기상청 API 호출 → 날씨 데이터 변환
async function fetchWeather(lat, lon) {
  const baseDate = new Date();
  const yyyy = baseDate.getFullYear();
  const mm = String(baseDate.getMonth() + 1).padStart(2, "0");
  const dd = String(baseDate.getDate()).padStart(2, "0");
  const dateStr = `${yyyy}${mm}${dd}`;

  // API 요청 (단기예보 - 실제로는 nx, ny 격자 좌표 필요)
  const url = `http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst`;
  const params = {
    serviceKey: SERVICE_KEY,
    numOfRows: 100,
    pageNo: 1,
    dataType: "JSON",
    base_date: dateStr,
    base_time: "0600", // 최근 발표 시각으로 수정 필요
    nx: 60, // 서울 종로구 예시 (격자 좌표)
    ny: 127,
  };

  const response = await axios.get(url, { params });
  const items = response.data.response.body.items.item;

  // 필요한 값만 추출
  let weather = {
    temperature: null,
    feels_like: null, // 기상청은 직접 제공 안 하므로 temperature+풍속으로 계산 가능
    humidity: null,
    precipitation: null,
    rain_probability: 0,
    wind_speed: null,
    status: "clear",
  };

  items.forEach((i) => {
    if (i.category === "T1H") weather.temperature = Number(i.obsrValue); // 기온
    if (i.category === "REH") weather.humidity = Number(i.obsrValue); // 습도
    if (i.category === "RN1") weather.precipitation = Number(i.obsrValue); // 강수량
    if (i.category === "WSD") weather.wind_speed = Number(i.obsrValue); // 풍속
  });

  // 단순히 체감온도 = 온도 - 풍속/2 (간단화)
  weather.feels_like = weather.temperature - weather.wind_speed / 2;

  return weather;
}

// API 엔드포인트
app.post("/recommend", async (req, res) => {
  const { lat, lon, user } = req.body;

  try {
    const weather = await fetchWeather(lat, lon);
    const result = recommendOutfit(weather, user);
    res.json({ weather, recommended_outfit: result });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "기상청 API 호출 실패" });
  }
});

app.listen(3000, () => console.log("Server running on port 3000"));
