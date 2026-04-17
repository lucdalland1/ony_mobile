import 'package:flutter/material.dart';

class ContainerField extends StatelessWidget {
  final double? width;
  final double? height;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final InputDecoration? decoration;

  const ContainerField({
    super.key,
    this.width,
    this.height,
    this.keyboardType,
    this.controller,
    this.decoration = const InputDecoration(),
  });

  @override
  Widget build(BuildContext context) {
    // Obtenir les dimensions de l'écran
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Calculer la largeur et la hauteur réactives
    final double responsiveWidth = width ?? screenWidth * 0.8; // Par défaut 80 % de la largeur de l'écran
    final double responsiveHeight = height ?? screenHeight * 0.07; // Par défaut 7 % de la hauteur de l'écran

    return Container(
      width: responsiveWidth,
      height: responsiveHeight,
      child: TextField(
        controller: controller,
        decoration: decoration,
        keyboardType: keyboardType,
      ),
    );
  }
}