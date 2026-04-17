import 'dart:math' as math;
import 'package:flutter/material.dart';

class SvgBackground extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  const SvgBackground({super.key, required this.screenWidth, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    final scale = screenWidth / 618.2;
    final displayH = 675.76 * scale;
    return ClipRect(
      child: SizedBox(
        width: screenWidth,
        height: displayH,
        child: CustomPaint(
          painter: _BgPainter(scale: scale),
          size: Size(screenWidth, displayH),
        ),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double scale;
  const _BgPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final paint = Paint()
      ..color = const Color(0xFFE6E6E6).withOpacity(0.32)
      ..style = PaintingStyle.fill;

    _drawRect(canvas, paint, rx: 518.71, ry: -88.12, rw: 520.96, rh: 540.4, rrx: 33.69, tx: 13.35,  ty: 413.99, angleDeg: -30);
    _drawRect(canvas, paint, rx: 475.94, ry: 80.35,  rw: 520.96, rh: 540.4, rrx: 33.69, tx: -76.61, ty: 415.18, angleDeg: -30);
  }

  void _drawRect(Canvas canvas, Paint paint, {
    required double rx, required double ry, required double rw, required double rh,
    required double rrx, required double tx, required double ty, required double angleDeg,
  }) {
    canvas.save();
    canvas.translate(tx * scale, ty * scale);
    canvas.rotate(angleDeg * math.pi / 180.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rx * scale, ry * scale, rw * scale, rh * scale), Radius.circular(rrx * scale)),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.scale != scale;
}