import 'dotenv/config';
import fetch from 'node-fetch';
import { getAddressFromCoordinates } from './kakaoService.js';

/**
 * WeatherService - OpenWeatherMap API를 통한 날씨 데이터 관리
 * 
 * 주요 기능:
 * - OpenWeatherMap API 호출 및 데이터 변환
 * - 메모리 캐시를 통한 성능 최적화
 * - 에러 핸들링 및 fallback 메커니즘
 * - 한국 지역 좌표 기반 도시명 매핑
 */

// ==================== 설정 및 상수 ====================
const CACHE_TTL_MS = 1 * 60 * 1000; // 1분 캐시 (더 짧게)
const API_TIMEOUT_MS = 10000; // 10초 타임아웃
const OPENWEATHER_BASE_URL = 'https://api.openweathermap.org/data/2.5';

// 메모리 캐시 (Map 기반)
const cache = new Map();

// ==================== 유틸리티 함수 ====================

/**
 * OpenWeatherMap API에서 받은 도시명을 한글로 변환
 * @param {Object} data - OpenWeatherMap API 응답
 * @returns {string} 한글 도시명
 */
function getCityNameFromAPI(data) {
  // OpenWeatherMap API에서 제공하는 도시명을 한글로 변환
  if (data.name) {
    const cityName = data.name;
    console.log(`[WeatherService] Original city name: "${cityName}"`);
    
    // 주요 도시명 한글 변환 (더 포괄적으로)
    const cityMap = {
      'Seoul': '서울',
      'Busan': '부산',
      'Daegu': '대구',
      'Incheon': '인천',
      'Gwangju': '광주',
      'Daejeon': '대전',
      'Ulsan': '울산',
      'Sejong': '세종',
      'Suwon': '수원',
      'Seongnam': '성남',
      'Goyang': '고양',
      'Yongin': '용인',
      'Bucheon': '부천',
      'Chuncheon': '춘천',
      'Wonju': '원주',
      'Cheonan': '천안',
      'Cheongju': '청주',
      'Jeonju': '전주',
      'Yeosu': '여수',
      'Changwon': '창원',
      'Jinju': '진주',
      'Pohang': '포항',
      'Gyeongju': '경주',
      'Jeju': '제주',
      'Seogwipo': '서귀포',
      'Icheon-si': '이천',
      'Icheon': '이천',
      'Anyang': '안양',
      'Namyangju': '남양주',
      'Hwaseong': '화성',
      'Pyeongtaek': '평택',
      'Osan': '오산',
      'Siheung': '시흥',
      'Gunpo': '군포',
      'Uijeongbu': '의정부',
      'Hanam': '하남',
      'Gimpo': '김포',
      'Yangju': '양주',
      'Gwangmyeong': '광명',
      'Dongducheon': '동두천',
      'Guri': '구리',
      'Anseong': '안성',
      'Paju': '파주',
      'Yeoju': '여주',
      'Yangpyeong': '양평',
      'Gapyeong': '가평',
      'Yeoncheon': '연천',
      // 추가 변환 규칙
      'Icheon-si, Gyeonggi': '이천',
      'Icheon-si, Gyeonggi-do': '이천',
      'Icheon-si, Gyeonggi Province': '이천',
      'Icheon-si, South Korea': '이천',
      'Icheon-si, Republic of Korea': '이천'
    };
    
    // 정확한 매칭 시도
    if (cityMap[cityName]) {
      console.log(`[WeatherService] Exact match: "${cityName}" -> "${cityMap[cityName]}"`);
      return cityMap[cityName];
    }
    
    // 부분 매칭 시도 (예: "Icheon-si" -> "Icheon")
    for (const [key, value] of Object.entries(cityMap)) {
      if (cityName.includes(key)) {
        console.log(`[WeatherService] Partial match: "${cityName}" -> "${value}"`);
        return value;
      }
    }
    
    // 한국어가 이미 포함된 경우 그대로 반환
    if (/[가-힣]/.test(cityName)) {
      console.log(`[WeatherService] Already Korean: "${cityName}"`);
      return cityName;
    }
    
    // 매칭되지 않는 경우 원본 도시명 반환
    console.log(`[WeatherService] No match found for: "${cityName}"`);
    return cityName;
  }
  
  // API에서 도시명이 없는 경우
  return '현재 위치';
}

/**
 * OpenWeatherMap API에서 받은 지역 정보를 한글로 변환
 * @param {Object} data - OpenWeatherMap API 응답
 * @returns {string} 한글 지역명
 */
function getDistrictFromAPI(data) {
  // OpenWeatherMap API에서 제공하는 지역 정보를 한글로 변환
  if (data.sys && data.sys.country) {
    const countryMap = {
      'KR': '대한민국',
      'US': '미국',
      'JP': '일본',
      'CN': '중국',
      'GB': '영국',
      'FR': '프랑스',
      'DE': '독일',
      'IT': '이탈리아',
      'ES': '스페인',
      'CA': '캐나다',
      'AU': '호주',
      'BR': '브라질',
      'IN': '인도',
      'RU': '러시아'
    };
    
    return countryMap[data.sys.country] || data.sys.country;
  }
  
  return '대한민국';
}

/**
 * 좌표 기반으로 시/도 정보를 결정
 * @param {number} lat - 위도
 * @param {number} lon - 경도
 * @returns {string} 시/도명
 */
