import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/ai/ai_ceo_screen.dart';
import 'screens/ai/ai_marketing_screen.dart';
import 'screens/employees/employees_screen.dart';
import 'screens/employees/employee_detail_screen.dart';
import 'screens/sales/sales_screen.dart';
import 'screens/assignments/assignments_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/vouchers/voucher_generator_screen.dart';
import 'screens/activity/employee_activity_screen.dart';
import 'screens/tracking/employee_tracking_screen.dart';
import 'screens/tracking/shared_sales_screen.dart';
import 'screens/tracking/commerce_tracking_screen.dart';
import 'screens/candidates/candidates_screen.dart';
import 'screens/candidates/relance_screen.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/rh/rh_dashboard_screen.dart';
import 'screens/rh/leaves_screen.dart';
import 'screens/rh/objectives_screen.dart';
import 'screens/rh/rewards_screen.dart';
import 'screens/rh/sanctions_screen.dart';
import 'screens/rh/trainings_screen.dart';
import 'screens/rh/manager_notes_screen.dart';
import 'screens/rh/daily_reports_admin_screen.dart';
import 'screens/rh/notifications_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
      GoRoute(path: '/', builder: (ctx, state) => const DashboardScreen()),
      GoRoute(path: '/ai-ceo', builder: (ctx, state) => const AiCeoScreen()),
      GoRoute(path: '/ai-marketing', builder: (ctx, state) => const AiMarketingScreen()),
      GoRoute(path: '/employees', builder: (ctx, state) => const EmployeesScreen()),
      GoRoute(
        path: '/employee-detail/:id',
        builder: (ctx, state) => EmployeeDetailScreen(employeeId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/sales', builder: (ctx, state) => const SalesScreen()),
      GoRoute(path: '/assignments', builder: (ctx, state) => const AssignmentsScreen()),
      GoRoute(path: '/settings', builder: (ctx, state) => const SettingsScreen()),
      GoRoute(path: '/profile', builder: (ctx, state) => const ProfileScreen()),
      GoRoute(path: '/vouchers', name: 'vouchers', builder: (ctx, state) => const VoucherGeneratorScreen()),
      GoRoute(path: '/activity', builder: (ctx, state) => const EmployeeActivityScreen()),
      GoRoute(path: '/employee-tracking', builder: (ctx, state) => const EmployeeTrackingScreen()),
      GoRoute(path: '/shared-sales', builder: (ctx, state) => const SharedSalesScreen()),
      GoRoute(path: '/commerce-tracking', builder: (ctx, state) => const CommerceTrackingScreen()),
      GoRoute(path: '/candidates', builder: (ctx, state) => const CandidatesScreen()),
      GoRoute(path: '/relance', builder: (ctx, state) => const RelanceScreen()),
      GoRoute(path: '/analytics', builder: (ctx, state) => const AnalyticsScreen()),
      GoRoute(path: '/rh', builder: (ctx, state) => const RhDashboardScreen()),
      GoRoute(path: '/leaves', builder: (ctx, state) => const LeavesScreen()),
      GoRoute(path: '/objectives', builder: (ctx, state) => const ObjectivesScreen()),
      GoRoute(path: '/rewards', builder: (ctx, state) => const RewardsScreen()),
      GoRoute(path: '/sanctions', builder: (ctx, state) => const SanctionsScreen()),
      GoRoute(path: '/trainings', builder: (ctx, state) => const TrainingsScreen()),
      GoRoute(path: '/manager-notes', builder: (ctx, state) => const ManagerNotesScreen()),
      GoRoute(path: '/daily-reports', builder: (ctx, state) => const DailyReportsAdminScreen()),
      GoRoute(path: '/notifications', builder: (ctx, state) => const NotificationsScreen()),
    ],
  );
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: YabissoAdminApp()));
}

class YabissoAdminApp extends ConsumerWidget {
  const YabissoAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Yabisso Super Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
