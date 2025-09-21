import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class RecommendationMessageWidget extends StatelessWidget {
  final WeatherModel weather;

  const RecommendationMessageWidget({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final message = _getRecommendationMessage();
    final icon = _getRecommendationIcon();
    final color = _getRecommendationColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather Tip',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRecommendationMessage() {
    final temp = weather.temperature;
    final condition = weather.condition.toLowerCase();
    final windSpeed = weather.windSpeed;
    final precipitation = weather.precipitation;

    // Weather condition messages (priority over temperature)
    if (precipitation > 0.1 || condition.contains('rain')) {
      return "Don't forget your umbrella! Waterproof shoes and a rain jacket are recommended.";
    }
    
    if (condition.contains('snow')) {
      return "Snowy conditions! Wear warm, waterproof boots and insulated clothing.";
    }
    
    if (windSpeed > 10) {
      return "It's windy today! Consider a windbreaker or secure your hat.";
    }
    
    if (condition.contains('sun') || condition.contains('clear')) {
      return "Sunny day! Don't forget sunglasses and sunscreen protection.";
    }
    
    if (condition.contains('cloud')) {
      return "Cloudy skies ahead. Perfect for layering - the weather might change.";
    }

    // Temperature-based messages
    if (temp < 5) {
      return "It's very cold! Layer up with warm clothing and don't forget gloves and a scarf.";
    } else if (temp < 10) {
      return "It's chilly outside. A warm jacket and layers will keep you comfortable.";
    } else if (temp < 15) {
      return "Cool weather calls for a light jacket or cardigan to stay cozy.";
    } else if (temp < 25) {
      return "Pleasant weather! Light layers are perfect for today's temperature.";
    } else if (temp < 30) {
      return "It's warm today. Light, breathable fabrics will keep you cool.";
    } else {
      return "Hot weather ahead! Choose light colors and loose-fitting clothes.";
    }
  }

  IconData _getRecommendationIcon() {
    final temp = weather.temperature;
    final condition = weather.condition.toLowerCase();
    final windSpeed = weather.windSpeed;
    final precipitation = weather.precipitation;

    if (precipitation > 0.1 || condition.contains('rain')) {
      return Icons.umbrella;
    }
    
    if (condition.contains('snow')) {
      return Icons.ac_unit;
    }
    
    if (windSpeed > 10) {
      return Icons.air;
    }
    
    if (condition.contains('sun') || condition.contains('clear')) {
      return Icons.wb_sunny;
    }
    
    if (temp < 10) {
      return Icons.ac_unit;
    } else if (temp > 25) {
      return Icons.wb_sunny;
    }
    
    return Icons.info_outline;
  }

  Color _getRecommendationColor() {
    final temp = weather.temperature;
    final condition = weather.condition.toLowerCase();
    final precipitation = weather.precipitation;

    if (precipitation > 0.1 || condition.contains('rain')) {
      return Colors.blue;
    }
    
    if (condition.contains('snow')) {
      return Colors.cyan;
    }
    
    if (temp < 10) {
      return Colors.blue;
    } else if (temp > 25) {
      return Colors.orange;
    }
    
    return Colors.green;
  }
}
