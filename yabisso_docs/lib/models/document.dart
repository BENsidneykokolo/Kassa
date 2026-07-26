class Document {
  final int? id;
  final String title;
  final String? content;
  final String? templateId;
  final String type;
  final String status;
  final String? clientName;
  final double? amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Document({
    this.id,
    required this.title,
    this.content,
    this.templateId,
    this.type = 'autre',
    this.status = 'brouillon',
    this.clientName,
    this.amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'content': content,
        'template_id': templateId,
        'type': type,
        'status': status,
        'client_name': clientName,
        'amount': amount,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Document.fromMap(Map<String, dynamic> m) => Document(
        id: m['id'] as int?,
        title: m['title'] as String,
        content: m['content'] as String?,
        templateId: m['template_id'] as String?,
        type: m['type'] as String? ?? 'autre',
        status: m['status'] as String? ?? 'brouillon',
        clientName: m['client_name'] as String?,
        amount: (m['amount'] as num?)?.toDouble(),
        createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
        updatedAt: m['updated_at'] != null ? DateTime.parse(m['updated_at']) : null,
      );

  String get typeLabel {
    switch (type) {
      case 'facture':
        return 'Facture';
      case 'devis':
        return 'Devis';
      case 'contrat':
        return 'Contrat';
      case 'bon':
        return 'Bon de commande';
      case 'recu':
        return 'Reçu';
      case 'lettre':
        return 'Lettre';
      default:
        return 'Autre';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'brouillon':
        return 'Brouillon';
      case 'finalise':
        return 'Finalisé';
      case 'archive':
        return 'Archivé';
      default:
        return status;
    }
  }
}
