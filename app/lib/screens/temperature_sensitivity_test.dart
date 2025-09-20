import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class TemperatureSensitivityTest extends ConsumerStatefulWidget {
  const TemperatureSensitivityTest({super.key});

  @override
  ConsumerState<TemperatureSensitivityTest> createState() => _TemperatureSensitivityTestState();
}

class _TemperatureSensitivityTestState extends ConsumerState<TemperatureSensitivityTest> {
  int _currentQuestion = 0;
  Map<int, int> _answers = {};
  
  final List<Map<String, dynamic>> _questions = [
    {
      'question': '겨울철 실외에서 5분 정도 기다릴 때 어떤가요?',
      'options': [
        {'text': '매우 춥다', 'cold': 0.8, 'heat': 0.0},
        {'text': '조금 춥다', 'cold': 0.4, 'heat': 0.0},
        {'text': '적당하다', 'cold': 0.0, 'heat': 0.0},
        {'text': '조금 덥다', 'cold': 0.0, 'heat': 0.4},
        {'text': '매우 덥다', 'cold': 0.0, 'heat': 0.8},
      ]
    },
    {
      'question': '여름철 30도 날씨에서 실외 활동 시 어떤가요?',
      'options': [
        {'text': '매우 시원하다', 'cold': 0.0, 'heat': -0.8},
        {'text': '조금 시원하다', 'cold': 0.0, 'heat': -0.4},
        {'text': '적당하다', 'cold': 0.0, 'heat': 0.0},
        {'text': '조금 덥다', 'cold': 0.0, 'heat': 0.4},
        {'text': '매우 덥다', 'cold': 0.0, 'heat': 0.8},
      ]
    },
    {
      'question': '실내 온도 22도에서 어떤가요?',
      'options': [
        {'text': '추워서 옷을 더 입고 싶다', 'cold': 0.6, 'heat': 0.0},
        {'text': '조금 시원하다', 'cold': 0.3, 'heat': 0.0},
        {'text': '완벽하다', 'cold': 0.0, 'heat': 0.0},
        {'text': '조금 덥다', 'cold': 0.0, 'heat': 0.3},
        {'text': '더워서 옷을 벗고 싶다', 'cold': 0.0, 'heat': 0.6},
      ]
    },
    {
      'question': '가을철 18도 날씨에서 어떤가요?',
      'options': [
        {'text': '매우 춥다', 'cold': 0.7, 'heat': 0.0},
        {'text': '조금 춥다', 'cold': 0.3, 'heat': 0.0},
        {'text': '적당하다', 'cold': 0.0, 'heat': 0.0},
        {'text': '조금 덥다', 'cold': 0.0, 'heat': 0.3},
        {'text': '매우 덥다', 'cold': 0.0, 'heat': 0.7},
      ]
    },
    {
      'question': '에어컨이 켜진 실내(24도)에서 어떤가요?',
      'options': [
        {'text': '추워서 겉옷이 필요하다', 'cold': 0.5, 'heat': 0.0},
        {'text': '조금 시원하다', 'cold': 0.2, 'heat': 0.0},
        {'text': '적당하다', 'cold': 0.0, 'heat': 0.0},
        {'text': '조금 덥다', 'cold': 0.0, 'heat': 0.2},
        {'text': '더워서 에어컨을 더 켜고 싶다', 'cold': 0.0, 'heat': 0.5},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030213),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '체온 민감도 테스트',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: (_currentQuestion + 1) / _questions.length,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              
              const SizedBox(height: 32),
              
              // Question
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${_currentQuestion + 1}/${_questions.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _questions[_currentQuestion]['question'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    
                    // Options
                    ..._questions[_currentQuestion]['options'].asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = _answers[_currentQuestion] == index;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _answers[_currentQuestion] = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              option['text'],
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF030213) : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              
              // Navigation Buttons
              Row(
                children: [
                  if (_currentQuestion > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousQuestion,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          '이전',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  
                  if (_currentQuestion > 0) const SizedBox(width: 16),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _answers.containsKey(_currentQuestion) ? _nextQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF030213),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentQuestion == _questions.length - 1 ? '완료' : '다음',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
      });
    } else {
      _completeTest();
    }
  }

  void _completeTest() {
    // Calculate sensitivity scores
    double coldSensitivity = 0.0;
    double heatSensitivity = 0.0;
    
    for (int i = 0; i < _questions.length; i++) {
      final answerIndex = _answers[i] ?? 0;
      final option = _questions[i]['options'][answerIndex];
      coldSensitivity += option['cold'] as double;
      heatSensitivity += option['heat'] as double;
    }
    
    // Average the scores
    coldSensitivity /= _questions.length;
    heatSensitivity /= _questions.length;
    
    // Determine sensitivity level
    String level = 'normal';
    if (coldSensitivity > 0.3) {
      level = 'low'; // 추위를 많이 탐
    } else if (heatSensitivity > 0.3) {
      level = 'high'; // 더위를 많이 탐
    }
    
    // Update user profile
    final userProvider = ref.read(userProviderProvider.notifier);
    final currentUser = userProvider.currentUser;
    
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        temperatureSensitivity: TemperatureSensitivity(
          coldSensitivity: coldSensitivity,
          heatSensitivity: heatSensitivity,
          level: level,
        ),
        updatedAt: DateTime.now(),
      );
      
      userProvider.updateUser(updatedUser);
    }
    
    // Show results
    _showResults(coldSensitivity, heatSensitivity, level);
  }

  void _showResults(double coldSensitivity, double heatSensitivity, String level) {
    String sensitivityText = '보통';
    String description = '일반적인 체온 민감도를 가지고 있습니다.';
    
    if (level == 'low') {
      sensitivityText = '추위를 많이 탐';
      description = '추위에 민감하므로 다른 사람보다 옷을 더 따뜻하게 입어야 합니다.';
    } else if (level == 'high') {
      sensitivityText = '더위를 많이 탐';
      description = '더위에 민감하므로 다른 사람보다 옷을 더 시원하게 입어야 합니다.';
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('테스트 완료'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '체온 민감도: $sensitivityText',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
