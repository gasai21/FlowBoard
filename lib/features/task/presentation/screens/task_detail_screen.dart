import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/task.dart';
import '../../../workspace/presentation/providers/workspace_provider.dart';

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
  late List<ChecklistItem> _checklist;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.low;
  final List<String> _labels = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _checklist = List.from(widget.task.checklist);
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _labels.addAll(widget.task.labels);
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
              checklist: _checklist,
              dueDate: _dueDate,
              priority: _priority,
              labels: _labels,
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

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final board = ref.read(currentBoardProvider);
              if (board != null) {
                final updatedColumns = board.columns.map((col) {
                  if (col.id == widget.columnId) {
                    return col.copyWith(
                      tasks: col.tasks.where((t) => t.id != widget.task.id).toList(),
                    );
                  }
                  return col;
                }).toList();
                
                final updatedBoard = board.copyWith(columns: updatedColumns);
                ref.read(currentBoardProvider.notifier).state = updatedBoard;
                ref.read(workspaceProvider.notifier).updateBoard(updatedBoard);
              }
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to Board
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = 0;
    if (_checklist.isNotEmpty) {
      int completed = _checklist.where((item) => item.isDone).length;
      progress = completed / _checklist.length;
    }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF172B4D),
              ),
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Task Title'),
            ),
            _buildSectionHeader(Icons.label_outline, 'Labels'),
            Wrap(
              spacing: 8,
              children: [
                ..._labels.map((l) => Chip(
                  label: Text(l, style: TextStyle(fontSize: 12.sp)),
                  onDeleted: () => setState(() => _labels.remove(l)),
                )),
                ActionChip(
                  label: const Icon(Icons.add, size: 16),
                  onPressed: () => _showAddLabelDialog(),
                ),
              ],
            ),
            _buildSectionHeader(Icons.priority_high, 'Priority'),
            SegmentedButton<TaskPriority>(
              segments: const [
                ButtonSegment(value: TaskPriority.low, label: Text('Low')),
                ButtonSegment(value: TaskPriority.medium, label: Text('Medium')),
                ButtonSegment(value: TaskPriority.high, label: Text('High')),
              ],
              selected: {_priority},
              onSelectionChanged: (val) => setState(() => _priority = val.first),
            ),
            _buildSectionHeader(Icons.calendar_today_outlined, 'Due Date'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_dueDate == null ? 'Set due date' : DateFormat('EEE, d MMM yyyy').format(_dueDate!)),
              trailing: const Icon(Icons.edit_calendar),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _dueDate = date);
              },
            ),
            _buildSectionHeader(Icons.checklist, 'Checklist'),
            if (_checklist.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF44546F))),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFFF1F2F4),
                          color: progress == 1.0 ? Colors.green : const Color(0xFF0079BF),
                          minHeight: 8.h,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ..._checklist.asMap().entries.map((entry) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Checkbox(
                value: entry.value.isDone,
                onChanged: (val) => setState(() {
                  _checklist[entry.key] = entry.value.copyWith(isDone: val);
                }),
              ),
              title: Text(
                entry.value.title,
                style: TextStyle(
                  fontSize: 14.sp,
                  decoration: entry.value.isDone ? TextDecoration.lineThrough : null,
                  color: entry.value.isDone ? const Color(0xFF44546F) : const Color(0xFF172B4D),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => setState(() {
                  _checklist.removeAt(entry.key);
                }),
              ),
            )),
            TextButton.icon(
              onPressed: () => _showAddChecklistDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add item'),
            ),
            _buildSectionHeader(Icons.description_outlined, 'Description'),
            TextField(
              controller: _descController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Add description...',
                filled: true,
                fillColor: const Color(0xFFF1F2F4),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 32.h),
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
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _deleteTask,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF44546F)),
          SizedBox(width: 8.w),
          Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showAddLabelDialog() {
    final controller = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Add Label'),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () {
          if (controller.text.isNotEmpty) setState(() => _labels.add(controller.text));
          Navigator.pop(context);
        }, child: const Text('Add')),
      ],
    ));
  }

  void _showAddChecklistDialog() {
    final controller = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Add Checklist Item'),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () {
          if (controller.text.isNotEmpty) {
            setState(() => _checklist.add(ChecklistItem(id: const Uuid().v4(), title: controller.text)));
          }
          Navigator.pop(context);
        }, child: const Text('Add')),
      ],
    ));
  }
}
