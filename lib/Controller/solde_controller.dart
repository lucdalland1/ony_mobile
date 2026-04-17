import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/user_inscription.dart';

class SoldeRefreshController extends GetxController {
  final AuthController authController = Get.find();

 void refreshSolde() {
    // Appelle la méthode pour récupérer le solde
    AuthController authController = Get.find();
    authController.fetchSolde();
  }
  void loadinUser() {
    // Appelle la méthode pour récupérer le solde
    AuthController authController = Get.find();
    authController.loadUserInfo();
  }
   Future<void> refreshUser() async {
    try {
      // Appelle la méthode pour récupérer le solde
      await authController.fetchSolde();
      
      // Actualise les informations de l'utilisateur
      authController.loadUserInfo();
      
      // Optionnel : Afficher un Snackbar pour indiquer que l'actualisation a réussi
      // Get.snackbar(
      //   'Succès',
      //   'Informations et solde actualisés avec succès.',
      //   backgroundColor: Colors.orange,
      //   colorText: Colors.white,
      // );
    } catch (e) {
      // Afficher un Snackbar en cas d'erreur
      // Get.snackbar(
      //   'Erreur',
      //   'Échec de l\'actualisation des informations: $e',
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
    }
  }
}