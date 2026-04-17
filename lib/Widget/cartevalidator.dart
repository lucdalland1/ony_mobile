import 'package:flutter/material.dart';

import '../Color/app_color_model.dart';



class CarteValidator extends StatelessWidget {
  final void Function()? onTap;
  final double? width;
  final String text;
  const CarteValidator({
    required this.width,
    required this.text,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColorModel.Grey,
          border: Border.all(
            color: AppColorModel.BlueSimple,
            width: 1,
          )
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                "asset/APPLICATION ONYFAST 2.png",
                fit: BoxFit.cover,
              ),
              Center(
                child: Text(text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
