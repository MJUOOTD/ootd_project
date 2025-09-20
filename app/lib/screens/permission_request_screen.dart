import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';

class PermissionRequestScreen extends StatefulWidget {
  const PermissionRequestScreen({super.key});

  @override
  State<PermissionRequestScreen> createState() => _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
  bool _locationPermissionGranted = false;
  bool _notificationPermissionGranted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final locationStatus = await Permission.location.status;
    final notificationStatus = await Permission.notification.status;
    
    setState(() {
      _locationPermissionGranted = locationStatus.isGranted;
      _notificationPermissionGranted = notificationStatus.isGranted;
    });
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    final status = await Permission.location.request();
    
    setState(() {
      _locationPermissionGranted = status.isGranted;
      _isLoading = false;
    });

    if (!status.isGranted) {
      _showPermissionDeniedDialog('위치');
    }
  }

  Future<void> _requestNotificationPermission() async {
    setState(() {
      _isLoading = true;
    });

    final status = await Permission.notification.request();
    
    setState(() {
      _notificationPermissionGranted = status.isGranted;
      _isLoading = false;
    });

    if (!status.isGranted) {
      _showPermissionDeniedDialog('알림');
    }
  }

  void _showPermissionDeniedDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionType 권한이 필요합니다'),
        content: Text(
          permissionType == '위치' 
            ? '현 위치 날씨 정보를 불러오기 위해 위치 권한이 필요합니다.'
            : '날씨 변화와 옷차림 추천 알림을 받기 위해 알림 권한이 필요합니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('권한 켜기'),
          ),
        ],
      ),
    );
  }

  void _continueToOnboarding() {
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Title
              const Text(
                '앱 사용을 위한\n권한이 필요해요',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF030213),
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                '더 나은 서비스를 제공하기 위해\n다음 권한들이 필요합니다.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Location Permission
              _buildPermissionCard(
                icon: Icons.location_on,
                title: '위치 서비스',
                description: '현 위치 기반 날씨 정보 수집',
                isGranted: _locationPermissionGranted,
                onRequest: _requestLocationPermission,
              ),
              
              const SizedBox(height: 20),
              
              // Notification Permission
              _buildPermissionCard(
                icon: Icons.notifications,
                title: '알림',
                description: '날씨 변화 및 옷차림 추천 알림',
                isGranted: _notificationPermissionGranted,
                onRequest: _requestNotificationPermission,
              ),
              
              const Spacer(),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continueToOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF030213),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '계속하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onRequest,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted ? const Color(0xFF4CAF50) : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isGranted 
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isGranted ? const Color(0xFF4CAF50) : Colors.grey[600],
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF030213),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          if (isGranted)
            const Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
              size: 24,
            )
          else
            TextButton(
              onPressed: onRequest,
              child: const Text(
                '허용',
                style: TextStyle(
                  color: Color(0xFF030213),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
