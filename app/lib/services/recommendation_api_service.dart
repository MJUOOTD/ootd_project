import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../models/outfit_model.dart';
import '../models/user_model.dart';
import '../models/weather_model.dart';
import 'network/base_url.dart';

class RecommendationApiService {
  static const Duration _timeout = Duration(seconds: 8);
  static final String _defaultBaseUrl = getDefaultBackendBaseUrl();
  final String baseUrl;

  RecommendationApiService({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl;

  Future<OutfitRecommendation> getServerRecommendation({
    required WeatherModel weather,
    required UserModel user,
    String occasion = 'daily',
  }) async {
    final lat = weather.location.latitude;
    final lon = weather.location.longitude;
    final userId = user.id.isNotEmpty ? user.id : 'guest';
    final uri = Uri.parse(
      '$baseUrl/api/recommendations?userId=$userId&lat=$lat&lon=$lon&situation=$occasion',
    );

    final resp = await http.get(uri).timeout(_timeout);
    if (resp.statusCode != 200) {
      throw Exception('Recommendation API error: ${resp.statusCode}');
    }

    final Map<String, dynamic> jsonBody = json.decode(resp.body) as Map<String, dynamic>;
    return _mapServerResponseToOutfitRecommendation(jsonBody);
  }

  OutfitRecommendation _mapServerResponseToOutfitRecommendation(Map<String, dynamic> j) {
    final weather = WeatherModel.fromJson(j['weather'] ?? {});
    final rec = (j['recommendedOutfit'] ?? {}) as Map<String, dynamic>;
    final List<dynamic> acc = (rec['accessories'] is List)
        ? (rec['accessories'] as List)
        : (rec['accessories'] == null || rec['accessories'] == ''
            ? []
            : [rec['accessories']]);

    final List<String> items = [
      if ((rec['top'] ?? '').toString().isNotEmpty) rec['top'].toString(),
      if ((rec['bottom'] ?? '').toString().isNotEmpty) rec['bottom'].toString(),
      if ((rec['outer'] ?? '').toString().isNotEmpty && rec['outer'] != '없음') rec['outer'].toString(),
      if ((rec['shoes'] ?? '').toString().isNotEmpty) rec['shoes'].toString(),
      ...acc.map((e) => e.toString()),
    ];

    final outfit = Outfit(
      title: '오늘의 코디',
      description: '날씨와 상황에 맞춘 추천',
      occasion: (j['situation'] ?? 'daily').toString(),
      rating: 4.0,
      items: items,
      tags: [],
      imageUrl: '',
    );

    return OutfitRecommendation(
      id: 'server_${DateTime.now().millisecondsSinceEpoch}',
      outfit: outfit,
      weather: weather,
      confidence: 0.9,
      reason: '체감온도와 날씨 조건을 반영한 추천',
      tips: [],
    );
  }
}



