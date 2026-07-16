class Tithe {
  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final String titheType;
  final String? notes;
  final String date;
  final String createdAt;

  const Tithe({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.titheType,
    this.notes,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'member_id': memberId,
      'member_name': memberName,
      'amount': amount,
      'tithe_type': titheType,
      'notes': notes,
      'date': date,
      'created_at': createdAt,
    };
  }

  factory Tithe.fromMap(Map<String, dynamic> map) {
    return Tithe(
      id: map['id'] ?? '',
      memberId: map['member_id'] ?? '',
      memberName: map['member_name'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      titheType: map['tithe_type'] ?? 'tithe',
      notes: map['notes'],
      date: map['date'] ?? '',
      createdAt: map['created_at'] ?? '',
    );
  }
}
