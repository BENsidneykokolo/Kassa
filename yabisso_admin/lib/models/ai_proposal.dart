class AiProposal {
  final String id;
  final String title;
  final String description;
  final String expectedImpact;
  final String priority;
  final String category;
  final String status;
  final String createdAt;
  final String? reviewedAt;
  final String? reviewedBy;

  AiProposal({
    required this.id,
    required this.title,
    required this.description,
    required this.expectedImpact,
    this.priority = 'medium',
    this.category = 'general',
    this.status = 'pending',
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'expected_impact': expectedImpact,
    'priority': priority,
    'category': category,
    'status': status,
    'created_at': createdAt,
    'reviewed_at': reviewedAt,
    'reviewed_by': reviewedBy,
  };

  factory AiProposal.fromMap(Map<String, dynamic> m) => AiProposal(
    id: m['id'],
    title: m['title'],
    description: m['description'],
    expectedImpact: m['expected_impact'],
    priority: m['priority'] ?? 'medium',
    category: m['category'] ?? 'general',
    status: m['status'] ?? 'pending',
    createdAt: m['created_at'],
    reviewedAt: m['reviewed_at'],
    reviewedBy: m['reviewed_by'],
  );

  AiProposal copyWith({String? status, String? reviewedAt, String? reviewedBy}) => AiProposal(
    id: id, title: title, description: description,
    expectedImpact: expectedImpact, priority: priority,
    category: category, status: status ?? this.status,
    createdAt: createdAt, reviewedAt: reviewedAt ?? this.reviewedAt,
    reviewedBy: reviewedBy ?? this.reviewedBy,
  );

  String get priorityLabel {
    switch (priority) {
      case 'high': return 'Haute';
      case 'medium': return 'Moyenne';
      case 'low': return 'Basse';
      default: return priority;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'En attente';
      case 'approved': return 'Approuvé';
      case 'rejected': return 'Rejeté';
      default: return status;
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'marketing': return 'Marketing';
      case 'sales': return 'Ventes';
      case 'hr': return 'RH';
      case 'operations': return 'Opérations';
      case 'finance': return 'Finance';
      default: return 'Général';
    }
  }
}