function getProvinceFromCoordinates(lat, lon) {
  // 한국 주요 시/도 좌표 범위
  const provinceRanges = [
    { name: '서울특별시', latMin: 37.4, latMax: 37.7, lonMin: 126.7, lonMax: 127.2 },
    { name: '부산광역시', latMin: 35.0, latMax: 35.3, lonMin: 128.9, lonMax: 129.3 },
    { name: '대구광역시', latMin: 35.7, latMax: 36.0, lonMin: 128.4, lonMax: 128.8 },
    { name: '인천광역시', latMin: 37.4, latMax: 37.6, lonMin: 126.5, lonMax: 126.8 },
    { name: '광주광역시', latMin: 35.1, latMax: 35.2, lonMin: 126.7, lonMax: 127.0 },
    { name: '대전광역시', latMin: 36.2, latMax: 36.5, lonMin: 127.3, lonMax: 127.6 },
    { name: '울산광역시', latMin: 35.4, latMax: 35.7, lonMin: 129.2, lonMax: 129.4 },
    { name: '세종특별자치시', latMin: 36.4, latMax: 36.6, lonMin: 127.2, lonMax: 127.4 },
    { name: '경기도', latMin: 37.0, latMax: 38.3, lonMin: 126.5, lonMax: 127.8 },
    { name: '강원도', latMin: 37.0, latMax: 38.6, lonMin: 127.5, lonMax: 129.1 },
    { name: '충청북도', latMin: 36.0, latMax: 37.2, lonMin: 127.0, lonMax: 128.5 },
    { name: '충청남도', latMin: 35.8, latMax: 37.0, lonMin: 126.0, lonMax: 127.5 },
    { name: '전라북도', latMin: 35.4, latMax: 36.2, lonMin: 126.0, lonMax: 127.5 },
    { name: '전라남도', latMin: 34.3, latMax: 35.4, lonMin: 125.0, lonMax: 127.5 },
    { name: '경상북도', latMin: 35.5, latMax: 37.0, lonMin: 128.0, lonMax: 129.5 },
    { name: '경상남도', latMin: 34.5, latMax: 35.5, lonMin: 127.5, lonMax: 129.0 },
    { name: '제주특별자치도', latMin: 33.0, latMax: 33.6, lonMin: 126.0, lonMax: 126.9 }
  ];

  for (const province of provinceRanges) {
    if (lat >= province.latMin && lat <= province.latMax && 
        lon >= province.lonMin && lon <= province.lonMax) {
      return province.name;
    }
  }
  
    return '한국';
}

/**
 * 좌표 기반으로 구/군 정보를 결정
 * @param {number} lat - 위도
 * @param {number} lon - 경도
 * @param {string} cityName - 도시명
 * @returns {string} 구/군명
 */
function getDistrictFromCoordinates(lat, lon, cityName) {
  // 주요 도시별 구/군 좌표 범위
  const districtRanges = {
    '서울': [
      { name: '강남구', latMin: 37.5, latMax: 37.6, lonMin: 127.0, lonMax: 127.1 },
      { name: '강동구', latMin: 37.5, latMax: 37.6, lonMin: 127.1, lonMax: 127.2 },
      { name: '강북구', latMin: 37.6, latMax: 37.7, lonMin: 127.0, lonMax: 127.1 },
      { name: '강서구', latMin: 37.5, latMax: 37.6, lonMin: 126.8, lonMax: 126.9 },
      { name: '관악구', latMin: 37.4, latMax: 37.5, lonMin: 126.9, lonMax: 127.0 },
      { name: '광진구', latMin: 37.5, latMax: 37.6, lonMin: 127.1, lonMax: 127.2 },
      { name: '구로구', latMin: 37.4, latMax: 37.5, lonMin: 126.8, lonMax: 126.9 },
      { name: '금천구', latMin: 37.4, latMax: 37.5, lonMin: 126.8, lonMax: 126.9 },
      { name: '노원구', latMin: 37.6, latMax: 37.7, lonMin: 127.0, lonMax: 127.1 },
      { name: '도봉구', latMin: 37.6, latMax: 37.7, lonMin: 127.0, lonMax: 127.1 },
      { name: '동대문구', latMin: 37.5, latMax: 37.6, lonMin: 127.0, lonMax: 127.1 },
      { name: '동작구', latMin: 37.4, latMax: 37.5, lonMin: 126.9, lonMax: 127.0 },
      { name: '마포구', latMin: 37.5, latMax: 37.6, lonMin: 126.9, lonMax: 127.0 },
      { name: '서대문구', latMin: 37.5, latMax: 37.6, lonMin: 126.9, lonMax: 127.0 },
      { name: '서초구', latMin: 37.4, latMax: 37.5, lonMin: 127.0, lonMax: 127.1 },
      { name: '성동구', latMin: 37.5, latMax: 37.6, lonMin: 127.0, lonMax: 127.1 },
      { name: '성북구', latMin: 37.5, latMax: 37.6, lonMin: 127.0, lonMax: 127.1 },
      { name: '송파구', latMin: 37.4, latMax: 37.5, lonMin: 127.1, lonMax: 127.2 },
      { name: '양천구', latMin: 37.5, latMax: 37.6, lonMin: 126.8, lonMax: 126.9 },
      { name: '영등포구', latMin: 37.5, latMax: 37.6, lonMin: 126.8, lonMax: 126.9 },
      { name: '용산구', latMin: 37.5, latMax: 37.6, lonMin: 126.9, lonMax: 127.0 },
      { name: '은평구', latMin: 37.6, latMax: 37.7, lonMin: 126.9, lonMax: 127.0 },
      { name: '종로구', latMin: 37.5, latMax: 37.6, lonMin: 126.9, lonMax: 127.0 },
      { name: '중구', latMin: 37.5, latMax: 37.6, lonMin: 126.9, lonMax: 127.0 },
      { name: '중랑구', latMin: 37.5, latMax: 37.6, lonMin: 127.0, lonMax: 127.1 }
    ],
    '이천': [
      { name: '중구', latMin: 37.2, latMax: 37.3, lonMin: 127.4, lonMax: 127.5 },
      { name: '장호원읍', latMin: 37.2, latMax: 37.3, lonMin: 127.3, lonMax: 127.4 },
      { name: '부발읍', latMin: 37.3, latMax: 37.4, lonMin: 127.4, lonMax: 127.5 },
      { name: '신둔면', latMin: 37.2, latMax: 37.3, lonMin: 127.5, lonMax: 127.6 },
      { name: '마장면', latMin: 37.3, latMax: 37.4, lonMin: 127.3, lonMax: 127.4 },
      { name: '대월면', latMin: 37.2, latMax: 37.3, lonMin: 127.3, lonMax: 127.4 },
      { name: '모가면', latMin: 37.1, latMax: 37.2, lonMin: 127.4, lonMax: 127.5 },
      { name: '설성면', latMin: 37.1, latMax: 37.2, lonMin: 127.3, lonMax: 127.4 },
      { name: '율면', latMin: 37.0, latMax: 37.1, lonMin: 127.4, lonMax: 127.5 }
    ],
    '수원': [
      { name: '영통구', latMin: 37.2, latMax: 37.3, lonMin: 127.0, lonMax: 127.1 },
      { name: '권선구', latMin: 37.2, latMax: 37.3, lonMin: 126.9, lonMax: 127.0 },
      { name: '팔달구', latMin: 37.2, latMax: 37.3, lonMin: 126.9, lonMax: 127.0 },
      { name: '장안구', latMin: 37.3, latMax: 37.4, lonMin: 126.9, lonMax: 127.0 }
    ]
  };

  const districts = districtRanges[cityName];
  if (districts) {
    for (const district of districts) {
    if (lat >= district.latMin && lat <= district.latMax && 
        lon >= district.lonMin && lon <= district.lonMax) {
      return district.name;
      }
    }
  }
  
  return '중구'; // 기본값
}

