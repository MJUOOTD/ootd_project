import '../models/user_model.dart';
import '../models/weather_model.dart';
import '../models/outfit_model.dart';

class RecommendationService {
  static const Map<WeatherCategory, List<String>> _weatherOutfitMapping = {
    WeatherCategory.cold: ['heavy_coat', 'sweater', 'thermal_underwear', 'gloves', 'scarf'],
    WeatherCategory.cool: ['light_jacket', 'long_sleeve', 'jeans', 'boots'],
    WeatherCategory.mild: ['cardigan', 't_shirt', 'jeans', 'sneakers'],
    WeatherCategory.hot: ['t_shirt', 'shorts', 'sandals', 'hat'],
    WeatherCategory.rainy: ['raincoat', 'umbrella', 'waterproof_shoes', 'waterproof_bag'],
  };

  static const Map<String, List<String>> _genderOutfitMapping = {
    'male': ['shirt', 'pants', 'jacket', 'sneakers', 'belt'],
    'female': ['blouse', 'jeans', 'cardigan', 'heels', 'handbag'],
  };

  static const Map<String, List<String>> _occasionOutfitMapping = {
    'work': ['formal_shirt', 'dress_pants', 'blazer', 'dress_shoes'],
    'casual': ['t_shirt', 'jeans', 'sneakers', 'hoodie'],
    'date': ['dress_shirt', 'dark_jeans', 'leather_jacket', 'dress_shoes'],
    'exercise': ['athletic_shirt', 'shorts', 'running_shoes', 'sports_bag'],
    'formal': ['suit', 'dress_shirt', 'tie', 'dress_shoes', 'watch'],
  };

  // Main recommendation algorithm
  static Future<List<OutfitRecommendation>> getRecommendations({
    required WeatherModel weather,
    required UserModel user,
    String occasion = 'casual',
    int limit = 3,
  }) async {
    List<OutfitRecommendation> recommendations = [];

    // Get base outfit items based on weather
    List<String> baseItems = _getWeatherBasedItems(weather);
    
    // Adjust for user sensitivity
    List<String> adjustedItems = _adjustForUserSensitivity(baseItems, user.temperatureSensitivity, weather);
    
    // Add gender-specific items
    List<String> genderItems = _getGenderSpecificItems(user.gender);
    
    // Add occasion-specific items
    List<String> occasionItems = _getOccasionSpecificItems(occasion);
    
    // Combine all items
    List<String> allItems = [...adjustedItems, ...genderItems, ...occasionItems];
    
    // Generate recommendations
    for (int i = 0; i < limit; i++) {
      recommendations.add(_generateOutfitRecommendation(
        allItems,
        weather,
        user,
        occasion,
        i,
      ));
    }

    return recommendations;
  }

  static List<String> _getWeatherBasedItems(WeatherModel weather) {
    WeatherCategory category = _getWeatherCategory(weather.temperature, weather.condition);
    return _weatherOutfitMapping[category] ?? [];
  }

  static WeatherCategory _getWeatherCategory(double temperature, String condition) {
    if (condition.toLowerCase().contains('rain')) {
      return WeatherCategory.rainy;
    }
    
    if (temperature < 5) {
      return WeatherCategory.cold;
    } else if (temperature < 15) {
      return WeatherCategory.cool;
    } else if (temperature < 25) {
      return WeatherCategory.mild;
    } else {
      return WeatherCategory.hot;
    }
  }

