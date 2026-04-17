import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../Color/app_color_model.dart';

class ContainerListeView extends StatelessWidget {
  final String image;
  final String text1;
  final String text2;
  final String solde;
  final Color? color;
  
  const ContainerListeView({
    super.key,
    required this.image,
    required this.solde,
    required this.text1,
    required this.text2,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      height: 80,
      width: screenWidth * 0.9, // 90% de la largeur de l'écran
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        color: color,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Partie gauche : Icône + Textes
          Row(
            children: [
              // Conteneur de l'icône
              Container(
                height: 40,
                width: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColorModel.Grey,
                ),
                child: Center(
                  child: Image.asset(
                    image, 
                    height: 30, 
                    width: 30,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Gap(12),
              
              // Colonne de textes
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text1, 
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    text2,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Colors.grey[600],
                      fontSize: 12,
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
              fontSize: 14, 
              color: AppColorModel.BlueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}