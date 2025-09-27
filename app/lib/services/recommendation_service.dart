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
    
    // Remove duplicates and generate outfit recommendations
    Set<String> uniqueItems = allItems.toSet();
    
    for (int i = 0; i < limit; i++) {
      OutfitRecommendation recommendation = await _generateOutfitRecommendation(
        uniqueItems.toList(),
        weather,
        user,
        occasion,
        i,
      );
      recommendations.add(recommendation);
    }

    return recommendations;
  }

  static List<String> _getWeatherBasedItems(WeatherModel weather) {
    WeatherCategory category = weather.getWeatherCategory();
    return _weatherOutfitMapping[category] ?? _weatherOutfitMapping[WeatherCategory.mild]!;
  }

  static List<String> _adjustForUserSensitivity(
    List<String> baseItems,
    TemperatureSensitivity sensitivity,
    WeatherModel weather,
  ) {
    List<String> adjustedItems = List.from(baseItems);
    
    // Adjust for cold sensitivity
    if (sensitivity.coldSensitivity < -0.3) {
      adjustedItems.addAll(['extra_layer', 'scarf', 'gloves']);
    } else if (sensitivity.coldSensitivity > 0.3) {
      adjustedItems.removeWhere((item) => ['scarf', 'gloves', 'heavy_coat'].contains(item));
    }
    
    // Adjust for heat sensitivity
    if (sensitivity.heatSensitivity < -0.3) {
      adjustedItems.addAll(['light_fabric', 'breathable_material']);
      adjustedItems.removeWhere((item) => ['heavy_coat', 'sweater'].contains(item));
    }
    
    // Adjust for actual temperature
    double adjustedTemp = weather.getAdjustedTemperature(sensitivity);
    if (adjustedTemp < 10) {
      adjustedItems.addAll(['thermal_layer', 'heavy_coat']);
    } else if (adjustedTemp > 30) {
      adjustedItems.addAll(['light_material', 'sun_hat']);
    }
    
    return adjustedItems;
  }

  static List<String> _getGenderSpecificItems(String gender) {
    return _genderOutfitMapping[gender.toLowerCase()] ?? _genderOutfitMapping['male']!;
  }

  static List<String> _getOccasionSpecificItems(String occasion) {
    return _occasionOutfitMapping[occasion.toLowerCase()] ?? _occasionOutfitMapping['casual']!;
  }

  static Future<OutfitRecommendation> _generateOutfitRecommendation(
    List<String> items,
    WeatherModel weather,
    UserModel user,
    String occasion,
    int variation,
  ) async {
    // Create mock outfit data
    OutfitModel outfit = OutfitModel(
      id: 'outfit_${DateTime.now().millisecondsSinceEpoch}_$variation',
      title: _generateOutfitTitle(weather, occasion, variation),
      description: _generateOutfitDescription(items, weather),
      items: _createClothingItems(items, variation),
      suitableWeather: weather.getWeatherCategory(),
      gender: user.gender,
      occasion: occasion,
      imageUrl: _getOutfitImageUrl(weather, occasion, variation),
      rating: 4.0 + (variation * 0.1),
      tags: _generateTags(items, weather, occasion),
      createdAt: DateTime.now(),
    );

    return OutfitRecommendation(
      outfit: outfit,
      confidence: _calculateConfidence(weather, user, items),
      reason: _generateReason(weather, user, occasion),
      tips: _generateTips(weather, items),
      recommendedAt: DateTime.now(),
    );
  }

  static String _generateOutfitTitle(WeatherModel weather, String occasion, int variation) {
    List<String> titles = [
      'Perfect for ${weather.condition.toLowerCase()} weather',
<<<<<<< HEAD
      'Stylish $occasion look',
      'Comfortable ${weather.getWeatherCategory().name} outfit',
      'Trendy $occasion ensemble',
=======
      'Stylish ${occasion} look',
      'Comfortable ${weather.getWeatherCategory().name} outfit',
      'Trendy ${occasion} ensemble',
>>>>>>> origin/moon
    ];
    return titles[variation % titles.length];
  }

  static String _generateOutfitDescription(List<String> items, WeatherModel weather) {
    return 'A comfortable outfit perfect for ${weather.condition.toLowerCase()} weather. '
           'This combination includes ${items.take(3).join(', ')} and more.';
  }

  static List<ClothingItem> _createClothingItems(List<String> items, int variation) {
    return items.take(5).map((item) => ClothingItem(
      id: 'item_${item}_$variation',
      name: _formatItemName(item),
      category: _getItemCategory(item),
      subcategory: _getItemSubcategory(item),
      color: _getRandomColor(),
      material: _getRandomMaterial(),
      brand: _getRandomBrand(),
      price: _getRandomPrice(),
      imageUrl: _getItemImageUrl(item),
      warmthLevel: _getWarmthLevel(item),
      season: _getSeason(item),
    )).toList();
  }

  static String _getOutfitImageUrl(WeatherModel weather, String occasion, int variation) {
    // Mock image URLs - in real app, these would be actual outfit images
    return 'https://via.placeholder.com/300x400/cccccc/666666?text=${weather.condition}+$occasion+$variation';
  }

  static List<String> _generateTags(List<String> items, WeatherModel weather, String occasion) {
    List<String> tags = [weather.condition.toLowerCase(), occasion, weather.getWeatherCategory().name];
    tags.addAll(items.take(3));
    return tags;
  }

  static double _calculateConfidence(WeatherModel weather, UserModel user, List<String> items) {
    double confidence = 0.8; // Base confidence
    
    // Adjust based on weather match
    if (weather.getWeatherCategory() == WeatherCategory.mild) {
      confidence += 0.1;
    }
    
    // Adjust based on user preferences
    if (user.stylePreferences.isNotEmpty) {
      confidence += 0.05;
    }
    
    return confidence.clamp(0.0, 1.0);
  }

  static String _generateReason(WeatherModel weather, UserModel user, String occasion) {
    return 'Recommended based on current ${weather.condition.toLowerCase()} weather, '
           'your temperature sensitivity (${user.temperatureSensitivity.level}), '
<<<<<<< HEAD
           'and the $occasion occasion.';
=======
           'and the ${occasion} occasion.';
>>>>>>> origin/moon
  }

  static List<String> _generateTips(WeatherModel weather, List<String> items) {
    List<String> tips = [];
    
    if (weather.windSpeed > 5) {
      tips.add('It\'s windy today, consider a windbreaker or secure your hat.');
    }
    
    if (weather.precipitation > 0) {
      tips.add('Don\'t forget an umbrella or rain jacket.');
    }
    
    if (weather.temperature > 25) {
      tips.add('Stay hydrated and wear light colors to stay cool.');
    }
    
    return tips;
  }

  // Helper methods for mock data generation
  static String _formatItemName(String item) {
    return item.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  static String _getItemCategory(String item) {
    if (item.contains('shirt') || item.contains('blouse')) return 'top';
    if (item.contains('pants') || item.contains('jeans') || item.contains('shorts')) return 'bottom';
    if (item.contains('jacket') || item.contains('coat')) return 'outerwear';
    if (item.contains('shoes') || item.contains('boots')) return 'shoes';
    return 'accessories';
  }

  static String _getItemSubcategory(String item) {
    return item; // For simplicity, use the item name as subcategory
  }

  static String _getRandomColor() {
    List<String> colors = ['Black', 'White', 'Blue', 'Gray', 'Navy', 'Brown', 'Green', 'Red'];
    return colors[DateTime.now().millisecond % colors.length];
  }

  static String _getRandomMaterial() {
    List<String> materials = ['Cotton', 'Polyester', 'Wool', 'Denim', 'Linen', 'Silk'];
    return materials[DateTime.now().millisecond % materials.length];
  }

  static String _getRandomBrand() {
    List<String> brands = ['Uniqlo', 'H&M', 'Zara', 'Nike', 'Adidas', 'Gap'];
    return brands[DateTime.now().millisecond % brands.length];
  }

  static double _getRandomPrice() {
    return (20 + (DateTime.now().millisecond % 200)).toDouble();
  }

  static String _getItemImageUrl(String item) {
    return 'https://via.placeholder.com/150x150/cccccc/666666?text=$item';
  }

  static double _getWarmthLevel(String item) {
    if (item.contains('heavy') || item.contains('thermal')) return 0.9;
    if (item.contains('coat') || item.contains('sweater')) return 0.7;
    if (item.contains('jacket') || item.contains('cardigan')) return 0.5;
    if (item.contains('shirt') || item.contains('blouse')) return 0.3;
    if (item.contains('t_shirt') || item.contains('shorts')) return 0.1;
    return 0.5;
  }

  static String _getSeason(String item) {
    if (item.contains('heavy') || item.contains('thermal') || item.contains('coat')) return 'winter';
    if (item.contains('jacket') || item.contains('cardigan')) return 'fall';
    if (item.contains('shirt') || item.contains('blouse')) return 'spring';
    if (item.contains('t_shirt') || item.contains('shorts')) return 'summer';
    return 'all';
  }
}
