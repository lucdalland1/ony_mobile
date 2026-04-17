import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import '../Color/app_color_model.dart';

class ContainerListeView2 extends StatelessWidget {
  final String image;
  final String text1;
  final String text2;
  final String solde;
  final Color? color;

  const ContainerListeView2({
    super.key,
    required this.image,
    required this.solde,
    required this.text1,
    required this.text2,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 10.h,
      width: 100.w, 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.dp),
        color: color,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.dp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 06.h,
                width: 11.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.dp),
                  color: AppColorModel.Grey,
                ),
                child: Center(
                  child: Image.asset(
                    image, 
                    height: 10.h, 
                    width: 08.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
             Gap(12.dp),
              
              // Colonne de textes
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text1, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.dp,
                    ),
                  ),
                  Gap(4.dp),
                  Text(
                    text2,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Colors.grey[600],
                      fontSize: 11.dp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Montant à droite
          Text(
            solde,
            style: TextStyle(
              fontSize: 13.dp, 
              color: AppColorModel.BlueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}