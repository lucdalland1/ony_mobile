import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DateController extends GetxController {
  // TextEditingController pour stocker la date sélectionnée
  final TextEditingController dateController = TextEditingController();

  // Méthode pour ouvrir le sélecteur de date
  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      // Mettre à jour le TextEditingController avec la date sélectionnée
      dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
    }
  }

  // Méthode pour valider la date
  String? validateDate() {
    if (dateController.text.isEmpty) {
      return 'Veuillez sélectionner une date';
    }
    return null;
  }

  // N'oubliez pas de disposer le contrôleur
  @override
  void onClose() {
    dateController.dispose();
    super.onClose();
  }
}