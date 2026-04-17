import 'package:flutter/material.dart';
import '../Color/app_color_model.dart';
import '../View/View2/cercleCouleur.dart';
import 'container.dart';
import 'historyque.dart';

class TabHistorique extends StatelessWidget {
  const TabHistorique({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupérer la taille de l'écran
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: ContainerWidget(
        height: 390,
        width: screenWidth * 0.9, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColorModel.Grey,
          width: 0.75,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0, 3),
          ),
        ],
        color: AppColorModel.WhiteColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.05, 
                  right: 0,
                  top: 1,
                  bottom: 0,
                ),
                child: CircleWithFourColors(),
              ),
              Text(
                "Dernières transactions",
                style: TextStyle(
                  color: AppColorModel.BlueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 2,
                itemBuilder: (context, index) {
                  return ItemWidget(index: index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}