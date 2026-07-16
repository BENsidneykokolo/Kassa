class ChurchEvent {
  final String id;
  final String title;
  final String? description;
  final String eventType;
  final String startDate;
  final String? endDate;
  final String? location;
  final String? speaker;
  final int? expectedAttendees;
  final String? notes;
  final String createdAt;
  final String? updatedAt;

  const ChurchEvent({
    required this.id,
    required this.title,
    this.description,
    required this.eventType,
    required this.startDate,
    this.endDate,
    this.location,
    this.speaker,
    this.expectedAttendees,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_type': eventType,
      'start_date': startDate,
      'end_date': endDate,
      'location': location,
      'speaker': speaker,
      'expected_attendees': expectedAttendees,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory ChurchEvent.fromMap(Map<String, dynamic> map) {
    return ChurchEvent(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      eventType: map['event_type'] ?? 'worship',
      startDate: map['start_date'] ?? '',
      endDate: map['end_date'],
      location: map['location'],
      speaker: map['speaker'],
      expectedAttendees: map['expected_attendees'],
      notes: map['notes'],
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'],
    );
  }
}
