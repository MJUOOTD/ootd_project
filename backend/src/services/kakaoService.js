import 'dotenv/config';
import fetch from 'node-fetch';

const KAKAO_API_KEY = process.env.KAKAO_API_KEY;
const KAKAO_BASE_URL = 'https://dapi.kakao.com/v2/local';

// 카카오 API 키 확인
if (!KAKAO_API_KEY || KAKAO_API_KEY === 'your_kakao_api_key_here') {
  console.warn('[KakaoService] KAKAO_API_KEY is not configured. City search will use fallback data.');
}

// 도시명 정리 함수
function cleanCityName(placeName) {
  if (!placeName) return '';
  
  // 불필요한 접미사 제거
  let cleaned = placeName
    .replace(/특별시$/, '시')
    .replace(/광역시$/, '시')
    .replace(/자치시$/, '시')
    .replace(/자치도$/, '도')
    .replace(/특별자치시$/, '시')
    .replace(/특별자치도$/, '도');
  
  return cleaned;
}

// 주소명 정리 함수
function cleanAddressName(addressName) {
  if (!addressName) return '';
  
  // 시/도 단위로 정리
  const parts = addressName.split(' ');
  if (parts.length >= 2) {
    return `${parts[0]} ${parts[1]}`;
  }
  
  return addressName;
}

