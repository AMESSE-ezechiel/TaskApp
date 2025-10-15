
class TaskModel {
  final int? id;
  final String? title;
  final String? description;
  final String? status;
  final String? priority;
  final String? dueDate;
  final int? userId;

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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0'),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      priority: json['priority']?.toString(),
      dueDate: json['due_date']?.toString(),
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'due_date': dueDate,
      'user_id': userId,
    };
  }
}

