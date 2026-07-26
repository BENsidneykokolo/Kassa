class Promotion {
  final String id;
  final String title;
  final String description;
  final String discountType;
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdAt,
  });

  factory Promotion.fromMap(Map<String, dynamic> map) {
    return Promotion(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      discountType: map['discountType'] as String,
      discountValue: (map['discountValue'] as num).toDouble(),
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      isActive: (map['isActive'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Promotion copyWith({
    String? id,
    String? title,
    String? description,
    String? discountType,
    double? discountValue,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Promotion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
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
  bool get isCurrentlyActive => isActive && !isExpired && DateTime.now().isAfter(startDate);
}
