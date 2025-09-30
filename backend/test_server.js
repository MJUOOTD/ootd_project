import express from 'express';
import cors from 'cors';

const app = express();
const PORT = 4000;

app.use(cors());
app.use(express.json());

// 간단한 테스트 엔드포인트
app.get('/api/test', (req, res) => {
  res.json({ message: 'Server is working!', timestamp: new Date().toISOString() });
});

// 현재 날씨 API (간단한 mock 데이터)
app.get('/api/weather/current', (req, res) => {
  const { lat, lon } = req.query;
  
  const mockWeather = {
    temperature: 18.5,
    feelsLike: 17.2,
    humidity: 75,
    windSpeed: 2.1,
    windDirection: 180,
    precipitation: 0,
    condition: 'Clouds',
    description: '구름많음',
    icon: '04d',
    timestamp: new Date().toISOString(),
    location: {
      latitude: parseFloat(lat) || 37.5665,
      longitude: parseFloat(lon) || 126.9780,
      city: '서울특별시',
      country: '대한민국',
      district: '중구',
      subLocality: '명동'
    },
    source: 'mock',
    cached: false
  };
  
  res.json(mockWeather);
});

// 시간별 예보 API (간단한 mock 데이터)
app.get('/api/weather/forecast', (req, res) => {
  const { lat, lon } = req.query;
  const now = new Date();
  const currentHour = now.getHours();
  
  const forecast = [];
  
  // 24시간 예보 생성
  for (let i = 0; i < 8; i++) {
    const forecastTime = new Date(now.getTime() + (i * 3 * 60 * 60 * 1000));
    const forecastHour = forecastTime.getHours();
    
    forecast.push({
      temperature: 15 + Math.random() * 10,
      feelsLike: 14 + Math.random() * 10,
      humidity: 60 + Math.random() * 30,
      windSpeed: 1 + Math.random() * 5,
      windDirection: Math.floor(Math.random() * 360),
      precipitation: Math.random() * 2,
      condition: 'Clouds',
      description: '구름많음',
      icon: '04d',
      timestamp: forecastTime.toISOString(),
      isCurrent: forecastHour === currentHour, // 현재 시간과 일치하는 예보만 true
      location: {
        latitude: parseFloat(lat) || 37.5665,
        longitude: parseFloat(lon) || 126.9780,
        city: '서울특별시',
        country: '대한민국',
        district: '중구',
        subLocality: '명동'
      }
    });
  }
  
  res.json(forecast);
});

app.listen(PORT, () => {
  console.log(`Test server running on port ${PORT}`);
});
