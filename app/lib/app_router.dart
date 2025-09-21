import 'package:go_router/go_router.dart';
import 'widgets/app_scaffold.dart';
import 'features/home/home_screen.dart';
import 'features/search/search_screen.dart';
import 'features/saved/saved_screen.dart';
import 'features/notifications/notification_screen.dart';
import 'features/settings/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/saved',
          name: 'saved',
          builder: (context, state) => const SavedScreen(),
        ),
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
