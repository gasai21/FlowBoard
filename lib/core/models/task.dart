import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }

class ChecklistItem {
  final String id;
  final String title;
  final bool isDone;

  ChecklistItem({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  ChecklistItem copyWith({String? title, bool? isDone}) {
    return ChecklistItem(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final List<String> labels;
  final DateTime? dueDate;
  final List<ChecklistItem> checklist;
  final TaskPriority priority;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.labels = const [],
    this.dueDate,
    this.checklist = const [],
    this.priority = TaskPriority.low,
  });

  factory Task.create(String title, {String description = ''}) {
    return Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
    );
  }

  Task copyWith({
    String? title,
    String? description,
    List<String>? labels,
    DateTime? dueDate,
    List<ChecklistItem>? checklist,
    TaskPriority? priority,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      labels: labels ?? this.labels,
      dueDate: dueDate ?? this.dueDate,
      checklist: checklist ?? this.checklist,
      priority: priority ?? this.priority,
    );
  }
}
