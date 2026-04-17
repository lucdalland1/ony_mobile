// lib/controllers/container_controller.dart
import 'package:get/get.dart';

class RemplacerContainerController extends GetxController {
  var showFirstContainer = true.obs;

  void toggleContainers() {
    showFirstContainer.value = !showFirstContainer.value;
  }
}