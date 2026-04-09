import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board_column.dart';
import '../models/task.dart';

class BoardNotifier extends StateNotifier<List<BoardColumn>> {
  BoardNotifier() : super([]) {
    _loadInitialData();
  }

  void _loadInitialData() {
    state = [
      BoardColumn.create('To Do', tasks: [
        Task.create('Research fonts', description: 'Find Inter and Poppins details'),
        Task.create('Setup Riverpod', description: 'Add dependencies and create base classes'),
      ]),
      BoardColumn.create('In Progress', tasks: [
        Task.create('Design UI', description: 'Create main board layout'),
      ]),
      BoardColumn.create('Done', tasks: []),
    ];
  }

  void addColumn(String title) {
    state = [...state, BoardColumn.create(title)];
  }

  void addTask(String columnId, String title) {
    state = [
      for (final column in state)
        if (column.id == columnId)
          column.copyWith(tasks: [...column.tasks, Task.create(title)])
        else
          column
    ];
  }

  void moveTask(String taskId, String fromColumnId, String toColumnId, int newIndex) {
    final fromColumn = state.firstWhere((col) => col.id == fromColumnId);
    final task = fromColumn.tasks.firstWhere((t) => t.id == taskId);

    final updatedFromTasks = fromColumn.tasks.where((t) => t.id != taskId).toList();

    state = [
      for (final column in state)
        if (column.id == fromColumnId && column.id == toColumnId)
          column.copyWith(
            tasks: [...updatedFromTasks..insert(newIndex, task)],
          )
        else if (column.id == fromColumnId)
          column.copyWith(tasks: updatedFromTasks)
        else if (column.id == toColumnId)
          column.copyWith(
            tasks: [...column.tasks..insert(newIndex, task)],
          )
        else
          column
    ];
  }

  void updateTask(String taskId, {String? title, String? description}) {
    state = [
      for (final column in state)
        column.copyWith(
          tasks: [
            for (final task in column.tasks)
              if (task.id == taskId)
                task.copyWith(title: title, description: description)
              else
                task
          ],
        )
    ];
  }
}

final boardProvider = StateNotifierProvider<BoardNotifier, List<BoardColumn>>((ref) {
  return BoardNotifier();
});
