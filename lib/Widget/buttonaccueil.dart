import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import '../Color/app_color_model.dart';
import 'container.dart';

class ButtonAccueil extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final String image;

  const ButtonAccueil({
    Key? key,
    required this.onTap,
    required this.image,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width
   // final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      child: ContainerWidget(
        height: 09.h,
        width: 43.w, // 40% of the screen width
        color: AppColorModel.WhiteColor,
          borderRadius: BorderRadius.circular(5.dp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Gap(02.dp),
            Image.asset(
              image,
              height: 04.h,
              width: 08.w,
            ),
            Gap(01.dp),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.dp,
                color: AppColorModel.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}