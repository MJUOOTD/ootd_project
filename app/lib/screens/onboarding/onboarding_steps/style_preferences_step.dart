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

  @override
  void initState() {
    super.initState();
    _selectedPreferences = List.from(widget.selectedPreferences);
  }

  void _updateData() {
    widget.onChanged(_selectedPreferences);
  }

  void _togglePreference(String preference) {
    setState(() {
      if (_selectedPreferences.contains(preference)) {
        _selectedPreferences.remove(preference);
      } else {
        _selectedPreferences.add(preference);
      }
      _updateData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '선호하는 스타일을 선택해주세요',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '여러 개 선택 가능해요. 선호하는 스타일을 모두 선택해주세요',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          
          _buildStyleOptions(),
        ],
      ),
    );
  }

  Widget _buildStyleOptions() {
    final styleOptions = [
      {'value': 'casual', 'label': '캐주얼', 'icon': Icons.sports_outlined},
      {'value': 'formal', 'label': '포멀', 'icon': Icons.business_center_outlined},
      {'value': 'street', 'label': '스트릿', 'icon': Icons.sports_esports_outlined},
      {'value': 'minimal', 'label': '미니멀', 'icon': Icons.design_services_outlined},
      {'value': 'vintage', 'label': '빈티지', 'icon': Icons.history_edu_outlined},
      {'value': 'romantic', 'label': '로맨틱', 'icon': Icons.favorite_outline},
      {'value': 'sporty', 'label': '스포티', 'icon': Icons.sports_soccer_outlined},
      {'value': 'bohemian', 'label': '보헤미안', 'icon': Icons.eco_outlined},
      {'value': 'preppy', 'label': '프레피', 'icon': Icons.school_outlined},
      {'value': 'edgy', 'label': '에지', 'icon': Icons.flash_on_outlined},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: styleOptions.length,
      itemBuilder: (context, index) {
        final option = styleOptions[index];
        final isSelected = _selectedPreferences.contains(option['value'] as String);
        
        return GestureDetector(
          onTap: () => _togglePreference(option['value'] as String),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  option['icon'] as IconData,
                  color: isSelected ? const Color(0xFF030213) : Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  option['label'] as String,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF030213) : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
