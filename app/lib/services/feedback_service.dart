import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/feedback_model.dart';
import '../models/weather_model.dart';
import '../models/user_model.dart';

class FeedbackService {
  static const String _baseUrl = 'http://localhost:3000';

  // Submit feedback
  static Future<bool> submitFeedback({
    required String userId,
    required String outfitId,
    required FeedbackType feedbackType,
    required WeatherModel weather,
    required UserModel user,
    String comment = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/feedback'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'outfitId': outfitId,
          'feedbackType': feedbackType.name,
          'comment': comment,
          'weather': weather.toJson(),
          'user': user.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to submit feedback: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error submitting feedback: $e');
      return false;
    }
  }

  // Get feedback statistics
  static Future<Map<String, dynamic>> getFeedbackStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/feedback/stats/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Return mock data if API fails
        return _getMockFeedbackStats();
      }
    } catch (e) {
      print('Error fetching feedback stats: $e');
      return _getMockFeedbackStats();
    }
  }

  // Get user feedback history
  static Future<List<FeedbackModel>> getUserFeedback(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/feedback/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseFeedbackList(data['feedback'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching user feedback: $e');
      return [];
    }
  }

  // Parse feedback list from backend
  static List<FeedbackModel> _parseFeedbackList(List<dynamic> feedbackData) {
    return feedbackData.map((item) => FeedbackModel(
      id: item['id'] ?? '',
      userId: item['userId'] ?? '',
      outfitId: item['outfitId'] ?? '',
      type: _parseFeedbackType(item['feedbackType'] ?? 'general'),
      rating: item['rating'] ?? 5,
      comment: item['comment'] ?? '',
      timestamp: DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now(),
      metadata: Map<String, dynamic>.from(item['metadata'] ?? {}),
    )).toList();
  }

  // Parse feedback type from string
  static FeedbackType _parseFeedbackType(String feedbackString) {
    switch (feedbackString.toLowerCase()) {
      case 'hot':
        return FeedbackType.hot;
      case 'cold':
        return FeedbackType.cold;
      case 'perfect':
        return FeedbackType.perfect;
      case 'too_formal':
        return FeedbackType.tooFormal;
      case 'too_casual':
        return FeedbackType.tooCasual;
      case 'temperature':
        return FeedbackType.temperature;
      case 'style':
        return FeedbackType.style;
      case 'fit':
        return FeedbackType.fit;
      case 'occasion':
        return FeedbackType.occasion;
      default:
        return FeedbackType.general;
    }
  }

  // Mock feedback statistics
  static Map<String, dynamic> _getMockFeedbackStats() {
    return {
      'totalFeedback': 15,
      'averageRating': 4.2,
      'feedbackCounts': {
        'hot': 3,
        'cold': 2,
        'perfect': 8,
        'too_formal': 1,
        'too_casual': 1,
      },
      'improvementSuggestions': [
        '더 정확한 추천을 위해 피드백을 계속 남겨주세요',
        '체온 민감도 테스트를 다시 받아보세요',
        '다양한 상황에서의 옷차림을 시도해보세요',
      ],
    };
  }

  // Get feedback type display name
  static String getFeedbackTypeDisplayName(FeedbackType type) {
    switch (type) {
      case FeedbackType.hot:
        return '더웠어요';
      case FeedbackType.cold:
        return '추웠어요';
      case FeedbackType.perfect:
        return '적당했어요';
      case FeedbackType.tooFormal:
        return '너무 정장';
      case FeedbackType.tooCasual:
        return '너무 캐주얼';
      case FeedbackType.temperature:
        return '온도 관련';
      case FeedbackType.style:
        return '스타일 관련';
      case FeedbackType.fit:
        return '핏 관련';
      case FeedbackType.occasion:
        return '상황 관련';
      case FeedbackType.general:
        return '일반';
    }
  }

  // Get feedback type icon
  static String getFeedbackTypeIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.hot:
        return '🌡️';
      case FeedbackType.cold:
        return '❄️';
      case FeedbackType.perfect:
        return '✅';
      case FeedbackType.tooFormal:
        return '👔';
      case FeedbackType.tooCasual:
        return '👕';
      case FeedbackType.temperature:
        return '🌡️';
      case FeedbackType.style:
        return '👗';
      case FeedbackType.fit:
        return '📏';
      case FeedbackType.occasion:
        return '🎯';
      case FeedbackType.general:
        return '💬';
    }
  }
}