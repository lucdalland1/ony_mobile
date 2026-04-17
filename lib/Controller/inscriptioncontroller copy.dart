import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';

class InscriptionController extends GetxController {
  var nomController = TextEditingController();
  var prenomController = TextEditingController();
  var emailController = TextEditingController();
  var adresseController = TextEditingController();

  var nomError = ''.obs;
  var prenomError = ''.obs;
  var emailError = ''.obs;
  var isLoading = false.obs;
  var adresseError = ''.obs;


  void choixCameraPhto() async {
      Get.back();

    print('Bonjour');
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 15,
              width: 100,
              decoration: BoxDecoration(
                color: AppColorModel.Bluecolor242,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: (){},
                      child: Container(
                        child: Icon(Icons.camera_alt, color: AppColorModel.WhiteColor),
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: AppColorModel.Bluecolor242,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Text(
                      'Prendre une photo',
                      style: TextStyle(color: AppColorModel.Bluecolor242),
                    ),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      onTap:  (){},
                      child: Container(
                        child: Icon(Icons.image, color: AppColorModel.WhiteColor),
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: AppColorModel.Bluecolor242,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Text(
                      'Galerie',
                      style: TextStyle(color: AppColorModel.Bluecolor242),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool validateInfoSup() {

    bool isValid = true;

    if (nomController.text.isEmpty) {
      nomError.value = "Le nom est requis";
      isValid = false;
    } else {
      nomError.value = '';
    }

    if (prenomController.text.isEmpty) {
      prenomError.value = "Le prénom est requis";
      isValid = false;
    } else {
      prenomError.value = '';
    }

    if (emailController.text.isEmpty ||
        !GetUtils.isEmail(emailController.text)) {
      emailError.value = "Email invalide";
      isValid = false;
    } else {
      emailError.value = '';
    }

    return isValid;
  }

  clearChamp()
  {
    nomController.clear();
    prenomController.clear();
    emailController.clear();
    nomError.value = '';
    prenomError.value = '';
    emailError.value = '';
  }
}
