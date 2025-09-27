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
      'level': TemperatureSensitivity.veryCold,
      'label': '매우 추위를 많이 탐',
      'description': '평소보다 두꺼운 옷을 추천해드려요',
      'coldSensitivity': -1.0,
      'heatSensitivity': 0.0,
      'icon': Icons.ac_unit,
      'color': Colors.blue,
    },
    {
      'level': TemperatureSensitivity.cold,
      'label': '추위를 많이 탐',
      'description': '평소보다 따뜻한 옷을 추천해드려요',
      'coldSensitivity': -0.5,
      'heatSensitivity': 0.0,
      'icon': Icons.thermostat,
      'color': Colors.lightBlue,
    },
    {
      'level': TemperatureSensitivity.normal,
      'label': '보통',
      'description': '일반적인 옷차림을 추천해드려요',
      'coldSensitivity': 0.0,
      'heatSensitivity': 0.0,
      'icon': Icons.thermostat_auto,
      'color': Colors.green,
    },
    {
      'level': TemperatureSensitivity.hot,
      'label': '더위를 많이 탐',
      'description': '평소보다 시원한 옷을 추천해드려요',
      'coldSensitivity': 0.0,
      'heatSensitivity': 0.5,
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
    },
    {
      'level': TemperatureSensitivity.veryHot,
      'label': '매우 더위를 많이 탐',
      'description': '평소보다 매우 시원한 옷을 추천해드려요',
      'coldSensitivity': 0.0,
      'heatSensitivity': 1.0,
      'icon': Icons.wb_sunny_outlined,
      'color': Colors.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedSensitivity = widget.temperatureSensitivity;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '체감온도 설정',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '개인별 체감온도에 맞는 옷차림을 추천해드려요',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 32),
          
          // Sensitivity Options
          Expanded(
            child: ListView.builder(
              itemCount: _sensitivityOptions.length,
              itemBuilder: (context, index) {
                final option = _sensitivityOptions[index];
                final isSelected = _selectedSensitivity == option['level'];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedSensitivity = option['level'];
                        });
                        widget.onChanged(_selectedSensitivity);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? (option['color'] as Color).withOpacity(0.1)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                                ? option['color'] as Color
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? option['color'] as Color
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                option['icon'] as IconData,
                                color: isSelected ? Colors.white : Colors.grey[600],
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['label'] as String,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected 
                                          ? option['color'] as Color
                                          : const Color(0xFF2C3E50),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option['description'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected 
                                          ? (option['color'] as Color).withOpacity(0.8)
                                          : const Color(0xFF7F8C8D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: option['color'] as Color,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Temperature Scale
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '체감온도 기준',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTemperatureIndicator(
                        '매우 추위',
                        Colors.blue,
                        -1.0,
                      ),
                    ),
                    Expanded(
                      child: _buildTemperatureIndicator(
                        '추위',
                        Colors.lightBlue,
                        -0.5,
                      ),
                    ),
                    Expanded(
                      child: _buildTemperatureIndicator(
                        '보통',
                        Colors.green,
                        0.0,
                      ),
                    ),
                    Expanded(
                      child: _buildTemperatureIndicator(
                        '더위',
                        Colors.orange,
                        0.5,
                      ),
                    ),
                    Expanded(
                      child: _buildTemperatureIndicator(
                        '매우 더위',
                        Colors.red,
                        1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureIndicator(String label, Color color, double value) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF7F8C8D),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}