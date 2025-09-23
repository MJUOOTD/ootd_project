import 'package:flutter/material.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '알림',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 모든 알림 삭제
            },
            child: const Text(
              '모두 삭제',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 알림 통계
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '새로운 알림',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '3개의 읽지 않은 알림이 있습니다',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 알림 리스트
          ..._buildNotificationList(),
        ],
      ),
    );
  }

  List<Widget> _buildNotificationList() {
    final notifications = [
      {
        'title': '오늘의 날씨 알림',
        'message': '오후 2시부터 비가 예상됩니다. 우산을 챙기세요!',
        'time': '5분 전',
        'isRead': false,
        'type': 'weather',
        'icon': Icons.wb_cloudy,
      },
      {
        'title': '새로운 룩 추천',
        'message': '출근룩 추천이 업데이트되었습니다.',
        'time': '1시간 전',
        'isRead': false,
        'type': 'recommendation',
        'icon': Icons.checkroom,
      },
      {
        'title': 'OOTD 앱 업데이트',
        'message': '새로운 기능이 추가되었습니다. 지금 확인해보세요!',
        'time': '2시간 전',
        'isRead': true,
        'type': 'update',
        'icon': Icons.system_update,
      },
      {
        'title': '온도 변화 알림',
        'message': '오늘 밤 기온이 많이 떨어집니다. 따뜻한 옷을 준비하세요.',
        'time': '3시간 전',
        'isRead': true,
        'type': 'weather',
        'icon': Icons.thermostat,
      },
      {
        'title': '프로필 완성',
        'message': '프로필을 완성하면 더 정확한 추천을 받을 수 있어요!',
        'time': '1일 전',
        'isRead': true,
        'type': 'profile',
        'icon': Icons.person_add,
      },
    ];

    return notifications.map((notification) => _buildNotificationItem(notification)).toList();
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // 알림 클릭 시 처리
          _handleNotificationTap(notification);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  notification['icon'] as IconData,
                  color: _getNotificationColor(notification['type']),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 알림 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification['time'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 더보기 버튼
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'weather':
        return Colors.blue;
      case 'recommendation':
        return Colors.green;
      case 'update':
        return Colors.orange;
      case 'profile':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // 알림 타입에 따른 처리
    switch (notification['type']) {
      case 'weather':
        // 날씨 페이지로 이동
        break;
      case 'recommendation':
        // 추천 페이지로 이동
        break;
      case 'update':
        // 업데이트 정보 페이지로 이동
        break;
      case 'profile':
        // 프로필 페이지로 이동
        break;
      default:
        break;
    }
  }
}
