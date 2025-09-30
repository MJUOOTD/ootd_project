import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/outfit_model.dart';
import '../models/user_model.dart';
import '../models/weather_model.dart';
import '../services/recommendation_service.dart';
import '../services/recommendation_api_service.dart';

class RecommendationProvider with ChangeNotifier {
  List<OutfitRecommendation> _recommendations = [];
  OutfitRecommendation? _selectedRecommendation;
  bool _isLoading = false;
  String? _error;
  String _currentOccasion = 'casual';

  List<OutfitRecommendation> get recommendations => _recommendations;
  OutfitRecommendation? get selectedRecommendation => _selectedRecommendation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentOccasion => _currentOccasion;
  bool get hasRecommendations => _recommendations.isNotEmpty;

  // Generate outfit recommendations based on weather and user
  Future<void> generateRecommendations({
    required WeatherModel weather,
    required UserModel user,
    String? occasion,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentOccasion = occasion ?? 'daily';

      // 1) 서버 추천 우선 시도
      try {
        final api = RecommendationApiService();
        final serverRec = await api.getServerRecommendation(
          weather: weather,
          user: user,
          occasion: _currentOccasion,
        );
        _recommendations = [serverRec];
      } catch (_) {
        // 2) 실패 시 로컬 규칙 폴백
        _recommendations = await RecommendationService.getRecommendations(
          weather: weather,
          user: user,
          occasion: _currentOccasion,
          limit: 5,
        );
      }

      // Select first recommendation by default
      if (_recommendations.isNotEmpty) {
        _selectedRecommendation = _recommendations.first;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to generate recommendations: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Select a specific recommendation
  void selectRecommendation(OutfitRecommendation recommendation) {
    _selectedRecommendation = recommendation;
    notifyListeners();
  }

  // Get next recommendation
  void nextRecommendation() {
    if (_recommendations.isEmpty) return;

    final currentIndex = _recommendations.indexOf(_selectedRecommendation!);
    final nextIndex = (currentIndex + 1) % _recommendations.length;
    _selectedRecommendation = _recommendations[nextIndex];
    notifyListeners();
  }

  // Get previous recommendation
  void previousRecommendation() {
    if (_recommendations.isEmpty) return;

    final currentIndex = _recommendations.indexOf(_selectedRecommendation!);
    final prevIndex = currentIndex > 0 ? currentIndex - 1 : _recommendations.length - 1;
    _selectedRecommendation = _recommendations[prevIndex];
    notifyListeners();
  }

  // Filter recommendations by occasion
  Future<void> filterByOccasion(String occasion, {
    required WeatherModel weather,
    required UserModel user,
  }) async {
    if (_currentOccasion == occasion) return;

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
    for (var rec in _recommendations) {
      if (!occasionRecs.containsKey(rec.outfit.occasion)) {
        occasionRecs[rec.outfit.occasion] = rec;
      }
    }
    
    return occasionRecs;
  }

  // Get outfit confidence level as a percentage
  int getConfidencePercentage() {
    if (_selectedRecommendation == null) return 0;
    return (_selectedRecommendation!.confidence * 100).round();
  }

  // Get outfit rating
  double getOutfitRating() {
    return _selectedRecommendation?.outfit.rating ?? 0.0;
  }

  // Get outfit tips
  List<String> getOutfitTips() {
    return _selectedRecommendation?.tips ?? [];
  }

  // Get recommendation reason
  String getRecommendationReason() {
    return _selectedRecommendation?.reason ?? '';
  }

  // Clear recommendations
  void clearRecommendations() {
    _recommendations.clear();
    _selectedRecommendation = null;
    _clearError();
    notifyListeners();
  }

  // Refresh recommendations
  Future<void> refreshRecommendations({
    required WeatherModel weather,
    required UserModel user,
  }) async {
    await generateRecommendations(
      weather: weather,
      user: user,
      occasion: _currentOccasion,
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

final recommendationProvider = ChangeNotifierProvider((ref) => RecommendationProvider());
