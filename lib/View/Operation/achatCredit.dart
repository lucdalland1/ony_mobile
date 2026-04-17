import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Color/app_color_model.dart';
import '../../Widget/container.dart';
import '../../Widget/icon.dart';
import '../../Controller/languescontroller.dart';

class AchatCredit extends StatelessWidget {
  const AchatCredit({super.key});

  void _showDialog(BuildContext context) {
    final AppController appState = Get.find<AppController>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              Gap(40),
              Text(
                appState.language == AppLanguage.french
                    ? "D'autres informations"
                    : appState.language == AppLanguage.english
                        ? 'Other information'
                        : 'Otra información',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/associercompte");
                    },
                    child: Text(
                      appState.language == AppLanguage.french
                          ? 'Associer à mon compte bancaire'
                          : appState.language == AppLanguage.english
                              ? 'Link to my bank account'
                              : 'Vincular a mi cuenta bancaria',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/parametre");
                    },
                    child: Text(
                      appState.language == AppLanguage.french
                          ? 'Paiement de facture'
                          : appState.language == AppLanguage.english
                              ? 'Bill Payment'
                              : 'Pago de facturas',
                    ),
                  ),
                  TextButton(
                    child: Text(
                      appState.language == AppLanguage.french
                          ? 'Fermer'
                          : appState.language == AppLanguage.english
                              ? 'Close'
                              : 'Cerrar',
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppController appState = Get.find<AppController>();

    // Obtenez les dimensions de l'écran
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ContainerWidget(
              height: screenHeight * 0.08,
              width: screenWidth,
              color: AppColorModel.BlueColor,
              child: null,
            ),
            ContainerWidget(
              height: screenHeight * 0.1,
              width: screenWidth,
              color: AppColorModel.WhiteColor,
              child: Row(
                children: [
                  Image.asset(
                    "asset/onylogo.png",
                    height: screenHeight * 0.08,
                    width: screenWidth * 0.15,
                  ),
                  Text(
                    appState.language == AppLanguage.french
                        ? 'Achat de crédit'
                        : appState.language == AppLanguage.english
                            ? 'Credit Purchase'
                            : 'Compra de crédito',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColorModel.BlueColor,
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                  Spacer(),
                 NotificationWidget(),
                  IconButtonWidget(
                    onPressed: () {
                      _showDialog(context);
                    },
                    icon: Icon(
                      Icons.menu,
                      color: AppColorModel.blackColor,
                      size: screenWidth * 0.08,
                    ),
                  ),
                ],
              ),
            ),
            ContainerWidget(
              height: screenHeight * 0.25,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              width: screenWidth * 0.9,
              borderRadius: BorderRadius.circular(10),
              color: AppColorModel.WhiteColor,
              child: Image.asset(
                "asset/MAQUETTE APPLICATION ONYSAT-18.png",
                fit: BoxFit.cover,
              ),
            ),
            Gap(screenHeight * 0.1),
            ContainerWidget(
              height: screenHeight * 0.06,
              width: screenWidth * 0.8,
              borderRadius: BorderRadius.circular(10),
              color: AppColorModel.BlueColor,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/mtn");
                },
                child: Center(
                  child: Text(
                    appState.language == AppLanguage.french
                        ? "Achat de crédit MTN"
                        : appState.language == AppLanguage.english
                            ? "MTN Credit Purchase"
                            : "Compra de crédito MTN",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      color: AppColorModel.WhiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Gap(screenHeight * 0.03),
            ContainerWidget(
              height: screenHeight * 0.06,
              width: screenWidth * 0.8,
              borderRadius: BorderRadius.circular(10),
              color: AppColorModel.BlueColor,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/airtel");
                },
                child: Center(
                  child: Text(
                    appState.language == AppLanguage.french
                        ? "Achat de crédit Airtel"
                        : appState.language == AppLanguage.english
                            ? "Airtel Credit Purchase"
                            : "Compra de crédito Airtel",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      color: AppColorModel.WhiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
