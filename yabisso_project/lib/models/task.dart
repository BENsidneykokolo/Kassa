class Task {
  final int? id;
  final int projectId;
  final String title;
  final String? description;
  final String status; // a_faire, en_cours, terminee, annulee
  final String priority; // haute, moyenne, basse
  final DateTime? dueDate;
  final String? assignee;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.status = 'a_faire',
    this.priority = 'moyenne',
    this.dueDate,
    this.assignee,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'project_id': projectId,
    'title': title,
    'description': description,
    'status': status,
    'priority': priority,
    'due_date': dueDate?.toIso8601String(),
    'assignee': assignee,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Task.fromMap(Map<String, dynamic> m) => Task(
    id: m['id'] as int?,
    projectId: m['project_id'] as int,
    title: m['title'] as String,
    description: m['description'] as String?,
    status: m['status'] as String? ?? 'a_faire',
    priority: m['priority'] as String? ?? 'moyenne',
    dueDate: m['due_date'] != null ? DateTime.parse(m['due_date']) : null,
    assignee: m['assignee'] as String?,
    createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
    updatedAt: m['updated_at'] != null ? DateTime.parse(m['updated_at']) : null,
  );

  Task copyWith({int? id, int? projectId, String? title, String? description, String? status, String? priority, DateTime? dueDate, String? assignee}) => Task(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    dueDate: dueDate ?? this.dueDate,
    assignee: assignee ?? this.assignee,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );

  String get statusLabel {
    switch (status) {
      case 'a_faire': return 'À faire';
      case 'en_cours': return 'En cours';
      case 'terminee': return 'Terminée';
      case 'annulee': return 'Annulée';
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
