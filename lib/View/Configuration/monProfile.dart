import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/datecontrollerProfil.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Color/app_color_model.dart';
import '../../Controller/genrecontroller.dart';
import '../../Widget/container.dart';
import '../../Widget/icon.dart';

class Monprofile extends StatelessWidget {
  const Monprofile({super.key});

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    

  final DateController dateController = Get.put(DateController());

  // Instancier le contrôleur
  final SexController sexController = Get.put(SexController());
  // Liste des options de sexe
  final List<String> sexOptions = ['Masculin', 'Féminin'];


    return Material(
      child: SingleChildScrollView(
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
                          "asset/favicon.png",
                          height: screenHeight * 0.08,
                          width: screenHeight * 0.08,
                        ),
                        Text(
                              'Modifier Mon Profil',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColorModel.BlueColor,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                        Spacer(),
                        NotificationWidget(),
                      ],
                    ),
                  ),
                  Gap(10),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: null,
                          decoration: InputDecoration(
                            labelText: "4 derniers chiffres de la carte",
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        TextFormField(
                          controller: null,
                          decoration: InputDecoration(
                            labelText: "Date d'expiration de la carte",
                          ),
                          keyboardType: TextInputType.datetime,
                        ),
                        TextFormField(
                          controller: null,
                          decoration: InputDecoration(
                            labelText: "Nom(s)",
                          ),
                          keyboardType: TextInputType.name,
                        ),
                        TextFormField(
                          controller: null,
                          decoration: InputDecoration(
                            labelText: "Prénom(s)",
                          ),
                          keyboardType: TextInputType.name,
                        ),
                        TextFormField(
                          controller: null,
                          decoration: InputDecoration(
                            labelText: "Email",
                          
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        TextFormField(
              controller: dateController.dateController,
              decoration: InputDecoration(
                hintText: 'Sélectionnez une date',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today, color: AppColorModel.BlueColor,),
                  onPressed: () => dateController.selectDate(context),
                ),
              ),
              readOnly: true, // Empêche la saisie manuelle
              validator: (value) {
                return dateController.validateDate();
              },
            ),
                         DropdownButtonFormField<String>(
              value: sexController.sexController.text.isEmpty
                  ? null
                  : sexController.sexController.text,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  sexController.sexController.text = newValue;
                }
              },
              items: sexController.sexOptions
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                hintText: 'Genre',
              ),
              validator: (value) {
                return sexController.validateSex();
              },
            ),
                        TextFormField(
                          controller: null,
                          decoration: InputDecoration(
                            labelText: "Téléphone (mobile)" ,
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                         TextFormField(
                          controller: null,
                          decoration: InputDecoration(
                            labelText: "Téléphone (autre)" ,
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        TextFormField(
                          controller: null,
                          decoration: InputDecoration(
                            labelText: "Adresse",
                          ),
                          keyboardType: TextInputType.name,
                        ),
                        TextFormField(
                          controller: null,
                          decoration: InputDecoration(
                            labelText: "Ville de résidence",
                          ),
                          keyboardType: TextInputType.name,
                        ),
                        Gap(30),
            InkWell(
              onTap: (){},
              child: Container(
                height: 40,
                width: 500,
                decoration: BoxDecoration(
                  color:AppColorModel.BlueColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Valider",
                    style: TextStyle(color: AppColorModel.WhiteColor, fontSize: 23),
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