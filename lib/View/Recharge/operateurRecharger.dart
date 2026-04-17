import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Color/app_color_model.dart';
import '../../Widget/container.dart';
import '../../Widget/icon.dart';

class OperateurRecharge extends StatefulWidget {
  const OperateurRecharge({super.key});

  @override
  State<OperateurRecharge> createState() => _OperateurRechargeState();
}

class _OperateurRechargeState extends State<OperateurRecharge> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Material(
      child: Column(
        children: [
          ContainerWidget(
            height: screenHeight * 0.08,
            width: screenWidth,
            color: AppColorModel.BlueColor,
          ),
          ContainerWidget(
            height: screenHeight * 0.1,
            width: screenWidth,
            color: AppColorModel.WhiteColor,
            child: Row(
              children: [
                Gap(10),
                Image.asset(
                  "asset/onylogo.png",
                  height: screenHeight * 0.05,
                  width: screenWidth * 0.1,
                ),
                Gap(5),
                Text(
                  'Choisissez votre opérateur'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColorModel.BlueColor,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
                Spacer(),
               NotificationWidget(),
              ],
            ),
          ),
          ContainerWidget(
            height: 200,
            width: 340,
            color: AppColorModel.Blue,
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              "asset/3.jpeg",
              fit: BoxFit.cover,
            ),
          ),
          Gap(20),
          ContainerWidget(
            height: 40,
            width: 350,
            
            color: AppColorModel.DeepPurple,
           borderRadius: BorderRadius.circular(10),
            
            child: Center(
              child: Text(
                "Airtel Money",
                style: TextStyle(
                    color: AppColorModel.WhiteColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Gap(12),
          ContainerWidget(
            height: 40,
            width: 350,
            
            color: AppColorModel.DeepPurple,
           borderRadius: BorderRadius.circular(10),
            
            child: Center(
              child: Text(
                "MTN Money",
                style: TextStyle(
                    color: AppColorModel.WhiteColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