/**
 * 실제 GPS 좌표를 기반으로 정확한 한국 주소 체계 결정
 * @param {number} lat - 위도
 * @param {number} lon - 경도
 * @param {string} cityName - API에서 받은 도시명
 * @returns {Object} 정확한 한국 주소 정보
 */
function getAccurateKoreanAddress(lat, lon, cityName) {
  // 한국의 실제 행정구역 체계에 맞게 정확한 주소 결정
  // 시/도/군/구/동/리 체계를 GPS 좌표 기반으로 정확하게 매핑
  
  // 주요 도시별 정확한 좌표 범위와 행정구역 정보
  const koreanAddressMap = [
    // 서울특별시 (25개 자치구)
    { 
      city: '서울특별시', 
      latMin: 37.4, latMax: 37.7, lonMin: 126.7, lonMax: 127.2,
      districts: [
        { name: '강남구', latMin: 37.5, latMax: 37.6, lonMin: 127.0, lonMax: 127.1 },
        { name: '강동구', latMin: 37.5, latMax: 37.6, lonMin: 127.1, lonMax: 127.2 },
        { name: '강북구', latMin: 37.6, latMax: 37.7, lonMin: 127.0, lonMax: 127.1 },
        { name: '강서구', latMin: 37.5, latMax: 37.6, lonMin: 126.8, lonMax: 126.9 },
        { name: '관악구', latMin: 37.4, latMax: 37.5, lonMin: 126.9, lonMax: 127.0 },
        { name: '광진구', latMin: 37.5, latMax: 37.6, lonMin: 127.1, lonMax: 127.2 },
        { name: '구로구', latMin: 37.4, latMax: 37.5, lonMin: 126.8, lonMax: 126.9 },
        { name: '금천구', latMin: 37.4, latMax: 37.5, lonMin: 126.8, lonMax: 126.9 },
        { name: '노원구', latMin: 37.6, latMax: 37.7, lonMin: 127.0, lonMax: 127.1 },
        { name: '도봉구', latMin: 37.6, latMax: 37.7, lonMin: 127.0, lonMax: 127.1 },
        { name: '동대문구', latMin: 37.5, latMax: 37.6, lonMin: 127.0, lonMax: 127.1 },
        { name: '동작구', latMin: 37.4, latMax: 37.5, lonMin: 126.9, lonMax: 127.0 },
        { name: '마포구', latMin: 37.5, latMax: 37.6, lonMin: 126.9, lonMax: 127.0 },
        { name: '서대문구', latMin: 37.5, latMax: 37.6, lonMin: 126.9, lonMax: 127.0 },
        { name: '서초구', latMin: 37.4, latMax: 37.5, lonMin: 127.0, lonMax: 127.1 },
        { name: '성동구', latMin: 37.5, latMax: 37.6, lonMin: 127.0, lonMax: 127.1 },
        { name: '성북구', latMin: 37.5, latMax: 37.6, lonMin: 127.0, lonMax: 127.1 },
        { name: '송파구', latMin: 37.4, latMax: 37.5, lonMin: 127.1, lonMax: 127.2 },
        { name: '양천구', latMin: 37.5, latMax: 37.6, lonMin: 126.8, lonMax: 126.9 },
        { name: '영등포구', latMin: 37.5, latMax: 37.6, lonMin: 126.8, lonMax: 126.9 },
        { name: '용산구', latMin: 37.5, latMax: 37.6, lonMin: 126.9, lonMax: 127.0 },
        { name: '은평구', latMin: 37.6, latMax: 37.7, lonMin: 126.9, lonMax: 127.0 },
        { name: '종로구', latMin: 37.5, latMax: 37.6, lonMin: 126.9, lonMax: 127.0 },
        { name: '중구', latMin: 37.5, latMax: 37.6, lonMin: 126.9, lonMax: 127.0 },
        { name: '중랑구', latMin: 37.5, latMax: 37.6, lonMin: 127.0, lonMax: 127.1 }
      ]
    },
    // 이천시 (구가 없는 시)
    { 
      city: '이천시', 
      latMin: 37.2, latMax: 37.4, lonMin: 127.3, lonMax: 127.6,
      districts: [
        { name: '중앙동', latMin: 37.2, latMax: 37.3, lonMin: 127.4, lonMax: 127.5 },
        { name: '관고동', latMin: 37.2, latMax: 37.3, lonMin: 127.4, lonMax: 127.5 },
        { name: '신흥동', latMin: 37.2, latMax: 37.3, lonMin: 127.4, lonMax: 127.5 },
        { name: '장호원읍', latMin: 37.2, latMax: 37.3, lonMin: 127.3, lonMax: 127.4 },
        { name: '부발읍', latMin: 37.3, latMax: 37.4, lonMin: 127.4, lonMax: 127.5 },
        { name: '신둔면', latMin: 37.2, latMax: 37.3, lonMin: 127.5, lonMax: 127.6 },
        { name: '마장면', latMin: 37.3, latMax: 37.4, lonMin: 127.3, lonMax: 127.4 },
        { name: '대월면', latMin: 37.2, latMax: 37.3, lonMin: 127.3, lonMax: 127.4 },
        { name: '모가면', latMin: 37.1, latMax: 37.2, lonMin: 127.4, lonMax: 127.5 },
        { name: '설성면', latMin: 37.1, latMax: 37.2, lonMin: 127.3, lonMax: 127.4 },
        { name: '율면', latMin: 37.0, latMax: 37.1, lonMin: 127.4, lonMax: 127.5 }
      ]
    },
    // 수원시 (4개 구)
    { 
      city: '수원시', 
      latMin: 37.2, latMax: 37.4, lonMin: 126.8, lonMax: 127.2,
      districts: [
        { name: '영통구', latMin: 37.2, latMax: 37.3, lonMin: 127.0, lonMax: 127.1 },
        { name: '권선구', latMin: 37.2, latMax: 37.3, lonMin: 126.9, lonMax: 127.0 },
        { name: '팔달구', latMin: 37.2, latMax: 37.3, lonMin: 126.9, lonMax: 127.0 },
        { name: '장안구', latMin: 37.3, latMax: 37.4, lonMin: 126.9, lonMax: 127.0 }
      ]
    }
  ];

  // 좌표를 기반으로 정확한 주소 찾기
  for (const cityInfo of koreanAddressMap) {
    if (lat >= cityInfo.latMin && lat <= cityInfo.latMax && 
        lon >= cityInfo.lonMin && lon <= cityInfo.lonMax) {
      
      // 해당 도시 내에서 정확한 구/군/동/리 찾기
      for (const district of cityInfo.districts) {
        if (lat >= district.latMin && lat <= district.latMax && 
            lon >= district.lonMin && lon <= district.lonMax) {
          
          return {
            city: cityInfo.city,
            district: district.name,
            subLocality: null, // 실제 좌표 기반으로는 동/리까지 정확히 매핑하기 어려움
            province: null // 시/도는 도시명에 포함됨
          };
        }
      }
      
      // 구/군을 찾지 못한 경우 도시명만 반환
      return {
        city: cityInfo.city,
        district: null,
        subLocality: null,
        province: null
      };
    }
  }
  
  // 매핑되지 않은 경우 API에서 받은 도시명 사용
  return {
    city: cityName,
    district: null,
    subLocality: null,
    province: null
  };
}

