import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/workspace_provider.dart';
import 'board_screen.dart';

class WorkspaceScreen extends ConsumerWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boards = ref.watch(workspaceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Workspace',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF172B4D),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.w,
          childAspectRatio: 1.5,
        ),
        itemCount: boards.length + 1,
        itemBuilder: (context, index) {
          if (index == boards.length) {
            return _buildAddBoardButton(context, ref);
          }
          final board = boards[index];
          return GestureDetector(
            onTap: () {
              ref.read(currentBoardProvider.notifier).state = board;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BoardScreen()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(int.parse(board.backgroundColor)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.all(12.w),
              child: Text(
                board.title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddBoardButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showAddBoardDialog(context, ref),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2F4),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, color: Color(0xFF44546F)),
              Text(
                'Create Board',
                style: GoogleFonts.inter(
                  color: const Color(0xFF44546F),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBoardDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Board', style: GoogleFonts.poppins()),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Board Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(workspaceProvider.notifier).addBoard(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
