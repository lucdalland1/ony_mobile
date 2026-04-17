// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';

// import '../Api/user_inscription.dart';

// class VerificationController extends GetxController {
//   final AuthController authService = Get.find<AuthController>();
//   final telephoneController = TextEditingController();
//   final passwordController = TextEditingController();
  
//   var initialCountry = 'CG';
//   var phoneNumber = PhoneNumber(isoCode: 'CG').obs;

//   // Concatenate the country code and phone number
//   String get fullPhoneNumber => '${phoneNumber.value.dialCode}${telephoneController.text}';

//   Future<void> register() async {
//     final phone = telephoneController.text.trim();
//     final password = passwordController.text.trim();

//     print(phone);

//     if (phone.isEmpty || password.isEmpty) {
//       Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
//       return;
//     }

//     await authService.register(phone, password, confirmPasswordController.text.trim());
//   }

//   @override
//   void onClose() {
//     telephoneController.dispose();
//     passwordController.dispose();
//     super.onClose();
//   }
// }