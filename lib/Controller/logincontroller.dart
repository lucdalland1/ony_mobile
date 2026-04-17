import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:onyfast/Api/user_inscription.dart';
import 'package:onyfast/Widget/alerte.dart';

class LoginController extends GetxController {
 RxBool isProcessing = false.obs;
  final AuthController authService = Get.find<AuthController>();
  final fullPhoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
    final CodeParrainController = TextEditingController();

  
  final countryCode = 'CG'.obs;
  final dialCode = '+242'.obs;     
  final completePhoneNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fullPhoneNumberController.addListener(_updateCompleteNumber);
  }

  @override
  void onClose() {
    fullPhoneNumberController.removeListener(_updateCompleteNumber);
    fullPhoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    CodeParrainController.dispose();
    super.onClose();
  }

  void _updateCompleteNumber() {
    final localNumber = fullPhoneNumberController.text;
    completePhoneNumber.value = '$dialCode$localNumber';
    
  }

  void updateCountryInfo(PhoneNumber phone) {
    countryCode.value = phone.isoCode ?? 'CG';
    dialCode.value = phone.dialCode ?? '+242';
    _updateCompleteNumber();
  }
  
  Future<void> register() async {
    if (completePhoneNumber.value.isEmpty) {
      SnackBarService.warning( 'Veuillez entrer un numéro de téléphone valide');
      return;
    }

    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      SnackBarService.warning('Veuillez remplir tous les champs');
      return;
    }

    if (password != confirmPassword) {
      SnackBarService.warning('Les mots de passe ne correspondent pas');
      return;
    }

    await authService.register(completePhoneNumber.value, password, confirmPassword, "Code", "Indicatif", CodeParrainController.text);
  }

  Future<void> login() async {
    if (completePhoneNumber.value.isEmpty) {
       SnackBarService.warning('Veuillez entrer un numéro de téléphone valide');
      return;
    }

    final password = passwordController.text.trim();

    if (password.isEmpty) {
       SnackBarService.warning('Veuillez entrer votre mot de passe');
      return;
    }

    await authService.login(completePhoneNumber.value, password);
  }
}