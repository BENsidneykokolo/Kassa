class PermissionsService {
  static final PermissionsService instance = PermissionsService._init();
  PermissionsService._init();

  static const Map<String, List<String>> rolePermissions = {
    'super_admin': [
      'employees_view', 'employees_create', 'employees_edit', 'employees_delete',
      'candidates_view', 'candidates_create', 'candidates_edit', 'candidates_delete',
      'tasks_view', 'tasks_create', 'tasks_edit', 'tasks_assign',
      'leaves_view', 'leaves_approve', 'leaves_reject',
      'objectives_view', 'objectives_create', 'objectives_edit',
      'rewards_view', 'rewards_create',
      'sanctions_view', 'sanctions_create',
      'trainings_view', 'trainings_create', 'trainings_edit',
      'reports_view', 'reports_export',
      'attendance_view', 'attendance_manage',
      'performance_view',
      'manager_notes_view', 'manager_notes_create',
      'notifications_send',
      'activity_log_view',
      'settings_manage',
      'vouchers_generate',
      'prospectives_view', 'prospectives_manage',
      'analytics_view',
    ],
    'admin': [
      'employees_view', 'employees_create', 'employees_edit',
      'candidates_view', 'candidates_create', 'candidates_edit',
      'tasks_view', 'tasks_create', 'tasks_edit', 'tasks_assign',
      'leaves_view', 'leaves_approve', 'leaves_reject',
      'objectives_view', 'objectives_create', 'objectives_edit',
      'rewards_view', 'rewards_create',
      'sanctions_view', 'sanctions_create',
      'trainings_view', 'trainings_create',
      'reports_view', 'reports_export',
      'attendance_view', 'attendance_manage',
      'performance_view',
      'manager_notes_view', 'manager_notes_create',
      'notifications_send',
      'activity_log_view',
      'prospectives_view', 'prospectives_manage',
      'analytics_view',
    ],
    'hr_manager': [
      'employees_view', 'employees_edit',
      'candidates_view', 'candidates_create', 'candidates_edit',
      'tasks_view', 'tasks_create', 'tasks_edit',
      'leaves_view', 'leaves_approve', 'leaves_reject',
      'objectives_view', 'objectives_create', 'objectives_edit',
      'rewards_view', 'rewards_create',
      'sanctions_view', 'sanctions_create',
      'trainings_view', 'trainings_create',
      'reports_view', 'reports_export',
      'attendance_view',
      'performance_view',
      'manager_notes_view', 'manager_notes_create',
      'notifications_send',
      'activity_log_view',
    ],
    'manager': [
      'employees_view',
      'candidates_view',
      'tasks_view', 'tasks_create', 'tasks_assign',
      'leaves_view',
      'objectives_view', 'objectives_create',
      'rewards_view',
      'reports_view',
      'attendance_view',
      'performance_view',
      'manager_notes_view', 'manager_notes_create',
      'prospectives_view',
    ],
    'superviseur': [
      'employees_view',
      'tasks_view',
      'attendance_view',
      'reports_view',
      'performance_view',
      'prospectives_view',
    ],
  };

  static const Map<String, String> roleLabels = {
    'super_admin': 'Super Admin',
    'admin': 'Administrateur',
    'hr_manager': 'Directeur RH',
    'manager': 'Manager',
    'superviseur': 'Superviseur',
  };

  bool hasPermission(String role, String permission) {
    final permissions = rolePermissions[role];
    if (permissions == null) return false;
    return permissions.contains(permission);
  }

  List<String> getPermissions(String role) {
    return rolePermissions[role] ?? [];
  }

  List<String> getAllRoles() {
    return roleLabels.keys.toList();
  }

  String getRoleLabel(String role) {
    return roleLabels[role] ?? role;
  }
}
