class Vendor {
  final String id;
  final String name;
  final String role;
  final String? pinHash;
  final String color;
  final String initials;
  final String? employeeId;
  final String createdAt;

  const Vendor({
    required this.id,
    required this.name,
    required this.role,
    this.pinHash,
    required this.color,
    required this.initials,
    this.employeeId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'pin_hash': pinHash,
      'color': color,
      'initials': initials,
      'employee_id': employeeId,
      'created_at': createdAt,
    };
  }

  factory Vendor.fromMap(Map<String, dynamic> map) {
    return Vendor(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      pinHash: map['pin_hash'],
      color: map['color'] ?? '#6B3FA0',
      initials: map['initials'] ?? '',
      employeeId: map['employee_id'],
      createdAt: map['created_at'] ?? '',
    );
  }
}
