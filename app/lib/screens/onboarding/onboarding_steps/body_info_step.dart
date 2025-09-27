import 'package:flutter/material.dart';

class BodyInfoStep extends StatefulWidget {
  final String bodyType;
  final String activityLevel;
  final Function(String bodyType, String activityLevel) onChanged;

  const BodyInfoStep({
    super.key,
    required this.bodyType,
    required this.activityLevel,
    required this.onChanged,
  });

  @override
  State<BodyInfoStep> createState() => _BodyInfoStepState();
}

class _BodyInfoStepState extends State<BodyInfoStep> {
  late String _selectedBodyType;
  late String _selectedActivityLevel;

  final List<Map<String, dynamic>> _bodyTypes = [
    {'value': 'slim', 'label': 'Slim', 'description': 'Thin build'},
    {'value': 'average', 'label': 'Average', 'description': 'Normal build'},
    {'value': 'athletic', 'label': 'Athletic', 'description': 'Muscular build'},
    {'value': 'curvy', 'label': 'Curvy', 'description': 'Curved build'},
  ];

  final List<Map<String, dynamic>> _activityLevels = [
    {'value': 'low', 'label': 'Low', 'description': 'Mostly indoors, minimal activity'},
    {'value': 'moderate', 'label': 'Moderate', 'description': 'Regular daily activities'},
    {'value': 'high', 'label': 'High', 'description': 'Very active lifestyle'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedBodyType = widget.bodyType;
    _selectedActivityLevel = widget.activityLevel;
  }

  void _updateData() {
    widget.onChanged(_selectedBodyType, _selectedActivityLevel);
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
            'Body & Lifestyle',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Help us understand your body type and activity level',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Body Type Section
          const Text(
            'Body Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ..._bodyTypes.map((bodyType) => _buildBodyTypeOption(bodyType)),
          
          const SizedBox(height: 32),
          
          // Activity Level Section
          const Text(
            'Activity Level',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ..._activityLevels.map((level) => _buildActivityLevelOption(level)),
          
          const Spacer(),
          
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
                    'This information helps us recommend outfits that fit your lifestyle and comfort preferences',
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

  Widget _buildBodyTypeOption(Map<String, dynamic> bodyType) {
    final isSelected = _selectedBodyType == bodyType['value'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedBodyType = bodyType['value'];
            _updateData();
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFF030213) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF030213) : Colors.white,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bodyType['label'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF030213) : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bodyType['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? const Color(0xFF030213).withOpacity(0.7) : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityLevelOption(Map<String, dynamic> level) {
    final isSelected = _selectedActivityLevel == level['value'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedActivityLevel = level['value'];
            _updateData();
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFF030213) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF030213) : Colors.white,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level['label'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF030213) : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? const Color(0xFF030213).withOpacity(0.7) : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
