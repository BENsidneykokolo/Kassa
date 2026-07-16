import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/subscription/subscription_screen.dart';
import '../screens/subscription/register_screen.dart';
import '../screens/vendor_auth/vendor_auth_screen.dart';
import '../screens/home/main_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/media/media_screen.dart';
import '../screens/events/events_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/give/give_screen.dart';
import '../screens/prayer_wall/prayer_wall_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/hotspot_sync_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/vendor-auth',
        builder: (context, state) => const VendorAuthScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/media',
            builder: (context, state) => const MediaScreen(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventsScreen(),
          ),
          GoRoute(
            path: '/shop',
            builder: (context, state) => const ShopScreen(),
          ),
          GoRoute(
            path: '/give',
            builder: (context, state) => const GiveScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/prayer-wall',
        builder: (context, state) => const PrayerWallScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/hotspot',
        builder: (context, state) => const HotspotSyncScreen(),
      ),
    ],
  );
});
