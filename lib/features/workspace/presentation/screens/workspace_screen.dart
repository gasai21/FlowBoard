import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/board.dart';
import '../../../../features/workspace/presentation/providers/workspace_provider.dart';
import '../../../../features/board/presentation/screens/board_screen.dart';

class WorkspaceScreen extends ConsumerWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boards = ref.watch(workspaceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'FlowBoard',
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
          return _buildBoardCard(context, ref, board);
        },
      ),
    );
  }

  Widget _buildBoardCard(BuildContext context, WidgetRef ref, Board board) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              board.title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () => _showBoardOptions(context, ref, board),
                child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBoardOptions(BuildContext context, WidgetRef ref, Board board) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename Board'),
              onTap: () {
                Navigator.pop(context);
                _showEditBoardDialog(context, ref, board);
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Change Color'),
              onTap: () {
                Navigator.pop(context);
                _showColorPicker(context, ref, board);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Board', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref, board);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, WidgetRef ref, Board board) {
    final colors = [
      '0xFF0079BF', '0xFF519839', '0xFFD29034', 
      '0xFFB04632', '0xFF89609E', '0xFFCD5A91', 
      '0xFF4BBF6B', '0xFF00AECC', '0xFF838C91',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: colors.map((color) => GestureDetector(
              onTap: () {
                ref.read(workspaceProvider.notifier).updateBoard(
                  board.copyWith(backgroundColor: color),
                );
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color(int.parse(color)),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: board.backgroundColor == color ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            )).toList(),
          ),
        ),
      ),
    );
  }

  void _showEditBoardDialog(BuildContext context, WidgetRef ref, Board board) {
    final controller = TextEditingController(text: board.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Board', style: GoogleFonts.poppins()),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Board Title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(workspaceProvider.notifier).updateBoard(
                  board.copyWith(title: controller.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Board board) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Board?', style: GoogleFonts.poppins()),
        content: Text('Are you sure you want to delete "${board.title}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(workspaceProvider.notifier).deleteBoard(board.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
