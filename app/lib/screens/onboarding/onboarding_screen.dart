import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../screens/main_navigation.dart';
import 'onboarding_steps/basic_info_step.dart';
import 'onboarding_steps/body_info_step.dart';
import 'onboarding_steps/temperature_sensitivity_step.dart';
import 'onboarding_steps/style_preferences_step.dart';
import 'onboarding_steps/situation_preferences_step.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Onboarding data
  String _name = '';
  String _email = '';
  String _gender = 'male';
  int _age = 25;
  String _bodyType = 'average';
  String _activityLevel = 'moderate';
  TemperatureSensitivity _temperatureSensitivity = TemperatureSensitivity.normal;
  List<String> _stylePreferences = [];
  Map<String, dynamic> _situationPreferences = {};

  final List<Widget> _steps = [];

  @override
  void initState() {
    super.initState();
    _initializeSteps();
  }

  void _initializeSteps() {
    _steps.addAll([
      BasicInfoStep(
        name: _name,
        email: _email,
        gender: _gender,
        age: _age,
        onChanged: (name, email, gender, age) {
          setState(() {
            _name = name;
            _email = email;
            _gender = gender;
            _age = age;
          });
        },
      ),
      BodyInfoStep(
        bodyType: _bodyType,
        activityLevel: _activityLevel,
        onChanged: (bodyType, activityLevel) {
          setState(() {
            _bodyType = bodyType;
            _activityLevel = activityLevel;
          });
        },
      ),
      TemperatureSensitivityStep(
        temperatureSensitivity: _temperatureSensitivity,
        onChanged: (sensitivity) {
          setState(() {
            _temperatureSensitivity = sensitivity;
          });
        },
      ),
      StylePreferencesStep(
        selectedPreferences: _stylePreferences,
        onChanged: (preferences) {
          setState(() {
            _stylePreferences = preferences;
          });
        },
      ),
      SituationPreferencesStep(
        preferences: _situationPreferences,
        onChanged: (preferences) {
          setState(() {
            _situationPreferences = preferences;
          });
        },
      ),
    ]);
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    final user = userProvider.createUser(
      name: _name,
      email: _email,
      gender: _gender,
      age: _age,
      bodyType: _bodyType,
      activityLevel: _activityLevel,
      temperatureSensitivity: _temperatureSensitivity,
      stylePreferences: _stylePreferences,
      situationPreferences: _situationPreferences,
    );

    await userProvider.completeOnboarding(user);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030213),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${_currentStep + 1} of $_totalSteps',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / _totalSteps,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                itemCount: _totalSteps,
                itemBuilder: (context, index) {
                  return _steps[index];
                },
              ),
            ),
            
            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _previousStep,
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 60),
                  
                  ElevatedButton(
                    onPressed: _isStepValid() ? _nextStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF030213),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _currentStep == _totalSteps - 1 ? 'Complete' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isStepValid() {
    switch (_currentStep) {
      case 0: // Basic Info
        return _name.isNotEmpty && _email.isNotEmpty;
      case 1: // Body Info
        return _bodyType.isNotEmpty && _activityLevel.isNotEmpty;
      case 2: // Temperature Sensitivity
        return true; // Always has a default value
      case 3: // Style Preferences
        return _stylePreferences.isNotEmpty;
      case 4: // Situation Preferences
        return true; // Optional
      default:
        return false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
