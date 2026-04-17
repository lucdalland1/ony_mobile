// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../Api/user_inscription.dart';

// class UpdateUserController extends GetxController {
//   final AuthController authService = Get.find<AuthController>();
//   final nameController = TextEditingController();
//   final prenomController = TextEditingController();
//   final emailController = TextEditingController();
//   final adresseController = TextEditingController();
//   final telephoneController = TextEditingController();
  


//   Future<void> register() async {
//     final email = emailController.text.trim();
//     final adresse = adresseController.text.trim();
//     final telephone = telephoneController.text.trim();
//     final name= nameController.text.trim();
//     final prenom= prenomController.text.trim();

//     print(name);print(prenom);print(telephone);print(email);print(adresse);

//     if (name.isEmpty || prenom.isEmpty|| email.isEmpty ||telephone.isEmpty  || adresse.isEmpty)  {
//       Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
//       return;
//     }

//     await authService.register(name,prenom);
//     await authService.register(adresse,telephone);
//     await authService.register(email,telephone);
//   }

// /*************  ✨ Codeium Command ⭐  *************/
//   /// Dispose of the `TextEditingController`s used by the `TextFormField`s
//   /// when the widget is closed. This is necessary to prevent memory leaks.
// /******  b476dd16-c24f-45b0-ba64-f36f023f4afc  *******/  @override

//   void onClose() {
//     telephoneController.dispose();
//     emailController.dispose();
//     nameController.dispose();
//     adresseController.dispose();
//     prenomController.dispose();
//     super.onClose();
//   }
// }