  static List<String> _adjustForUserSensitivity(
    List<String> baseItems,
    TemperatureSensitivity sensitivity,
    WeatherModel weather,
  ) {
    List<String> adjustedItems = List.from(baseItems);
    
    switch (sensitivity) {
      case TemperatureSensitivity.veryCold:
        if (weather.temperature < 20) {
          adjustedItems.addAll(['thermal_underwear', 'thick_socks', 'warm_hat']);
        }
        break;
      case TemperatureSensitivity.cold:
        if (weather.temperature < 18) {
          adjustedItems.addAll(['light_sweater', 'long_sleeve']);
        }
        break;
      case TemperatureSensitivity.normal:
        // No adjustment needed
        break;
      case TemperatureSensitivity.hot:
        if (weather.temperature > 22) {
          adjustedItems.removeWhere((item) => 
            item.contains('sweater') || item.contains('jacket'));
          adjustedItems.addAll(['tank_top', 'shorts']);
        }
        break;
      case TemperatureSensitivity.veryHot:
        if (weather.temperature > 20) {
          adjustedItems.removeWhere((item) => 
            item.contains('sweater') || item.contains('jacket') || item.contains('long_sleeve'));
          adjustedItems.addAll(['tank_top', 'shorts', 'light_fabric']);
        }
        break;
    }
    
    return adjustedItems;
  }

  static List<String> _getGenderSpecificItems(String gender) {
    return _genderOutfitMapping[gender.toLowerCase()] ?? [];
  }

  static List<String> _getOccasionSpecificItems(String occasion) {
    return _occasionOutfitMapping[occasion.toLowerCase()] ?? [];
  }

  static OutfitRecommendation _generateOutfitRecommendation(
    List<String> items,
    WeatherModel weather,
    UserModel user,
    String occasion,
    int index,
  ) {
    // Shuffle items for variety
    List<String> shuffledItems = List.from(items)..shuffle();
    
    // Take first 5-7 items for the outfit
    int itemCount = 5 + (index % 3);
    List<String> outfitItems = shuffledItems.take(itemCount).toList();
    
    final outfit = Outfit(
      title: _generateOutfitTitle(occasion, index),
      description: _generateDescription(outfitItems, weather, occasion),
      occasion: occasion,
      rating: 3.5 + (index % 3) * 0.5,
      items: outfitItems,
      tags: _generateTags(occasion, weather),
      imageUrl: _getOutfitImageUrl(outfitItems, occasion),
    );
    
    return OutfitRecommendation(
      id: 'outfit_${DateTime.now().millisecondsSinceEpoch}_$index',
      outfit: outfit,
      weather: weather,
      confidence: _calculateConfidence(weather, user, occasion),
      reason: _generateReason(weather, occasion),
      tips: _generateTips(occasion, weather),
    );
  }

  static double _calculateConfidence(WeatherModel weather, UserModel user, String occasion) {
    double confidence = 0.8; // Base confidence
    
    // Adjust based on weather accuracy
    if (weather.temperature > 0 && weather.temperature < 50) {
      confidence += 0.1;
    }
    
    // Adjust based on user preferences
    if (user.temperatureSensitivity == TemperatureSensitivity.normal) {
      confidence += 0.05;
    }
    
    // Adjust based on occasion
    if (['work', 'casual', 'date'].contains(occasion.toLowerCase())) {
      confidence += 0.05;
    }
    
    return confidence.clamp(0.0, 1.0);
  }

  static String _generateDescription(List<String> items, WeatherModel weather, String occasion) {
    String baseDescription = 'Perfect for $occasion';
    
    if (weather.temperature < 10) {
      baseDescription += ' in cold weather';
    } else if (weather.temperature > 25) {
      baseDescription += ' in warm weather';
    } else {
      baseDescription += ' in mild weather';
    }
    
    return baseDescription;
  }

  static String _getOutfitImageUrl(List<String> items, String occasion) {
    // This would typically return a URL to an outfit image
    // For now, return a placeholder
    return 'https://via.placeholder.com/300x400?text=${occasion.toUpperCase()}';
  }

