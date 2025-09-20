import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';
import '../providers/user_provider.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/weather_widget.dart';
import '../widgets/outfit_recommendation_widget.dart';
import '../widgets/recommendation_message_widget.dart';
import 'outfit_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final weatherProvider = ref.read(weatherProviderProvider.notifier);
    final userProvider = ref.read(userProviderProvider.notifier);
    final recommendationProvider = ref.read(recommendationProviderProvider.notifier);

    // Fetch weather data
    await weatherProvider.fetchCurrentWeather();

    // Generate recommendations if user is logged in and weather is available
    if (userProvider.isLoggedIn && weatherProvider.hasWeather) {
      await recommendationProvider.generateRecommendations(
        weather: weatherProvider.currentWeather!,
        user: userProvider.currentUser!,
      );
    }
  }

  Future<void> _refreshData() async {
    final weatherProvider = ref.read(weatherProviderProvider.notifier);
    final userProvider = ref.read(userProviderProvider.notifier);
    final recommendationProvider = ref.read(recommendationProviderProvider.notifier);

    // Refresh weather data
    await weatherProvider.refreshWeather();

    // Refresh recommendations
    if (userProvider.isLoggedIn && weatherProvider.hasWeather) {
      await recommendationProvider.refreshRecommendations(
        weather: weatherProvider.currentWeather!,
        user: userProvider.currentUser!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'OOTD',
          style: TextStyle(
            color: Color(0xFF030213),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF030213)),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer(
          builder: (context, ref, child) {
            final weatherProvider = ref.watch(weatherProviderProvider);
            final userProvider = ref.watch(userProviderProvider);
            final recommendationProvider = ref.watch(recommendationProviderProvider);
            if (weatherProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (weatherProvider.error != null) {
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
                      'Error: ${weatherProvider.error}',
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
                  // Greeting
                  _buildGreeting(userProvider.currentUser),
                  
                  const SizedBox(height: 24),
                  
                  // Weather Widget
                  if (weatherProvider.hasWeather)
                    WeatherWidget(weather: weatherProvider.currentWeather!),
                  
                  const SizedBox(height: 24),
                  
                  // Recommendation Message
                  if (weatherProvider.hasWeather)
                    RecommendationMessageWidget(weather: weatherProvider.currentWeather!),
                  
                  const SizedBox(height: 24),
                  
                  // Outfit Recommendations
                  if (userProvider.isLoggedIn)
                    _buildRecommendationsSection(recommendationProvider)
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

  Widget _buildGreeting(user) {
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

  Widget _buildRecommendationsSection(RecommendationProvider recommendationProvider) {
    if (recommendationProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (recommendationProvider.error != null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error: ${recommendationProvider.error}'),
          ],
        ),
      );
    }

    if (!recommendationProvider.hasRecommendations) {
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
          recommendation: recommendationProvider.selectedRecommendation!,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OutfitDetailScreen(
                  recommendation: recommendationProvider.selectedRecommendation!,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildRecommendationControls(recommendationProvider),
      ],
    );
  }

  Widget _buildRecommendationControls(RecommendationProvider recommendationProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: recommendationProvider.previousRecommendation,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF030213),
          ),
        ),
        Text(
          '${recommendationProvider.recommendations.indexOf(recommendationProvider.selectedRecommendation!) + 1} of ${recommendationProvider.recommendations.length}',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: recommendationProvider.nextRecommendation,
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
