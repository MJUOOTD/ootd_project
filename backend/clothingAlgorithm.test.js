const { recommendClothing } = require("./clothingAlgorithm");

describe("Clothing Recommendation Algorithm - Weather Scenarios", () => {
  test("한여름 (매우 더움)", () => {
    const result = recommendClothing({
      temperature: 32,
      humidity: 40,
      precipitation: 10,
      feelsLike: 33,
      userOffset: 0,
    });
    expect(result).toBe("반팔 티셔츠 + 반바지");
  });

  test("초여름 / 가을 (적당히 따뜻함)", () => {
    const result = recommendClothing({
      temperature: 24,
      humidity: 50,
      precipitation: 20,
      feelsLike: 24,
      userOffset: 0,
    });
    expect(result).toBe("얇은 긴팔 + 청바지");
  });

  test("봄 / 초가을 (살짝 쌀쌀함)", () => {
    const result = recommendClothing({
      temperature: 14,
      humidity: 55,
      precipitation: 20,
      feelsLike: 14,
      userOffset: 0,
    });
    expect(result).toBe("가디건 + 후드티");
  });

  test("한겨울 (추움)", () => {
    const result = recommendClothing({
      temperature: 2,
      humidity: 40,
      precipitation: 0,
      feelsLike: 0,
      userOffset: 0,
    });
    expect(result).toBe("두꺼운 코트 + 목도리");
  });

  test("비 오는 날 (강수량 영향)", () => {
    const result = recommendClothing({
      temperature: 21,
      humidity: 70,
      precipitation: 90,
      feelsLike: 21,
      userOffset: 0,
    });
    expect(result).toBe("우산 + 방수 점퍼");
  });

  test("개인차 반영 (사용자가 추위를 많이 탐)", () => {
    const result = recommendClothing({
      temperature: 22,
      humidity: 50,
      precipitation: 0,
      feelsLike: 22,
      userOffset: -5,
    });
    expect(result).toBe("가디건 + 후드티");
  });

  test("개인차 반영 (사용자가 더위를 많이 탐)", () => {
    const result = recommendClothing({
      temperature: 18,
      humidity: 50,
      precipitation: 0,
      feelsLike: 18,
      userOffset: +5,
    });
    expect(result).toBe("얇은 긴팔 + 청바지");
  });
});
