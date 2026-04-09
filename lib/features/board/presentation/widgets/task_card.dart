import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({super.key, required this.task, required this.onTap});

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedChecklist = task.checklist.where((item) => item.isDone).length;
    final totalChecklist = task.checklist.length;
    final progress = totalChecklist > 0 ? completedChecklist / totalChecklist : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.labels.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Wrap(
                  spacing: 4.w,
                  children: task.labels.map((label) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0079BF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0079BF),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            Text(
              task.title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF172B4D),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                if (task.dueDate != null) ...[
                  Icon(Icons.access_time, size: 14.sp, color: const Color(0xFF44546F)),
                  SizedBox(width: 4.w),
                  Text(
                    DateFormat('MMM d').format(task.dueDate!),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF44546F),
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                if (totalChecklist > 0) ...[
                  Icon(
                    completedChecklist == totalChecklist ? Icons.check_box : Icons.check_box_outlined,
                    size: 14.sp,
                    color: completedChecklist == totalChecklist ? Colors.green : const Color(0xFF44546F),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '$completedChecklist/$totalChecklist',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: completedChecklist == totalChecklist ? Colors.green : const Color(0xFF44546F),
                    ),
                  ),
                ],
              ],
            ),
            if (totalChecklist > 0) ...[
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(2.r),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4.h,
                  backgroundColor: const Color(0xFFF1F2F4),
                  color: progress == 1.0 ? Colors.green : const Color(0xFF0079BF),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
