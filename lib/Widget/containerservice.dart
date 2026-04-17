import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../Color/app_color_model.dart';
import 'container.dart';


class ContainerServices extends StatelessWidget {
  final String image;
  final String text;
  final void Function()? onTap;
  const ContainerServices({
    super.key,
    required this.onTap,
    required this.image,
    required this.text,
    required this.screenWidth,
  });

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return InkWell(
          onTap: onTap,
          child: ContainerWidget(
       height: 80,
       width: screenWidth * 0.4,
       borderRadius: BorderRadius.circular(05),
       color: AppColorModel.WhiteColor,
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
         
           Gap(10),
           Image.asset(image, height: 35,width: 35,),
           Gap(2),
           Text(text,
             style: TextStyle(
                 fontWeight: FontWeight.bold,
                 fontSize: 16,
                 color: AppColorModel.black),
           ),
         ],
       ),
     ),
        );
  }
}