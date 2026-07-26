import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/subscription/subscription_screen.dart';
import '../screens/vendor_auth/vendor_auth_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/campaigns/campaigns_screen.dart';
import '../screens/campaigns/add_campaign_screen.dart';
import '../screens/promotions/promotions_screen.dart';
import '../screens/promotions/add_promotion_screen.dart';
import '../screens/coupons/coupons_screen.dart';
import '../screens/coupons/add_coupon_screen.dart';
import '../screens/settings/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const SubscriptionScreen(),
    ),
    GoRoute(
      path: '/vendor-auth',
      builder: (context, state) => const VendorAuthScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/campaigns',
          builder: (context, state) => const CampaignsScreen(),
        ),
        GoRoute(
          path: '/campaigns/add',
          builder: (context, state) => const AddCampaignScreen(),
        ),
        GoRoute(
          path: '/promotions',
          builder: (context, state) => const PromotionsScreen(),
        ),
        GoRoute(
          path: '/promotions/add',
          builder: (context, state) => const AddPromotionScreen(),
        ),
        GoRoute(
          path: '/coupons',
          builder: (context, state) => const CouponsScreen(),
        ),
        GoRoute(
          path: '/coupons/add',
          builder: (context, state) => const AddCouponScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Campagnes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Promotions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: 'Coupons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/campaigns')) return 1;
    if (location.startsWith('/promotions')) return 2;
    if (location.startsWith('/coupons')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/campaigns');
        break;
      case 2:
        context.go('/promotions');
        break;
      case 3:
        context.go('/coupons');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }
}
