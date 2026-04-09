import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogo({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: CustomPaint(
        painter: _FlowBoardPainter(color ?? const Color(0xFF0079BF)),
      ),
    );
  }
}

class _FlowBoardPainter extends CustomPainter {
  final Color color;

  _FlowBoardPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;
    final double spacing = width * 0.15;
    final double barWidth = (width - (spacing * 2)) / 3;

    // Bar 1 (Short)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, height * 0.3, barWidth, height * 0.7),
        Radius.circular(barWidth * 0.3),
      ),
      paint,
    );

    // Bar 2 (Tall)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barWidth + spacing, 0, barWidth, height),
        Radius.circular(barWidth * 0.3),
      ),
      paint,
    );

    // Bar 3 (Medium)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH((barWidth + spacing) * 2, height * 0.15, barWidth, height * 0.85),
        Radius.circular(barWidth * 0.3),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
