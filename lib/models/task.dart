class Task {
  final String id;
  final String title;
  final String description;
  final String category;
  final int priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isCompleted;
  final int sortOrder;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    this.priority = 3,
    required this.createdAt,
    this.dueDate,
    this.isCompleted = false,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'sortOrder': sortOrder,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      category: map['category'],
      priority: map['priority'] ?? 3,
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      isCompleted: map['isCompleted'] == 1,
      sortOrder: map['sortOrder'] ?? 0,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isCompleted,
    int? sortOrder,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}