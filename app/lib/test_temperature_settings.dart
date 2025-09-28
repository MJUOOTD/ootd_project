// 온도 설정 테스트 코드
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/temperature_settings_provider.dart';
import 'models/temperature_settings_model.dart';
import 'services/service_locator.dart';

/// 온도 설정 테스트 화면
class TemperatureSettingsTestScreen extends ConsumerStatefulWidget {
  const TemperatureSettingsTestScreen({super.key});

  @override
  ConsumerState<TemperatureSettingsTestScreen> createState() => _TemperatureSettingsTestScreenState();
}

class _TemperatureSettingsTestScreenState extends ConsumerState<TemperatureSettingsTestScreen> {
  @override
  void initState() {
    super.initState();
    // 온도 설정 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
      ref.read(temperatureSettingsProvider.notifier).initialize();
    });
  }

  void _checkAuthStatus() {
    final authService = serviceLocator.authService;
    // 인증 상태 확인 (디버그용)
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(temperatureSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('온도 설정 테스트'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상태 표시
            _buildStatusCard(settingsState),
            const SizedBox(height: 20),
            
            // 테스트 버튼들
            _buildTestButtons(settingsState),
            const SizedBox(height: 20),
            
            // 현재 설정 표시
            if (settingsState.settings != null) ...[
              const Text(
                '현재 설정:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildSettingsCard(settingsState.settings!),
            ],
            
            // 에러 표시
            if (settingsState.error != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '에러: ${settingsState.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(TemperatureSettingsState state) {
    Color statusColor;
    String statusText;
    
    if (state.isLoading) {
      statusColor = Colors.orange;
      statusText = '로딩 중...';
    } else if (state.error != null) {
      statusColor = Colors.red;
      statusText = '에러 발생';
    } else if (state.settings != null) {
      statusColor = Colors.green;
      statusText = '설정 로드됨';
    } else {
      statusColor = Colors.grey;
      statusText = '초기화 대기 중';
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '상태: $statusText',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButtons(TemperatureSettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '테스트 기능:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: state.isLoading ? null : () {
                ref.read(temperatureSettingsProvider.notifier).refresh();
              },
              child: const Text('새로고침'),
            ),
            ElevatedButton(
              onPressed: state.isLoading ? null : () {
                _testCreateSettings();
              },
              child: const Text('새 설정 생성'),
            ),
            ElevatedButton(
              onPressed: state.isLoading ? null : () {
                _testUpdateSettings();
              },
              child: const Text('설정 업데이트'),
            ),
            ElevatedButton(
              onPressed: state.isLoading ? null : () {
                _testPersonalizedCalculation();
              },
              child: const Text('개인화 계산 테스트'),
            ),
            ElevatedButton(
              onPressed: state.isLoading ? null : () {
                ref.read(temperatureSettingsProvider.notifier).resetToDefault();
              },
              child: const Text('기본값으로 리셋'),
            ),
            ElevatedButton(
              onPressed: () {
                _checkAuthStatus();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('인증 상태를 확인했습니다')),
                );
              },
              child: const Text('인증 상태 확인'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsCard(TemperatureSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingRow('온도 감도', '${settings.temperatureSensitivity}'),
            _buildSettingRow('추위 감수성', settings.coldTolerance),
            _buildSettingRow('더위 감수성', settings.heatTolerance),
            _buildSettingRow('나이', settings.age?.toString() ?? '미설정'),
            _buildSettingRow('성별', settings.gender ?? '미설정'),
            _buildSettingRow('활동량', settings.activityLevel),
            _buildSettingRow('생성일', settings.createdAt.toString().split('.')[0]),
            _buildSettingRow('수정일', settings.updatedAt.toString().split('.')[0]),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _testCreateSettings() {
    final testSettings = TemperatureSettings(
      temperatureSensitivity: 1.2,
      coldTolerance: 'high',
      heatTolerance: 'low',
      age: 30,
      gender: 'female',
      activityLevel: 'moderate',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    ref.read(temperatureSettingsProvider.notifier).createSettings(testSettings);
  }

  void _testUpdateSettings() {
    final currentSettings = ref.read(temperatureSettingsProvider).settings;
    if (currentSettings == null) return;
    
    final updatedSettings = currentSettings.copyWith(
      temperatureSensitivity: 1.1,
      coldTolerance: 'normal',
      age: 25,
      updatedAt: DateTime.now(),
    );
    
    ref.read(temperatureSettingsProvider.notifier).updateSettings(updatedSettings);
  }

  void _testPersonalizedCalculation() {
    final settings = ref.read(temperatureSettingsProvider).settings;
    if (settings == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정이 없습니다. 먼저 설정을 로드하세요.')),
      );
      return;
    }
    
    // 테스트 온도들
    final testTemperatures = [0.0, 15.0, 25.0, 35.0];
    final results = <String>[];
    
    for (final temp in testTemperatures) {
      final personalized = ref.read(temperatureSettingsProvider.notifier)
          .calculatePersonalizedFeelsLike(temp);
      results.add('${temp}°C → ${personalized.toStringAsFixed(1)}°C');
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인화 체감온도 계산 결과'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: results.map((result) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(result),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
