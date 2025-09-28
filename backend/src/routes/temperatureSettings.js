import express from 'express';
import { TemperatureSettingsService } from '../services/temperatureSettingsService.js';
import { firebaseAuth } from '../middleware/firebaseAuth.js';

const router = express.Router();

/**
 * @swagger
 * components:
 *   schemas:
 *     TemperatureSettings:
 *       type: object
 *       properties:
 *         temperatureSensitivity:
 *           type: number
 *           minimum: 0.7
 *           maximum: 1.3
 *           description: 온도 감도 계수
 *         coldTolerance:
 *           type: string
 *           enum: [low, normal, high]
 *           description: 추위 감수성
 *         heatTolerance:
 *           type: string
 *           enum: [low, normal, high]
 *           description: 더위 감수성
 *         age:
 *           type: number
 *           minimum: 0
 *           maximum: 120
 *           nullable: true
 *           description: 나이
 *         gender:
 *           type: string
 *           enum: [male, female, other]
 *           nullable: true
 *           description: 성별
 *         activityLevel:
 *           type: string
 *           enum: [low, moderate, high]
 *           description: 활동량
 */

/**
 * @swagger
 * /api/temperature-settings:
 *   get:
 *     summary: 사용자 온도 설정 조회
 *     tags: [Temperature Settings]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: 온도 설정 조회 성공
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/TemperatureSettings'
 *       404:
 *         description: 설정을 찾을 수 없음
 *       500:
 *         description: 서버 오류
 */
router.get('/', firebaseAuth, async (req, res) => {
  try {
    const userId = req.userId; // 미들웨어에서 설정된 사용자 ID
    
    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }

    const settings = await TemperatureSettingsService.getSettings(userId);
    
    if (!settings) {
      return res.status(404).json({ error: 'Temperature settings not found' });
    }

    // TemperatureSettings 객체를 JSON으로 변환
    const settingsJson = settings.toJSON();
    
    res.json(settingsJson);
  } catch (error) {
    console.error('Error getting temperature settings:', error);
    res.status(500).json({ error: 'Failed to get temperature settings' });
  }
});

/**
 * @swagger
 * /api/temperature-settings:
 *   post:
 *     summary: 사용자 온도 설정 저장
 *     tags: [Temperature Settings]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/TemperatureSettings'
 *     responses:
 *       201:
 *         description: 온도 설정 저장 성공
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/TemperatureSettings'
 *       400:
 *         description: 잘못된 요청 데이터
 *       500:
 *         description: 서버 오류
 */
router.post('/', firebaseAuth, async (req, res) => {
  try {
    const userId = req.userId;
    
    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }

    const settings = await TemperatureSettingsService.saveSettings(userId, req.body);
    res.status(201).json(settings);
  } catch (error) {
    console.error('Error saving temperature settings:', error);
    
    if (error.message.includes('Invalid settings')) {
      return res.status(400).json({ error: error.message });
    }
    
    res.status(500).json({ error: 'Failed to save temperature settings' });
  }
});

/**
 * @swagger
 * /api/temperature-settings:
 *   put:
 *     summary: 사용자 온도 설정 업데이트
 *     tags: [Temperature Settings]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 temperatureSensitivity:
 *                   type: number
 *                 coldTolerance:
 *                   type: string
 *                 heatTolerance:
 *                   type: string
 *                 age:
 *                   type: number
 *                 gender:
 *                   type: string
 *                 activityLevel:
 *                   type: string
 *     responses:
 *       200:
 *         description: 온도 설정 업데이트 성공
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/TemperatureSettings'
 *       400:
 *         description: 잘못된 요청 데이터
 *       500:
 *         description: 서버 오류
 */
router.put('/', firebaseAuth, async (req, res) => {
  try {
    const userId = req.userId;
    
    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }

    const settings = await TemperatureSettingsService.updateSettings(userId, req.body);
    res.json(settings);
  } catch (error) {
    console.error('Error updating temperature settings:', error);
    
    if (error.message.includes('Invalid settings')) {
      return res.status(400).json({ error: error.message });
    }
    
    res.status(500).json({ error: 'Failed to update temperature settings' });
  }
});

/**
 * @swagger
 * /api/temperature-settings:
 *   delete:
 *     summary: 사용자 온도 설정 삭제
 *     tags: [Temperature Settings]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: 온도 설정 삭제 성공
 *       500:
 *         description: 서버 오류
 */
router.delete('/', firebaseAuth, async (req, res) => {
  try {
    const userId = req.userId;
    
    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }

    await TemperatureSettingsService.deleteSettings(userId);
    res.json({ message: 'Temperature settings deleted successfully' });
  } catch (error) {
    console.error('Error deleting temperature settings:', error);
    res.status(500).json({ error: 'Failed to delete temperature settings' });
  }
});

/**
 * @swagger
 * /api/temperature-settings/initialize:
 *   post:
 *     summary: 기본 온도 설정으로 초기화
 *     tags: [Temperature Settings]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       201:
 *         description: 기본 설정 초기화 성공
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/TemperatureSettings'
 *       500:
 *         description: 서버 오류
 */
router.post('/initialize', firebaseAuth, async (req, res) => {
  try {
    const userId = req.userId;
    
    if (!userId) {
      return res.status(401).json({ error: 'User not authenticated' });
    }

    const settings = await TemperatureSettingsService.initializeDefaultSettings(userId);
    res.status(201).json(settings);
  } catch (error) {
    console.error('Error initializing default settings:', error);
    res.status(500).json({ error: 'Failed to initialize default settings' });
  }
});

export default router;
