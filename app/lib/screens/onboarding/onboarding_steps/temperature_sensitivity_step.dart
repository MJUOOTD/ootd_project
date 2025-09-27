import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';

class TemperatureSensitivityStep extends StatefulWidget {
  final TemperatureSensitivity temperatureSensitivity;
  final Function(TemperatureSensitivity sensitivity) onChanged;

  const TemperatureSensitivityStep({
    super.key,
    required this.temperatureSensitivity,
    required this.onChanged,
  });

  @override
  State<TemperatureSensitivityStep> createState() => _TemperatureSensitivityStepState();
}

class _TemperatureSensitivityStepState extends State<TemperatureSensitivityStep> {
  late TemperatureSensitivity _selectedSensitivity;

  final List<Map<String, dynamic>> _sensitivityOptions = [
    {
      'level': 'low',
      'label': 'Cold Sensitive',
      'description': 'I feel cold easily and prefer warmer clothing',
      'coldSensitivity': -0.5,
      'heatSensitivity': 0.0,
      'icon': Icons.ac_unit,
    },
    {
      'level': 'normal',
      'label': 'Normal',
      'description': 'I have average temperature sensitivity',
      'coldSensitivity': 0.0,
      'heatSensitivity': 0.0,
      'icon': Icons.thermostat,
    },
    {
      'level': 'high',
      'label': 'Heat Sensitive',
      'description': 'I feel hot easily and prefer cooler clothing',
      'coldSensitivity': 0.0,
      'heatSensitivity': -0.5,
      'icon': Icons.wb_sunny,
    {
      'level': 'heat_sensitive',
      'label': '더위를 많이 탐',
      'description': '평소보다 시원한 옷을 추천해드려요',
      'coldSensitivity': 0.0,
      'heatSensitivity': 0.5,
    },
    {
      'level': 'normal',
      'label': '보통',
      'description': '일반적인 날씨 기준으로 추천해드려요',
      'coldSensitivity': 0.0,
      'heatSensitivity': 0.0,
    },
    {
      'level': 'cold_sensitive',
      'label': '추위를 많이 탐',
      'description': '평소보다 따뜻한 옷을 추천해드려요',
      'coldSensitivity': -0.5,
      'heatSensitivity': 0.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedSensitivity = widget.temperatureSensitivity;
  }

  void _updateData() {
    widget.onChanged(_selectedSensitivity);
  }

  String _getSelectedLabel() {
    final option = _sensitivityOptions.firstWhere(
      (opt) => opt['level'] == _selectedSensitivity.level,
      orElse: () => _sensitivityOptions[1],
    );
    return option['label'];
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'Temperature Sensitivity',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'How do you typically feel in different temperatures?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Sensitivity Options
          ..._sensitivityOptions.map((option) => _buildSensitivityOption(option)),
          
          const SizedBox(height: 32),
          
          // Visual Indicator
          if (_selectedSensitivity.level.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    _getSelectedIcon(),
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getSelectedLabel(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getSelectedDescription(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
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
                    'This helps us adjust outfit recommendations based on how you typically feel in different weather conditions',
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

  Widget _buildSensitivityOption(Map<String, dynamic> option) {
    final isSelected = _selectedSensitivity.level == option['level'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSensitivity = TemperatureSensitivity(
              coldSensitivity: option['coldSensitivity'],
              heatSensitivity: option['heatSensitivity'],
              level: option['level'],
            );
            _updateData();
          });
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF030213) 
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  option['icon'],
                  color: isSelected ? Colors.white : Colors.white70,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option['label'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF030213) : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected 
                            ? const Color(0xFF030213).withOpacity(0.7) 
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF030213),
                  size: 24,
                ),
=======
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Title
              const Text(
                '체온 민감도',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Dropdown Input Field
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isDropdownOpen = !_isDropdownOpen;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thermostat,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getSelectedLabel(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Options Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: _sensitivityOptions.map((option) => _buildOptionCard(option)).toList(),
                ),
              ),
              
              const Spacer(),
>>>>>>> origin/moon
            ],
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
  IconData _getSelectedIcon() {
    final option = _sensitivityOptions.firstWhere(
      (opt) => opt['level'] == _selectedSensitivity.level,
      orElse: () => _sensitivityOptions[1],
    );
    return option['icon'];
  }

  String _getSelectedLabel() {
    final option = _sensitivityOptions.firstWhere(
      (opt) => opt['level'] == _selectedSensitivity.level,
      orElse: () => _sensitivityOptions[1],
    );
    return option['label'];
  }

  String _getSelectedDescription() {
    final option = _sensitivityOptions.firstWhere(
      (opt) => opt['level'] == _selectedSensitivity.level,
      orElse: () => _sensitivityOptions[1],
    );
    return option['description'];
  }
}
=======
  Widget _buildOptionCard(Map<String, dynamic> option) {
    final isSelected = _selectedSensitivity == option['level'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSensitivity = option['level'];
          _isDropdownOpen = false;
        });
        _updateData();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              option['label'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option['description'],
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.grey[600] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
>>>>>>> origin/moon
