import 'package:flutter/material.dart';

class ContainerWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? color;
  final Widget? child;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? margin;

  const ContainerWidget({
    this.height,
    this.width,
    this.color,
    this.child,
    this.border,
    this.boxShadow,
    this.borderRadius,
    this.margin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Obtenir les dimensions de l'écran
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Calculer la hauteur et la largeur réactives
    final double responsiveHeight = height ?? screenHeight * 0.1; // Par défaut 10 % de la hauteur de l'écran
    final double responsiveWidth = width ?? screenWidth * 0.8; // Par défaut 80 % de la largeur de l'écran

    return Container(
      margin: margin,
      height: responsiveHeight,
      width: responsiveWidth,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        border: border,
      ),
      child: child,
    );
  }
}