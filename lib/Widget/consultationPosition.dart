import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:onyfast/View/Merchand/controller/view/Cartes/cartephysique.dart';
import 'package:onyfast/View/Merchand/controller/view/Cartes/cartevirtuelle.dart';
import 'package:onyfast/View/Merchand/controller/view/Cartes/macarte.dart';

import '../Color/app_color_model.dart';
import 'cartevalidator.dart';
import 'container.dart';

class ConsultationPosition extends StatelessWidget {
  const ConsultationPosition({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      top: screenHeight * 0.25, 
      left: screenWidth * 0.01,
      child: ContainerWidget(
        height: screenHeight * 0.5, 
        width: screenWidth * 0.95, 
        borderRadius: BorderRadius.circular(20),
        color: AppColorModel.GreyWhite,
        child: Column(
          children: [
            Gap(screenHeight * 0.045), 
            Text(
              "Consultation du relevé",
              style: TextStyle(
                color: AppColorModel.BlueColor,
                fontSize: screenWidth * 0.075,
              ),
            ),
            Gap(screenHeight * 0.03), 
            Row(
              children: [
                Gap(screenWidth * 0.1), 
                CarteValidator(
                  text: "Physique",
                  onTap: () {},
                  width: screenWidth * 0.35,
                ),
                Gap(screenWidth * 0.1), 
                CarteValidator(
                  text: "Virtuelle",
                  onTap: () {},
                  width: screenWidth * 0.35, 
                ),
              ],
            ),
            Gap(screenHeight * 0.05), 
            InkWell(
              onTap: (){
              
                Navigator.push(context, MaterialPageRoute(builder: (context) => CartePhysique()));
              },
              child: Container(
                height: screenHeight * 0.075, 
                width: screenWidth * 0.87, 
                decoration: BoxDecoration(
                  color: AppColorModel.WhiteColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Gap(screenHeight * 0.0125), 
                    CarteValidator(
                      text: "Ajouter une carte physique",
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => CartePhysique()));
                      },
                      width: screenWidth * 0.77, 
                    ),
                  ],
                ),
              ),
            ),
             Gap(screenHeight * 0.01), 
            InkWell(
              onTap: (){
           Navigator.push(context, MaterialPageRoute(builder: (context) => CarteVirtuelle()));
              },
              child: Container(
                height: screenHeight * 0.075, 
                width: screenWidth * 0.87, 
                decoration: BoxDecoration(
                  color: AppColorModel.WhiteColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Gap(screenHeight * 0.0125), 
                    CarteValidator(
                      text: "Emettre la carte virtuelle",
                      onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => CarteVirtuelle()));
                      },
                      width: screenWidth * 0.77, 
                    ),
                  ],
                ),
              ),
            ),
              Gap(screenHeight * 0.01), 
            InkWell(
              onTap: (){
             Navigator.push(context, MaterialPageRoute(builder: (context) => MaCarte()));
              },
              child: Container(
                height: screenHeight * 0.075, 
                width: screenWidth * 0.87, 
                decoration: BoxDecoration(
                  color: AppColorModel.WhiteColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Gap(screenHeight * 0.0125), 
                    CarteValidator(
                      text: "Commander ma carte",
                      onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MaCarte()));
                      },
                      width: screenWidth * 0.77, 
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
