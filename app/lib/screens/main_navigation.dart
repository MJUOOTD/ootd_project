import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'saved_screen.dart';
import 'my_page_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // initState에서는 context를 사용할 수 없으므로 기본값으로 설정
    _currentIndex = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndexFromRoute();
  }

  void _updateIndexFromRoute() {
    try {
      final location = GoRouterState.of(context).uri.path;
      switch (location) {
        case '/':
        case '/home':
          _currentIndex = 0;
          break;
        case '/search':
          _currentIndex = 1;
          break;
        case '/saved':
          _currentIndex = 2;
          break;
        case '/my':
          _currentIndex = 3;
          break;
        default:
          _currentIndex = 0;
      }
    } catch (e) {
      // GoRouter가 아직 초기화되지 않은 경우 기본값 사용
      _currentIndex = 0;
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const SavedScreen(),
    const MyPageScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, '홈'),
                _buildNavItem(1, Icons.search_outlined, Icons.search, '검색'),
                _buildNavItem(2, Icons.favorite_outline, Icons.favorite, '좋아요'),
                _buildNavItem(3, Icons.person_outline, Icons.person, '마이'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        // Navigate to the corresponding route
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/search');
            break;
          case 2:
            context.go('/saved');
            break;
          case 3:
            context.go('/my');
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(239, 107, 141, 252).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? Border.all(color: const Color.fromARGB(239, 107, 141, 252), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ?  const Color.fromARGB(239, 107, 141, 252) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ?  const Color.fromARGB(239, 107, 141, 252) : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
