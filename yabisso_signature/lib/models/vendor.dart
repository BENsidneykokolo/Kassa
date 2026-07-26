class Vendor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? businessName;
  final String? address;
  final DateTime createdAt;
  final bool isActive;

  Vendor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.businessName,
    this.address,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'business_name': businessName,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Vendor.fromMap(Map<String, dynamic> map) {
    return Vendor(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      businessName: map['business_name'],
      address: map['address'],
      createdAt: DateTime.parse(map['created_at']),
      isActive: map['is_active'] == 1,
    );
  }

  Vendor copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? businessName,
    String? address,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
