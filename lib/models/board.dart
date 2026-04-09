import 'package:uuid/uuid.dart';
import 'board_column.dart';

class Board {
  final String id;
  final String title;
  final List<BoardColumn> columns;
  final String backgroundColor;

  Board({
    required this.id,
    required this.title,
    required this.columns,
    this.backgroundColor = '0xFF0079BF',
  });

  factory Board.create(String title, {String color = '0xFF0079BF'}) {
    return Board(
      id: const Uuid().v4(),
      title: title,
      columns: [],
      backgroundColor: color,
    );
  }

  Board copyWith({String? title, List<BoardColumn>? columns}) {
    return Board(
      id: id,
      title: title ?? this.title,
      columns: columns ?? this.columns,
      backgroundColor: backgroundColor,
    );
  }
}
