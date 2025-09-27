import 'package:go_router/go_router.dart';
import 'screens/main_navigation.dart';
import 'screens/situation_outfit_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/onboarding/welcome_onboarding_screen.dart';
import 'screens/initial_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'initial',
      builder: (context, state) => const InitialScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const WelcomeOnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/main',
      name: 'main',
      builder: (context, state) => const MainNavigation(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const MainNavigation(),
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const MainNavigation(),
    ),
    GoRoute(
      path: '/saved',
      name: 'saved',
      builder: (context, state) => const MainNavigation(),
    ),
    GoRoute(
      path: '/my',
      name: 'my',
      builder: (context, state) => const MainNavigation(),
    ),
    GoRoute(
      path: '/situation-outfit-detail',
      name: 'situation-outfit-detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SituationOutfitDetailScreen(
          title: extra?['title'] ?? '프로페셔널 룩',
          rating: extra?['rating'] ?? '4.8',
          tags: extra?['tags'] ?? ['프로페셔널', '깔끔한'],
          temperature: extra?['temperature'] ?? '18',
          situation: extra?['situation'] ?? '출근',
          imageUrl: extra?['imageUrl'],
        );
      },
    ),
  ],
);
