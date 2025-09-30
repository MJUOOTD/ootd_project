import express from 'express';
import cors from 'cors';

const app = express();
const PORT = 4000;

// CORS 설정 추가
app.use(cors({
  origin: ['http://localhost:8080', 'http://127.0.0.1:8080', 'http://localhost:3000', 'http://127.0.0.1:3000'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

app.get('/api/weather/current', (req, res) => {
  const { lat, lon } = req.query;
  console.log('===== BACKEND API REQUEST =====');
  console.log(`Weather request: lat=${lat}, lon=${lon}`);
  console.log(`Request headers:`, req.headers);
  console.log(`Request method: ${req.method}`);
  console.log(`Request URL: ${req.url}`);
  
  // 간단한 테스트 응답
  const response = {
    timestamp: new Date().toISOString(),
    temperature: 22,
    feelsLike: 24,
    humidity: 65,
    windSpeed: 2.5,
    windDirection: 180,
    precipitation: 0,
    condition: 'Clear',
    description: 'clear sky',
    icon: '01d',
    location: {
      latitude: parseFloat(lat),
      longitude: parseFloat(lon),
      city: 'Seoul',
      country: 'South Korea',
      district: 'Jung-gu',
      subLocality: 'Myeong-dong'
    },
    source: 'test',
    cached: false,
    isCurrent: true
  };
  
  console.log('===== BACKEND API RESPONSE =====');
  console.log('Response data:', JSON.stringify(response, null, 2));
  console.log('Sending response...');
  
  res.json(response);
});

// 예보 API 엔드포인트 추가
app.get('/api/weather/forecast', (req, res) => {
  const { lat, lon } = req.query;
  console.log('===== FORECAST API REQUEST =====');
  console.log(`Forecast request: lat=${lat}, lon=${lon}`);
  
  // 간단한 예보 데이터 생성 (8시간)
  const forecast = [];
  const now = new Date();
  
  for (let i = 0; i < 8; i++) {
    const forecastTime = new Date(now.getTime() + (i * 3 * 60 * 60 * 1000)); // 3시간 간격
    const temperature = 22 + Math.sin(i * Math.PI / 4) * 5; // 온도 변화
    
    forecast.push({
      timestamp: forecastTime.toISOString(),
      temperature: Math.round(temperature),
      feelsLike: Math.round(temperature + 2),
      humidity: 60 + Math.random() * 20,
      windSpeed: 2.0 + Math.random() * 2,
      windDirection: Math.floor(Math.random() * 360),
      precipitation: Math.random() * 2,
      condition: i % 3 === 0 ? 'Clouds' : 'Clear',
      description: i % 3 === 0 ? 'partly cloudy' : 'clear sky',
      icon: i % 3 === 0 ? '02d' : '01d',
      location: {
        latitude: parseFloat(lat),
        longitude: parseFloat(lon),
        city: 'Seoul',
        country: 'South Korea',
        district: 'Jung-gu',
        subLocality: 'Myeong-dong'
      },
      source: 'test',
      cached: false,
      isCurrent: i === 0
    });
  }
  
  console.log('===== FORECAST API RESPONSE =====');
  console.log(`Sending ${forecast.length} forecast items...`);
  
  res.json(forecast);
});

app.listen(PORT, () => {
  console.log(`Test server running on port ${PORT}`);
});