/**
 * OpenWeatherMap API에서 받은 상세 지역 정보를 한글로 변환
 * @param {Object} data - OpenWeatherMap API 응답
 * @returns {string} 한글 상세 지역명
 */
function getSubLocalityFromAPI(data) {
  // OpenWeatherMap API에서 제공하는 상세 지역 정보를 한글로 변환
  if (data.weather && data.weather[0] && data.weather[0].description) {
    const weatherMap = {
      'clear sky': '맑음',
      'few clouds': '구름 조금',
      'scattered clouds': '구름 많음',
      'broken clouds': '구름 많음',
      'shower rain': '소나기',
      'rain': '비',
      'thunderstorm': '뇌우',
      'snow': '눈',
      'mist': '안개',
      'fog': '안개',
      'haze': '실안개',
      'dust': '먼지',
      'sand': '모래',
      'ash': '재',
      'squall': '돌풍',
      'tornado': '토네이도'
    };
    
    const description = data.weather[0].description.toLowerCase();
    return weatherMap[description] || data.weather[0].description;
  }
  
  return '현재 위치';
}

/**
 * 시간대 기반 날씨 아이콘 결정
 * @param {number} hour - 시간 (0-23)
 * @param {string} condition - 날씨 조건
 * @returns {string} 아이콘 코드
 */
