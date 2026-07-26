import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yabisso_signature/screens/subscription/subscription_screen.dart';
import 'package:yabisso_signature/screens/vendor_auth/vendor_auth_screen.dart';
import 'package:yabisso_signature/screens/dashboard/dashboard_screen.dart';
import 'package:yabisso_signature/screens/signatures/signatures_screen.dart';
import 'package:yabisso_signature/screens/signatures/add_signature_screen.dart';
import 'package:yabisso_signature/screens/signatures/signature_detail_screen.dart';
import 'package:yabisso_signature/screens/settings/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
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
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/signatures',
        name: 'signatures',
        builder: (context, state) => const SignaturesScreen(),
      ),
      GoRoute(
        path: '/signatures/add',
        name: 'add-signature',
        builder: (context, state) => const AddSignatureScreen(),
      ),
      GoRoute(
        path: '/signatures/:id',
        name: 'signature-detail',
        builder: (context, state) => SignatureDetailScreen(
          signatureId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
