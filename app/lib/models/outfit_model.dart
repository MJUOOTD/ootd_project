import 'weather_model.dart';

class OutfitRecommendation {
  final String id;
  final Outfit outfit;
  final WeatherModel weather;
  final double confidence;
  final String reason;
  final List<String> tips;

  OutfitRecommendation({
    required this.id,
    required this.outfit,
    required this.weather,
    required this.confidence,
    required this.reason,
    required this.tips,
  });

  factory OutfitRecommendation.fromJson(Map<String, dynamic> json) {
    return OutfitRecommendation(
      id: json['id'] ?? '',
      outfit: Outfit.fromJson(json['outfit'] ?? {}),
      weather: WeatherModel.fromJson(json['weather'] ?? {}),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      reason: json['reason'] ?? '',
      tips: List<String>.from(json['tips'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'outfit': outfit.toJson(),
      'weather': weather.toJson(),
      'confidence': confidence,
      'reason': reason,
      'tips': tips,
    };
  }

  OutfitRecommendation copyWith({
    String? id,
    Outfit? outfit,
    WeatherModel? weather,
    double? confidence,
    String? reason,
    List<String>? tips,
  }) {
    return OutfitRecommendation(
      id: id ?? this.id,
      outfit: outfit ?? this.outfit,
      weather: weather ?? this.weather,
      confidence: confidence ?? this.confidence,
      reason: reason ?? this.reason,
      tips: tips ?? this.tips,
    );
  }
}

class Outfit {
  final String title;
  final String description;
  final String occasion;
  final double rating;
  final List<String> items;
  final List<String> tags;
  final String imageUrl;

  Outfit({
    required this.title,
    required this.description,
    required this.occasion,
    required this.rating,
    required this.items,
    required this.tags,
    required this.imageUrl,
  });

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      occasion: json['occasion'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      items: List<String>.from(json['items'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'occasion': occasion,
      'rating': rating,
      'items': items,
      'tags': tags,
      'imageUrl': imageUrl,
    };
  }

  Outfit copyWith({
    String? title,
    String? description,
    String? occasion,
    double? rating,
    List<String>? items,
    List<String>? tags,
    String? imageUrl,
  }) {
    return Outfit(
      title: title ?? this.title,
      description: description ?? this.description,
      occasion: occasion ?? this.occasion,
      rating: rating ?? this.rating,
      items: items ?? this.items,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class OutfitItem {
  final String id;
  final String name;
  final String category;
  final String color;
  final String size;
  final String brand;
  final String imageUrl;
  final double price;
  final List<String> tags;

  OutfitItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.size,
    required this.brand,
    required this.imageUrl,
    required this.price,
    required this.tags,
  });

  factory OutfitItem.fromJson(Map<String, dynamic> json) {
    return OutfitItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      color: json['color'] ?? '',
      size: json['size'] ?? '',
      brand: json['brand'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'size': size,
      'brand': brand,
      'imageUrl': imageUrl,
      'price': price,
      'tags': tags,
    };
  }
}

// ClothingItem은 OutfitItem의 별칭으로 사용
typedef ClothingItem = OutfitItem;

class OutfitCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> subcategories;

  OutfitCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.subcategories,
  });

  factory OutfitCategory.fromJson(Map<String, dynamic> json) {
    return OutfitCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      subcategories: List<String>.from(json['subcategories'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'subcategories': subcategories,
    };
  }
}