function getWeatherIcon(hour, condition, sunrise = 6, sunset = 18) {
  // 일출/일몰 시간을 고려한 시간대 판단
  // 일출: 06시~18시 (낮), 일몰: 18시~다음날 06시 (밤)
  const isDaytime = hour >= sunrise && hour < sunset;
  const iconSuffix = isDaytime ? 'd' : 'n';
  
  console.log(`[WeatherService] getWeatherIcon: hour=${hour}, sunrise=${sunrise}, sunset=${sunset}, isDaytime=${isDaytime}, condition=${condition}`);
  
  // 시간대별 특별한 아이콘 처리
  let iconCode = '';
  
  switch (condition) {
    case 'Clear':
      if (isDaytime) {
        // 낮 시간: 해 아이콘
        iconCode = '01d';
      } else {
        // 밤 시간: 달 아이콘
        iconCode = '01n';
      }
      break;
    case 'Clouds':
      iconCode = `02${iconSuffix}`;
      break;
    case 'Rain':
      iconCode = `10${iconSuffix}`;
      break;
    case 'Snow':
      iconCode = `13${iconSuffix}`;
      break;
    case 'Thunderstorm':
      iconCode = `11${iconSuffix}`;
      break;
    case 'Drizzle':
      iconCode = `09${iconSuffix}`;
      break;
    case 'Mist':
    case 'Fog':
      iconCode = `50${iconSuffix}`;
      break;
    default:
      iconCode = `02${iconSuffix}`;
  }
  
  return iconCode;
}

// ==================== API 호출 함수 ====================

/**
 * OpenWeatherMap API 호출 (타임아웃 포함)
 * @param {string} url - API URL
 * @returns {Promise<Object>} API 응답 데이터
 */
async function fetchWithTimeout(url) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), API_TIMEOUT_MS);
  
  try {
    const response = await fetch(url, { 
      signal: controller.signal,
      headers: {
        'User-Agent': 'OOTD-App/1.0'
      }
    });
    
    clearTimeout(timeoutId);
    
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(`OpenWeatherMap API error: ${response.status} - ${errorData.message || 'Unknown error'}`);
    }
    
    return await response.json();
  } catch (error) {
    clearTimeout(timeoutId);
    if (error.name === 'AbortError') {
      throw new Error('API request timeout');
    }
    throw error;
  }
}

/**
 * OpenWeatherMap 현재 날씨 데이터 가져오기
 * @param {number} lat - 위도
 * @param {number} lon - 경도
 * @returns {Promise<Object>} 날씨 데이터
 */
async function fetchCurrentWeather(lat, lon) {
  const apiKey = process.env.OPENWEATHER_API_KEY;
  if (!apiKey) {
    throw new Error('OPENWEATHER_API_KEY is not configured');
  }

  const url = `${OPENWEATHER_BASE_URL}/weather?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric&lang=kr`;
  console.log(`[WeatherService] Fetching current weather for lat=${lat}, lon=${lon}`);
  
  return await fetchWithTimeout(url);
}

/**
 * OpenWeatherMap 예보 데이터 가져오기
 * @param {number} lat - 위도
 * @param {number} lon - 경도
 * @returns {Promise<Object>} 예보 데이터
 */
async function fetchWeatherForecast(lat, lon) {
  const apiKey = process.env.OPENWEATHER_API_KEY;
  if (!apiKey) {
    throw new Error('OPENWEATHER_API_KEY is not configured');
  }

  const url = `${OPENWEATHER_BASE_URL}/forecast?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric&lang=kr`;
  console.log(`[WeatherService] Fetching forecast for lat=${lat}, lon=${lon}`);
  
  return await fetchWithTimeout(url);
}

// ==================== 데이터 변환 함수 ====================

/**
 * OpenWeatherMap 데이터를 앱 형식으로 변환 (API 데이터 기반 위치 정보 사용)
 * @param {Object} data - OpenWeatherMap API 응답
 * @param {number} lat - 위도
 * @param {number} lon - 경도
 * @returns {Object} 변환된 날씨 데이터
 */
