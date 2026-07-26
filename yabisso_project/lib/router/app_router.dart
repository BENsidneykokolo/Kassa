import 'package:go_router/go_router.dart';
import '../screens/subscription/subscription_screen.dart';
import '../screens/vendor_auth/vendor_auth_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/projects/projects_screen.dart';
import '../screens/projects/add_project_screen.dart';
import '../screens/projects/project_detail_screen.dart';
import '../screens/tasks/tasks_screen.dart';
import '../screens/tasks/add_task_screen.dart';
import '../screens/team/team_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const SubscriptionScreen()),
      GoRoute(path: '/vendor-auth', builder: (context, state) => const VendorAuthScreen()),
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/projects', builder: (context, state) => const ProjectsScreen()),
      GoRoute(path: '/projects/add', builder: (context, state) => const AddProjectScreen()),
      GoRoute(path: '/projects/:id', builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ProjectDetailScreen(projectId: id);
      }),
      GoRoute(path: '/tasks', builder: (context, state) => const TasksScreen()),
      GoRoute(path: '/tasks/add', builder: (context, state) {
        final projectId = state.uri.queryParameters['project_id'];
        return AddTaskScreen(projectId: projectId != null ? int.parse(projectId) : null);
      }),
      GoRoute(path: '/team', builder: (context, state) => const TeamScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    ],
  );
}
