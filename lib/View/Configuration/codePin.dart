import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/ModifiePassword.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Color/app_color_model.dart';
import '../../Widget/container.dart';
import '../../Widget/icon.dart';

class CodePin extends StatelessWidget {
  const CodePin({super.key});

  @override
  Widget build(BuildContext context) {


    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

  final PasswordController passwordController = Get.put(PasswordController());
    return Material(
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
                        Text("Modifiez votre mot de passe",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColorModel.BlueColor,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                        Spacer(),
                      NotificationWidget()
                      ],
                    ),
                  ),
                  Gap(20),
                  Form(
                    child: Padding(
                      padding: EdgeInsets.only(left: 30, right: 30, top: 95, bottom: 1),
                      child: Column(
                        children: [
                      Obx(() {
              return TextFormField(
                controller: passwordController.passwordController,
                decoration: InputDecoration(
                  labelText: "Mot de passe",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordController.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      passwordController.togglePasswordVisibility();
                    },
                  ),
                ),
                keyboardType: TextInputType.phone, // Pour le clavier numérique
                obscureText: !passwordController.isPasswordVisible.value, // Masquer ou afficher le texte
                maxLength: 4, // Limiter à 4 chiffres
              );
            }),
            Obx(() {
              return TextFormField(
                controller: passwordController.newpasswordController,
                decoration: InputDecoration(
                  labelText: "Le même mot de passe se répète automatique",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordController.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      passwordController.togglePasswordVisibility();
                    },
                  ),
                ),
                keyboardType: TextInputType.phone, // Pour le clavier numérique
                obscureText: !passwordController.isPasswordVisible.value, // Masquer ou afficher le texte
                maxLength: 4, // Limiter à 4 chiffres
              );
            }),
            Gap(50),
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
                    ),
                  )
        ],
      ),
    );
  }
}
