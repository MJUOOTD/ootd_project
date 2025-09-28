import express from 'express';
import fetch from 'node-fetch';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// OpenWeatherMap API 설정
const OPENWEATHER_API_KEY = process.env.OPENWEATHER_API_KEY;
const OPENWEATHER_BASE_URL = 'https://api.openweathermap.org/data/2.5';

// 한국 시간 가져오기 함수
function getKoreaTime() {
  const now = new Date();
  const utcTime = now.getTime() + (now.getTimezoneOffset() * 60000);
  const koreaTime = new Date(utcTime + (9 * 3600000)); // UTC+9
  return koreaTime;
}

// 현재 날씨 정보 가져오기
async function getCurrentWeather(lat, lon) {
  try {
    const url = `${OPENWEATHER_BASE_URL}/weather?lat=${lat}&lon=${lon}&appid=${OPENWEATHER_API_KEY}&units=metric&lang=kr`;
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`OpenWeatherMap API error: ${response.status}`);
    }
    
    const data = await response.json();
    
    return {
      temp: Math.round(data.main.temp),
      feels_like: Math.round(data.main.feels_like),
      condition: data.weather[0].main,
      humidity: data.main.humidity,
      wind_speed: data.wind.speed
    };
  } catch (error) {
    console.error('Error fetching current weather:', error);
    throw new Error('Failed to fetch current weather data');
  }
}

// 시간별 예보 가져오기
async function getHourlyForecast(lat, lon) {
  try {
    const url = `${OPENWEATHER_BASE_URL}/forecast?lat=${lat}&lon=${lon}&appid=${OPENWEATHER_API_KEY}&units=metric&lang=kr`;
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`OpenWeatherMap API error: ${response.status}`);
    }
    
    const data = await response.json();
    const koreaTime = getKoreaTime();
    const currentHour = koreaTime.getHours();
    
    // 현재 시간부터 3시간 이후까지의 예보 필터링
    const forecast = data.list
      .filter(item => {
        const itemTime = new Date(item.dt * 1000);
        const itemHour = itemTime.getHours();
        return itemHour >= currentHour;
      })
      .slice(0, 3) // 최소 3시간 예보
      .map(item => {
        const itemTime = new Date(item.dt * 1000);
        const timeString = itemTime.getHours().toString().padStart(2, '0') + ':00';
        
        return {
          time: timeString,
          temp: Math.round(item.main.temp),
          condition: item.weather[0].main,
          precipitation_prob: Math.round(item.pop * 100) // 강수 확률을 퍼센트로 변환
        };
      });
    
    return forecast;
  } catch (error) {
    console.error('Error fetching hourly forecast:', error);
    throw new Error('Failed to fetch forecast data');
  }
}

// 메인 API 엔드포인트
app.get('/weather', async (req, res) => {
  try {
    const { lat, lon } = req.query;
    
    // 입력 검증
    if (!lat || !lon) {
      return res.status(400).json({
        error: 'Missing required parameters',
        message: 'latitude (lat) and longitude (lon) are required'
      });
    }
    
    const latitude = parseFloat(lat);
    const longitude = parseFloat(lon);
    
    if (isNaN(latitude) || isNaN(longitude)) {
      return res.status(400).json({
        error: 'Invalid parameters',
        message: 'latitude and longitude must be valid numbers'
      });
    }
    
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      return res.status(400).json({
        error: 'Invalid coordinates',
        message: 'latitude must be between -90 and 90, longitude must be between -180 and 180'
      });
    }
    
    // API 키 검증
    if (!OPENWEATHER_API_KEY) {
      return res.status(500).json({
        error: 'Server configuration error',
        message: 'OpenWeatherMap API key is not configured'
      });
    }
    
    // 현재 날씨와 예보 데이터를 병렬로 가져오기
    const [current, forecast] = await Promise.all([
      getCurrentWeather(latitude, longitude),
      getHourlyForecast(latitude, longitude)
    ]);
    
    // 응답 데이터 구조화
    const response = {
      current,
      forecast
    };
    
    res.json(response);
    
  } catch (error) {
    console.error('Weather API error:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: error.message || 'Failed to fetch weather data'
    });
  }
});

// 서버 시작
app.listen(PORT, () => {
  console.log(`Weather API server running on port ${PORT}`);
  console.log(`API endpoint: http://localhost:${PORT}/weather`);
  console.log(`Example: http://localhost:${PORT}/weather?lat=37.27&lon=127.45`);
});

export default app;
