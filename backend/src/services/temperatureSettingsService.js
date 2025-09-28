import { db } from '../config/firebase.js';
import { TemperatureSettings, PersonalizationCalculator } from '../models/temperatureSettings.js';

/**
 * 사용자 온도 설정 서비스
 */
export class TemperatureSettingsService {
  
  /**
   * 사용자의 온도 설정 조회
   * @param {string} userId - Firebase Auth UID
   * @returns {Promise<TemperatureSettings|null>}
   */
  static async getSettings(userId) {
    try {
      if (!userId) {
        throw new Error('User ID is required');
      }

      const docRef = db
        .collection('users')
        .doc(userId)
        .collection('temperatureSettings')
        .doc('main');

      const doc = await docRef.get();
      
      if (!doc.exists) {
        return null;
      }

      const data = doc.data();
      
      try {
        const settings = TemperatureSettings.fromFirestore(data);
        return settings;
      } catch (parseError) {
        console.error(`[TemperatureSettingsService] Error parsing Firestore data:`, parseError);
        throw parseError;
      }
    } catch (error) {
      console.error('Error getting temperature settings:', error);
      throw new Error(`Failed to get temperature settings: ${error.message}`);
    }
  }

  /**
   * 사용자의 온도 설정 저장
   * @param {string} userId - Firebase Auth UID
   * @param {Object} settingsData - 설정 데이터
   * @returns {Promise<TemperatureSettings>}
   */
  static async saveSettings(userId, settingsData) {
    try {
      if (!userId) {
        throw new Error('User ID is required');
      }

      // TemperatureSettings 객체 생성
      const settings = new TemperatureSettings(settingsData);
      
      // 유효성 검사
      const validation = settings.validate();
      if (!validation.isValid) {
        throw new Error(`Invalid settings: ${validation.errors.join(', ')}`);
      }

      // Firestore에 저장
      const docRef = db
        .collection('users')
        .doc(userId)
        .collection('temperatureSettings')
        .doc('main');

      const firestoreData = settings.toFirestore();
      
      await docRef.set(firestoreData);
      
      return settings;
    } catch (error) {
      console.error('Error saving temperature settings:', error);
      throw new Error(`Failed to save temperature settings: ${error.message}`);
    }
  }

  /**
   * 사용자의 온도 설정 업데이트
   * @param {string} userId - Firebase Auth UID
   * @param {Object} updates - 업데이트할 필드들
   * @returns {Promise<TemperatureSettings>}
   */
  static async updateSettings(userId, updates) {
    try {
      if (!userId) {
        throw new Error('User ID is required');
      }

      // 기존 설정 조회
      const existingSettings = await this.getSettings(userId);
      
      if (!existingSettings) {
        // 기존 설정이 없으면 새로 생성
        return await this.saveSettings(userId, updates);
      }

      // 기존 설정과 업데이트 데이터 병합
      const mergedData = {
        ...existingSettings,
        ...updates,
        updatedAt: new Date()
      };

      return await this.saveSettings(userId, mergedData);
    } catch (error) {
      console.error('Error updating temperature settings:', error);
      throw new Error(`Failed to update temperature settings: ${error.message}`);
    }
  }

  /**
   * 사용자의 온도 설정 삭제
   * @param {string} userId - Firebase Auth UID
   * @returns {Promise<boolean>}
   */
  static async deleteSettings(userId) {
    try {
      if (!userId) {
        throw new Error('User ID is required');
      }

      const docRef = db
        .collection('users')
        .doc(userId)
        .collection('temperatureSettings')
        .doc('main');

      await docRef.delete();
      
      return true;
    } catch (error) {
      console.error('Error deleting temperature settings:', error);
      throw new Error(`Failed to delete temperature settings: ${error.message}`);
    }
  }

  /**
   * 기본 설정으로 초기화
   * @param {string} userId - Firebase Auth UID
   * @returns {Promise<TemperatureSettings>}
   */
  static async initializeDefaultSettings(userId) {
    try {
      const defaultSettings = TemperatureSettings.getDefault();
      return await this.saveSettings(userId, defaultSettings);
    } catch (error) {
      console.error('Error initializing default settings:', error);
      throw new Error(`Failed to initialize default settings: ${error.message}`);
    }
  }

  /**
   * 개인화된 체감온도 계산
   * @param {string} userId - Firebase Auth UID
   * @param {Object} weather - 날씨 데이터
   * @returns {Promise<number>} - 개인화된 체감온도
   */
  static async calculatePersonalizedFeelsLike(userId, weather) {
    try {
      // 사용자 설정 조회
      const settings = await this.getSettings(userId);
      
      if (!settings) {
        // 설정이 없으면 기본 체감온도 반환
        return weather.feelsLike || weather.temperature;
      }

      // 기본 체감온도 (이미 계산된 값 사용)
      const baseFeelsLike = weather.feelsLike || weather.temperature;
      
      // 개인화 보정값 계산
      const personalAdjustment = PersonalizationCalculator.calculatePersonalAdjustment(
        settings,
        weather.temperature
      );

      // 온도 감도 계수 적용
      const personalizedFeelsLike = (baseFeelsLike + personalAdjustment) * settings.temperatureSensitivity;
      
      return Math.round(personalizedFeelsLike * 10) / 10; // 소수점 1자리
    } catch (error) {
      console.error('Error calculating personalized feels like:', error);
      // 에러 발생시 기본 체감온도 반환
      return weather.feelsLike || weather.temperature;
    }
  }
}
