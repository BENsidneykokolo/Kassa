import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/subscription/subscription_screen.dart';
import '../screens/vendor_auth/vendor_auth_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/forms/forms_screen.dart';
import '../screens/forms/add_form_screen.dart';
import '../screens/forms/form_detail_screen.dart';
import '../screens/forms/fill_form_screen.dart';
import '../screens/forms/responses_screen.dart';
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
        path: '/forms',
        name: 'forms',
        builder: (context, state) => const FormsScreen(),
      ),
      GoRoute(
        path: '/forms/add',
        name: 'add-form',
        builder: (context, state) => const AddFormScreen(),
      ),
      GoRoute(
        path: '/forms/:id',
        name: 'form-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return FormDetailScreen(formId: id);
        },
      ),
      GoRoute(
        path: '/forms/:id/fill',
        name: 'fill-form',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return FillFormScreen(formId: id);
        },
      ),
      GoRoute(
        path: '/forms/:id/responses',
        name: 'form-responses',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ResponsesScreen(formId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
