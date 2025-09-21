// 날씨 정보를 담을 클래스
class WeatherData {
  final double temperature;
  final double windSpeed;
  final double feelsLikeTemperature; // 체감온도

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.feelsLikeTemperature,
  });
}