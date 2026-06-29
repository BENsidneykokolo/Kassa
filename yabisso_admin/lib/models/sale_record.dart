class SaleRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final String shopName;
  final String plan;
  final int amount;
  final int commission;
  final String createdAt;

  SaleRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.shopName,
    required this.plan,
    required this.amount,
    this.commission = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'employee_id': employeeId,
    'employee_name': employeeName,
    'shop_name': shopName,
    'plan': plan,
    'amount': amount,
    'commission': commission,
    'created_at': createdAt,
  };

  factory SaleRecord.fromMap(Map<String, dynamic> m) => SaleRecord(
    id: m['id'],
    employeeId: m['employee_id'],
    employeeName: m['employee_name'],
    shopName: m['shop_name'],
    plan: m['plan'],
    amount: m['amount'],
    commission: m['commission'] ?? 0,
    createdAt: m['created_at'],
  );

  String get formattedAmount {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} FCFA';
  }
}
