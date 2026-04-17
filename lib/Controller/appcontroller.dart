import 'package:get/get.dart';

class AppController extends GetxController {
  // Exemple d'état à gérer
  var isLoggedIn = false.obs;

  void toggleLogin() {
    isLoggedIn.value = !isLoggedIn.value;
  }
}