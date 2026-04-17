import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:onyfast/Widget/textfield.dart';

import '../../Color/app_color_model.dart';
import '../../Controller/datecontrollerProfil.dart';
import '../../Widget/container.dart';
import '../../Widget/icon.dart';
import '../../Controller/languescontroller.dart';

class CongoTelecom extends StatelessWidget {
  const CongoTelecom({super.key});

  void _showDialog(BuildContext context) {
    final AppController appState = Get.put(AppController());
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
                              : 'Pago de factura',
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
    final AppController appState = Get.put(AppController());
    final DateController dateController = Get.put(DateController());

    TextEditingController IdCarteController = TextEditingController();
    TextEditingController ChiffreCarteController = TextEditingController();
    TextEditingController MontantController = TextEditingController();


    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
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
                    height: screenHeight * 0.08, 
                    width: screenWidth * 0.2,
                  ),
                  Text(
                    appState.language == AppLanguage.french
                        ? 'Paiement de facture'
                        : appState.language == AppLanguage.english
                            ? 'Invoice Payment'
                            : 'Pago de factura',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColorModel.BlueColor,
                      fontSize: screenHeight * 0.025,
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
                      size: 42,
                    ),
                  ),
                ],
              ),
            ),
            ContainerWidget(
              height: screenHeight * 0.3,
              margin: EdgeInsets.symmetric(horizontal: 10),
              width: screenWidth * 0.9,
              borderRadius: BorderRadius.circular(10),
              color: AppColorModel.WhiteColor,
              child: Image.asset(
                "asset/MAQUETTE APPLICATION ONYSAT-17.png",
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: 1, left: screenWidth * 0.3, bottom: 10, right: 10),
              child: Text(
                "Congo Telecom",
                style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                    color: AppColorModel.BlueColor),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 10),
              child: Column(
                children: [
                  TextfielWidget(
                    keyboardType: TextInputType.number,
                    controller: IdCarteController,
                    labelText: appState.language == AppLanguage.french
                        ? 'L’identifiant de la carte'
                        : appState.language == AppLanguage.english
                            ? 'Card ID'
                            : 'Identificación de la tarjeta',
                    border: null,
                  ),
                  TextfielWidget(
                    keyboardType: TextInputType.number,
                    controller: ChiffreCarteController,
                    labelText: appState.language == AppLanguage.french
                        ? 'Les 4 derniers chiffres de la carte'
                        : appState.language == AppLanguage.english
                            ? 'The last 4 digits of the card'
                            : 'Los últimos 4 dígitos de la tarjeta',
                    border: null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
              controller: dateController.dateController,
              decoration: InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
                hintText: 'Sélectionnez une date',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => dateController.selectDate(context),
                ),
              ),
              readOnly: true, // Empêche la saisie manuelle
              validator: (value) {
                return dateController.validateDate();
              },
            ),
                  ),
                  TextfielWidget(
                    keyboardType: TextInputType.number,
                    controller: MontantController,
                    labelText: appState.language == AppLanguage.french
                        ? 'Montant XAF'
                        : appState.language == AppLanguage.english
                            ? 'Amount in XAF'
                            : 'Cantidad en XAF',
                    border: null,
                  ),
                  Gap(screenHeight * 0.03),
                  ContainerWidget(
                    margin: null,
                    height: screenHeight * 0.07,
                    width: screenWidth * 0.8,
                    color: AppColorModel.BlueColor,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () {
                      },
                      child: Center(
                        child: Text(
                          appState.language == AppLanguage.french
                              ? 'Soumettre'
                              : appState.language == AppLanguage.english
                                  ? 'Submit'
                                  : 'Enviar',
                          style: TextStyle(
                              color: AppColorModel.WhiteColor,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}