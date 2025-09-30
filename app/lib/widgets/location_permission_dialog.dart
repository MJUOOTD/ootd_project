import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.location_on, color: Colors.blue),
          SizedBox(width: 8),
          Text('위치 권한 필요'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '정확한 날씨 정보를 제공하기 위해 위치 정보가 필요합니다.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Text(
            '• 현재 위치의 실시간 날씨 정보 제공\n'
            '• 개인화된 옷차림 추천\n'
            '• 정확한 날씨 예보',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('나중에'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop(true);
            await _requestLocationPermission(context);
          },
          child: const Text('권한 허용'),
        ),
      ],
    );
  }

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const LocationPermissionDialog(),
    );
    return result ?? false;
  }

  static Future<void> _requestLocationPermission(BuildContext context) async {
    try {
      final permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        _showPermissionDeniedDialog(context);
      } else if (permission == LocationPermission.deniedForever) {
        _showPermissionPermanentlyDeniedDialog(context);
      } else {
        _showPermissionGrantedDialog(context);
      }
    } catch (e) {
      _showPermissionErrorDialog(context, e.toString());
    }
  }

  static void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위치 권한 거부됨'),
        content: const Text('위치 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  static void _showPermissionPermanentlyDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위치 권한 영구 거부됨'),
        content: const Text('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 직접 권한을 허용해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openAppSettings();
            },
            child: const Text('설정 열기'),
          ),
        ],
      ),
    );
  }

  static void _showPermissionGrantedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위치 권한 허용됨'),
        content: const Text('위치 권한이 허용되었습니다. 이제 정확한 날씨 정보를 받을 수 있습니다.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  static void _showPermissionErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류 발생'),
        content: Text('위치 권한 요청 중 오류가 발생했습니다: $error'),
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
