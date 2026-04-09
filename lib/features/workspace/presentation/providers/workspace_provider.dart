import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/board.dart';
import '../../../../core/models/board_column.dart';
import '../../../../core/models/task.dart';
import '../../../../core/database/database_service.dart';

class WorkspaceNotifier extends StateNotifier<List<Board>> {
  final DatabaseService _db = DatabaseService();

  WorkspaceNotifier() : super([]) {
    _loadData();
  }

  Future<void> _loadData() async {
    final boards = await _db.getBoards();
    if (boards.isNotEmpty) {
      state = boards;
    } else {
      _loadInitialDummyData();
    }
  }

  void _loadInitialDummyData() {
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
    _db.saveBoards(state);
  }

  Future<void> addBoard(String title) async {
    state = [...state, Board.create(title)];
    await _db.saveBoards(state);
  }

  Future<void> updateBoard(Board updatedBoard) async {
    state = [
      for (final board in state)
        if (board.id == updatedBoard.id) updatedBoard else board
    ];
    await _db.saveBoards(state);
  }

  Future<void> deleteBoard(String boardId) async {
    state = state.where((board) => board.id != boardId).toList();
    await _db.saveBoards(state);
  }
}

final workspaceProvider = StateNotifierProvider<WorkspaceNotifier, List<Board>>((ref) {
  return WorkspaceNotifier();
});

final currentBoardProvider = StateProvider<Board?>((ref) => null);
