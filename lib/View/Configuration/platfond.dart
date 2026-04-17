import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/View/Niveau_validation/niveau2.dart';
import 'package:onyfast/View/Niveau_validation/niveau3.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Widget/container.dart';
import 'package:onyfast/Widget/icon.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Controller/validationcontroller.dart';

class Platfond extends StatelessWidget {
  Platfond({super.key});

  final ValidationController validationController = Get.put(ValidationController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Obx(()=>Column(
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
                  width: screenWidth * 0.2,
                ),
                Text(
                  "Augmenter son plafond",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColorModel.BlueColor,
                    fontSize: screenHeight * 0.022,
                  ),
                ),
                const Spacer(),
               NotificationWidget(),
              ],
            ),
          ),
          const Gap(10),
          ContainerWidget(
            height: 200,
            width: 340,
            color: AppColorModel.BlueWhiteColor,
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              "asset/MAQUETTE APPLICATION ONYSAT-16.png",
              fit: BoxFit.cover,
            ),
          ),
          const Gap(10),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  "Augmenter son plafond pour bénéficier de ",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  "nouvelle fonctionnalité sur l'application.",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Gap(30),
                // Niveau 1 - Toujours actif
                ContainerWidget(
                  height: 40,
                  width: 400,
                  color: AppColorModel.BlueColor,
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Niveau 1",
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(10),
                      Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                
              Gap(10),
                // Niveau 2
                InkWell(
                  onTap: () {
                    Get.to(() => Niveau2())?.then((value) {
                      if (value != null && value == false) {
                        validationController.completeNiveau2(false);
                      }
                    });
                  },
                  child: ContainerWidget(
                    height: 40,
                    width: 400,
                    color: validationController.niveau1Complete.value 
                        ? AppColorModel.BlueColor
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Niveau 2",
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                            color: validationController.niveau1Complete.value 
                                ? Colors.white 
                                : Colors.black,
                          ),
                        ),
                        const Gap(10),
                        Container(
                          width: 20.0,
                          height: 20.0,
                          decoration: BoxDecoration(
                            color: validationController.niveau2Complete.value
                                ? Colors.green
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Gap(10),
                // Niveau 3 - Dépend du niveau 2
                InkWell(
                  onTap: validationController.niveau2Complete.value
                      ? () {
                          Get.to(() => Niveau3())?.then((value) {
                            if (value != null && value == false) {
                              validationController.completeNiveau3(false);
                            }
                          });
                        }
                      : null,
                  child: ContainerWidget(
                    height: 40,
                    width: 400,
                    color: validationController.niveau2Complete.value
                        ? AppColorModel.BlueColor
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Niveau 3",
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                            color: validationController.niveau2Complete.value
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const Gap(10),
                        Container(
                          width: 20.0,
                          height: 20.0,
                          decoration: BoxDecoration(
                            color: validationController.niveau3Complete.value
                                ? Colors.green
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ],
      ),)
    );
  }
}