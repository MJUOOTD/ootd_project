import 'package:flutter_riverpod/flutter_riverpod.dart';

// Weather data model
class WeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String conditionIcon;
  final double humidity;
  final double windSpeed;
  final String windDirection;

  const WeatherData({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.conditionIcon,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
  });

  WeatherData copyWith({
    String? location,
    double? temperature,
    double? feelsLike,
    String? condition,
    String? conditionIcon,
    double? humidity,
    double? windSpeed,
    String? windDirection,
  }) {
    return WeatherData(
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      condition: condition ?? this.condition,
      conditionIcon: conditionIcon ?? this.conditionIcon,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
    );
  }
}

// Outfit recommendation model
class OutfitRecommendationData {
  final String top;
  final String bottom;
  final String outer;
  final String topImage;
  final String bottomImage;
  final String outerImage;
  final String description;
  final double confidence;

  const OutfitRecommendationData({
    required this.top,
    required this.bottom,
    required this.outer,
    required this.topImage,
    required this.bottomImage,
    required this.outerImage,
    required this.description,
    required this.confidence,
  });
}

// Weather message model
class WeatherMessage {
  final String message;
  final String icon;
  final String type; // 'warning', 'info', 'tip'

  const WeatherMessage({
    required this.message,
    required this.icon,
    required this.type,
  });
}

// Mock data
class MockData {
  static const List<WeatherData> weatherOptions = [
    WeatherData(
      location: '서울시 강남구',
      temperature: 22.0,
      feelsLike: 25.0,
      condition: '맑음',
      conditionIcon: '☀️',
      humidity: 65.0,
      windSpeed: 3.2,
      windDirection: '남동',
    ),
    WeatherData(
      location: '서울시 강남구',
      temperature: 18.0,
      feelsLike: 16.0,
      condition: '흐림',
      conditionIcon: '☁️',
      humidity: 80.0,
      windSpeed: 5.5,
      windDirection: '북서',
    ),
    WeatherData(
      location: '서울시 강남구',
      temperature: 15.0,
      feelsLike: 12.0,
      condition: '비',
      conditionIcon: '🌧️',
      humidity: 90.0,
      windSpeed: 8.0,
      windDirection: '서',
    ),
  ];

  static const List<OutfitRecommendationData> outfitOptions = [
    OutfitRecommendationData(
      top: '반팔 티셔츠',
      bottom: '청바지',
      outer: '가벼운 자켓',
      topImage: '👕',
      bottomImage: '👖',
      outerImage: '🧥',
      description: '따뜻한 날씨에 적합한 가벼운 코디',
      confidence: 0.85,
    ),
    OutfitRecommendationData(
      top: '긴팔 셔츠',
      bottom: '슬랙스',
      outer: '트렌치코트',
      topImage: '👔',
      bottomImage: '👔',
      outerImage: '🧥',
      description: '시원한 날씨에 적합한 세련된 코디',
      confidence: 0.92,
    ),
    OutfitRecommendationData(
      top: '니트 스웨터',
      bottom: '데님 팬츠',
      outer: '우비',
      topImage: '🧶',
      bottomImage: '👖',
      outerImage: '🧥',
      description: '비 오는 날에 적합한 실용적인 코디',
      confidence: 0.78,
    ),
  ];

  static const List<WeatherMessage> messageOptions = [
    WeatherMessage(
      message: '우산을 꼭 챙기세요! 오늘은 비가 올 예정입니다.',
      icon: '☂️',
      type: 'warning',
    ),
    WeatherMessage(
      message: '바람이 강하니 겉옷을 챙기세요.',
      icon: '💨',
      type: 'info',
    ),
    WeatherMessage(
      message: '자외선이 강하니 선크림을 발라주세요.',
      icon: '☀️',
      type: 'tip',
    ),
    WeatherMessage(
      message: '완벽한 날씨네요! 가벼운 옷차림이 좋겠어요.',
      icon: '😊',
      type: 'info',
    ),
  ];
}

// Home state
class HomeState {
  final bool isLoading;
  final WeatherData? weather;
  final OutfitRecommendationData? outfitRecommendation;
  final WeatherMessage? weatherMessage;
  final DateTime? lastUpdated;
  final String? error;

  const HomeState({
    required this.isLoading,
    this.weather,
    this.outfitRecommendation,
    this.weatherMessage,
    this.lastUpdated,
    this.error,
  });

  factory HomeState.initial() {
    return const HomeState(isLoading: false);
  }

  HomeState copyWith({
    bool? isLoading,
    WeatherData? weather,
    OutfitRecommendationData? outfitRecommendation,
    WeatherMessage? weatherMessage,
    DateTime? lastUpdated,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      weather: weather ?? this.weather,
      outfitRecommendation: outfitRecommendation ?? this.outfitRecommendation,
      weatherMessage: weatherMessage ?? this.weatherMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      error: error ?? this.error,
    );
  }
}

// Home state notifier
class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() => HomeState.initial();

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Randomly select mock data
    final random = DateTime.now().millisecondsSinceEpoch % MockData.weatherOptions.length;
    final weather = MockData.weatherOptions[random];
    final outfit = MockData.outfitOptions[random];
    final message = MockData.messageOptions[random];
    
    state = state.copyWith(
      isLoading: false,
      weather: weather,
      outfitRecommendation: outfit,
      weatherMessage: message,
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> refresh() async {
    await loadData();
  }
}

// Providers
final homeProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});

final weatherProvider = Provider<WeatherData?>((ref) {
  return ref.watch(homeProvider).weather;
});

final outfitRecommendationProvider = Provider<OutfitRecommendationData?>((ref) {
  return ref.watch(homeProvider).outfitRecommendation;
});

final weatherMessageProvider = Provider<WeatherMessage?>((ref) {
  return ref.watch(homeProvider).weatherMessage;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(homeProvider).isLoading;
});