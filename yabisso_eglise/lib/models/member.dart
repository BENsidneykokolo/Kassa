class Member {
  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final String? address;
  final String? photoPath;
  final String? role;
  final String? baptismDate;
  final String? membershipDate;
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  const Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
    this.address,
    this.photoPath,
    this.role,
    this.baptismDate,
    this.membershipDate,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'address': address,
      'photo_path': photoPath,
      'role': role,
      'baptism_date': baptismDate,
      'membership_date': membershipDate,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] ?? '',
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      photoPath: map['photo_path'],
      role: map['role'],
      baptismDate: map['baptism_date'],
      membershipDate: map['membership_date'],
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'],
    );
  }

  Member copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
    String? photoPath,
    String? role,
    String? baptismDate,
    String? membershipDate,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return Member(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      photoPath: photoPath ?? this.photoPath,
      role: role ?? this.role,
      baptismDate: baptismDate ?? this.baptismDate,
      membershipDate: membershipDate ?? this.membershipDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
