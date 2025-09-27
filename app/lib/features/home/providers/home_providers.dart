import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/weather_provider.dart';
import '../../../providers/recommendation_provider.dart';

final weatherProvider = StateNotifierProvider<WeatherProvider, WeatherState>((ref) {
  return WeatherProvider();
});

final recommendationProvider = StateNotifierProvider<RecommendationProvider, RecommendationState>((ref) {
  return RecommendationProvider();
});

// Home-specific providers
final homeProvider = StateNotifierProvider<WeatherProvider, WeatherState>((ref) {
  return WeatherProvider();
});

final isLoadingProvider = Provider((ref) {
  final weatherState = ref.watch(weatherProvider);
  final recommendationState = ref.watch(recommendationProvider);
  return weatherState.isLoading || recommendationState.isLoading;
});
