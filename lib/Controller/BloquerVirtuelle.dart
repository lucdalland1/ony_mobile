import 'package:get/get.dart';

class BloquerVirtuelleController extends GetxController {
  var isActive = false.obs;

  void toggle() {
    isActive.toggle();
  }
}