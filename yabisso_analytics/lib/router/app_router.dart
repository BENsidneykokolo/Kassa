import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/subscription/subscription_screen.dart';
import '../screens/vendor_auth/vendor_auth_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/charts/charts_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/kpis/kpis_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/vendor-auth',
        name: 'vendor-auth',
        builder: (context, state) => const VendorAuthScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/charts',
        name: 'charts',
        builder: (context, state) => const ChartsScreen(),
      ),
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/kpis',
        name: 'kpis',
        builder: (context, state) => const KpisScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
