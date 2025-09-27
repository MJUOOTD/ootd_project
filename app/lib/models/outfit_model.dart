import 'weather_model.dart';

class OutfitModel {
  final String id;
  final String title;
  final String description;
  final List<ClothingItem> items;
  final WeatherCategory suitableWeather;
  final String gender;
  final String occasion;
  final String imageUrl;
  final double rating;
  final List<String> tags;
  final DateTime createdAt;

  OutfitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.items,
    required this.suitableWeather,
    required this.gender,
    required this.occasion,
    required this.imageUrl,
    required this.rating,
    required this.tags,
    required this.createdAt,
  });

  factory OutfitModel.fromJson(Map<String, dynamic> json) {
    return OutfitModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      items: (json['items'] as List?)
          ?.map((item) => ClothingItem.fromJson(item))
          .toList() ?? [],
      suitableWeather: WeatherCategory.values.firstWhere(
        (e) => e.name == json['suitableWeather'],
        orElse: () => WeatherCategory.mild,
      ),
      gender: json['gender'] ?? '',
      occasion: json['occasion'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'items': items.map((item) => item.toJson()).toList(),
      'suitableWeather': suitableWeather.name,
      'gender': gender,
      'occasion': occasion,
      'imageUrl': imageUrl,
      'rating': rating,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ClothingItem {
  final String id;
  final String name;
  final String category;
  final String subcategory;
  final String color;
  final String material;
  final String brand;
  final double price;
  final String imageUrl;
  final double warmthLevel; // 0.0 to 1.0
  final String season;

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.color,
    required this.material,
    required this.brand,
    required this.price,
    required this.imageUrl,
    required this.warmthLevel,
    required this.season,
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      color: json['color'] ?? '',
      material: json['material'] ?? '',
      brand: json['brand'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      warmthLevel: (json['warmthLevel'] ?? 0.0).toDouble(),
      season: json['season'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'color': color,
      'material': material,
      'brand': brand,
      'price': price,
      'imageUrl': imageUrl,
      'warmthLevel': warmthLevel,
      'season': season,
    };
  }
}

class OutfitRecommendation {
  final OutfitModel outfit;
  final double confidence; // 0.0 to 1.0
  final String reason;
  final List<String> tips;
  final DateTime recommendedAt;

  OutfitRecommendation({
    required this.outfit,
    required this.confidence,
    required this.reason,
    required this.tips,
    required this.recommendedAt,
  });

  factory OutfitRecommendation.fromJson(Map<String, dynamic> json) {
    return OutfitRecommendation(
      outfit: OutfitModel.fromJson(json['outfit'] ?? {}),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      reason: json['reason'] ?? '',
      tips: List<String>.from(json['tips'] ?? []),
      recommendedAt: DateTime.parse(json['recommendedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'outfit': outfit.toJson(),
      'confidence': confidence,
      'reason': reason,
      'tips': tips,
      'recommendedAt': recommendedAt.toIso8601String(),
    };
  }
}

enum ClothingCategory {
  top,
  bottom,
  outerwear,
  shoes,
  accessories,
}

enum Occasion {
  casual,
  work,
  formal,
  date,
  exercise,
  travel,
  party,
}
