import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../theme/app_theme.dart';

class BasicInfoStep extends ConsumerStatefulWidget {
  const BasicInfoStep({super.key});

  @override
  ConsumerState<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends ConsumerState<BasicInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = '';

  @override
  void initState() {
    super.initState();
    // Load existing data if available
    final data = ref.read(onboardingProvider);
    _nameController.text = data.name;
    _emailController.text = data.email;
    _ageController.text = data.age > 0 ? data.age.toString() : '';
    _selectedGender = data.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _updateData() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 0;

    ref.read(onboardingProvider.notifier)
      ..updateName(name)
      ..updateEmail(email)
      ..updateGender(_selectedGender)
      ..updateAge(age);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = ref.watch(basicInfoValidationProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기본 정보를 입력해주세요',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '더 정확한 추천을 위해 필요한 정보입니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          
          // Name field
          Text(
            '이름',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: '이름을 입력해주세요',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '이름을 입력해주세요';
              }
              return null;
            },
            onChanged: (_) => _updateData(),
          ),
          const SizedBox(height: 24),

          // Email field
          Text(
            '이메일',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: '이메일을 입력해주세요',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '이메일을 입력해주세요';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return '올바른 이메일 형식을 입력해주세요';
              }
              return null;
            },
            onChanged: (_) => _updateData(),
          ),
          const SizedBox(height: 24),

          // Gender selection
          Text(
            '성별',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _GenderOption(
                  label: '남성',
                  value: 'male',
                  isSelected: _selectedGender == 'male',
                  onTap: () {
                    setState(() {
                      _selectedGender = 'male';
                    });
                    _updateData();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GenderOption(
                  label: '여성',
                  value: 'female',
                  isSelected: _selectedGender == 'female',
                  onTap: () {
                    setState(() {
                      _selectedGender = 'female';
                    });
                    _updateData();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Age field
          Text(
            '나이',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '나이를 입력해주세요',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '나이를 입력해주세요';
              }
              final age = int.tryParse(value);
              if (age == null || age < 1 || age > 120) {
                return '올바른 나이를 입력해주세요';
              }
              return null;
            },
            onChanged: (_) => _updateData(),
          ),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: AppTheme.borderRadiusAll,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

