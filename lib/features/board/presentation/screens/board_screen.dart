import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/board_column.dart';
import '../../../../core/models/task.dart';
import '../../../task/presentation/screens/task_detail_screen.dart';
import '../../presentation/widgets/task_card.dart';
import '../../../workspace/presentation/providers/workspace_provider.dart';

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
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
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
      ),
    );
  }

  Widget _buildColumn(BuildContext context, WidgetRef ref, BoardColumn column) {
    return Container(
      width: 280.w,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(12.r),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                IconButton(
                  icon: const Icon(Icons.more_horiz, size: 20, color: Color(0xFF44546F)),
                  onPressed: () => _showColumnOptions(context, ref, column),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          Flexible(
            child: DragTarget<Map<String, dynamic>>(
              onWillAccept: (data) => data?['fromColumnId'] != column.id,
              onAccept: (data) {
                _handleMoveTask(ref, data['taskId'], data['fromColumnId'], column.id);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty 
                        ? Colors.black.withOpacity(0.05) 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (column.tasks.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: column.tasks.length,
                          itemBuilder: (context, index) {
                            final task = column.tasks[index];
                            return _buildDraggableTask(context, ref, task, column.id);
                          },
                        )
                      else
                        Container(
                          height: 100.h,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: candidateData.isNotEmpty 
                              ? const Icon(Icons.add_circle_outline, color: Color(0xFF0079BF))
                              : null,
                        ),
                    ],
                  ),
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

  void _showColumnOptions(BuildContext context, WidgetRef ref, BoardColumn column) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename List'),
              onTap: () {
                Navigator.pop(context);
                _showRenameColumnDialog(context, ref, column);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete List', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteColumnConfirmation(context, ref, column);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameColumnDialog(BuildContext context, WidgetRef ref, BoardColumn column) {
    final controller = TextEditingController(text: column.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename List', style: GoogleFonts.poppins()),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'List Title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final board = ref.read(currentBoardProvider)!;
                final updatedColumns = board.columns.map((c) => c.id == column.id ? c.copyWith(title: controller.text) : c).toList();
                final updatedBoard = board.copyWith(columns: updatedColumns);
                ref.read(currentBoardProvider.notifier).state = updatedBoard;
                ref.read(workspaceProvider.notifier).updateBoard(updatedBoard);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteColumnConfirmation(BuildContext context, WidgetRef ref, BoardColumn column) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete List?', style: GoogleFonts.poppins()),
        content: Text('Delete "${column.title}" and all its tasks?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final board = ref.read(currentBoardProvider)!;
              final updatedColumns = board.columns.where((c) => c.id != column.id).toList();
              final updatedBoard = board.copyWith(columns: updatedColumns);
              ref.read(currentBoardProvider.notifier).state = updatedBoard;
              ref.read(workspaceProvider.notifier).updateBoard(updatedBoard);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableTask(BuildContext context, WidgetRef ref, Task task, String columnId) {
    return Draggable<Map<String, dynamic>>(
      data: {'taskId': task.id, 'fromColumnId': columnId},
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 256.w,
          child: TaskCard(task: task, onTap: () {}),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: TaskCard(task: task, onTap: () {}),
      ),
      child: TaskCard(
        task: task,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task, columnId: columnId),
            ),
          );
        },
      ),
    );
  }

  void _handleMoveTask(WidgetRef ref, String taskId, String fromColumnId, String toColumnId) {
    final board = ref.read(currentBoardProvider)!;
    final fromColumn = board.columns.firstWhere((col) => col.id == fromColumnId);
    final task = fromColumn.tasks.firstWhere((t) => t.id == taskId);
    
    final updatedColumns = board.columns.map((column) {
      if (column.id == fromColumnId) {
        return column.copyWith(tasks: column.tasks.where((t) => t.id != taskId).toList());
      } else if (column.id == toColumnId) {
        if (column.tasks.any((t) => t.id == taskId)) return column;
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
      margin: EdgeInsets.symmetric(horizontal: 8.w),
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
