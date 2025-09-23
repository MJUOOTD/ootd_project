
class FeedbackModel {
  final String id;
  final String userId;
  final String outfitId;
  final FeedbackType type;
  final int rating; // 1-5 scale
  final String comment;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.outfitId,
    required this.type,
    required this.rating,
    required this.comment,
    required this.timestamp,
    required this.metadata,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      outfitId: json['outfitId'] ?? '',
      type: FeedbackType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FeedbackType.general,
      ),
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'outfitId': outfitId,
      'type': type.name,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

enum FeedbackType {
  temperature, // Too hot/cold feedback
  style,       // Style preference feedback
  fit,         // Fit/comfort feedback
  occasion,    // Occasion appropriateness feedback
  general,     // General feedback
}

class TemperatureFeedback extends FeedbackModel {
  final bool wasTooHot;
  final bool wasTooCold;
  final double actualTemperature;

  TemperatureFeedback({
    required super.id,
    required super.userId,
    required super.outfitId,
    required super.type,
    required super.rating,
    required super.comment,
    required super.timestamp,
    required super.metadata,
    required this.wasTooHot,
    required this.wasTooCold,
    required this.actualTemperature,
  });

  factory TemperatureFeedback.fromFeedback(FeedbackModel feedback, {
    required bool wasTooHot,
    required bool wasTooCold,
    required double actualTemperature,
  }) {
    return TemperatureFeedback(
      id: feedback.id,
      userId: feedback.userId,
      outfitId: feedback.outfitId,
      type: feedback.type,
      rating: feedback.rating,
      comment: feedback.comment,
      timestamp: feedback.timestamp,
      metadata: feedback.metadata,
      wasTooHot: wasTooHot,
      wasTooCold: wasTooCold,
      actualTemperature: actualTemperature,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'wasTooHot': wasTooHot,
      'wasTooCold': wasTooCold,
      'actualTemperature': actualTemperature,
    });
    return json;
  }
}
