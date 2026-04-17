import 'package:flutter/material.dart';

import '../Color/app_color_model.dart';
import '../Controller/languescontroller.dart';
import 'container.dart';



class ContainerOPeration extends StatelessWidget {


  final double screenHeight;
  final double screenWidth;
  final AppController appState;
  final void Function()? onTap;
  final String text;
  final double? height;
  final double? width;
  const ContainerOPeration({
    super.key,
    required this.height,
    required this.width,
    required this.onTap,
    required this.screenHeight,
    required this.screenWidth,
    required this.appState,
    required this.text,
  });


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:onTap,
      child: ContainerWidget(
        height:height,
        width: width,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: AppColorModel.GreyBlack,
          width: 1,
        ),
        color: AppColorModel.WhiteColor,
        child: Center(
          child: Text(text,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: AppColorModel.GreyBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