async function transformWeatherData(data, lat, lon) {
  const now = new Date();
  const koreaTime = new Date(now.getTime() + (9 * 60 * 60 * 1000)); // UTC+9
  const currentHour = koreaTime.getHours();
  
  // Kakao API를 사용한 정확한 위치 정보 가져오기
  let locationInfo = {
    city: 'Unknown',
    country: '대한민국',
    district: null,
    subLocality: null,
    province: null
  };
  
  try {
    console.log(`[WeatherService] Getting accurate location from Kakao API for lat=${lat}, lon=${lon}`);
    const kakaoResult = await getAddressFromCoordinates(lat, lon);
    
    if (kakaoResult) {
      console.log(`[WeatherService] Kakao API result: ${kakaoResult.placeName} - ${kakaoResult.addressName}`);
      
      // Kakao API 결과에서 정확한 위치 정보 추출
      locationInfo = {
        city: kakaoResult.placeName || 'Unknown',
        country: '대한민국',
        district: kakaoResult.districtName || null,
        subLocality: null,
        province: '경기도' // Kakao API는 한국 내에서만 사용
      };
      
      console.log(`[WeatherService] ✅ Accurate location from Kakao API: ${locationInfo.city} ${locationInfo.district || ''}`);
    } else {
      console.log(`[WeatherService] ⚠️ Kakao API failed, using fallback`);
      // Fallback: OpenWeatherMap API 결과 사용
      const cityName = getCityNameFromAPI(data);
      const country = getDistrictFromAPI(data);
      const addressInfo = getAccurateKoreanAddress(lat, lon, cityName);
      
      locationInfo = {
        city: addressInfo.city,
        country: country,
        district: addressInfo.district,
        subLocality: addressInfo.subLocality,
        province: addressInfo.province
      };
    }
  } catch (error) {
    console.log(`[WeatherService] ❌ Kakao API error: ${error.message}, using fallback`);
    // Fallback: OpenWeatherMap API 결과 사용
    const cityName = getCityNameFromAPI(data);
    const country = getDistrictFromAPI(data);
    const addressInfo = getAccurateKoreanAddress(lat, lon, cityName);
    
    locationInfo = {
      city: addressInfo.city,
      country: country,
      district: addressInfo.district,
      subLocality: addressInfo.subLocality,
      province: addressInfo.province
    };
  }
  
  console.log(`[WeatherService] Final location info: ${locationInfo.city} ${locationInfo.district || ''} ${locationInfo.subLocality || ''} ${locationInfo.province || ''}`.trim());
  console.log(`[WeatherService] Coordinates: lat=${lat}, lon=${lon}`);
  
  // 일출/일몰 시간 추출 (한국 시간으로 변환)
  const sunrise = new Date(data.sys.sunrise * 1000);
  const sunset = new Date(data.sys.sunset * 1000);
  const sunriseHour = sunrise.getHours();
  const sunsetHour = sunset.getHours();
  
  console.log(`[WeatherService] Sunrise: ${sunriseHour}:00, Sunset: ${sunsetHour}:00`);
  
  return {
    timestamp: now.toISOString(),
    temperature: Math.round(data.main.temp),
    feelsLike: Math.round(data.main.feels_like),
    humidity: data.main.humidity,
    windSpeed: data.wind.speed,
    windDirection: data.wind.deg || 0,
    precipitation: data.rain?.['1h'] || data.snow?.['1h'] || 0,
    condition: data.weather[0].main,
    description: data.weather[0].description,
    icon: getWeatherIcon(currentHour, data.weather[0].main, sunriseHour, sunsetHour),
    location: {
      latitude: lat,
      longitude: lon,
      ...locationInfo
    },
    source: 'openweathermap',
    cached: false,
    isCurrent: true
  };
}

/**
 * OpenWeatherMap 예보 데이터를 앱 형식으로 변환
 * @param {Object} data - OpenWeatherMap API 응답
 * @param {number} lat - 위도
 * @param {number} lon - 경도
 * @returns {Array} 변환된 예보 데이터 배열
 */
