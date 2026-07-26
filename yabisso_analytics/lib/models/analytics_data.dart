class AnalyticsEvent {
  final String id;
  final String type;
  final String label;
  final double value;
  final DateTime date;
  final Map<String, dynamic>? metadata;

  AnalyticsEvent({
    required this.id,
    required this.type,
    required this.label,
    required this.value,
    required this.date,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'label': label,
      'value': value,
      'date': date.toIso8601String(),
      'metadata': metadata != null ? _encodeMetadata(metadata!) : null,
    };
  }

  factory AnalyticsEvent.fromMap(Map<String, dynamic> map) {
    return AnalyticsEvent(
      id: map['id'],
      type: map['type'],
      label: map['label'],
      value: (map['value'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      metadata: map['metadata'] != null ? _decodeMetadata(map['metadata']) : null,
    );
  }

  static String _encodeMetadata(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}=${e.value}').join(';');
  }

  static Map<String, dynamic>? _decodeMetadata(String raw) {
    if (raw.isEmpty) return null;
    final map = <String, dynamic>{};
    for (final part in raw.split(';')) {
      final kv = part.split('=');
      if (kv.length == 2) map[kv[0]] = kv[1];
    }
    return map.isEmpty ? null : map;
  }
}
