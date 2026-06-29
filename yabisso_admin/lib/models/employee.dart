class Employee {
  final String id;
  final String name;
  final String phone;
  final String role;
  final String? pinHash;
  final String color;
  final String initials;
  final bool isActive;
  final int baseSalary;
  final String createdAt;
  final String updatedAt;

  Employee({
    required this.id,
    required this.name,
    required this.phone,
    this.role = 'prestataire',
    this.pinHash,
    this.color = '#00694C',
    this.initials = '',
    this.isActive = true,
    this.baseSalary = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'role': role,
    'pin_hash': pinHash,
    'color': color,
    'initials': initials,
    'is_active': isActive ? 1 : 0,
    'base_salary': baseSalary,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  factory Employee.fromMap(Map<String, dynamic> m) => Employee(
    id: m['id'],
    name: m['name'],
    phone: m['phone'] ?? '',
    role: m['role'] ?? 'prestataire',
    pinHash: m['pin_hash'],
    color: m['color'] ?? '#00694C',
    initials: m['initials'] ?? '',
    isActive: (m['is_active'] ?? 1) == 1,
    baseSalary: m['base_salary'] ?? 0,
    createdAt: m['created_at'],
    updatedAt: m['updated_at'],
  );

  Employee copyWith({String? pinHash, bool? isActive, int? baseSalary}) => Employee(
    id: id, name: name, phone: phone, role: role,
    pinHash: pinHash ?? this.pinHash,
    color: color, initials: initials,
    isActive: isActive ?? this.isActive,
    baseSalary: baseSalary ?? this.baseSalary,
    createdAt: createdAt, updatedAt: updatedAt,
  );

  String get roleLabel {
    switch (role) {
      case 'commercial': return 'Commercial';
      case 'prestataire': return 'Prestataire';
      case 'manager': return 'Manager';
      default: return role;
    }
  }
}
