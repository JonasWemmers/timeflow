class Break {
  final String? id;
  final String userId;
  final String? workTimeId;
  final DateTime startTime;
  final DateTime? endTime;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Break({
    this.id,
    required this.userId,
    this.workTimeId,
    required this.startTime,
    this.endTime,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Break.fromJson(Map<String, dynamic> json) {
    return Break(
      id: json['id'],
      userId: json['user_id'],
      workTimeId: json['work_time_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'work_time_id': workTimeId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'date': date.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Break copyWith({
    String? id,
    String? userId,
    String? workTimeId,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Break(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workTimeId: workTimeId ?? this.workTimeId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  bool get isActive => endTime == null;
}
