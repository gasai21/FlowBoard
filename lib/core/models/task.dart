import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String description;

  Task({
    required this.id,
    required this.title,
    this.description = '',
  });

  factory Task.create(String title, {String description = ''}) {
    return Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
    );
  }

  Task copyWith({String? title, String? description}) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}
