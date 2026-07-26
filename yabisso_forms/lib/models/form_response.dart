class FormResponse {
  final int? id;
  final int formId;
  final String? respondentName;
  final String? respondentPhone;
  final String? answersJson;
  final DateTime createdAt;

  FormResponse({
    this.id,
    required this.formId,
    this.respondentName,
    this.respondentPhone,
    this.answersJson,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'form_id': formId,
        'respondent_name': respondentName,
        'respondent_phone': respondentPhone,
        'answers_json': answersJson,
        'created_at': createdAt.toIso8601String(),
      };

  factory FormResponse.fromMap(Map<String, dynamic> m) => FormResponse(
        id: m['id'] as int?,
        formId: m['form_id'] as int,
        respondentName: m['respondent_name'] as String?,
        respondentPhone: m['respondent_phone'] as String?,
        answersJson: m['answers_json'] as String?,
        createdAt: m['created_at'] != null
            ? DateTime.parse(m['created_at'])
            : null,
      );
}
