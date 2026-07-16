import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/media/media_screen.dart';
import '../../screens/events/events_screen.dart';
import '../../screens/shop/shop_screen.dart';
import '../../screens/give/give_screen.dart';

class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const _tabs = ['/', '/media', '/events', '/shop', '/give'];

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final newIndex = _tabs.indexOf(currentPath);
    if (newIndex >= 0 && newIndex != _currentIndex) {
      _currentIndex = newIndex;
    }

    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
                context.go(_tabs[index]);
              },
              backgroundColor: AppColors.primary,
              indicatorColor: AppColors.secondaryContainer,
              selectedIconTheme: const IconThemeData(color: AppColors.primary),
              unselectedIconTheme: IconThemeData(color: Colors.white.withValues(alpha: 0.6)),
              selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              unselectedLabelTextStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Icon(Icons.church, color: AppColors.secondary, size: 32),
              ),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Accueil')),
                NavigationRailDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: Text('Média')),
                NavigationRailDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: Text('Événements')),
                NavigationRailDestination(icon: Icon(Icons.store_outlined), selectedIcon: Icon(Icons.store), label: Text('Boutique')),
                NavigationRailDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: Text('Dons')),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          context.go(_tabs[index]);
        },
      ),
    );
  }
}
