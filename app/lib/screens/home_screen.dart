import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';
import '../providers/user_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/location_permission_provider.dart';
import '../widgets/weather_widget.dart';
import '../widgets/hourly_recommendation_widget.dart';
import '../widgets/situation_recommendation_widget.dart';
import 'notification_list_screen.dart';
import 'cart_screen.dart';
import '../widgets/feedback_modal.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isNotificationDismissed = false;

  @override
  void initState() {
    super.initState();
    // It's safer to call this after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _checkLocationPermission();
    });
  }

  Future<void> _checkLocationPermission() async {
    // 위치 권한 상태를 다시 확인
    await ref.read(locationPermissionProvider.notifier).checkAndRequestPermission();
  }

  Future<void> _initializeData() async {
    // WeatherProvider의 notifier를 통해 메서드 호출
    await ref.read(weatherProvider.notifier).fetchCurrentWeather();

    if (!mounted) return;

    // Read the provider's state to check values.
    final userState = ref.read(userProvider);
    final weatherState = ref.read(weatherProvider);

    // 추천 생성 (날씨가 있으면 항상)
    if (weatherState.currentWeather != null) {
      // 로그인된 경우에만 추천 생성
      if (userState.isLoggedIn) {
        await ref.read(recommendationProvider.notifier).generateRecommendations(
          weather: weatherState.currentWeather!,
          user: userState.currentUser!,
        );
        if (!mounted) return;
      }
    }
  }

  Future<void> _refreshData() async {
    // WeatherProvider의 notifier를 통해 메서드 호출
    await ref.read(weatherProvider.notifier).refreshWeather();

    if (!mounted) return;

    final userState = ref.read(userProvider);
    final weatherState = ref.read(weatherProvider);

    // 추천 새로고침 (날씨가 있으면 항상)
    if (weatherState.currentWeather != null) {
      // 로그인된 경우에만 추천 새로고침
      if (userState.isLoggedIn) {
        await ref.read(recommendationProvider.notifier).refreshRecommendations(
          weather: weatherState.currentWeather!,
          user: userState.currentUser!,
        );
        if (!mounted) return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OOTD',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A90E2),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF030213)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF030213)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF030213)),
            onSelected: (value) {
              switch (value) {
                case 'feedback':
                  showDialog(
                    context: context,
                    builder: (context) => const FeedbackModal(),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'feedback',
                child: Text('피드백 보내기'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final weatherState = ref.watch(weatherProvider);
          final userState = ref.watch(userProvider);
          final locationPermissionState = ref.watch(locationPermissionProvider);
          
          
          // 위치 권한 상태 변화 감지 (build 메서드에서만 ref.listen 사용 가능)
          ref.listen<LocationPermissionState>(locationPermissionProvider, (previous, next) {
            if (next.isGranted && _isNotificationDismissed) {
              // 권한이 허용되면 알림 상태 리셋
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isNotificationDismissed = false;
                  });
                }
              });
            }
          });
          
          // 메인 페이지 내용 (항상 표시)
          return Stack(
            children: [
              // 메인 페이지 내용 (무조건 표시)
              RefreshIndicator(
                onRefresh: _refreshData,
                child: _buildMainContent(weatherState, userState),
              ),
              // 위치 권한 거부 시 우측 상단 알림 (권한이 거부되거나 불명확하고 닫히지 않은 경우에만)
              if ((locationPermissionState.isDenied || locationPermissionState.isDeniedForever || locationPermissionState.isUnknown) && !_isNotificationDismissed)
                _buildLocationPermissionNotification(context, ref),
            ],
          );
        },
      ),
    );
  }

  /// 메인 페이지 내용 구성
  Widget _buildMainContent(WeatherState weatherState, UserState userState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          
          // 현재 날씨 섹션
          if (weatherState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (weatherState.currentWeather != null)
            WeatherWidget(
              weather: weatherState.currentWeather!,
              onRefresh: () => ref.read(weatherProvider.notifier).refreshWeather(),
            )
          else
            _buildWeatherErrorSection(weatherState.error ?? '날씨 정보를 가져올 수 없습니다'),
                  
          const SizedBox(height: 24),
          
          // 추천 섹션 (항상 표시)
          _buildRecommendationsSection(),
        ],
      ),
    );
  }

  /// 날씨 에러 섹션
  Widget _buildWeatherErrorSection(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(weatherProvider.notifier).fetchCurrentWeather();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF030213),
              foregroundColor: Colors.white,
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  /// 추천 섹션 구성
  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '오늘의 추천',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF030213),
          ),
        ),
        const SizedBox(height: 16),
        // 시간대별 추천 (항상 표시)
        const HourlyRecommendationWidget(),
        const SizedBox(height: 24),
        // 상황별 추천 (항상 표시)
        const SituationRecommendationWidget(),
      ],
    );
  }

  /// 위치 권한 거부 우측 상단 알림 위젯
  Widget _buildLocationPermissionNotification(BuildContext context, WidgetRef ref) {
    return Positioned(
      top: 7,
      right: 16,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_off, size: 20, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  '위치 권한 필요',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isNotificationDismissed = true;
                    });
                  },
                  child: const Icon(Icons.close, size: 18, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '정확한 날씨 정보를 위해 위치 권한을 허용해주세요.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

}