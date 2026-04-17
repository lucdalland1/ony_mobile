import 'package:flutter/material.dart';
import '../../model/merchand.dart';

class MerchantIcon extends StatelessWidget {
  final MerchantType type;
  final double size;

  const MerchantIcon({
    super.key,
    required this.type,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: type.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        type.icon,
        color: type.color,
        size: size * 0.6,
      ),
    );
  }
}