import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/employees/employees_screen.dart';
import 'screens/employees/employee_detail_screen.dart';
import 'screens/candidates/candidates_screen.dart';
import 'screens/candidates/relance_screen.dart';
import 'screens/rh/rh_dashboard_screen.dart';
import 'screens/rh/leaves_screen.dart';
import 'screens/rh/objectives_screen.dart';
import 'screens/rh/rewards_screen.dart';
import 'screens/rh/sanctions_screen.dart';
import 'screens/rh/trainings_screen.dart';
import 'screens/rh/manager_notes_screen.dart';
import 'screens/rh/daily_reports_admin_screen.dart';
import 'screens/rh/notifications_screen.dart';
import 'screens/rh/employee_tasks_screen.dart';
import 'screens/rh/performance_dashboard_screen.dart';
import 'screens/rh/activity_log_screen.dart';
import 'screens/rh/attendance_history_screen.dart';
import 'screens/sales/sales_screen.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/ai/ai_ceo_screen.dart';
import 'screens/ai/ai_marketing_screen.dart';
import 'screens/ai/ai_assistant_screen.dart';
import 'screens/tracking/commerce_tracking_screen.dart';
import 'screens/tracking/employee_tracking_screen.dart';
import 'screens/tracking/shared_sales_screen.dart';
import 'screens/tracking/shared_prospections_screen.dart';
import 'screens/tracking/crm_relance_screen.dart';
import 'screens/activity/employee_activity_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/vouchers/voucher_generator_screen.dart';
import 'screens/subscription_requests/subscription_requests_screen.dart';
import 'screens/assignments/assignments_screen.dart';
import 'screens/rh/export_screen.dart';
import 'screens/settings/pack_screen.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: YabissoAdminApp()));
}

final _router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    if (state.matchedLocation == '/login') return null;
    final container = ProviderScope.containerOf(context, listen: false);
    final admin = container.read(currentAdminProvider);
    if (admin == null) return '/login';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/employees', builder: (_, __) => const EmployeesScreen()),
    GoRoute(path: '/employee-detail', builder: (_, state) {
      final employeeId = state.uri.queryParameters['id'] ?? '';
      return EmployeeDetailScreen(employeeId: employeeId);
    }),
    GoRoute(path: '/candidates', builder: (_, __) => const CandidatesScreen()),
    GoRoute(path: '/relance', builder: (_, __) => const RelanceScreen()),
    GoRoute(path: '/rh-dashboard', builder: (_, __) => const RhDashboardScreen()),
    GoRoute(path: '/leaves', builder: (_, __) => const LeavesScreen()),
    GoRoute(path: '/objectives', builder: (_, __) => const ObjectivesScreen()),
    GoRoute(path: '/rewards', builder: (_, __) => const RewardsScreen()),
    GoRoute(path: '/sanctions', builder: (_, __) => const SanctionsScreen()),
    GoRoute(path: '/trainings', builder: (_, __) => const TrainingsScreen()),
    GoRoute(path: '/manager-notes', builder: (_, __) => const ManagerNotesScreen()),
    GoRoute(path: '/daily-reports', builder: (_, __) => const DailyReportsAdminScreen()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: '/employee-tasks', builder: (_, __) => const EmployeeTasksScreen()),
    GoRoute(path: '/performance', builder: (_, __) => const PerformanceDashboardScreen()),
    GoRoute(path: '/activity-log', builder: (_, __) => const ActivityLogScreen()),
    GoRoute(path: '/attendance', builder: (_, __) => const AttendanceHistoryScreen()),
    GoRoute(path: '/sales', builder: (_, __) => const SalesScreen()),
    GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
    GoRoute(path: '/ai-ceo', builder: (_, __) => const AiCeoScreen()),
    GoRoute(path: '/ai-marketing', builder: (_, __) => const AiMarketingScreen()),
    GoRoute(path: '/ai-assistant', builder: (_, __) => const AiAssistantScreen()),
    GoRoute(path: '/commerce-tracking', builder: (_, __) => const CommerceTrackingScreen()),
    GoRoute(path: '/employee-tracking', builder: (_, __) => const EmployeeTrackingScreen()),
    GoRoute(path: '/shared-sales', builder: (_, __) => const SharedSalesScreen()),
    GoRoute(path: '/shared-prospections', builder: (_, __) => const SharedProspectionsScreen()),
    GoRoute(path: '/crm-relance', builder: (_, __) => const CrmRelanceScreen()),
    GoRoute(path: '/employee-activity', builder: (_, __) => const EmployeeActivityScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/voucher-generator', builder: (_, __) => const VoucherGeneratorScreen()),
    GoRoute(path: '/subscription-requests', builder: (_, __) => const SubscriptionRequestsScreen()),
    GoRoute(path: '/assignments', builder: (_, __) => const AssignmentsScreen()),
    GoRoute(path: '/export', builder: (_, __) => const ExportScreen()),
    GoRoute(path: '/pack', builder: (_, __) => const PackScreen()),
  ],
);

class YabissoAdminApp extends ConsumerWidget {
  const YabissoAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Yabisso Super Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