async function transformForecastData(data, lat, lon) {
  const now = new Date();
  // 한국 시간대 (UTC+9) 정확한 계산
  const koreaTime = new Date(now.getTime() + (9 * 60 * 60 * 1000));
  const currentHour = koreaTime.getUTCHours();
  const currentMinute = koreaTime.getUTCMinutes();
  
  console.log(`[WeatherService] Current UTC time: ${now.toISOString()}`);
  console.log(`[WeatherService] Current Korea time: ${koreaTime.toISOString()}`);
  console.log(`[WeatherService] Current hour: ${currentHour}, minute: ${currentMinute}`);
  
  // Kakao API를 사용한 정확한 위치 정보 가져오기
  let locationInfo = {
    city: 'Unknown',
    country: '대한민국',
    district: null,
    subLocality: null,
    province: null
  };
  
  try {
    console.log(`[WeatherService] Getting accurate location from Kakao API for forecast lat=${lat}, lon=${lon}`);
    const kakaoResult = await getAddressFromCoordinates(lat, lon);
    
    if (kakaoResult) {
      console.log(`[WeatherService] Kakao API result for forecast: ${kakaoResult.placeName} - ${kakaoResult.addressName}`);
      
      // Kakao API 결과에서 정확한 위치 정보 추출
      locationInfo = {
        city: kakaoResult.placeName || 'Unknown',
        country: '대한민국',
        district: kakaoResult.districtName || null,
        subLocality: null,
        province: '경기도' // Kakao API는 한국 내에서만 사용
      };
      
      console.log(`[WeatherService] ✅ Accurate location from Kakao API for forecast: ${locationInfo.city} ${locationInfo.district || ''}`);
    } else {
      console.log(`[WeatherService] ⚠️ Kakao API failed for forecast, using fallback`);
      // Fallback: OpenWeatherMap API 결과 사용
      const firstItem = data.list[0];
      const cityName = getCityNameFromAPI(firstItem);
      const country = getDistrictFromAPI(firstItem);
      const addressInfo = getAccurateKoreanAddress(lat, lon, cityName);
      
      locationInfo = {
        city: addressInfo.city,
        country: country,
        district: addressInfo.district,
        subLocality: addressInfo.subLocality,
        province: addressInfo.province
      };
    }
  } catch (error) {
    console.log(`[WeatherService] ❌ Kakao API error for forecast: ${error.message}, using fallback`);
    // Fallback: OpenWeatherMap API 결과 사용
    const firstItem = data.list[0];
    const cityName = getCityNameFromAPI(firstItem);
    const country = getDistrictFromAPI(firstItem);
    const addressInfo = getAccurateKoreanAddress(lat, lon, cityName);
    
    locationInfo = {
      city: addressInfo.city,
      country: country,
      district: addressInfo.district,
      subLocality: addressInfo.subLocality,
      province: addressInfo.province
    };
  }
  
  // 일출/일몰 시간 (예보 API에서는 제공하지 않으므로 기본값 사용)
  // 실제로는 현재 날씨 API에서 가져온 정보를 사용하는 것이 좋음
  const sunriseHour = 6; // 기본값
  const sunsetHour = 18; // 기본값
  
  console.log(`[WeatherService] Using default sunrise: ${sunriseHour}:00, sunset: ${sunsetHour}:00`);
  console.log(`[WeatherService] Final location info for forecast: ${locationInfo.city} ${locationInfo.district || ''} ${locationInfo.subLocality || ''} ${locationInfo.province || ''}`.trim());
  
  // 3시간 간격 예보에서 현재 시간과 가장 가까운 시간을 찾기
  const allForecasts = data.list
    .map(item => {
      const itemTime = new Date(item.dt * 1000);
      // UTC 시간을 한국 시간대로 변환 (UTC+9)
      const itemKoreaTime = new Date(itemTime.getTime() + (9 * 60 * 60 * 1000));
      const itemHour = itemKoreaTime.getUTCHours();
      const itemMinute = itemKoreaTime.getUTCMinutes();
      
      // 현재 시간과의 차이를 분 단위로 계산
      const currentTimeInMinutes = currentHour * 60 + currentMinute;
      const itemTimeInMinutes = itemHour * 60 + itemMinute;
      const timeDiff = itemTimeInMinutes - currentTimeInMinutes;
      
      return {
        ...item,
        koreaTime: itemKoreaTime,
        hour: itemHour,
        minute: itemMinute,
        timeDiff: timeDiff,
        isCurrent: false
      };
    })
    .filter(item => {
      // 현재 시간 이후의 데이터만 포함 (현재 시간 포함)
      return item.timeDiff >= 0;
    })
    .sort((a, b) => {
      // 시간 순서대로 정렬
      return a.koreaTime - b.koreaTime;
    });

  // 현재 시간과 가장 가까운 예보 시간을 찾기 (3시간 간격이므로 90분 이내)
  let closestIndex = 0;
  let minTimeDiff = Math.abs(allForecasts[0].timeDiff);
  
  for (let i = 1; i < allForecasts.length; i++) {
    const timeDiff = Math.abs(allForecasts[i].timeDiff);
    if (timeDiff < minTimeDiff) {
      minTimeDiff = timeDiff;
      closestIndex = i;
    }
  }
  
  // 가장 가까운 시간을 현재로 설정 (90분 이내일 때만)
  if (minTimeDiff <= 90) {
    allForecasts[closestIndex].isCurrent = true;
    console.log(`[WeatherService] Setting item ${closestIndex} as CURRENT (timeDiff: ${minTimeDiff} minutes)`);
  } else {
    console.log(`[WeatherService] No item close enough to current time (minTimeDiff: ${minTimeDiff} minutes)`);
  }
  
  // 가장 가까운 시간부터 8개까지 선택
  let filteredAndSorted = allForecasts.slice(closestIndex, closestIndex + 8);
  
  // 3시간 간격을 유지하면서 연속된 시간대만 선택
  const continuousForecasts = [];
  let lastHour = -1;
  
  for (const item of filteredAndSorted) {
    // 첫 번째 항목이거나 정확히 3시간 간격인 경우만 포함
    if (lastHour === -1) {
      continuousForecasts.push(item);
      lastHour = item.hour;
    } else {
      // 3시간 간격인지 확인 (00:00은 24:00으로 처리)
      const currentHour = item.hour === 0 ? 24 : item.hour;
      const prevHour = lastHour === 0 ? 24 : lastHour;
      const hourDiff = currentHour - prevHour;
      
      if (hourDiff === 3) {
        continuousForecasts.push(item);
        lastHour = item.hour;
      }
    }
    
    // 8개까지만 선택
    if (continuousForecasts.length >= 8) break;
  }
  
  // 만약 8개 미만이면 다음 날 예보도 포함
  if (continuousForecasts.length < 8) {
    const remainingItems = allForecasts.slice(closestIndex + continuousForecasts.length);
    for (const item of remainingItems) {
      if (continuousForecasts.length >= 8) break;
      
      // 3시간 간격인지 확인
      if (lastHour === -1) {
        continuousForecasts.push(item);
        lastHour = item.hour;
      } else {
        const currentHour = item.hour === 0 ? 24 : item.hour;
        const prevHour = lastHour === 0 ? 24 : lastHour;
        const hourDiff = currentHour - prevHour;
        
        if (hourDiff === 3) {
          continuousForecasts.push(item);
          lastHour = item.hour;
        }
      }
    }
  }
  
  filteredAndSorted = continuousForecasts;
  
  // 첫 번째 항목을 "지금"으로 설정 (이미 가장 가까운 시간이므로)
  if (filteredAndSorted.length > 0) {
    filteredAndSorted[0].isCurrent = true;
  }
  
  console.log(`[WeatherService] Filtered forecast items: ${filteredAndSorted.length}`);
  filteredAndSorted.forEach((item, index) => {
    const timeString = `${item.hour.toString().padStart(2, '0')}:${item.minute.toString().padStart(2, '0')}`;
    console.log(`[WeatherService] Item ${index}: ${timeString} - ${item.isCurrent ? 'CURRENT' : 'FUTURE'}`);
  });
  
  return filteredAndSorted.map((item, index) => {
      const itemTime = new Date(item.dt * 1000);
      // UTC 시간을 한국 시간대로 변환 (UTC+9)
      const itemKoreaTime = new Date(itemTime.getTime() + (9 * 60 * 60 * 1000));
      const itemHour = itemKoreaTime.getUTCHours();
      
      console.log(`[WeatherService] Item ${index}: UTC=${itemTime.toISOString()}, Korea=${itemKoreaTime.toISOString()}, hour=${itemHour}`);
      
      return {
        temperature: Math.round(item.main.temp),
        feelsLike: Math.round(item.main.feels_like),
        humidity: item.main.humidity,
        windSpeed: item.wind.speed,
        windDirection: item.wind.deg || 0,
        precipitation: item.rain?.['3h'] || item.snow?.['3h'] || 0,
        condition: item.weather[0].main,
        description: item.weather[0].description,
      icon: getWeatherIcon(itemHour, item.weather[0].main, sunriseHour, sunsetHour),
      timestamp: itemKoreaTime.toISOString(), // 한국 시간으로 표시
      isCurrent: item.isCurrent,
        location: {
          latitude: lat,
          longitude: lon,
        ...locationInfo
        }
      };
    });
}

