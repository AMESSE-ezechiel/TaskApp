enum TaskStatus {
  EN_ATTENTE('en_attente'),
  EN_COURS('en_cours'),
  TERMINE('termine'),
  ANNULE('annule');

  final String value;

  String get label {
    switch (this) {
      case TaskStatus.EN_ATTENTE:
        return "En attente";
      case TaskStatus.EN_COURS:
        return "En cours";
      case TaskStatus.TERMINE:
        return "Terminé";
      case TaskStatus.ANNULE:
        return "Annulé";
    }
  }
  const TaskStatus(this.value);

  /// Convertit une chaîne (ex: 'en_attente') en [TaskStatus].
  static TaskStatus? fromString(String? s) {
    if (s == null) return null;
    for (final e in TaskStatus.values) {
      if (e.value == s) return e;
    }
    return null;
  }

  @override
  String toString() => value;
}

enum TaskPriority {
  ELEVE('eleve'),
  MOYENNE('moyenne'),
  BASSE('basse'),
  INDIFFERENT('indifferent');

  final String value;
  const TaskPriority(this.value);

  String get label {
    switch (this) {
      case TaskPriority.ELEVE:
        return "Élevée";
      case TaskPriority.MOYENNE:
        return "Moyenne";
      case TaskPriority.BASSE:
        return "Basse";
      case TaskPriority.INDIFFERENT:
        return "Indifférente";
    }
  }

  /// Convertit une chaîne (ex: 'eleve') en [TaskPriority].
  static TaskPriority? fromString(String? s) {
    if (s == null) return null;
    for (final e in TaskPriority.values) {
      if (e.value == s) return e;
    }
    return null;
  }

  @override
  String toString() => value;
}

class TaskModel {
  final int? id;
  final String? title;
  final String? description;
  final TaskStatus? status;
  final TaskPriority? priority;
  final String? dueDate;
  final int? userId;

  /// Fournit la valeur enum correspondante si possible
  TaskStatus? get statusEnum => status;

  /// Fournit la valeur enum de priorité si possible
  TaskPriority? get priorityEnum => priority;

  TaskModel({
    this.id,
    this.title,
    this.description,
    this.status,
    this.priority,
    this.dueDate,
    this.userId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0'),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      status: json['status'] != null ? TaskStatus.fromString(json['status']) : null,
      priority: json['priority'] != null ? TaskPriority.fromString(json['priority']) : null,
      dueDate: json['due_date']?.toString(),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status?.value,
      'priority': priority?.value,
      'due_date': dueDate,
      'user_id': userId,
    };
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? dueDate,
    int? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      userId: userId ?? this.userId,
    );
  }
}