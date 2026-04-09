import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/workspace_provider.dart';
import '../widgets/task_card.dart';
import '../models/board_column.dart';
import '../models/task.dart';
import 'task_detail_screen.dart';

class BoardScreen extends ConsumerWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(currentBoardProvider);
    if (board == null) return const Scaffold();

    return Scaffold(
      backgroundColor: Color(int.parse(board.backgroundColor)),
      appBar: AppBar(
        backgroundColor: Colors.black12,
        elevation: 0,
        title: Text(
          board.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final column in board.columns)
                _buildColumn(context, ref, column),
              _buildAddColumnButton(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(BuildContext context, WidgetRef ref, BoardColumn column) {
    return Container(
      width: 280.w,
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    column.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF172B4D),
                    ),
                  ),
                ),
                const Icon(Icons.more_horiz, size: 20, color: Color(0xFF44546F)),
              ],
            ),
          ),
          Flexible(
            child: DragTarget<Map<String, dynamic>>(
              onWillAccept: (data) => true,
              onAccept: (data) {
                _handleMoveTask(ref, data['taskId'], data['fromColumnId'], column.id);
              },
              builder: (context, candidateData, rejectedData) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: column.tasks.length,
                  itemBuilder: (context, index) {
                    final task = column.tasks[index];
                    return Draggable<Map<String, dynamic>>(
                      data: {'taskId': task.id, 'fromColumnId': column.id},
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          width: 256.w,
                          child: TaskCard(task: task, onTap: () {}),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: TaskCard(task: task, onTap: () {}),
                      ),
                      child: TaskCard(
                        task: task,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskDetailScreen(task: task, columnId: column.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: TextButton.icon(
              onPressed: () => _showAddTaskDialog(context, ref, column.id),
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                'Add a card',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF44546F),
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMoveTask(WidgetRef ref, String taskId, String fromColumnId, String toColumnId) {
    final board = ref.read(currentBoardProvider)!;
    
    final fromColumn = board.columns.firstWhere((col) => col.id == fromColumnId);
    final task = fromColumn.tasks.firstWhere((t) => t.id == taskId);
    
    final updatedColumns = board.columns.map((column) {
      if (column.id == fromColumnId && column.id == toColumnId) {
         // Same column move (not implemented for index here for simplicity, just stays)
         return column;
      } else if (column.id == fromColumnId) {
        return column.copyWith(tasks: column.tasks.where((t) => t.id != taskId).toList());
      } else if (column.id == toColumnId) {
        return column.copyWith(tasks: [...column.tasks, task]);
      }
      return column;
    }).toList();

    final updatedBoard = board.copyWith(columns: updatedColumns);
    ref.read(currentBoardProvider.notifier).state = updatedBoard;
    ref.read(workspaceProvider.notifier).updateBoard(updatedBoard);
  }

  Widget _buildAddColumnButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280.w,
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextButton.icon(
        onPressed: () => _showAddColumnDialog(context, ref),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add another list',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref, String columnId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Task', style: GoogleFonts.poppins()),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter task title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final board = ref.read(currentBoardProvider)!;
                final updatedColumns = board.columns.map((col) {
                  if (col.id == columnId) {
                    return col.copyWith(tasks: [...col.tasks, Task.create(controller.text)]);
                  }
                  return col;
                }).toList();
                
                final updatedBoard = board.copyWith(columns: updatedColumns);
                ref.read(currentBoardProvider.notifier).state = updatedBoard;
                ref.read(workspaceProvider.notifier).updateBoard(updatedBoard);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddColumnDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New List', style: GoogleFonts.poppins()),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter list title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final board = ref.read(currentBoardProvider)!;
                final updatedBoard = board.copyWith(
                  columns: [...board.columns, BoardColumn.create(controller.text)],
                );
                ref.read(currentBoardProvider.notifier).state = updatedBoard;
                ref.read(workspaceProvider.notifier).updateBoard(updatedBoard);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
