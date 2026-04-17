import 'package:get/get.dart';

class BloquerPhysiqueController extends GetxController {
  var isActive = false.obs;

  void toggle() {
    isActive.toggle();
  }
}