import 'package:flutter/material.dart';

import '../Color/app_color_model.dart';
import 'container.dart';

class ItemWidget extends StatelessWidget {
  final int index;

  const ItemWidget({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Récupérer la taille de l'écran
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(
        left: 05,
        right: 05,
        top: 1,
        bottom: 0,
      ),
      child: Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: ContainerWidget(
                height: 65,
                color: AppColorModel.BlueWhiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(1),
                  bottomRight: Radius.circular(1),
                  bottomLeft: Radius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Text("le 12/11/2024"),
                    Text("à 04:24:08"),
                  ],
                ),
              ),
            ),
            ContainerWidget(
              height: 65,
              width: screenWidth * 0.4,
              color: AppColorModel.BlueColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(1),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
                bottomLeft: Radius.circular(1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: screenWidth * 0.03),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 12),
                          Text(
                            "Funds Transfer External",
                            style: TextStyle(
                              fontSize: 09,
                              color: AppColorModel.WhiteColor,
                            ),
                          ),
                          Text(
                            "Account to Cards",
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColorModel.WhiteColor,
                            ),
                          ),
                        ],
                      ),  
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 1,
                          right: 0,
                          top: 10,
                          bottom: 0,
                        ),
                        child: Icon(
                          Icons.arrow_downward_sharp,
                          color: AppColorModel.WhiteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}