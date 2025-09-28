import express from 'express';
import { searchPlaces, getAddressFromCoordinates } from '../services/kakaoService.js';

const router = express.Router();

// 도시명으로 장소 검색
router.get('/search', async (req, res) => {
  try {
    const { query } = req.query;
    
    if (!query || query.trim().length === 0) {
      return res.status(400).json({
        error: 'Query parameter is required',
        message: '검색어를 입력해주세요'
      });
    }

    console.log(`[Kakao API] Searching for: ${query}`);
    const results = await searchPlaces(query);
    
    res.json({
      success: true,
      data: results,
      count: results.length
    });
  } catch (error) {
    console.error('[Kakao API] Search error:', error);
    res.status(500).json({
      error: 'Search failed',
      message: '검색 중 오류가 발생했습니다',
      details: error.message
    });
  }
});

// 좌표로 주소 검색
router.get('/address', async (req, res) => {
  try {
    const { lat, lon } = req.query;
    
    if (!lat || !lon) {
      return res.status(400).json({
        error: 'Latitude and longitude parameters are required',
        message: '위도와 경도가 필요합니다'
      });
    }

    const latitude = parseFloat(lat);
    const longitude = parseFloat(lon);
    
    if (isNaN(latitude) || isNaN(longitude)) {
      return res.status(400).json({
        error: 'Invalid coordinates',
        message: '올바른 좌표를 입력해주세요'
      });
    }

    console.log(`[Kakao API] Getting address for: ${latitude}, ${longitude}`);
    const result = await getAddressFromCoordinates(latitude, longitude);
    
    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('[Kakao API] Address error:', error);
    res.status(500).json({
      error: 'Address lookup failed',
      message: '주소 검색 중 오류가 발생했습니다',
      details: error.message
    });
  }
});

export default router;
