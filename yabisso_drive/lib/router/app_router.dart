import 'package:go_router/go_router.dart';
import '../screens/subscription/subscription_screen.dart';
import '../screens/vendor_auth/vendor_auth_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/files/files_screen.dart';
import '../screens/files/file_detail_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/recent/recent_screen.dart';
import '../screens/trash/trash_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const SubscriptionScreen()),
      GoRoute(path: '/vendor-auth', builder: (context, state) => const VendorAuthScreen()),
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/files', builder: (context, state) => const FilesScreen()),
      GoRoute(path: '/files/:id', builder: (context, state) { final id = int.parse(state.pathParameters['id']!); return FileDetailScreen(fileId: id); }),
      GoRoute(path: '/favorites', builder: (context, state) => const FavoritesScreen()),
      GoRoute(path: '/recent', builder: (context, state) => const RecentScreen()),
      GoRoute(path: '/trash', builder: (context, state) => const TrashScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    ],
  );
}
