class TeamMember {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final String? role;
  final String? color;
  final DateTime createdAt;

  TeamMember({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.role,
    this.color,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'color': color,
    'created_at': createdAt.toIso8601String(),
  };

  factory TeamMember.fromMap(Map<String, dynamic> m) => TeamMember(
    id: m['id'] as int?,
    name: m['name'] as String,
    email: m['email'] as String?,
    phone: m['phone'] as String?,
    role: m['role'] as String?,
    color: m['color'] as String?,
    createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
  );

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}
