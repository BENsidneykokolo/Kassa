class Admin {
  final String id;
  final String name;
  final String phone;
  final String role;
  final String? pinHash;
  final String initials;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Admin({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.pinHash,
    this.initials = '',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'role': role,
    'pin_hash': pinHash,
    'initials': initials,
    'is_active': isActive ? 1 : 0,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  factory Admin.fromMap(Map<String, dynamic> m) => Admin(
    id: m['id'],
    name: m['name'],
    phone: m['phone'] ?? '',
    role: m['role'] ?? 'admin',
    pinHash: m['pin_hash'],
    initials: m['initials'] ?? '',
    isActive: (m['is_active'] ?? 1) == 1,
    createdAt: m['created_at'],
    updatedAt: m['updated_at'],
  );

  Admin copyWith({String? pinHash, bool? isActive}) => Admin(
    id: id, name: name, phone: phone, role: role,
    pinHash: pinHash ?? this.pinHash,
    initials: initials,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt, updatedAt: updatedAt,
  );

  String get roleLabel {
    switch (role) {
      case 'super_admin': return 'Super Admin';
      case 'admin': return 'Admin';
      case 'hr_manager': return 'Directeur RH';
      case 'marketing_director': return 'Directeur Marketing';
      default: return role;
    }
  }

  static const List<String> roles = [
    'super_admin',
    'admin',
    'hr_manager',
    'marketing_director',
  ];

  static const Map<String, String> roleLabels = {
    'super_admin': 'Super Admin',
    'admin': 'Admin',
    'hr_manager': 'Directeur RH',
    'marketing_director': 'Directeur Marketing',
  };
}
