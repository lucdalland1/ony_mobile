
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../Color/app_color_model.dart';
class CircleWithFourColors extends StatelessWidget {
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
          child: Column(
            children: [
              SvgPicture.asset(
                "asset/recharge.svg",
                height: 30,
                width: 20,
                color: AppColorModel.Grey,
              ),
              Text(
                "50%",
                style: TextStyle(
                    fontSize: 30,
                    color: AppColorModel.BlueColor,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "Recharge",
                style: TextStyle(fontSize: 13, color: AppColorModel.Grey),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class FourColorCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2.7;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Liste des couleurs
    final List<Color> colors = [
      Colors.red,
      AppColorModel.BlueColor,
      AppColorModel.blackColor,
      AppColorModel.Grey
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
