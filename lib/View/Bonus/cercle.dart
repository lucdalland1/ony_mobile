import 'dart:math';

import 'package:flutter/material.dart';
import 'package:onyfast/Color/app_color_model.dart';

class SemiCircleChart extends StatelessWidget {
  final double percentage;

  const SemiCircleChart({Key? key, required this.percentage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        CustomPaint(
          size: Size(200, 100), // Taille du demi-cercle
          painter: SemiCirclePainter(),
        ),
        Positioned(
          top: 60,
          child: Text(
            "${percentage.toInt()}%",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColorModel.GreyBlack,
            ),
          ),
        ),
      ],
    );
  }
}

class SemiCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    final colors = [Colors.red, Colors.green, Colors.blue, Colors.orange];
    final sweepAngle = pi / 4; // 45° par segment
    double startAngle = pi; // Commence à 180°
    for (int i = 0; i < 4; i++) {
      paint.color = colors[i];
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}