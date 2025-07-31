class Holiday {
  final String? id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Holiday({
    this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'],
      userId: json['user_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Holiday copyWith({
    String? id,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Holiday(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }
}
