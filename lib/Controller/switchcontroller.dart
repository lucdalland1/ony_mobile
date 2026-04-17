import 'package:get/get.dart';

class SwitchController extends GetxController {
  var switchValues = [false, false, false].obs;

  void toggleSwitch(int index, bool value) {
    switchValues[index] = value;
  }
}