// ==================== 캐시 관리 ====================

/**
 * 캐시에서 데이터 조회
 * @param {string} key - 캐시 키
 * @returns {Object|null} 캐시된 데이터 또는 null
 */
function getCachedData(key, isArray = false) {
  const cached = cache.get(key);
  if (cached && Date.now() - cached.timestamp < CACHE_TTL_MS) {
    console.log(`[WeatherService] Cache hit for key: ${key}`);
    if (isArray) {
      // forecast 데이터는 배열이므로 그대로 반환
      return cached.data;
    } else {
      // current 데이터는 객체이므로 cached 플래그 추가
    return { ...cached.data, cached: true };
    }
  }
  return null;
}

/**
 * 데이터를 캐시에 저장
 * @param {string} key - 캐시 키
 * @param {Object} data - 저장할 데이터
 */
function setCachedData(key, data) {
  cache.set(key, {
    data,
    timestamp: Date.now()
  });
  console.log(`[WeatherService] Data cached with key: ${key}`);
}

// ==================== 공개 API ====================

/**
 * 현재 날씨 데이터 가져오기
 * @param {number} lat - 위도
 * @param {number} lon - 경도
 * @param {Object} options - 옵션 (force: boolean)
 * @returns {Promise<Object>} 현재 날씨 데이터
 */
export async function getCurrentWeather(lat, lon, options = {}) {
  // 입력 검증
  if (typeof lat !== 'number' || typeof lon !== 'number') {
    throw new Error('lat and lon must be numbers');
  }
  
  if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
    throw new Error('Invalid coordinates: lat must be -90 to 90, lon must be -180 to 180');
  }

  const cacheKey = `current_${lat}_${lon}`;
  
  // 캐시 확인 (force가 false인 경우)
  if (!options.force) {
    const cached = getCachedData(cacheKey);
    if (cached) {
      console.log(`[WeatherService] Using cached data for ${cacheKey}`);
      return cached;
    }
  } else {
    console.log(`[WeatherService] Force refresh requested for ${cacheKey}`);
  }

  try {
    const data = await fetchCurrentWeather(lat, lon);
    const transformed = await transformWeatherData(data, lat, lon);
    
    setCachedData(cacheKey, transformed);
    return transformed;
  } catch (error) {
    console.error('[WeatherService] Error fetching current weather:', error.message);
    throw error;
  }
}

/**
 * 날씨 예보 데이터 가져오기
 * @param {number} lat - 위도
 * @param {number} lon - 경도
 * @returns {Promise<Array>} 예보 데이터 배열
 */
export async function getWeatherForecast(lat, lon) {
  // 입력 검증
  if (typeof lat !== 'number' || typeof lon !== 'number') {
    throw new Error('lat and lon must be numbers');
  }
  
  if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
    throw new Error('Invalid coordinates: lat must be -90 to 90, lon must be -180 to 180');
  }

  const cacheKey = `forecast_${lat}_${lon}`;
  
  // 캐시 확인
  const cached = getCachedData(cacheKey, true); // forecast는 배열
  if (cached) return cached;

  try {
    const data = await fetchWeatherForecast(lat, lon);
    const transformed = await transformForecastData(data, lat, lon);
    
    setCachedData(cacheKey, transformed);
    return transformed;
  } catch (error) {
    console.error('[WeatherService] Error fetching forecast:', error.message);
    throw error;
  }
}

/**
 * 캐시 초기화
 */
export function clearCache() {
  cache.clear();
  console.log('[WeatherService] Cache cleared');
}

/**
 * 캐시 상태 조회
 * @returns {Object} 캐시 상태 정보
 */
export function getCacheStats() {
  return {
    size: cache.size,
    maxAge: CACHE_TTL_MS,
    entries: Array.from(cache.keys())
  };
}