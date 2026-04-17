import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SexController extends GetxController {
  // TextEditingController pour stocker la valeur sélectionnée
  final TextEditingController sexController = TextEditingController();

  // Liste des options de sexe
  final List<String> sexOptions = ['Masculin', 'Féminin'];

  // Méthode pour valider la sélection
  String? validateSex() {
    if (sexController.text.isEmpty) {
      return 'Veuillez sélectionner votre sexe';
    }
    return null;
  }

  // N'oubliez pas de disposer le contrôleur
  @override
  void onClose() {
    sexController.dispose();
    super.onClose();
  }
}