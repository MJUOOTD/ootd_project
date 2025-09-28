import { Router } from 'express';
import { getCurrentWeather, getWeatherForecast } from '../services/weatherService.js';

const router = Router();

/**
 * Weather API Routes
 * 
 * 주요 기능:
 * - 현재 날씨 정보 제공
 * - 시간별 예보 정보 제공
 * - 통합 날씨 정보 제공 (현재 + 예보)
 * - 입력 검증 및 에러 핸들링
 */

// ==================== 입력 검증 미들웨어 ====================

/**
 * 좌표 검증 미들웨어
 * @param {Object} req - Express request 객체
 * @param {Object} res - Express response 객체
 * @param {Function} next - Express next 함수
 */
const validateCoordinates = (req, res, next) => {
  const { lat, lon } = req.query;
  
  // 필수 파라미터 확인
  if (lat === undefined || lon === undefined) {
    return res.status(400).json({
      error: 'Missing required parameters',
      message: 'latitude (lat) and longitude (lon) are required',
      example: '/api/weather/current?lat=37.5665&lon=126.9780'
    });
  }
  
  // 숫자 변환 및 검증
  const latitude = Number(lat);
  const longitude = Number(lon);
  
  if (Number.isNaN(latitude) || Number.isNaN(longitude)) {
    return res.status(400).json({
      error: 'Invalid parameter types',
      message: 'lat and lon must be valid numbers',
      received: { lat, lon }
    });
  }
  
  if (latitude < -90 || latitude > 90) {
    return res.status(400).json({
      error: 'Invalid latitude',
      message: 'Latitude must be between -90 and 90 degrees',
      received: latitude
    });
  }
  
  if (longitude < -180 || longitude > 180) {
    return res.status(400).json({
      error: 'Invalid longitude',
      message: 'Longitude must be between -180 and 180 degrees',
      received: longitude
    });
  }
  
  // 검증된 좌표를 req 객체에 저장
  req.coordinates = { lat: latitude, lon: longitude };
  next();
};

// ==================== API 엔드포인트 ====================

/**
 * @swagger
 * /api/weather/current:
 *   get:
 *     summary: Get current weather information
 *     tags: [Weather]
 *     parameters:
 *       - in: query
 *         name: lat
 *         schema:
 *           type: number
 *         required: true
 *         description: Latitude coordinate
 *         example: 37.5665
 *       - in: query
 *         name: lon
 *         schema:
 *           type: number
 *         required: true
 *         description: Longitude coordinate
 *         example: 126.9780
 *       - in: query
 *         name: force
 *         schema:
 *           type: boolean
 *         required: false
 *         description: Force refresh (bypass cache)
 *         example: false
 *     responses:
 *       200:
 *         description: Current weather data
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *                 temperature:
 *                   type: number
 *                   description: Temperature in Celsius
 *                 condition:
 *                   type: string
 *                   description: Weather condition
 *                 location:
 *                   type: object
 *                   properties:
 *                     latitude:
 *                       type: number
 *                     longitude:
 *                       type: number
 *                     city:
 *                       type: string
 *       400:
 *         description: Bad request
 *       500:
 *         description: Internal server error
 */
router.get('/current', validateCoordinates, async (req, res, next) => {
  try {
    const { lat, lon } = req.coordinates;
    const force = req.query.force === 'true' || req.query.force === '1';
    
    console.log(`[WeatherAPI] Current weather request: lat=${lat}, lon=${lon}, force=${force}`);
    
    const weatherData = await getCurrentWeather(lat, lon, { force });
    
    res.json(weatherData);
  } catch (error) {
    console.error('[WeatherAPI] Current weather error:', error.message);
    next(error);
  }
});

/**
 * @swagger
 * /api/weather/forecast:
 *   get:
 *     summary: Get weather forecast
 *     tags: [Weather]
 *     parameters:
 *       - in: query
 *         name: lat
 *         schema:
 *           type: number
 *         required: true
 *         description: Latitude coordinate
 *         example: 37.5665
 *       - in: query
 *         name: lon
 *         schema:
 *           type: number
 *         required: true
 *         description: Longitude coordinate
 *         example: 126.9780
 *     responses:
 *       200:
 *         description: Weather forecast data
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   temperature:
 *                     type: number
 *                   condition:
 *                     type: string
 *                   timestamp:
 *                     type: string
 *                     format: date-time
 *       400:
 *         description: Bad request
 *       500:
 *         description: Internal server error
 */
router.get('/forecast', validateCoordinates, async (req, res, next) => {
  try {
    const { lat, lon } = req.coordinates;
    
    console.log(`[WeatherAPI] Forecast request: lat=${lat}, lon=${lon}`);
    
    const forecastData = await getWeatherForecast(lat, lon);
    
    res.json(forecastData);
  } catch (error) {
    console.error('[WeatherAPI] Forecast error:', error.message);
    next(error);
  }
});

/**
 * @swagger
 * /api/weather:
 *   get:
 *     summary: Get comprehensive weather information (current + forecast)
 *     tags: [Weather]
 *     parameters:
 *       - in: query
 *         name: lat
 *         schema:
 *           type: number
 *         required: true
 *         description: Latitude coordinate
 *         example: 37.5665
 *       - in: query
 *         name: lon
 *         schema:
 *           type: number
 *         required: true
 *         description: Longitude coordinate
 *         example: 126.9780
 *       - in: query
 *         name: force
 *         schema:
 *           type: boolean
 *         required: false
 *         description: Force refresh (bypass cache)
 *         example: false
 *     responses:
 *       200:
 *         description: Comprehensive weather data
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 current:
 *                   type: object
 *                   description: Current weather data
 *                 forecast:
 *                   type: array
 *                   description: Weather forecast data
 *       400:
 *         description: Bad request
 *       500:
 *         description: Internal server error
 */
router.get('/', validateCoordinates, async (req, res, next) => {
  try {
    const { lat, lon } = req.coordinates;
    const force = req.query.force === 'true' || req.query.force === '1';
    
    console.log(`[WeatherAPI] Comprehensive weather request: lat=${lat}, lon=${lon}, force=${force}`);
    
    // 현재 날씨와 예보를 병렬로 가져오기 (성능 최적화)
    const [currentData, forecastData] = await Promise.all([
      getCurrentWeather(lat, lon, { force }),
      getWeatherForecast(lat, lon)
    ]);
    
    // Flutter 앱에서 바로 사용할 수 있는 완전한 형식으로 응답
    const response = {
      timestamp: currentData.timestamp,
      temperature: currentData.temperature,
      feelsLike: currentData.feelsLike,
      humidity: currentData.humidity,
      windSpeed: currentData.windSpeed,
      windDirection: currentData.windDirection,
      precipitation: currentData.precipitation,
      condition: currentData.condition,
      description: currentData.description,
      icon: currentData.icon,
      location: currentData.location,
      source: currentData.source,
      cached: currentData.cached,
      isCurrent: currentData.isCurrent,
      forecast: forecastData
    };
    
    res.json(response);
  } catch (error) {
    console.error('[WeatherAPI] Comprehensive weather error:', error.message);
    next(error);
  }
});

// ==================== 헬스체크 엔드포인트 ====================

/**
 * @swagger
 * /api/weather/health:
 *   get:
 *     summary: Weather service health check
 *     tags: [Weather]
 *     responses:
 *       200:
 *         description: Service is healthy
 */
router.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'weather',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

export default router;