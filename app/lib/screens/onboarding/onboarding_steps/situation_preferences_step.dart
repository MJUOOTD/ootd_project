import 'package:flutter/material.dart';

class SituationPreferencesStep extends StatefulWidget {
  final Map<String, dynamic> preferences;
  final Function(Map<String, dynamic> preferences) onChanged;

  const SituationPreferencesStep({
    super.key,
    required this.preferences,
    required this.onChanged,
  });

  @override
  State<SituationPreferencesStep> createState() => _SituationPreferencesStepState();
}

class _SituationPreferencesStepState extends State<SituationPreferencesStep> {
  late Map<String, dynamic> _preferences;

  final List<Map<String, dynamic>> _situations = [
    {
      'key': 'work',
      'label': 'Work',
      'description': 'Professional office attire',
      'icon': Icons.work,
      'frequency': 'daily',
    },
    {
      'key': 'casual',
      'label': 'Casual',
      'description': 'Relaxed everyday wear',
      'icon': Icons.home,
      'frequency': 'daily',
    },
    {
      'key': 'date',
      'label': 'Date Night',
      'description': 'Special occasions and dates',
      'icon': Icons.favorite,
      'frequency': 'weekly',
    },
    {
      'key': 'exercise',
      'label': 'Exercise',
      'description': 'Workout and sports',
      'icon': Icons.fitness_center,
      'frequency': 'frequent',
    },
    {
      'key': 'travel',
      'label': 'Travel',
      'description': 'Vacation and trips',
      'icon': Icons.flight,
      'frequency': 'occasional',
    },
    {
      'key': 'formal',
      'label': 'Formal Events',
      'description': 'Parties and formal occasions',
      'icon': Icons.event,
      'frequency': 'occasional',
    },
  ];

  @override
  void initState() {
    super.initState();
    _preferences = Map.from(widget.preferences);
    
    // Initialize preferences with default values
    for (var situation in _situations) {
      _preferences[situation['key']] = _preferences[situation['key']] ?? {
        'enabled': true,
        'frequency': situation['frequency'],
        'priority': 3, // 1-5 scale
      };
    }
  }

  void _updatePreference(String key, String field, dynamic value) {
    setState(() {
      _preferences[key][field] = value;
      widget.onChanged(_preferences);
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
            'Situation Preferences',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Tell us about your lifestyle and the situations you dress for most often',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Situations List
          Expanded(
            child: ListView.builder(
              itemCount: _situations.length,
              itemBuilder: (context, index) {
                final situation = _situations[index];
                return _buildSituationCard(situation);
              },
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
                    'This information helps us prioritize outfit recommendations for your most common situations',
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

  Widget _buildSituationCard(Map<String, dynamic> situation) {
    final key = situation['key'] as String;
    final data = _preferences[key];
    final isEnabled = data['enabled'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Header
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                situation['icon'],
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              situation['label'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              situation['description'],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            trailing: Switch(
              value: isEnabled,
              onChanged: (value) => _updatePreference(key, 'enabled', value),
              activeColor: Colors.white,
            ),
            onTap: () => _updatePreference(key, 'enabled', !isEnabled),
          ),
          
          // Settings (only show if enabled)
          if (isEnabled) ...[
            const Divider(color: Colors.white24, height: 1),
            
            // Frequency Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How often?',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['rarely', 'occasional', 'frequent', 'daily'].map((freq) {
                      final isSelected = data['frequency'] == freq;
                      return GestureDetector(
                        onTap: () => _updatePreference(key, 'frequency', freq),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            freq,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF030213) : Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            // Priority Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Priority',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${data['priority']}/5',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: (data['priority'] as int).toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white.withOpacity(0.3),
                    onChanged: (value) => _updatePreference(key, 'priority', value.round()),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
