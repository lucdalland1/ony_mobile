import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../Color/app_color_model.dart';
import '../Controller/languescontroller.dart';
import '../Controller/themecontroller.dart';
import '../Controller/togglecontroller.dart';
import '../Widget/container.dart';
import '../Widget/icon.dart';

class Deconnecter extends StatelessWidget {
  const Deconnecter({super.key});

  void _showDialog(BuildContext context) {
    final AppController appState = Get.find<AppController>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Obx(() {
            return Text(appState.language.value == AppLanguage.french
                ? 'Paramètre de configuration'
                : appState.language.value == AppLanguage.english
                    ? 'Configuration settings'
                    : 'Configuración de parámetros');
          }),
          actions: [
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, "/deconnecter"),
                  child: Obx(() {
                    return Text(appState.language.value == AppLanguage.french
                        ? 'Deconnecter'
                        : appState.language.value == AppLanguage.english
                            ? 'Disconnect'
                            : 'Desconectar');
                  }),
                ),
                TextButton(
                  child: Obx(() {
                    return Text(appState.language.value == AppLanguage.french
                        ? 'Fermer'
                        : appState.language.value == AppLanguage.english
                            ? 'Close'
                            : 'Cerrar');
                  }),
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
    final AppController appState = Get.find<AppController>();
    final ToggleController toggleController = Get.put(ToggleController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ContainerWidget(
              height: 60,
              width: 500,
              color: AppColorModel.WhiteColor,
            ),
            ContainerWidget(
              height: 70,
              width: 500,
              color: AppColorModel.WhiteColor,
              child: Row(
                children: [
                  Image.asset("asset/onylogo.png", height: 75, width: 97),
                  Obx(() {
                    return Text(
                      appState.language.value == AppLanguage.french
                          ? 'Parametre'
                          : appState.language.value == AppLanguage.english
                              ? 'Setting'
                              : 'Configuración',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:AppColorModel.blackColor,
                        fontSize: 20,
                      ),
                    );
                  }),
                  const Gap(90),
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
              height: 200,
              width: 500,
              color:AppColorModel.WhiteColor,
              child: Column(
                children: [
                  const Gap(25),
                  ContainerWidget(
                    height: 150,
                    width: 400,
                    borderRadius: BorderRadius.circular(20),
                    color: AppColorModel.WhiteColor,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10, right: 190, top: 10),
                      child: Column(
                        children: [
                          Text(
                            "Bloquer ma carte",
                            style: TextStyle(
                              color: AppColorModel.blackColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const Gap(10),
                          Obx(() {
                            return GestureDetector(
                              onTap: () {
                                toggleController.toggle();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 120,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: toggleController.isActive.value
                                      ? AppColorModel.BlueColor
                                      : Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: toggleController.isActive.value
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: toggleController.isActive.value
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 900),
                                      width: 50,
                                      height: 120,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            );
                          }),
                          Obx(() {
                            return Text(
                              toggleController.isActive.value
                                  ? 'Inactif'
                                  : 'Activé',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              key: ValueKey<bool>(toggleController.isActive.value),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(35),
            ContainerWidget(
              height: 90,
              width: 450,
              border: Border.all(
                color: AppColorModel.BlueWhiteColor,
                width: 1,
              ),
              color: AppColorModel.WhiteColor,
              child: Row(
                children: [
                  const Gap(10),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Gap(20),
                        Text(
                          "Conditions d’utilisation (PDF à lire)",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColorModel.Grey,
                          ),
                        ),
                        const Gap(10),
                        Icon(Icons.arrow_downward_outlined, color: AppColorModel.Grey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ContainerWidget(
              height: 90,
              width: 450,
              border: Border.all(
                color: AppColorModel.BlueWhiteColor,
                width: 1,
              ),
              color: AppColorModel.WhiteColor,
              child: Row(
                children: [
                  const Gap(55),
                  ContainerWidget(
                    height: 50,
                    width: 300,
                    borderRadius: BorderRadius.circular(10),
                    color: AppColorModel.WhiteColor,
                    child: InkWell(
                      onTap: () {},
                      child: Center(
                        child: Text(
                          "Se déconnecter",
                          style: TextStyle(
                            fontSize: 20,
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
            ContainerWidget(
              height: 90,
              width: 450,
              border: Border.all(
                color: AppColorModel.BlueWhiteColor,
                width: 1,
              ),
              color: AppColorModel.WhiteColor,
              child: Row(
                children: [
                  const Gap(10),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Gap(20),
                        Text(
                          "À propos (version de l’application)",
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColorModel.Grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(10),
                        Icon(Icons.arrow_downward_outlined, color: AppColorModel.Grey),
                      ],
                    ),
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