import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/subscription/subscription_screen.dart';
import '../screens/vendor_auth/vendor_auth_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/documents/documents_screen.dart';
import '../screens/documents/add_document_screen.dart';
import '../screens/documents/document_detail_screen.dart';
import '../screens/templates/templates_screen.dart';
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
        path: '/documents',
        name: 'documents',
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: '/documents/add',
        name: 'add-document',
        builder: (context, state) => const AddDocumentScreen(),
      ),
      GoRoute(
        path: '/documents/:id',
        name: 'document-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return DocumentDetailScreen(documentId: id);
        },
      ),
      GoRoute(
        path: '/templates',
        name: 'templates',
        builder: (context, state) => const TemplatesScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
