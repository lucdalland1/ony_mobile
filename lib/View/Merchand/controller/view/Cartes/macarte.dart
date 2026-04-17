import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../../../../Color/app_color_model.dart';
import '../../../../../Widget/container.dart';
import '../../../../../Widget/icon.dart';

class MaCarte extends StatefulWidget {
  const MaCarte({super.key});

  @override
  State<MaCarte> createState() => _MaCarteState();
}

class _MaCarteState extends State<MaCarte> {
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
                        Image.asset(
                          "asset/onylogo.png",
                          height: screenHeight * 0.06,
                          width: screenHeight * 0.08,
                        ),
                        Gap(screenWidth * 0.03),
                        Text(
                          'Commander ma carte'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColorModel.BlueColor,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                        Spacer(),
                        NotificationWidget()
                      ],
                    ),
                  ),
        ],
      ),
    );
  }
}