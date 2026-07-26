class Vendor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String businessName;
  final String businessType;
  final String address;
  final String? profileImage;
  final bool isActive;
  final DateTime createdAt;

  Vendor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.businessName,
    required this.businessType,
    required this.address,
    this.profileImage,
    this.isActive = true,
    required this.createdAt,
  });

  factory Vendor.fromMap(Map<String, dynamic> map) {
    return Vendor(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      businessName: map['businessName'] as String,
      businessType: map['businessType'] as String,
      address: map['address'] as String,
      profileImage: map['profileImage'] as String?,
      isActive: (map['isActive'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'businessName': businessName,
      'businessType': businessType,
      'address': address,
      'profileImage': profileImage,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Vendor copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? businessName,
    String? businessType,
    String? address,
    String? profileImage,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
