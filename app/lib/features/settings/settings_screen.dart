import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'providers/settings_providers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _settingsProvider = SettingsProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _settingsProvider.initialize(userProvider.currentUser);
    });
  }

  @override
  void dispose() {
    _settingsProvider.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    
    if (currentUser == null) return;

    final updatedUser = _settingsProvider.getUpdatedUser(currentUser);
    if (updatedUser == null) return;

    try {
      await userProvider.updateUser(updatedUser);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('설정이 저장되었습니다'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _settingsProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('설정'),
          elevation: 0,
        ),
        body: Consumer2<UserProvider, SettingsProvider>(
          builder: (context, userProvider, settingsProvider, child) {
            final user = userProvider.currentUser;
            
            if (user == null) {
              return const Center(
                child: Text('로그인이 필요합니다'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  _buildSectionHeader('프로필'),
                  const SizedBox(height: 16),
                  _buildProfileCard(user),
                  const SizedBox(height: 32),
                  
                  // Gender Selection
                  _buildSectionHeader('성별'),
                  const SizedBox(height: 16),
                  _buildGenderSelection(),
                  const SizedBox(height: 32),
                  
                  // Temperature Sensitivity Selection
                  _buildSectionHeader('체온 민감도'),
                  const SizedBox(height: 16),
                  _buildSensitivitySelection(),
                  const SizedBox(height: 32),
                  
                  // Save Button
                  _buildSaveButton(user),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildProfileCard(user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildReadOnlyField('이름', user.name),
            const SizedBox(height: 16),
            _buildReadOnlyField('이메일', user.email),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('남성'),
                  value: 'male',
                  groupValue: settingsProvider.selectedGender,
                  onChanged: (value) {
                    settingsProvider.updateGender(value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
                RadioListTile<String>(
                  title: const Text('여성'),
                  value: 'female',
                  groupValue: settingsProvider.selectedGender,
                  onChanged: (value) {
                    settingsProvider.updateGender(value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSensitivitySelection() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('추위를 많이 탐'),
                  subtitle: const Text('기준 온도보다 2-3도 높게 추천'),
                  value: 'high',
                  groupValue: settingsProvider.selectedSensitivity,
                  onChanged: (value) {
                    settingsProvider.updateSensitivity(value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
                RadioListTile<String>(
                  title: const Text('보통'),
                  subtitle: const Text('기준 온도 그대로 추천'),
                  value: 'normal',
                  groupValue: settingsProvider.selectedSensitivity,
                  onChanged: (value) {
                    settingsProvider.updateSensitivity(value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
                RadioListTile<String>(
                  title: const Text('더위를 많이 탐'),
                  subtitle: const Text('기준 온도보다 2-3도 낮게 추천'),
                  value: 'low',
                  groupValue: settingsProvider.selectedSensitivity,
                  onChanged: (value) {
                    settingsProvider.updateSensitivity(value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton(user) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final hasChanges = settingsProvider.hasChanges(user);
        final isValid = settingsProvider.isValid;
        final isLoading = settingsProvider.isLoading;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (hasChanges && isValid && !isLoading) ? _saveSettings : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '설정 저장',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
