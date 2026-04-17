import 'package:get/get.dart';

class NavigationController extends GetxController {
  var selectedIndex = 0.obs; // Initialiser sur "Accueil"

  void setIndex(int index) {
    selectedIndex.value = index;
  }
}