// 도시명으로 장소 검색
export async function searchPlaces(query) {
  if (!KAKAO_API_KEY || KAKAO_API_KEY === 'your_kakao_api_key_here') {
    console.log('[KakaoService] Using fallback data for query:', query);
    return getFallbackCities(query);
  }

  try {
    const url = `${KAKAO_BASE_URL}/search/keyword.json?query=${encodeURIComponent(query)}&size=20`;
    
    const response = await fetch(url, {
      headers: {
        'Authorization': `KakaoAK ${KAKAO_API_KEY}`,
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`Kakao API error: ${response.status}`);
    }

    const data = await response.json();
    const documents = data.documents || [];
    
    // 한국의 도시/지역 관련 결과만 필터링하고 정리
    const filteredResults = documents
      .filter(doc => {
        const category = doc.category_name || '';
        const placeName = doc.place_name || '';
        const addressName = doc.address_name || '';
        
        // 한국의 행정구역 관련 카테고리 필터링
        return category.includes('지역') || 
               category.includes('행정') ||
               category.includes('시') ||
               category.includes('도') ||
               category.includes('구') ||
               category.includes('군') ||
               category.includes('특별시') ||
               category.includes('광역시') ||
               category.includes('자치시') ||
               category.includes('자치도') ||
               // 도시명에 시/도가 포함된 경우
               placeName.includes('시') ||
               placeName.includes('도') ||
               placeName.includes('구') ||
               placeName.includes('군') ||
               // 주소에 시/도가 포함된 경우
               addressName.includes('시') ||
               addressName.includes('도');
      })
      .map(doc => ({
        ...doc,
        place_name: cleanCityName(doc.place_name),
        address_name: cleanAddressName(doc.address_name)
      }));

    return filteredResults.map(doc => ({
      id: doc.id,
      placeName: doc.place_name,
      addressName: doc.address_name,
      roadAddressName: doc.road_address_name,
      categoryName: doc.category_name,
      latitude: parseFloat(doc.y),
      longitude: parseFloat(doc.x),
      phone: doc.phone,
      placeUrl: doc.place_url,
    }));
  } catch (error) {
    console.error('[KakaoService] Error searching places:', error.message);
    return getFallbackCities(query);
  }
}

// 좌표로 주소 검색 (역지오코딩)
export async function getAddressFromCoordinates(lat, lon) {
  if (!KAKAO_API_KEY || KAKAO_API_KEY === 'your_kakao_api_key_here') {
    console.log('[KakaoService] Using fallback address for coordinates:', lat, lon);
    return getFallbackAddress(lat, lon);
  }

  try {
    const url = `${KAKAO_BASE_URL}/geo/coord2address.json?x=${lon}&y=${lat}&input_coord=WGS84`;
    
    const response = await fetch(url, {
      headers: {
        'Authorization': `KakaoAK ${KAKAO_API_KEY}`,
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`Kakao API error: ${response.status}`);
    }

    const data = await response.json();
    const documents = data.documents || [];
    
    if (documents.length > 0) {
      const doc = documents[0];
      const address = doc.address || {};
      const roadAddress = doc.road_address || {};
      
      // 더 디테일한 위치 정보 구성
      let placeName = '';
      let addressName = '';
      
      console.log(`[KakaoService] Kakao API response for ${lat}, ${lon}:`);
      console.log(`[KakaoService] - roadAddress:`, roadAddress);
      console.log(`[KakaoService] - address:`, address);
      
      if (roadAddress.address_name) {
        // 도로명 주소가 있는 경우
        placeName = roadAddress.region_2depth_name || roadAddress.region_1depth_name || 'Unknown';
        addressName = roadAddress.address_name;
        console.log(`[KakaoService] Using road address: ${placeName} - ${addressName}`);
      } else if (address.address_name) {
        // 지번 주소가 있는 경우
        placeName = address.region_2depth_name || address.region_1depth_name || 'Unknown';
        addressName = address.address_name;
        console.log(`[KakaoService] Using address: ${placeName} - ${addressName}`);
      } else {
        placeName = 'Unknown Location';
        addressName = 'Unknown Address';
        console.log(`[KakaoService] No valid address found, using fallback`);
      }
      
      return {
        id: `location_${lat}_${lon}`,
        placeName: placeName,
        addressName: addressName,
        roadAddressName: roadAddress.address_name || addressName,
        categoryName: '지역',
        latitude: lat,
        longitude: lon,
        phone: '',
        placeUrl: '',
      };
    }
    
    return null;
  } catch (error) {
    console.error('[KakaoService] Error getting address:', error.message);
    return getFallbackAddress(lat, lon);
  }
}

// API 키가 없을 때 사용할 기본 도시 목록
function getFallbackCities(query) {
  const cities = [
    // 광역시
    {
      id: 'seoul',
      placeName: '서울특별시',
      addressName: '서울특별시',
      roadAddressName: '서울특별시',
      categoryName: '지역',
      latitude: 37.5665,
      longitude: 126.9780,
    },
    {
      id: 'busan',
      placeName: '부산광역시',
      addressName: '부산광역시',
      roadAddressName: '부산광역시',
      categoryName: '지역',
      latitude: 35.1796,
      longitude: 129.0756,
    },
    {
      id: 'daegu',
      placeName: '대구광역시',
      addressName: '대구광역시',
      roadAddressName: '대구광역시',
      categoryName: '지역',
      latitude: 35.8714,
      longitude: 128.6014,
    },
    {
      id: 'incheon',
      placeName: '인천광역시',
      addressName: '인천광역시',
      roadAddressName: '인천광역시',
      categoryName: '지역',
      latitude: 37.4563,
      longitude: 126.7052,
    },
    {
      id: 'gwangju',
      placeName: '광주광역시',
      addressName: '광주광역시',
      roadAddressName: '광주광역시',
      categoryName: '지역',
      latitude: 35.1595,
      longitude: 126.8526,
    },
    {
      id: 'daejeon',
      placeName: '대전광역시',
      addressName: '대전광역시',
      roadAddressName: '대전광역시',
      categoryName: '지역',
      latitude: 36.3504,
      longitude: 127.3845,
    },
    // 주요 도시
    {
      id: 'ulsan',
      placeName: '울산광역시',
      addressName: '울산광역시',
      roadAddressName: '울산광역시',
      categoryName: '지역',
      latitude: 35.5384,
      longitude: 129.3114,
    },
    {
      id: 'sejong',
      placeName: '세종특별자치시',
      addressName: '세종특별자치시',
      roadAddressName: '세종특별자치시',
      categoryName: '지역',
      latitude: 36.4800,
      longitude: 127.2890,
    },
    // 경기도 주요 도시
    {
      id: 'suwon',
      placeName: '수원시',
      addressName: '경기도 수원시',
      roadAddressName: '경기도 수원시',
      categoryName: '지역',
      latitude: 37.2636,
      longitude: 127.0286,
    },
    {
      id: 'yongin',
      placeName: '용인시',
      addressName: '경기도 용인시',
      roadAddressName: '경기도 용인시',
      categoryName: '지역',
      latitude: 37.2411,
      longitude: 127.1776,
    },
    {
      id: 'seongnam',
      placeName: '성남시',
      addressName: '경기도 성남시',
      roadAddressName: '경기도 성남시',
      categoryName: '지역',
      latitude: 37.4201,
      longitude: 127.1265,
    },
    {
      id: 'goyang',
      placeName: '고양시',
      addressName: '경기도 고양시',
      roadAddressName: '경기도 고양시',
      categoryName: '지역',
      latitude: 37.6584,
      longitude: 126.8320,
    },
    {
      id: 'bucheon',
      placeName: '부천시',
      addressName: '경기도 부천시',
      roadAddressName: '경기도 부천시',
      categoryName: '지역',
      latitude: 37.5034,
      longitude: 126.7660,
    },
    // 강원도
    {
      id: 'chuncheon',
      placeName: '춘천시',
      addressName: '강원도 춘천시',
      roadAddressName: '강원도 춘천시',
      categoryName: '지역',
      latitude: 37.8813,
      longitude: 127.7298,
    },
    {
      id: 'wonju',
      placeName: '원주시',
      addressName: '강원도 원주시',
      roadAddressName: '강원도 원주시',
      categoryName: '지역',
      latitude: 37.3422,
      longitude: 127.9202,
    },
    // 충청도
    {
      id: 'cheonan',
      placeName: '천안시',
      addressName: '충청남도 천안시',
      roadAddressName: '충청남도 천안시',
      categoryName: '지역',
      latitude: 36.8151,
      longitude: 127.1139,
    },
    {
      id: 'cheongju',
      placeName: '청주시',
      addressName: '충청북도 청주시',
      roadAddressName: '충청북도 청주시',
      categoryName: '지역',
      latitude: 36.6424,
      longitude: 127.4890,
    },
    // 전라도
    {
      id: 'jeonju',
      placeName: '전주시',
      addressName: '전라북도 전주시',
      roadAddressName: '전라북도 전주시',
      categoryName: '지역',
      latitude: 35.8242,
      longitude: 127.1480,
    },
    {
      id: 'yeosu',
      placeName: '여수시',
      addressName: '전라남도 여수시',
      roadAddressName: '전라남도 여수시',
      categoryName: '지역',
      latitude: 34.7604,
      longitude: 127.6622,
    },
    // 경상도
    {
      id: 'changwon',
      placeName: '창원시',
      addressName: '경상남도 창원시',
      roadAddressName: '경상남도 창원시',
      categoryName: '지역',
      latitude: 35.2281,
      longitude: 128.6811,
    },
    {
      id: 'jinju',
      placeName: '진주시',
      addressName: '경상남도 진주시',
      roadAddressName: '경상남도 진주시',
      categoryName: '지역',
      latitude: 35.1806,
      longitude: 128.1077,
    },
    {
      id: 'pohang',
      placeName: '포항시',
      addressName: '경상북도 포항시',
      roadAddressName: '경상북도 포항시',
      categoryName: '지역',
      latitude: 36.0190,
      longitude: 129.3435,
    },
    {
      id: 'gyeongju',
      placeName: '경주시',
      addressName: '경상북도 경주시',
      roadAddressName: '경상북도 경주시',
      categoryName: '지역',
      latitude: 35.8562,
      longitude: 129.2247,
    },
    // 제주도
    {
      id: 'jeju',
      placeName: '제주시',
      addressName: '제주특별자치도 제주시',
      roadAddressName: '제주특별자치도 제주시',
      categoryName: '지역',
      latitude: 33.4996,
      longitude: 126.5312,
    },
    {
      id: 'seogwipo',
      placeName: '서귀포시',
      addressName: '제주특별자치도 서귀포시',
      roadAddressName: '제주특별자치도 서귀포시',
      categoryName: '지역',
      latitude: 33.2541,
      longitude: 126.5601,
    },
  ];

  // 쿼리에 따라 필터링
  if (query && query.trim().length > 0) {
    return cities.filter(city => 
      city.placeName.includes(query) || 
      city.addressName.includes(query)
    );
  }

  return cities;
}

// API 키가 없을 때 사용할 기본 주소
function getFallbackAddress(lat, lon) {
  // 한국 주요 지역 판별 로직
  console.log(`[KakaoService] Fallback address for coordinates: ${lat}, ${lon}`);
  console.log(`[KakaoService] Checking region for lat: ${lat}, lon: ${lon}`);
  
  // 서울특별시
  if (lat >= 37.4 && lat <= 37.7 && lon >= 126.7 && lon <= 127.2) {
    return {
      id: 'seoul',
      placeName: '서울특별시',
      addressName: '서울특별시',
      roadAddressName: '서울특별시',
      categoryName: '지역',
      latitude: lat,
      longitude: lon,
    };
  }
  
  // 수원시 (실제 중심 좌표 기반: 37.2636, 126.9986)
  if (lat >= 37.20 && lat <= 37.32 && lon >= 126.95 && lon <= 127.05) {
    console.log(`[KakaoService] Matched Suwon: lat=${lat}, lon=${lon}`);
    return {
      id: 'suwon',
      placeName: '수원시',
      addressName: '경기도 수원시',
      roadAddressName: '경기도 수원시',
      categoryName: '지역',
      latitude: lat,
      longitude: lon,
    };
  }
  
  // 경기도 (수원시 제외)
  if (lat >= 37.0 && lat <= 38.3 && lon >= 126.0 && lon <= 127.5) {
    return {
      id: 'gyeonggi',
      placeName: '경기도',
      addressName: '경기도',
      roadAddressName: '경기도',
      categoryName: '지역',
      latitude: lat,
      longitude: lon,
    };
  }
  
  // 부산광역시
  if (lat >= 35.0 && lat <= 35.4 && lon >= 128.8 && lon <= 129.3) {
    return {
      id: 'busan',
      placeName: '부산광역시',
      addressName: '부산광역시',
      roadAddressName: '부산광역시',
      categoryName: '지역',
      latitude: lat,
      longitude: lon,
    };
  }
  
  // 대구광역시
  if (lat >= 35.7 && lat <= 36.0 && lon >= 128.4 && lon <= 128.8) {
    return {
      id: 'daegu',
      placeName: '대구광역시',
      addressName: '대구광역시',
      roadAddressName: '대구광역시',
      categoryName: '지역',
      latitude: lat,
      longitude: lon,
    };
  }
  
  // 인천광역시
  if (lat >= 37.2 && lat <= 37.7 && lon >= 126.4 && lon <= 126.8) {
    return {
      id: 'incheon',
      placeName: '인천광역시',
      addressName: '인천광역시',
      roadAddressName: '인천광역시',
      categoryName: '지역',
      latitude: lat,
      longitude: lon,
    };
  }
  
  // 광주광역시
  if (lat >= 35.0 && lat <= 35.3 && lon >= 126.7 && lon <= 127.0) {
    return {
      id: 'gwangju',
      placeName: '광주광역시',
      addressName: '광주광역시',
      roadAddressName: '광주광역시',
      categoryName: '지역',
      latitude: lat,
      longitude: lon,
    };
  }
  
  // 대전광역시
  if (lat >= 36.2 && lat <= 36.5 && lon >= 127.2 && lon <= 127.6) {
    return {
      id: 'daejeon',
      placeName: '대전광역시',
      addressName: '대전광역시',
      roadAddressName: '대전광역시',
      categoryName: '지역',
      latitude: lat,
      longitude: lon,
    };
  }
  
  // 울산광역시
  if (lat >= 35.4 && lat <= 35.7 && lon >= 129.1 && lon <= 129.4) {
    return {
      id: 'ulsan',
      placeName: '울산광역시',
      addressName: '울산광역시',
      roadAddressName: '울산광역시',
      categoryName: '지역',
      latitude: lat,
      longitude: lon,
    };
  }
  
  // 세종특별자치시
  if (lat >= 36.4 && lat <= 36.7 && lon >= 127.1 && lon <= 127.4) {
    return {
      id: 'sejong',
      placeName: '세종특별자치시',
      addressName: '세종특별자치시',
      roadAddressName: '세종특별자치시',
      categoryName: '지역',
      latitude: lat,
      longitude: lon,
    };
  }
  
  // 성남시
  if (lat >= 37.4 && lat <= 37.5 && lon >= 127.1 && lon <= 127.2) {
    return {
      id: 'seongnam',
      placeName: '성남시',
      addressName: '경기도 성남시',
      roadAddressName: '경기도 성남시',
      categoryName: '지역',
      latitude: lat,
      longitude: lon,
    };
  }
  
  // 고양시
  if (lat >= 37.6 && lat <= 37.7 && lon >= 126.7 && lon <= 126.9) {
    return {
      id: 'goyang',
      placeName: '고양시',
      addressName: '경기도 고양시',
      roadAddressName: '경기도 고양시',
      categoryName: '지역',
      latitude: lat,
      longitude: lon,
    };
  }
  
  // 용인시 (실제 중심 좌표 기반: 37.2411, 127.1776)
  if (lat >= 37.10 && lat <= 37.40 && lon >= 127.05 && lon <= 127.30) {
    console.log(`[KakaoService] Matched Yongin: lat=${lat}, lon=${lon}`);
    return {
      id: 'yongin',
      placeName: '용인시',
      addressName: '경기도 용인시',
      roadAddressName: '경기도 용인시',
      categoryName: '지역',
      latitude: lat,
      longitude: lon,
    };
  }
  
  // 안양시
  if (lat >= 37.3 && lat <= 37.4 && lon >= 126.9 && lon <= 127.0) {
    return {
      id: 'anyang',
      placeName: '안양시',
      addressName: '경기도 안양시',
      roadAddressName: '경기도 안양시',
      categoryName: '지역',
      latitude: lat,
      longitude: lon,
    };
  }
  
  // 기타 한국 지역
  if (lat >= 33.0 && lat <= 38.7 && lon >= 124.0 && lon <= 131.9) {
    return {
      id: 'korea_other',
      placeName: '한국',
      addressName: '한국',
      roadAddressName: '한국',
      categoryName: '지역',
      latitude: lat,
      longitude: lon,
    };
  }
  
  return {
    id: 'unknown',
    placeName: '알 수 없는 지역',
    addressName: '알 수 없는 지역',
    roadAddressName: '알 수 없는 지역',
    categoryName: '지역',
    latitude: lat,
    longitude: lon,
  };
}
