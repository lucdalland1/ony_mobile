import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Color/app_color_model.dart';
import '../../Controller/formcontroller.dart';
import '../../Controller/identitecartecontroller.dart';
import '../../Widget/container.dart';
import '../../Widget/icon.dart';

class Niveau2 extends StatefulWidget {
  const Niveau2({super.key});

  @override
  State<Niveau2> createState() => _Niveau2State();
}

class _Niveau2State extends State<Niveau2> {
  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
final FormController formController =
      Get.put(FormController()); // Initialiser le contrôleur

      TextEditingController numerocontroller=TextEditingController();
       numerocontroller.addListener(() {
      formController.updateFirstName(numerocontroller.text);
    });


  final IdentityFormController controller = Get.put(IdentityFormController());
    return Scaffold(
      body: Obx(()=>SingleChildScrollView(
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
                        "Emettre sa pièce d'identité",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColorModel.BlueColor,
                          fontSize: screenHeight * 0.022,
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
                            "Emettre une carte Onyfast",
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
        
              // Sélection du type de pièce d'identité
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedIdType.value.isEmpty 
                        ? null 
                        : controller.selectedIdType.value,
                    items: controller.idTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) => controller.selectIdType(value!),
                    decoration: const InputDecoration(
                      hintText: 'Sélectionnez un type',
                    ),
                    validator: (value) =>
                        value == null ? 'Ce champ est obligatoire' : null,
                  )),
              const SizedBox(height: 24),
        
              // Upload du fichier PDF
              const Text(
                'Fichier PDF de la pièce d\'identité recto-verso',
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
              TextFormField(
                controller: numerocontroller,
                            decoration: InputDecoration(
                              labelText: "N° de la pièce",
                              hintText: "123456789",
                              labelStyle:
                                  TextStyle(color: AppColorModel.BlueColor),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) =>
                                formController.name.value = value,
                            validator: (value) =>
                                value!.isEmpty ? 'Veuillez entrer un numéro' : null,
                          ),
              const SizedBox(height: 24),
        
              // Bouton de soumission
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.submitForm,
                  child: controller.isLoading.value
                        ? const CupertinoActivityIndicator(
                            color: Colors.white,
                          )
                        :  Text("Emettre ma carte",
                                  style:
                                      TextStyle(color: AppColorModel.WhiteColor)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColorModel.BlueColor,
                                minimumSize:
                                    Size(screenWidth * 0.9, screenHeight * 0.06),
                              ),
                  )),
        
                            // // bool isFormValid = formController.validate();
                            //   ElevatedButton(
                            //   onPressed:
                            //   //  isFormValid
                            //   //    ?
                            //       () {
                            //           // Logique pour traiter les données
                            //         },
                            //       // : null, // Désactiver le bouton si le formulaire n'est pas valide
                            //   child: Text("Arrière",
                            //       style:
                            //           TextStyle(color: AppColorModel.WhiteColor)),
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: AppColorModel.Green,
                            //     minimumSize:
                            //         Size(screenWidth * 0.9, screenHeight * 0.06),
                            //   ),
                            // ) ,
                           
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),)
    );
  }
}