import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/home_providers.dart';
import 'widgets/weather_card.dart';
import 'widgets/outfit_recommendation.dart' as outfit_widget;
import 'widgets/weather_message_banner.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).loadData();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(homeProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OOTD'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting section
              _buildGreetingSection(theme),
              const SizedBox(height: 24),

              // Weather card
              const WeatherCard(),
              const SizedBox(height: 24),

              // Weather message banner
              const WeatherMessageBanner(),
              const SizedBox(height: 24),

              // Outfit recommendation
              const outfit_widget.OutfitRecommendation(),
              const SizedBox(height: 24),

              // Last updated info
              if (homeState.lastUpdated != null)
                _buildLastUpdatedInfo(theme, homeState.lastUpdated!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오늘도 완벽한 코디로 시작해보세요!',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLastUpdatedInfo(ThemeData theme, DateTime lastUpdated) {
    final timeAgo = _getTimeAgo(lastUpdated);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppTheme.borderRadiusAll,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            '마지막 업데이트: $timeAgo',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '좋은 아침이에요!';
    } else if (hour < 18) {
      return '좋은 오후에요!';
    } else {
      return '좋은 저녁이에요!';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }
}
