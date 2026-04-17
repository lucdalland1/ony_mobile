import 'package:get/get.dart';

class SoldeController extends GetxController {
  var isBalanceVisible = false.obs; // État de visibilité du solde
  var balance = 100.0.obs; // Solde initial

  void toggleBalanceVisibility() {
    print('voila le toggle ${isBalanceVisible.value}');

    isBalanceVisible.value = !isBalanceVisible.value;
  }
}