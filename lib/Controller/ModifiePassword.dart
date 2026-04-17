import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordController extends GetxController {
  // TextEditingController pour gérer la saisie du mot de passe
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController newpasswordController = TextEditingController();

  // Variable observable pour stocker la visibilité du mot de passe
  var isPasswordVisible = false.obs;

  // Méthode pour basculer la visibilité du mot de passe
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Méthode pour valider le mot de passe
  String? validatePassword() {
    if (passwordController.text.isEmpty || newpasswordController.text.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    if (passwordController.text.length != 4 && newpasswordController.text != 4) {
      return 'Le mot de passe doit contenir exactement 4 chiffres';
    }
    return null;
  }

  // N'oubliez pas de disposer le contrôleur
  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }
}