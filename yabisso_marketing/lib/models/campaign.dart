class Campaign {
  final String id;
  final String name;
  final String type;
  final String message;
  final String segment;
  final String status;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final int recipientsCount;
  final DateTime createdAt;

  Campaign({
    required this.id,
    required this.name,
    required this.type,
    required this.message,
    required this.segment,
    required this.status,
    this.scheduledAt,
    this.sentAt,
    this.recipientsCount = 0,
    required this.createdAt,
  });

  factory Campaign.fromMap(Map<String, dynamic> map) {
    return Campaign(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      message: map['message'] as String,
      segment: map['segment'] as String,
      status: map['status'] as String,
      scheduledAt: map['scheduledAt'] != null
          ? DateTime.parse(map['scheduledAt'] as String)
          : null,
      sentAt: map['sentAt'] != null
          ? DateTime.parse(map['sentAt'] as String)
          : null,
      recipientsCount: map['recipientsCount'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'message': message,
      'segment': segment,
      'status': status,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'recipientsCount': recipientsCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Campaign copyWith({
    String? id,
    String? name,
    String? type,
    String? message,
    String? segment,
    String? status,
    DateTime? scheduledAt,
    DateTime? sentAt,
    int? recipientsCount,
    DateTime? createdAt,
  }) {
    return Campaign(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      message: message ?? this.message,
      segment: segment ?? this.segment,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      recipientsCount: recipientsCount ?? this.recipientsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get typeLabel {
    switch (type) {
      case 'sms':
        return 'SMS';
      case 'whatsapp':
        return 'WhatsApp';
      case 'email':
        return 'Email';
      case 'reseaux_sociaux':
        return 'Réseaux Sociaux';
      default:
        return type;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'brouillon':
        return 'Brouillon';
      case 'envoye':
        return 'Envoyé';
      case 'programme':
        return 'Programmé';
      default:
        return status;
    }
  }
}
