import 'package:get/get.dart';

class FormController extends GetxController {
  var isVisible = false.obs; // Contrôle de la visibilité
    var phoneNumber = ''.obs;
  var montant="".obs;

   var bankCode = ''.obs;
  var branchCode = ''.obs;
  var accountNumber = ''.obs;
  var key = ''.obs;
  var amount = ''.obs;

  void submitForm(String phone, String amount) {
    phoneNumber.value = phone;
    this.amount.value = amount;
  }
  void validerbank(String bankCode, String branchCode, String accountNumber, String key, String amount) {
    this.bankCode.value = bankCode;
    this.branchCode.value = branchCode;
    this.accountNumber.value = accountNumber;
    this.key.value = key;
    this.amount.value = amount;
  }
}