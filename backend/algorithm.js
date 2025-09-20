// backend/app.js
const express = require("express");
const app = express();
app.use(express.json());

// 옷차림 추천 함수
function recommendOutfit(weather, user) {
  const adjustedTemp = weather.feels_like + user.temp_bias;
  let outfit = [];

  // 기본 룰
  if (adjustedTemp >= 30) outfit.push("반팔", "반바지", "린넨 소재");
  else if (adjustedTemp >= 25) outfit.push("반팔", "얇은 셔츠", "반바지");
  else if (adjustedTemp >= 20) outfit.push("긴팔 티셔츠", "가디건", "얇은 바람막이");
  else if (adjustedTemp >= 15) outfit.push("니트", "얇은 자켓", "가디건");
  else if (adjustedTemp >= 10) outfit.push("자켓", "트렌치코트", "맨투맨");
  else if (adjustedTemp >= 5) outfit.push("코트", "가죽자켓", "두꺼운 니트");
  else if (adjustedTemp >= 0) outfit.push("두꺼운 코트", "패딩", "목도리");
  else outfit.push("두꺼운 패딩", "장갑", "목도리", "모자");

  // 보조 조건
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

// API 엔드포인트
app.post("/recommend", (req, res) => {
  const { weather, user } = req.body;
  const result = recommendOutfit(weather, user);
  res.json({ recommended_outfit: result });
});

app.listen(3000, () => console.log("Server running on port 3000"));
