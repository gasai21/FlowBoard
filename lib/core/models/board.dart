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

  factory Board.create(String title, {String? color}) {
    return Board(
      id: const Uuid().v4(),
      title: title,
      columns: [],
      backgroundColor: color ?? _getRandomColor(),
    );
  }

  static String _getRandomColor() {
    final colors = [
      '0xFF0079BF', // Blue
      '0xFF519839', // Green
      '0xFFD29034', // Orange
      '0xFFB04632', // Red
      '0xFF89609E', // Purple
      '0xFFCD5A91', // Pink
      '0xFF4BBF6B', // Light Green
      '0xFF00AECC', // Sky Blue
      '0xFF838C91', // Grey
    ];
    return (colors..shuffle()).first;
  }

  Board copyWith({String? title, List<BoardColumn>? columns, String? backgroundColor}) {
    return Board(
      id: id,
      title: title ?? this.title,
      columns: columns ?? this.columns,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}
