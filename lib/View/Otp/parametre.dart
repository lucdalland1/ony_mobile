import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/languescontroller.dart';
import 'package:onyfast/Widget/container.dart';
import 'package:onyfast/Widget/icon.dart';
import 'package:onyfast/Widget/notificationWidget.dart';



class Parametre extends StatelessWidget {
  const Parametre({super.key});

  String _getLocalizedText(String french, String english, String spanish) {
    final appState = Get.find<AppController>();
    switch (appState.language.value) {
      case AppLanguage.french:
        return french;
      case AppLanguage.english:
        return english;
      default:
        return spanish;
    }
  }

  void _showDialog(BuildContext context) {
    final appState = Get.find<AppController>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Obx(() => Text(
            _getLocalizedText('Paramètre de configuration', 'Configuration settings', 'Configuración de parámetros'),
          )),
          actions: [
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, "/deconnecter"),
                  child: Obx(() => Text(
                    _getLocalizedText('Deconnecter', 'Disconnect', 'Desconectar'),
                  )),
                ),
                TextButton(
                  child: Obx(() => Text(
                    _getLocalizedText('Fermer', 'Close', 'Cerrar'),
                  )),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Get.find<AppController>();

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColorModel.secondaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ContainerWidget(
              height: screenHeight * 0.08,
              width: screenWidth,
              color: AppColorModel.WhiteColor,
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
                    height: 65,
                    width: 78,
                  ),
                  Obx(() => Text(
                    _getLocalizedText('Parametre', 'Setting', 'Configuración'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColorModel.BlueColor,
                      fontSize: screenWidth * 0.05,
                    ),
                  )),
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
            Image.asset(
              "asset/ann.jpg",
              height: screenHeight * 0.3,
              width: screenWidth,
              fit: BoxFit.cover,
            ),
            Gap(10),
            ContainerWidget(
              height: screenHeight * 0.25,
              border: Border.all(
                color: AppColorModel.blackColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(15),
              width: screenWidth * 0.9,
              color: AppColorModel.WhiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
              child: Column(
                children: [
                  Gap(30),
                InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, "/profil");
                  },
                  child: ContainerWidget(height: screenHeight*0.06,
                  borderRadius: BorderRadius.circular(10),
                  child: Center(child: Text("Profile", style: TextStyle(color: AppColorModel.WhiteColor, fontSize: 19, fontWeight: FontWeight.bold),)),
                  width: 300,
                  color: AppColorModel.blackColor,
                  ),
                ),
                  Gap(20),
                  _buildButton(
                    context,
                    screenWidth * 0.8,
                    _getLocalizedText('Associer mon compte bancaire', 'Link my bank account', 'Vincular mi cuenta bancaria'),
                    () => Navigator.pushNamed(context, "/associercompte"),
                    AppColorModel.blackColor
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, double width, String label, VoidCallback onPressed, Color color) {
    return ContainerWidget(
      height: 55,
      width: width,
      borderRadius: BorderRadius.circular(8),
      color: color,
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColorModel.WhiteColor,
            ),
          ),
        ),
      ),
    );
  }
}