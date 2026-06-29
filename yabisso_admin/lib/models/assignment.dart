class Assignment {
  final String id;
  final String employeeId;
  final String employeeName;
  final String shopName;
  final String territory;
  final String description;
  final String status;
  final String date;
  final String? completedAt;
  final String createdAt;

  Assignment({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.shopName,
    required this.territory,
    required this.description,
    this.status = 'pending',
    required this.date,
    this.completedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'employee_id': employeeId,
    'employee_name': employeeName,
    'shop_name': shopName,
    'territory': territory,
    'description': description,
    'status': status,
    'date': date,
    'completed_at': completedAt,
    'created_at': createdAt,
  };

  factory Assignment.fromMap(Map<String, dynamic> m) => Assignment(
    id: m['id'],
    employeeId: m['employee_id'],
    employeeName: m['employee_name'],
    shopName: m['shop_name'],
    territory: m['territory'],
    description: m['description'],
    status: m['status'] ?? 'pending',
    date: m['date'],
    completedAt: m['completed_at'],
    createdAt: m['created_at'],
  );

  Assignment copyWith({String? status, String? completedAt}) => Assignment(
    id: id, employeeId: employeeId, employeeName: employeeName,
    shopName: shopName, territory: territory, description: description,
    status: status ?? this.status, date: date,
    completedAt: completedAt ?? this.completedAt, createdAt: createdAt,
  );

  String get statusLabel {
    switch (status) {
      case 'pending': return 'En attente';
      case 'in_progress': return 'En cours';
      case 'completed': return 'Terminé';
      case 'cancelled': return 'Annulé';
      default: return status;
    }
  }
}
