import 'package:uuid/uuid.dart';
import 'task.dart';

class BoardColumn {
  final String id;
  final String title;
  final List<Task> tasks;

  BoardColumn({
    required this.id,
    required this.title,
    required this.tasks,
  });

  factory BoardColumn.create(String title, {List<Task>? tasks}) {
    return BoardColumn(
      id: const Uuid().v4(),
      title: title,
      tasks: tasks ?? [],
    );
  }

  BoardColumn copyWith({String? title, List<Task>? tasks}) {
    return BoardColumn(
      id: id,
      title: title ?? this.title,
      tasks: tasks ?? this.tasks,
    );
  }
}