  static String _generateOutfitTitle(String occasion, int index) {
    final titles = {
      'work': ['Professional Look', 'Business Attire', 'Office Style'],
      'casual': ['Casual Chic', 'Weekend Look', 'Relaxed Style'],
      'date': ['Romantic Outfit', 'Date Night Look', 'Elegant Style'],
      'exercise': ['Athletic Wear', 'Gym Look', 'Sporty Style'],
      'formal': ['Formal Attire', 'Elegant Look', 'Sophisticated Style'],
    };
    
    final occasionTitles = titles[occasion.toLowerCase()] ?? ['Fashion Look', 'Style Outfit'];
    return occasionTitles[index % occasionTitles.length];
  }

  static List<String> _generateTags(String occasion, WeatherModel weather) {
    List<String> tags = [occasion.toLowerCase()];
    
    if (weather.temperature < 10) {
      tags.addAll(['winter', 'warm', 'layered']);
    } else if (weather.temperature > 25) {
      tags.addAll(['summer', 'light', 'breathable']);
    } else {
      tags.addAll(['spring', 'autumn', 'versatile']);
    }
    
    if (weather.condition.toLowerCase().contains('rain')) {
      tags.add('waterproof');
    }
    
    return tags;
  }

  static String _generateReason(WeatherModel weather, String occasion) {
    String reason = 'Perfect for $occasion';
    
    if (weather.temperature < 10) {
      reason += ' in cold weather';
    } else if (weather.temperature > 25) {
      reason += ' in warm weather';
    } else {
      reason += ' in mild weather';
    }
    
    if (weather.condition.toLowerCase().contains('rain')) {
      reason += ' with rain protection';
    }
    
    return reason;
  }

  static List<String> _generateTips(String occasion, WeatherModel weather) {
    List<String> tips = [];
    
    if (occasion.toLowerCase() == 'work') {
      tips.add('Choose neutral colors for a professional look');
      tips.add('Ensure clothes are well-fitted and clean');
    } else if (occasion.toLowerCase() == 'date') {
      tips.add('Dress one level up from the venue');
      tips.add('Choose colors that complement your skin tone');
    } else if (occasion.toLowerCase() == 'casual') {
      tips.add('Mix and match different textures');
      tips.add('Express your personal style');
    }
    
    if (weather.temperature < 15) {
      tips.add('Layer your clothing for warmth and style');
    } else if (weather.temperature > 25) {
      tips.add('Choose light, breathable fabrics');
    }
    
    return tips;
  }

  // Helper method to get outfit suggestions for specific situations
  static List<String> getOutfitSuggestions({
    required String occasion,
    required double temperature,
    required String gender,
  }) {
    List<String> suggestions = [];
    
    // Add occasion-specific items
    suggestions.addAll(_getOccasionSpecificItems(occasion));
    
    // Add weather-appropriate items
    WeatherCategory category = _getWeatherCategory(temperature, '');
    suggestions.addAll(_weatherOutfitMapping[category] ?? []);
    
    // Add gender-specific items
    suggestions.addAll(_getGenderSpecificItems(gender));
    
    return suggestions.toSet().toList(); // Remove duplicates
  }

  // Helper method to get style tips
  static List<String> getStyleTips({
    required String occasion,
    required double temperature,
  }) {
    List<String> tips = [];
    
    if (occasion.toLowerCase() == 'work') {
      tips.add('Choose neutral colors for a professional look');
      tips.add('Ensure clothes are well-fitted and clean');
      tips.add('Accessorize with a watch or simple jewelry');
    } else if (occasion.toLowerCase() == 'date') {
      tips.add('Dress one level up from the venue');
      tips.add('Choose colors that complement your skin tone');
      tips.add('Don\'t forget to wear comfortable shoes');
    } else if (occasion.toLowerCase() == 'casual') {
      tips.add('Mix and match different textures');
      tips.add('Layer for versatility');
      tips.add('Express your personal style');
    }
    
    if (temperature < 15) {
      tips.add('Layer your clothing for warmth and style');
      tips.add('Choose fabrics like wool or fleece');
    } else if (temperature > 25) {
      tips.add('Choose light, breathable fabrics');
      tips.add('Wear light colors to reflect heat');
    }
    
    return tips;
  }
}