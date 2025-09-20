import 'package:flutter/material.dart';

class StylePreferencesStep extends StatefulWidget {
  final List<String> selectedPreferences;
  final Function(List<String> preferences) onChanged;

  const StylePreferencesStep({
    super.key,
    required this.selectedPreferences,
    required this.onChanged,
  });

  @override
  State<StylePreferencesStep> createState() => _StylePreferencesStepState();
}

class _StylePreferencesStepState extends State<StylePreferencesStep> {
  late List<String> _selectedPreferences;

  final List<Map<String, dynamic>> _styleOptions = [
    {
      'value': 'casual',
      'label': 'Casual',
      'description': 'Relaxed and comfortable',
      'icon': Icons.sports_baseball,
      'color': Colors.blue,
    },
    {
      'value': 'formal',
      'label': 'Formal',
      'description': 'Professional and elegant',
      'icon': Icons.business,
      'color': Colors.grey,
    },
    {
      'value': 'streetwear',
      'label': 'Streetwear',
      'description': 'Urban and trendy',
      'icon': Icons.streetview,
      'color': Colors.black,
    },
    {
      'value': 'vintage',
      'label': 'Vintage',
      'description': 'Classic and timeless',
      'icon': Icons.access_time,
      'color': Colors.brown,
    },
    {
      'value': 'minimalist',
      'label': 'Minimalist',
      'description': 'Simple and clean',
      'icon': Icons.remove,
      'color': Colors.white,
    },
    {
      'value': 'bohemian',
      'label': 'Bohemian',
      'description': 'Free-spirited and artistic',
      'icon': Icons.palette,
      'color': Colors.purple,
    },
    {
      'value': 'sporty',
      'label': 'Sporty',
      'description': 'Active and athletic',
      'icon': Icons.directions_run,
      'color': Colors.green,
    },
    {
      'value': 'romantic',
      'label': 'Romantic',
      'description': 'Feminine and delicate',
      'icon': Icons.favorite,
      'color': Colors.pink,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedPreferences = List.from(widget.selectedPreferences);
  }

  void _togglePreference(String value) {
    setState(() {
      if (_selectedPreferences.contains(value)) {
        _selectedPreferences.remove(value);
      } else {
        _selectedPreferences.add(value);
      }
      widget.onChanged(_selectedPreferences);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'Style Preferences',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Select the styles that appeal to you most',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Choose at least 3 styles',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Style Options Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _styleOptions.length,
              itemBuilder: (context, index) {
                final style = _styleOptions[index];
                return _buildStyleOption(style);
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Selected Count
          if (_selectedPreferences.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_selectedPreferences.length} styles selected',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Your style preferences help us recommend outfits that match your personal taste',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleOption(Map<String, dynamic> style) {
    final isSelected = _selectedPreferences.contains(style['value']);
    final color = style['color'] as Color;
    
    return GestureDetector(
      onTap: () => _togglePreference(style['value']),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                style['icon'],
                color: isSelected ? color : Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              style['label'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              style['description'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected 
                    ? color.withOpacity(0.8) 
                    : Colors.white70,
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
