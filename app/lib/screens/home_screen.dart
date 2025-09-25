import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';
import '../providers/user_provider.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/weather_widget.dart';
import '../widgets/outfit_recommendation_widget.dart';
import '../widgets/hourly_recommendation_widget.dart';
import '../widgets/situation_recommendation_widget.dart';
import 'outfit_detail_screen.dart';
import 'notification_list_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // It's safer to call this after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    // ChangeNotifierProvider는 .notifier가 아닌 인스턴스에 직접 호출
    final weatherSvc = ref.read(weatherProvider);
    await weatherSvc.fetchCurrentWeather();
    if (!mounted) return;

    // Read the provider's state to check values.
    final userState = ref.read(userProvider);
    final weatherState = ref.read(weatherProvider);

    // Check conditions using the state objects.
    if (userState.isLoggedIn && weatherState.hasWeather) {
      await ref.read(recommendationProvider.notifier).generateRecommendations(
        weather: weatherState.currentWeather!,
        user: userState.currentUser!,
      );
      if (!mounted) return;
    }
  }

  Future<void> _refreshData() async {
    // ChangeNotifierProvider는 .notifier가 아닌 인스턴스에 직접 호출
    final weatherSvc = ref.read(weatherProvider);
    await weatherSvc.refreshWeather();
    if (!mounted) return;

    final userState = ref.read(userProvider);
    final weatherState = ref.read(weatherProvider);

    if (userState.isLoggedIn && weatherState.hasWeather) {
      await ref.read(recommendationProvider.notifier).refreshRecommendations(
        weather: weatherState.currentWeather!,
        user: userState.currentUser!,
      );
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'OOTD',
              style: TextStyle(
                color:  Color.fromARGB(239, 107, 141, 252),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color.fromARGB(255, 225, 204, 126), size: 24),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationListScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Color.fromARGB(255, 75, 70, 70), size: 24),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer(
          builder: (context, ref, child) {
            // Use `ref.watch` to get the state and rebuild on changes.
            // Note the corrected provider names.
            final weatherState = ref.watch(weatherProvider);
            final userState = ref.watch(userProvider);
            final recommendationState = ref.watch(recommendationProvider);
            if (weatherState.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (weatherState.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${weatherState.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pass state properties to widgets.
                  _buildGreeting(userState.currentUser),
                  
                  const SizedBox(height: 24),
                  
                  if (weatherState.hasWeather)
                    const WeatherWidget(),
                  
                  const SizedBox(height: 24),
                  
                  const HourlyRecommendationWidget(),
                  
                  const SizedBox(height: 24),
                  
                  const SituationRecommendationWidget(),
                  
                  const SizedBox(height: 24),
                  
                  // Use state to conditionally show widgets.
                  if (userState.isLoggedIn)
                    _buildRecommendationsSection(recommendationState)
                  else
                    _buildLoginPrompt(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGreeting(dynamic user) { // Using dynamic for user model type safety
    final time = DateTime.now().hour;
    String greeting;
    
    if (time < 12) {
      greeting = 'Good Morning';
    } else if (time < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF030213),
          ),
        ),
        Text(
          user?.name ?? 'User',
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(dynamic recommendationState) {
    if (recommendationState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (recommendationState.error != null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error: ${recommendationState.error}'),
          ],
        ),
      );
    }

    if (!recommendationState.hasRecommendations) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No recommendations available'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Recommendations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF030213),
          ),
        ),
        const SizedBox(height: 16),
        OutfitRecommendationWidget(
          recommendation: recommendationState.selectedRecommendation!,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OutfitDetailScreen(
                  recommendation: recommendationState.selectedRecommendation!,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildRecommendationControls(recommendationState),
      ],
    );
  }

  Widget _buildRecommendationControls(dynamic recommendationState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          // Call actions on the notifier.
          onPressed: ref.read(recommendationProvider.notifier).previousRecommendation,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF030213),
          ),
        ),
        Text(
          '${recommendationState.recommendations.indexOf(recommendationState.selectedRecommendation!) + 1} of ${recommendationState.recommendations.length}',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          // Call actions on the notifier.
          onPressed: ref.read(recommendationProvider.notifier).nextRecommendation,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF030213),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_outline,
            size: 48,
            color: Color(0xFF030213),
          ),
          const SizedBox(height: 16),
          const Text(
            'Complete your profile to get personalized outfit recommendations',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to settings/profile
              Navigator.of(context).pushNamed('/settings');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF030213),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Complete Profile'),
          ),
        ],
      ),
    );
  }
}
