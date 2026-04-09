import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board.dart';
import '../models/board_column.dart';
import '../models/task.dart';

class WorkspaceNotifier extends StateNotifier<List<Board>> {
  WorkspaceNotifier() : super([]) {
    _loadInitialData();
  }

  void _loadInitialData() {
    state = [
      Board(
        id: '1',
        title: 'Project Alpha',
        backgroundColor: '0xFF0079BF',
        columns: [
          BoardColumn.create('To Do', tasks: [
            Task.create('Research fonts'),
            Task.create('Setup Riverpod'),
          ]),
          BoardColumn.create('In Progress'),
          BoardColumn.create('Done'),
        ],
      ),
      Board(
        id: '2',
        title: 'Personal Goals',
        backgroundColor: '0xFF519839',
        columns: [
          BoardColumn.create('Backlog'),
          BoardColumn.create('This Month'),
        ],
      ),
    ];
  }

  void addBoard(String title) {
    state = [...state, Board.create(title)];
  }

  void updateBoard(Board updatedBoard) {
    state = [
      for (final board in state)
        if (board.id == updatedBoard.id) updatedBoard else board
    ];
  }
}

final workspaceProvider = StateNotifierProvider<WorkspaceNotifier, List<Board>>((ref) {
  return WorkspaceNotifier();
});

final currentBoardProvider = StateProvider<Board?>((ref) => null);
