import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordController extends GetxController {
  // Observable pour gérer l'état de visibilité du mot de passe
TextEditingController passwordController = TextEditingController();

  var isPasswordVisible = false.obs;

  // Fonction pour basculer la visibilité du mot de passe
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
}