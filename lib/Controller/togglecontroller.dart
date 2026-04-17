import 'package:get/get.dart';

class ToggleController extends GetxController {
  var isActive = false.obs;

  void toggle() {
    isActive.toggle();
  }
}