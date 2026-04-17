
import 'package:flutter/material.dart';

import '../../Color/app_color_model.dart';
class CirclePoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Cercle avec quatre couleurs distinctes
        CustomPaint(
          size: Size(200, 200), // Taille du cercle
          painter: FourColorCirclePainter(),
        ),
        // Cercle blanc au centre
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class FourColorCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 1.7;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Liste des couleurs
    final List<Color> colors = [
      AppColorModel.YellowColor,

      AppColorModel.YellowColor,
      AppColorModel.Blue,
      AppColorModel.BlueSimple
    ];

    // Dessiner quatre secteurs
    for (int i = 0; i < 4; i++) {
      final Paint paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      final double startAngle =
          i * (3.141592653589793 / 2); // 90 degrés en radians
      final double sweepAngle = 3.141592653589793 / 2; // 90 degrés en radians

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
