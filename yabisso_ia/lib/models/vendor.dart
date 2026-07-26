class Vendor {
  final int? id;
  final String name;
  final String? role;
  final String? pinHash;
  final String? color;
  final String? initials;
  final DateTime createdAt;

  Vendor({this.id, required this.name, this.role, this.pinHash, this.color, this.initials, DateTime? createdAt}) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'name': name, 'role': role, 'pin_hash': pinHash, 'color': color, 'initials': initials, 'created_at': createdAt.toIso8601String(),
  };

  factory Vendor.fromMap(Map<String, dynamic> m) => Vendor(
    id: m['id'] as int?, name: m['name'] as String, role: m['role'] as String?,
    pinHash: m['pin_hash'] as String?, color: m['color'] as String?, initials: m['initials'] as String?,
    createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
  );
}
