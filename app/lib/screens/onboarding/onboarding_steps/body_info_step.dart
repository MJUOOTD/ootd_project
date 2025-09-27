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
          const Text(
            '체형과 활동량을 알려주세요',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '개인화된 코디 추천을 위해 체형과 활동량 정보가 필요해요',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          
          // Body Type Selection
          const Text(
            '체형',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildBodyTypeOptions(),
          const SizedBox(height: 32),
          
          // Activity Level Selection
          const Text(
            '활동량',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildActivityLevelOptions(),
        ],
      ),
    );
  }

  Widget _buildBodyTypeOptions() {
    final bodyTypes = [
      {'value': 'slim', 'label': '슬림', 'description': '마른 체형'},
      {'value': 'average', 'label': '보통', 'description': '균형잡힌 체형'},
      {'value': 'athletic', 'label': '근육형', 'description': '운동으로 단련된 체형'},
      {'value': 'curvy', 'label': '커브형', 'description': '곡선이 아름다운 체형'},
    ];

    return Column(
      children: bodyTypes.map((type) {
        final isSelected = _selectedBodyType == type['value'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedBodyType = type['value']!;
                _updateData();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? const Color(0xFF030213) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF030213) : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type['label']!,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF030213) : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          type['description']!,
                          style: TextStyle(
                            color: isSelected 
                                ? const Color(0xFF030213).withOpacity(0.7)
                                : Colors.white.withOpacity(0.7),
                            fontSize: 14,
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
      }).toList(),
    );
  }

  Widget _buildActivityLevelOptions() {
    final activityLevels = [
      {'value': 'low', 'label': '낮음', 'description': '주로 실내에서 활동'},
      {'value': 'moderate', 'label': '보통', 'description': '가벼운 운동과 활동'},
      {'value': 'high', 'label': '높음', 'description': '규칙적인 운동과 활동'},
      {'value': 'very_high', 'label': '매우 높음', 'description': '매일 운동하는 활동적인 생활'},
    ];

    return Column(
      children: activityLevels.map((level) {
        final isSelected = _selectedActivityLevel == level['value'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedActivityLevel = level['value']!;
                _updateData();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? const Color(0xFF030213) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF030213) : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level['label']!,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF030213) : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          level['description']!,
                          style: TextStyle(
                            color: isSelected 
                                ? const Color(0xFF030213).withOpacity(0.7)
                                : Colors.white.withOpacity(0.7),
                            fontSize: 14,
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
      }).toList(),
    );
  }
}
