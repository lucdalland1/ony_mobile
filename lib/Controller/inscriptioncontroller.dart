import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:onyfast/Api/User_Formulaire_Api/user_formulaire.dart';
import 'package:onyfast/View/menuscreen.dart';
import 'package:onyfast/Widget/alerte.dart';

class InscriptionController extends GetxController {
  var phoneNumber = ''.obs;
  var pin = ''.obs;
  var confirmPassword = ''.obs;
  var isPasswordVisible = false.obs;
  var sexeController = 'M'.obs; // 'M', 'F', ou ''
  var dateNaissanceController = TextEditingController();


  var nomController = TextEditingController();
  var prenomController = TextEditingController();
  var emailController = TextEditingController();
  var adresseController = TextEditingController();
  var montantController = TextEditingController();
 var isLoading=false.obs;
  

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void choixCameraPhto() {
    Get.bottomSheet(
      SizedBox(
        height: 150,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Caméra'),
              onTap: () {
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galerie'),
              onTap: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  bool validateForm() {
    bool validateField(String value, String fieldName) {
      if (value.isEmpty) {
        SnackBarService.warning( '$fieldName est requis');
        return false;
      }
      if (fieldName == 'nom' || fieldName == 'prénom') {
        if (!RegExp(r'^[a-zA-Z\s-]+$').hasMatch(value)) {
          SnackBarService.warning(
              '$fieldName ne doit contenir que des lettres, espaces, - et _');
          return false;
        }
      }

    
      return true;
    }
    if (!validateField(nomController.text, 'nom')) return false;
    if (!validateField(prenomController.text, 'prénom')) return false;
  
     // 🔹 VALIDATION SEXE
if (sexeController.value.isEmpty) {
  SnackBarService.warning('Le sexe est requis');
  return false;
}

// 🔹 VALIDATION DATE DE NAISSANCE
final dateText = dateNaissanceController.text;

if (dateText.isEmpty) {
  SnackBarService.warning('La date de naissance est requise');
  return false;
}

// Vérifie format JJ/MM/AAAA
if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(dateText)) {
  SnackBarService.warning('Format JJ/MM/AAAA requis');
  return false;
}

try {
  final parts = dateText.split('/');
  final day = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  final year = int.parse(parts[2]);

  final birthDate = DateTime(year, month, day);
  final today = DateTime.now();

  int age = today.year - birthDate.year;

  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }

  if (age < 18) {
    SnackBarService.warning('Vous devez avoir au minimum 18 ans');
    return false;
  }

} catch (e) {
  SnackBarService.warning('Date invalide');
  return false;
}
    bool validateEmail(String email) {
      if (email.isEmpty) {
        SnackBarService.warning("L'email est requis");
        return false;
      }
      if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email)) {
        SnackBarService.warning('Format email invalide');
        return false;
      }
      return true;
    }

    // Vérification de tous les champs
      if (!validateField(adresseController.text, 'adresse')) return false;
    if (!validateEmail(emailController.text)) return false;

    return true;
  }

submitForm() {
    if (validateForm()) {
      final storage = GetStorage();

      final id = storage.read('userInfo');
      final token = storage.read('token');
      if (id == null) {
        SnackBarService.warning('ID utilisateur non trouvé');
        return;
      }

      updateUserInfosup(userId: id['id'], token: token);

      // Sauvegarde des données dans le storage
      /* final storage = GetStorage();
      storage.write('nom', nomController.text);
      storage.write('prenom', prenomController.text);
      storage.write('adresse', adresseController.text);    
      storage.write('email', emailController.text); */
    }
  }

  //////////////////// Partie ajoutée : appel API infosup ////////////////////

  final _userService = UserService();
String convertirDate(String date) {
  try {
    DateTime parsedDate = DateFormat('dd/MM/yyyy').parseStrict(date);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  } catch (e) {
    return ''; // ou gérer l'erreur autrement
  }
}  Future<void> updateUserInfosup(
      {required int userId, required String token}) async {
        final dateNaissance = convertirDate(dateNaissanceController.text);

    final nom = nomController.value;
    final prenom = prenomController.value;
    final adresse = adresseController.value;
    final email = emailController.value;
    final telephone = phoneNumber.value.toString();
    final sexe = sexeController.value=='F'?2:1;
    print('✅ voila  le sexe $sexe');
    print('✅ voila  la date de naissance $dateNaissance');
    
    // Show loading snackbar
    final snackBarController = Get.snackbar(
      'Envoi...',
      'Mise à jour en cours...',
      showProgressIndicator: true,
      isDismissible: false,
      duration: Duration.zero,
    );

    try {
      
      final result = await _userService.updateUserInfo(
        id: userId,
        token: token,
        name: nomController.text,
        email: emailController.text,
        prenom: prenomController.text,
        adresse: adresseController.text,
        telephone: telephone,
        sexe: sexe,
        dateNaissance: dateNaissance,

      );
      print(result);
      // Dismiss loading snackbar and show result
      snackBarController.close();
      if (result != null) {
        Get.offAll(() => MenuScreen());
        SnackBarService.success( 'Informations mises à jour avec succès');
        final storage = GetStorage();
        storage.write('nom', nomController.text);
        storage.write('prenom', prenomController.text);
        storage.write('adresse', adresseController.text);
        storage.write('email', emailController.text);
        
      } else {
        SnackBarService.warning( 'Cet email est déjà pris');
      }
    } catch (e) {
      // Dismiss loading snackbar and show error
      snackBarController.close();
      SnackBarService.warning('Une erreur est survenue \n Si Le problème persite contacter \nle service client');
    }
  }
}
