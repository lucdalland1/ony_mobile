import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/justificatifcontroller.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Color/app_color_model.dart';
import '../../Controller/formcontroller.dart';
import '../../Controller/identitecartecontroller.dart';
import '../../Widget/container.dart';
import '../../Widget/icon.dart';

class Niveau3 extends StatefulWidget {
  const Niveau3({super.key});

  @override
  State<Niveau3> createState() => _Niveau3State();
}

class _Niveau3State extends State<Niveau3> {
  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
final FormController formController =
      Get.put(FormController()); // Initialiser le contrôleur


  final JustificatifController controller = Get.put(JustificatifController());
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
                          height: screenHeight * 0.06,
                          width: screenWidth * 0.2,
                        ),
                        Text(
                          "Emettre son justificatif de domicile",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColorModel.BlueColor,
                            fontSize: screenHeight * 0.019,
                          ),
                        ),
                         
                        Spacer(),
                        NotificationWidget(),
                      ],
                    ),
                  ),
                  Gap(10),
                    ContainerWidget(
                    height: 800,
                    width: screenWidth * 0.9,
                    color: AppColorModel.WhiteColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              "Emettre un justificatif Onyfast",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Gap(5),
                            Gap(5),
                            Text(
                                "Ne manquez pas votre chance de transformer"),
                                Text("vos paiements quotidiens en expérience fluides"),
                                Text("et sans accroc. Emettre votre carte virtuelle en"),
                                 Text("un clic."),
                                 Gap(03),
                                Text("Remplissez le formulaire ci-dessous 👇"),
                            Gap(10),
                            Text("Sélectionnez une pièce justificative."),
                            Gap(10),
                             const Text(
                  'Type de pièce d\'identité',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 24),
          
                // Upload du fichier PDF
                 Text(
                  "Fichier PDF ou Image de la pièce d'identité",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  "(facture d'eau, Courant EEC etc.)",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                 Text("👇",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Obx(() => OutlinedButton(
                      onPressed: controller.pickIdFile,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const CupertinoActivityIndicator()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                
                                const SizedBox(width: 8),
                                Text(
                                  controller.idFile.value == null
                                      ? 'Sélectionner un fichier PDF'
                                      : controller.idFile.value!.name,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                    )),
                if (controller.idFile.value != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Fichier sélectionné: ${controller.idFile.value!.name}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                                           
                ],
            
                const SizedBox(height: 24),
          
                // Bouton de soumission
                Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.submitForm,
                    child: controller.isLoading.value
                          ? const CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                          :  Text("Emettre son justificatif",
                                    style:
                                        TextStyle(color: AppColorModel.WhiteColor)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColorModel.BlueColor,
                                  minimumSize:
                                      Size(screenWidth * 0.9, screenHeight * 0.06),
                                ),
                    )),      
                          ],
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