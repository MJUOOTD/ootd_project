// 한국의 4계절 일출/일몰 시간 계산
function getSunriseSunsetTimes(month) {
  const times = {
    1: { sunrise: 7, sunset: 17 }, // 1월: 07:00-17:00
    2: { sunrise: 7, sunset: 18 }, // 2월: 07:00-18:00
    3: { sunrise: 6, sunset: 18 }, // 3월: 06:00-18:00
    4: { sunrise: 6, sunset: 19 }, // 4월: 06:00-19:00
    5: { sunrise: 5, sunset: 19 }, // 5월: 05:00-19:00
    6: { sunrise: 5, sunset: 20 }, // 6월: 05:00-20:00
    7: { sunrise: 5, sunset: 20 }, // 7월: 05:00-20:00
    8: { sunrise: 6, sunset: 19 }, // 8월: 06:00-19:00
    9: { sunrise: 6, sunset: 19 }, // 9월: 06:00-19:00
    10: { sunrise: 6, sunset: 17 }, // 10월: 06:00-17:00
    11: { sunrise: 7, sunset: 17 }, // 11월: 07:00-17:00
    12: { sunrise: 7, sunset: 17 }, // 12월: 07:00-17:00
  };
  
  return times[month] || { sunrise: 6, sunset: 18 }; // 기본값
}

// 시간대에 따른 해/달 아이콘 결정
function getTimeBasedIcon(condition, hour, month) {
  const { sunrise, sunset } = getSunriseSunsetTimes(month);
  
  // 모든 날씨 조건에 대해 낮/밤 구분
  // 일출 시간부터 일몰 시간 전까지가 낮
  const isDaytime = hour >= sunrise && hour < sunset;
  
  console.log(`Month: ${month}, Hour: ${hour}, Sunrise: ${sunrise}, Sunset: ${sunset}, IsDaytime: ${isDaytime}`);
  
  const iconMap = {
    'Clear': isDaytime ? '01d' : '01n', // 맑음: 해/달
    'Clouds': isDaytime ? '02d' : '02n', // 구름: 낮구름/밤구름
    'Rain': isDaytime ? '10d' : '10n', // 비: 낮비/밤비
    'Snow': isDaytime ? '13d' : '13n', // 눈: 낮눈/밤눈
    'Thunderstorm': isDaytime ? '11d' : '11n', // 뇌우: 낮뇌우/밤뇌우
    'Fog': isDaytime ? '50d' : '50n', // 안개: 낮안개/밤안개
  };
  
  const icon = iconMap[condition] || (isDaytime ? '02d' : '02n');
  console.log(`Selected icon: ${icon}`);
  
  return icon;
}

// 테스트
console.log('=== 9월 아이콘 테스트 ===');
console.log('12시:', getTimeBasedIcon('Clouds', 12, 9));
console.log('15시:', getTimeBasedIcon('Clouds', 15, 9));
console.log('21시:', getTimeBasedIcon('Clouds', 21, 9));
console.log('00시:', getTimeBasedIcon('Clouds', 0, 9));
