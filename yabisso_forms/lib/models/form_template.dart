class FormTemplate {
  final int? id;
  final String name;
  final String? description;
  final String? fieldsJson;
  final String type;
  final int responseCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  FormTemplate({
    this.id,
    required this.name,
    this.description,
    this.fieldsJson,
    this.type = 'autre',
    this.responseCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'description': description,
        'fields_json': fieldsJson,
        'type': type,
        'response_count': responseCount,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory FormTemplate.fromMap(Map<String, dynamic> m) => FormTemplate(
        id: m['id'] as int?,
        name: m['name'] as String,
        description: m['description'] as String?,
        fieldsJson: m['fields_json'] as String?,
        type: m['type'] as String? ?? 'autre',
        responseCount: m['response_count'] as int? ?? 0,
        createdAt: m['created_at'] != null
            ? DateTime.parse(m['created_at'])
            : null,
        updatedAt: m['updated_at'] != null
            ? DateTime.parse(m['updated_at'])
            : null,
      );

  String get typeLabel {
    switch (type) {
      case 'feedback':
        return 'Feedback';
      case 'commande':
        return 'Commande';
      case 'inscription':
        return 'Inscription';
      case 'enquete':
        return 'Enquête';
      default:
        return 'Autre';
    }
  }
}
