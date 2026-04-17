import 'package:get/get.dart';

class PayerController extends GetxController {
  var telephone = ''.obs;
  var argent = 0.obs; // Assurez-vous que c'est un RxInt

  var isValidationContainerVisible = false.obs;


  void updateTelephone(String value) {
    telephone.value = value;
  }

  void updateMontant(String value) {
    argent.value = int.tryParse(value) ?? 0;
    isValidationContainerVisible.value = argent.value >= 1000;
  }
}