class Conversation {
  final int? id;
  final String title;
  final String? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({this.id, required this.title, this.lastMessage, DateTime? createdAt, DateTime? updatedAt})
      : createdAt = createdAt ?? DateTime.now(), updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'title': title, 'last_message': lastMessage,
    'created_at': createdAt.toIso8601String(), 'updated_at': updatedAt.toIso8601String(),
  };

  factory Conversation.fromMap(Map<String, dynamic> m) => Conversation(
    id: m['id'] as int?, title: m['title'] as String, lastMessage: m['last_message'] as String?,
    createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
    updatedAt: m['updated_at'] != null ? DateTime.parse(m['updated_at']) : null,
  );
}
