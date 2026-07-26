class Coupon {
  final String id;
  final String code;
  final String discountType;
  final double discountValue;
  final double minPurchase;
  final int maxUses;
  final int usedCount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;

  Coupon({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minPurchase = 0,
    this.maxUses = 0,
    this.usedCount = 0,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdAt,
  });

  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      id: map['id'] as String,
      code: map['code'] as String,
      discountType: map['discountType'] as String,
      discountValue: (map['discountValue'] as num).toDouble(),
      minPurchase: (map['minPurchase'] as num?)?.toDouble() ?? 0,
      maxUses: map['maxUses'] as int? ?? 0,
      usedCount: map['usedCount'] as int? ?? 0,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      isActive: (map['isActive'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'discountType': discountType,
      'discountValue': discountValue,
      'minPurchase': minPurchase,
      'maxUses': maxUses,
      'usedCount': usedCount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Coupon copyWith({
    String? id,
    String? code,
    String? discountType,
    double? discountValue,
    double? minPurchase,
    int? maxUses,
    int? usedCount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minPurchase: minPurchase ?? this.minPurchase,
      maxUses: maxUses ?? this.maxUses,
      usedCount: usedCount ?? this.usedCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get discountTypeLabel {
    switch (discountType) {
      case 'pourcentage':
        return 'Pourcentage';
      case 'fixe':
        return 'Montant fixe';
      default:
        return discountType;
    }
  }

  String get discountDisplay {
    if (discountType == 'pourcentage') {
      return '${discountValue.toStringAsFixed(0)}%';
    }
    return '${discountValue.toStringAsFixed(0)} FCFA';
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isFullyUsed => maxUses > 0 && usedCount >= maxUses;
  bool get isCurrentlyValid => isActive && !isExpired && !isFullyUsed;
  int get remainingUses => maxUses > 0 ? (maxUses - usedCount) : -1;
}
