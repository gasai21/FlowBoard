import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../providers/workspace_provider.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final Task task;
  final String columnId;

  const TaskDetailScreen({super.key, required this.task, required this.columnId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final board = ref.read(currentBoardProvider);
    if (board == null) return;

    final updatedColumns = board.columns.map((col) {
      if (col.id == widget.columnId) {
        final updatedTasks = col.tasks.map((t) {
          if (t.id == widget.task.id) {
            return t.copyWith(
              title: _titleController.text,
              description: _descController.text,
            );
          }
          return t;
        }).toList();
        return col.copyWith(tasks: updatedTasks);
      }
      return col;
    }).toList();

    final updatedBoard = board.copyWith(columns: updatedColumns);
    ref.read(currentBoardProvider.notifier).state = updatedBoard;
    ref.read(workspaceProvider.notifier).updateBoard(updatedBoard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF172B4D)),
          onPressed: () {
            _saveChanges();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF172B4D),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Task Title',
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                const Icon(Icons.description_outlined, size: 20, color: Color(0xFF44546F)),
                SizedBox(width: 8.w),
                Text(
                  'Description',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF172B4D),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _descController,
              maxLines: null,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFF172B4D),
              ),
              decoration: InputDecoration(
                hintText: 'Add a more detailed description...',
                filled: true,
                fillColor: const Color(0xFFF1F2F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _saveChanges();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0079BF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
