import 'package:get/get.dart';

class ValidationController extends GetxController {
  // États observables
  final RxBool niveau1Complete = false.obs;
  final RxBool niveau2Complete = false.obs;
  final RxBool niveau3Complete = false.obs;

  // Valider le niveau 2
  void completeNiveau2(bool value) {
    niveau2Complete.value = value;
    if (!value) niveau3Complete.value = false; // Réinitialiser niveau 3 si niveau 2 est invalidé
  }

  // Valider le niveau 3
  void completeNiveau3(bool value) {
    if (niveau2Complete.value) { // Ne peut valider que si niveau 2 est complet
      niveau3Complete.value = value;
    }
  }
}