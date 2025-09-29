/**
 * 개인화 체감온도 계산 간단 테스트
 */

const API_BASE = 'http://localhost:4000/api';

async function testPersonalizedWeather() {
  console.log('🧪 개인화 체감온도 계산 테스트 시작\n');

  try {
    // 1. 기본 날씨 조회 (개인화 없음)
    console.log('1️⃣ 기본 체감온도 조회...');
    const basicResponse = await fetch(`${API_BASE}/weather/current?lat=37.5665&lon=126.9780`);
    
    if (!basicResponse.ok) {
      throw new Error(`기본 날씨 조회 실패: ${basicResponse.status}`);
    }
    
    const basicWeather = await basicResponse.json();
    console.log(`✅ 기본 체감온도: ${basicWeather.temperature}°C → ${basicWeather.feelsLike}°C`);

    // 2. 온도 설정 생성 (테스트용)
    console.log('\n2️⃣ 테스트 사용자 온도 설정 생성...');
    const testUserId = 'test-user-' + Date.now();
    
    // Firebase ID 토큰이 필요하므로, 실제로는 인증된 사용자만 가능
    // 여기서는 API가 인증 없이도 작동하는지 확인
    console.log('⚠️  실제 테스트를 위해서는 Firebase 인증이 필요합니다.');
    console.log('   Flutter 앱에서 로그인 후 테스트해주세요.');

    // 3. API 응답 구조 확인
    console.log('\n3️⃣ API 응답 구조 확인...');
    console.log('📊 날씨 데이터 구조:');
    console.log(`   - 온도: ${basicWeather.temperature}°C`);
    console.log(`   - 체감온도: ${basicWeather.feelsLike}°C`);
    console.log(`   - 습도: ${basicWeather.humidity}%`);
    console.log(`   - 풍속: ${basicWeather.windSpeed}km/h`);
    console.log(`   - 조건: ${basicWeather.condition}`);

    console.log('\n✅ 기본 API 테스트 완료!');
    console.log('💡 개인화 테스트를 위해서는 Flutter 앱에서 로그인 후 확인해주세요.');

  } catch (error) {
    console.error('❌ 테스트 중 오류 발생:', error.message);
    
    if (error.message.includes('fetch')) {
      console.log('💡 백엔드 서버가 실행 중인지 확인해주세요.');
    }
  }
}

// 테스트 실행
testPersonalizedWeather();
