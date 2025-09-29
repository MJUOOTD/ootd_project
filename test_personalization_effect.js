/**
 * 개인화 체감온도 효과 테스트
 */

const API_BASE = 'http://localhost:4000/api';

async function testPersonalizationEffect() {
  console.log('🧪 개인화 체감온도 효과 테스트\n');

  try {
    // 1. 기본 날씨 조회
    console.log('1️⃣ 기본 체감온도 조회...');
    const basicResponse = await fetch(`${API_BASE}/weather/current?lat=37.5665&lon=126.9780`);
    const basicWeather = await basicResponse.json();
    console.log(`✅ 기본 체감온도: ${basicWeather.temperature}°C → ${basicWeather.feelsLike}°C`);

    // 2. 개인화 효과 시뮬레이션
    console.log('\n2️⃣ 개인화 효과 시뮬레이션...');
    
    // 시뮬레이션: 추위에 민감한 여성, 30세, 활동량 적음
    const simulatedSettings = {
      temperatureSensitivity: 1.3,  // 30% 더 민감
      coldTolerance: 'low',         // 추위에 민감
      heatTolerance: 'normal',
      age: 30,                      // 30세
      gender: 'female',             // 여성
      activityLevel: 'low'          // 활동량 적음
    };

    console.log('📊 시뮬레이션 설정:');
    console.log(`   - 온도 감도: ${simulatedSettings.temperatureSensitivity}x`);
    console.log(`   - 추위 감수성: ${simulatedSettings.coldTolerance}`);
    console.log(`   - 나이: ${simulatedSettings.age}세`);
    console.log(`   - 성별: ${simulatedSettings.gender}`);
    console.log(`   - 활동량: ${simulatedSettings.activityLevel}`);

    // 3. 개인화 보정값 계산 시뮬레이션
    console.log('\n3️⃣ 개인화 보정값 계산...');
    
    // 나이 보정 (30세): 0°C
    const ageAdj = 0;
    
    // 성별 보정 (여성): +0.8°C
    const genderAdj = 0.8;
    
    // 활동량 보정 (낮음): +1.5°C
    const activityAdj = 1.5;
    
    // 추위/더위 감수성 보정 (22°C는 일반 조건): 0°C
    const toleranceAdj = 0;
    
    const totalAdjustment = ageAdj + genderAdj + activityAdj + toleranceAdj;
    const personalizedFeelsLike = (22 + totalAdjustment) * 1.3;
    
    console.log(`   - 나이 보정: ${ageAdj}°C`);
    console.log(`   - 성별 보정: ${genderAdj}°C`);
    console.log(`   - 활동량 보정: ${activityAdj}°C`);
    console.log(`   - 감수성 보정: ${toleranceAdj}°C`);
    console.log(`   - 총 보정: ${totalAdjustment}°C`);
    console.log(`   - 최종 체감온도: (22 + ${totalAdjustment}) × 1.3 = ${personalizedFeelsLike.toFixed(1)}°C`);

    console.log('\n📈 예상 개인화 효과:');
    console.log(`   기본: 22°C → 22°C`);
    console.log(`   개인화: 22°C → ${personalizedFeelsLike.toFixed(1)}°C`);
    console.log(`   차이: +${(personalizedFeelsLike - 22).toFixed(1)}°C`);

    console.log('\n💡 실제 테스트를 위해서는:');
    console.log('   1. Flutter 앱에서 로그인');
    console.log('   2. 온도 설정에서 개인화 값 조정');
    console.log('   3. 메인 화면에서 체감온도 변화 확인');

  } catch (error) {
    console.error('❌ 테스트 중 오류 발생:', error.message);
  }
}

// 테스트 실행
testPersonalizationEffect();
