import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ExpediteurController extends GetxController {
  final GetStorage storage = GetStorage();
  var totelephoneController = TextEditingController();
  var fromTelephoneController = TextEditingController();
  var isVisible = false.obs; // Contrôle de la visibilité

  @override
  void onInit() {
    super.onInit();
    // Récupérer les informations de l'utilisateur
    var user = getUser();
    totelephoneController.text = user['telephone'] ?? ''; // Remplir le champ avec le numéro de téléphone
    fromTelephoneController.text = ''; // Initialiser le deuxième champ
  }

  // Logique pour obtenir l'utilisateur
  Map<String, dynamic> getUser() {
    return {'telephone': storage.read('telephone')}; // Exemple de récupération
  }

  // Méthode pour basculer la visibilité
  void toggleVisibility() {
    isVisible.value = !isVisible.value; // Alterner la visibilité
  }
}