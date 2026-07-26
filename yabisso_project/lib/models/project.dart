class Project {
  final int? id;
  final String name;
  final String? description;
  final String status; // en_cours, termine, archive, en_attente
  final String priority; // haute, moyenne, basse
  final DateTime? deadline;
  final double progress; // 0-100
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    this.id,
    required this.name,
    this.description,
    this.status = 'en_cours',
    this.priority = 'moyenne',
    this.deadline,
    this.progress = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'description': description,
    'status': status,
    'priority': priority,
    'deadline': deadline?.toIso8601String(),
    'progress': progress,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Project.fromMap(Map<String, dynamic> m) => Project(
    id: m['id'] as int?,
    name: m['name'] as String,
    description: m['description'] as String?,
    status: m['status'] as String? ?? 'en_cours',
    priority: m['priority'] as String? ?? 'moyenne',
    deadline: m['deadline'] != null ? DateTime.parse(m['deadline']) : null,
    progress: (m['progress'] as num?)?.toDouble() ?? 0,
    createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
    updatedAt: m['updated_at'] != null ? DateTime.parse(m['updated_at']) : null,
  );

  Project copyWith({int? id, String? name, String? description, String? status, String? priority, DateTime? deadline, double? progress}) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    deadline: deadline ?? this.deadline,
    progress: progress ?? this.progress,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );

  String get statusLabel {
    switch (status) {
      case 'en_cours': return 'En cours';
      case 'termine': return 'Terminé';
      case 'archive': return 'Archivé';
      case 'en_attente': return 'En attente';
      default: return status;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 'haute': return 'Haute';
      case 'moyenne': return 'Moyenne';
      case 'basse': return 'Basse';
      default: return priority;
    }
  }
}
