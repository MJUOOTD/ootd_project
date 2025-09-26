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
  late String _selectedSensitivity;
  bool _isDropdownOpen = false;

  final List<Map<String, dynamic>> _sensitivityOptions = [
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
    _selectedSensitivity = widget.temperatureSensitivity.level;
  }

  void _updateData() {
    final option = _sensitivityOptions.firstWhere(
      (opt) => opt['level'] == _selectedSensitivity,
      orElse: () => _sensitivityOptions[1],
    );
    
    final newSensitivity = TemperatureSensitivity(
      coldSensitivity: option['coldSensitivity'],
      heatSensitivity: option['heatSensitivity'],
      level: option['level'],
    );
    
    widget.onChanged(newSensitivity);
  }

  String _getSelectedLabel() {
    final option = _sensitivityOptions.firstWhere(
      (opt) => opt['level'] == _selectedSensitivity,
      orElse: () => _sensitivityOptions[1],
    );
    return option['label'];
  }

  @override
  Widget build(BuildContext context) {
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
            ],
          ),
        ),
      ),
    );
  }

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