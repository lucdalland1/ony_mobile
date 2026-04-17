import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/View/C2C/c2c.dart';
import 'package:onyfast/Widget/container.dart';
import '../Color/app_color_model.dart';

class ComposantAccueilButton extends StatelessWidget {
  const ComposantAccueilButton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // final AuthController authController = Get.find();
    // final AuthController connexionController = Get.find();
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05), // Padding sur les côtés
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Espacement entre les boutons
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                // Action à réaliser
              },
              child: ContainerWidget(
                height: 50,
                borderRadius: BorderRadius.circular(10),
                color: AppColorModel.blackColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "asset/retrait.svg",
                      height: 46,
                      width: 20,
                      color: AppColorModel.WhiteColor,
                    ),
                    const Gap(10), // Espace constant
                    Text(
                      "Retrait",
                      style: TextStyle(
                        color: AppColorModel.WhiteColor,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(10), // Espace entre les boutons
          Expanded(
            child: InkWell(
              onTap: () {
                // Action à réaliser
              },
              child: InkWell(
                onTap: () => Get.to(SendMoneyPage()),
                child: ContainerWidget(
                  height: 50,
                  borderRadius: BorderRadius.circular(10),
                  color: AppColorModel.blackColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        "asset/recevoir.svg",
                        height: 40,
                        width: 20,
                        color: AppColorModel.WhiteColor,
                      ),
                      const Gap(10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "C2C",
                            style: TextStyle(
                              color: AppColorModel.WhiteColor,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            "( Client to client )",
                            style: TextStyle(
                              color: AppColorModel.WhiteColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
