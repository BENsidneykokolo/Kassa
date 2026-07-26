class Insight {
  final int? id;
  final String type; // tendance, alerte, recommandation, prediction
  final String title;
  final String description;
  final String? data;
  final bool isRead;
  final DateTime createdAt;

  Insight({this.id, required this.type, required this.title, required this.description, this.data, this.isRead = false, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'type': type, 'title': title, 'description': description,
    'data': data, 'is_read': isRead ? 1 : 0, 'created_at': createdAt.toIso8601String(),
  };

  factory Insight.fromMap(Map<String, dynamic> m) => Insight(
    id: m['id'] as int?, type: m['type'] as String, title: m['title'] as String,
    description: m['description'] as String, data: m['data'] as String?,
    isRead: (m['is_read'] as int?) == 1, createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
  );

  String get typeLabel {
    switch (type) {
      case 'tendance': return 'Tendance';
      case 'alerte': return 'Alerte';
      case 'recommandation': return 'Recommandation';
      case 'prediction': return 'Prédiction';
      default: return type;
    }
  }
}
