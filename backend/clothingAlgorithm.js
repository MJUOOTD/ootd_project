// clothingAlgorithm.js

function recommendClothing({ temperature, humidity, precipitation, feelsLike, userOffset }) {
  let adjustedTemp = feelsLike + userOffset;

  if (precipitation > 60) {
    return "우산 + 방수 점퍼";
  }

  if (adjustedTemp >= 28) {
    return "반팔 티셔츠 + 반바지";
  } else if (adjustedTemp >= 20) {
    return "얇은 긴팔 + 청바지";
  } else if (adjustedTemp >= 10) {
    return "가디건 + 후드티";
  } else {
    return "두꺼운 코트 + 목도리";
  }
}

module.exports = { recommendClothing };
