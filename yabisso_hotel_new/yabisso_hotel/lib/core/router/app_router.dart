import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/session_service.dart';
import '../widgets/app_shell.dart';
import '../../features/ai_manager/ai_manager_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/attendance/attendance_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/role_selection_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/checkin/checkin_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/client_portal/client_portal_screen.dart';
import '../../features/crm/crm_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/employees/employees_screen.dart';
import '../../features/finance/finance_screen.dart';
import '../../features/housekeeping/housekeeping_screen.dart';
import '../../features/inventory/inventory_screen.dart';
import '../../features/maintenance/maintenance_screen.dart';
import '../../features/marketing/marketing_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/pos_bar/pos_bar_screen.dart';
import '../../features/pos_restaurant/pos_restaurant_screen.dart';
import '../../features/reception/reception_screen.dart';
import '../../features/reservations/reservations_screen.dart';
import '../../features/room_service/room_service_screen.dart';
import '../../features/rooms/rooms_screen.dart';
import '../../features/settings/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final loggingIn = ['/splash', '/onboarding', '/login', '/role-selection'].contains(state.matchedLocation);

      if (!session.isLoggedIn && !loggingIn) return '/onboarding';
      if (session.isLoggedIn && loggingIn && state.matchedLocation != '/splash') return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(onDone: () => context.go('/onboarding')),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(
          onStart: () => context.go('/login'),
          onLogin: () => context.go('/login'),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(onLoggedIn: () => context.go('/role-selection')),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => RoleSelectionScreen(
          onRoleSelected: (role) async {
            await ref.read(sessionProvider.notifier).login(userName: 'Ben', role: role);
            if (context.mounted) context.go('/dashboard');
          },
        ),
      ),

      // Coquille avec bottom navigation pour les modules principaux.
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/rooms', builder: (context, state) => const RoomsScreen()),
          GoRoute(path: '/reservations', builder: (context, state) => const ReservationsScreen()),
          GoRoute(path: '/more', builder: (context, state) => const MoreMenuScreen()),
        ],
      ),

      // Modules secondaires, accessibles depuis "Plus" ou en push direct.
      GoRoute(path: '/reception', builder: (context, state) => const ReceptionScreen()),
      GoRoute(path: '/checkin', builder: (context, state) => const CheckinScreen()),
      GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
      GoRoute(path: '/pos-restaurant', builder: (context, state) => const PosRestaurantScreen()),
      GoRoute(path: '/pos-bar', builder: (context, state) => const PosBarScreen()),
      GoRoute(path: '/room-service', builder: (context, state) => const RoomServiceScreen()),
      GoRoute(path: '/employees', builder: (context, state) => const EmployeesScreen()),
      GoRoute(path: '/attendance', builder: (context, state) => const AttendanceScreen()),
      GoRoute(path: '/housekeeping', builder: (context, state) => const HousekeepingScreen()),
      GoRoute(path: '/maintenance', builder: (context, state) => const MaintenanceScreen()),
      GoRoute(path: '/inventory', builder: (context, state) => const InventoryScreen()),
      GoRoute(path: '/finance', builder: (context, state) => const FinanceScreen()),
      GoRoute(path: '/crm', builder: (context, state) => const CrmScreen()),
      GoRoute(path: '/marketing', builder: (context, state) => const MarketingScreen()),
      GoRoute(path: '/analytics', builder: (context, state) => const AnalyticsScreen()),
      GoRoute(path: '/ai-manager', builder: (context, state) => const AiManagerScreen()),
      GoRoute(path: '/client-portal', builder: (context, state) => const ClientPortalScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    ],
  );
});
