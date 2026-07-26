class Message {
  final int? id;
  final int conversationId;
  final String role; // user, assistant
  final String content;
  final DateTime createdAt;

  Message({this.id, required this.conversationId, required this.role, required this.content, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'conversation_id': conversationId, 'role': role, 'content': content,
    'created_at': createdAt.toIso8601String(),
  };

  factory Message.fromMap(Map<String, dynamic> m) => Message(
    id: m['id'] as int?, conversationId: m['conversation_id'] as int, role: m['role'] as String,
    content: m['content'] as String, createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
  );
}
