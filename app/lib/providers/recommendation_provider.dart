import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/outfit_model.dart';
import '../models/user_model.dart';
import '../models/weather_model.dart';
import '../services/recommendation_service.dart';

class RecommendationState {
  final List<OutfitRecommendation> recommendations;
  final OutfitRecommendation? selectedRecommendation;
  final bool isLoading;
  final String? error;
  final String currentOccasion;

  RecommendationState({
    this.recommendations = const [],
    this.selectedRecommendation,
    this.isLoading = false,
    this.error,
    this.currentOccasion = 'casual',
  });

  bool get hasRecommendations => recommendations.isNotEmpty;

  RecommendationState copyWith({
    List<OutfitRecommendation>? recommendations,
    OutfitRecommendation? selectedRecommendation,
    bool? isLoading,
    String? error,
    String? currentOccasion,
  }) {
    return RecommendationState(
      recommendations: recommendations ?? this.recommendations,
      selectedRecommendation: selectedRecommendation ?? this.selectedRecommendation,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentOccasion: currentOccasion ?? this.currentOccasion,
    );
  }
}

class RecommendationProvider extends StateNotifier<RecommendationState> {
  RecommendationProvider() : super(RecommendationState());

  // Generate outfit recommendations based on weather and user
  Future<void> generateRecommendations({
    required WeatherModel weather,
    required UserModel user,
    String? occasion,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final currentOccasion = occasion ?? 'casual';
      
      final recommendations = await RecommendationService.getRecommendations(
        weather: weather,
        user: user,
        occasion: currentOccasion,
        limit: 5,
      );

      // Select first recommendation by default
      OutfitRecommendation? selectedRecommendation;
      if (recommendations.isNotEmpty) {
        selectedRecommendation = recommendations.first;
      }

      state = state.copyWith(
        recommendations: recommendations,
        selectedRecommendation: selectedRecommendation,
        currentOccasion: currentOccasion,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to generate recommendations: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // Select a specific recommendation
  void selectRecommendation(OutfitRecommendation recommendation) {
    state = state.copyWith(selectedRecommendation: recommendation);
  }

  // Get next recommendation
  void nextRecommendation() {
    if (state.recommendations.isEmpty) return;

    final currentIndex = state.recommendations.indexOf(state.selectedRecommendation!);
    final nextIndex = (currentIndex + 1) % state.recommendations.length;
    state = state.copyWith(selectedRecommendation: state.recommendations[nextIndex]);
  }

  // Get previous recommendation
  void previousRecommendation() {
    if (state.recommendations.isEmpty) return;

    final currentIndex = state.recommendations.indexOf(state.selectedRecommendation!);
    final prevIndex = currentIndex > 0 ? currentIndex - 1 : state.recommendations.length - 1;
    state = state.copyWith(selectedRecommendation: state.recommendations[prevIndex]);
  }

  // Filter recommendations by occasion
  Future<void> filterByOccasion(String occasion, {
    required WeatherModel weather,
    required UserModel user,
  }) async {
    if (state.currentOccasion == occasion) return;

    await generateRecommendations(
      weather: weather,
      user: user,
      occasion: occasion,
    );
  }

  // Get recommendations for different occasions
  Map<String, OutfitRecommendation> getOccasionRecommendations() {
    Map<String, OutfitRecommendation> occasionRecs = {};
    
    // Group recommendations by occasion
    for (var rec in state.recommendations) {
      if (!occasionRecs.containsKey(rec.outfit.occasion)) {
        occasionRecs[rec.outfit.occasion] = rec;
      }
    }
    
    return occasionRecs;
  }

  // Get outfit confidence level as a percentage
  int getConfidencePercentage() {
    if (state.selectedRecommendation == null) return 0;
    return (state.selectedRecommendation!.confidence * 100).round();
  }

  // Get outfit rating
  double getOutfitRating() {
    return state.selectedRecommendation?.outfit.rating ?? 0.0;
  }

  // Get outfit tips
  List<String> getOutfitTips() {
    return state.selectedRecommendation?.tips ?? [];
  }

  // Get recommendation reason
  String getRecommendationReason() {
    return state.selectedRecommendation?.reason ?? '';
  }

  // Clear recommendations
  void clearRecommendations() {
    state = RecommendationState();
  }

  // Refresh recommendations
  Future<void> refreshRecommendations({
    required WeatherModel weather,
    required UserModel user,
  }) async {
    await generateRecommendations(
      weather: weather,
      user: user,
      occasion: state.currentOccasion,
    );
  }
}

final recommendationProvider = StateNotifierProvider<RecommendationProvider, RecommendationState>((ref) {
  return RecommendationProvider();
});
