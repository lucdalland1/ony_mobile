import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/identitecartecontroller.dart';
import 'package:onyfast/View/Gerer_cartes/cartevirtuelle.dart';
import 'package:onyfast/View/Notification/notification.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Color/app_color_model.dart';
import '../../Controller/formcontroller.dart';
import '../../Widget/container.dart';

class CarteVirtuelle2 extends StatefulWidget {
  const CarteVirtuelle2({super.key});

  @override
  State<CarteVirtuelle2> createState() => _CarteVirtuelle2State();
}

class _CarteVirtuelle2State extends State<CarteVirtuelle2> {
  @override
  Widget build(BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final _formKey = GlobalKey<FormState>();
    final FormController formController =
      Get.put(FormController()); // Initialiser le contrôleur


  final IdentityFormController controller = Get.put(IdentityFormController());

    return Scaffold(
            appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        title: Text(
          "Gérer mes cartes Visa",
          style: TextStyle(
              fontSize: 17.dp,
              fontWeight: FontWeight.bold,
              color: AppColorModel.WhiteColor),
        ),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        actions: [
       NotificationWidget()
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
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
                    decoration: InputDecoration(
                      labelText: "N° de la pièce",
                      hintText: "123456789",
                      labelStyle:
                          TextStyle(color: AppColorModel.Bluecolor242),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        formController.name.value = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Veuillez entrer un numéro' : null,
                  ),
                    SizedBox(height: 75.dp),
          
                      // Bouton de soumission

          Obx(()=>InkWell(
                      onTap: controller.isLoading.value ? null : controller.submitForm,
          child: controller.isLoading.value
                ? const CupertinoActivityIndicator(
                    color: Colors.white,
                  )
                :
                      ContainerWidget(
                        height: 05.50.h,
                        width: 120.w,
                        
                        color: AppColorModel.Bluecolor242,
                        borderRadius: BorderRadius.circular(10),
                        child: Center(child: Text("Emettre ma carte", style: TextStyle(fontSize: 17.dp,color: AppColorModel.WhiteColor,fontWeight: FontWeight.bold),),),
                      ),
                    ),),
                          Gap(10.dp),
                          InkWell(
                            onTap: () {
                              Get.to(CarteVirtuelle());
                            },
                            child: ContainerWidget(
                                                    height: 05.50.h,
                                                    width: 120.w,
                                                    
                                                    color:Colors.green,
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: Center(child: Text("Arrière", style: TextStyle(fontSize: 17.dp,color: AppColorModel.WhiteColor,fontWeight: FontWeight.bold),),),
                                                  ),
                          ),    
                    // bool isFormValid = formController.validate();

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}