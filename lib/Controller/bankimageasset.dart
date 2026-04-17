import 'package:get/get.dart';

class BankSliderController extends GetxController {
  // Liste des chemins vers les images dans les assets
  final List<String> assetImagess = [
    'asset/uba.png',
    'asset/bgfi_bank.jpg',
    'asset/ecobank.jpeg',
  ];

  var currentIndex = 0.obs;

  void nextImages() {
    if (currentIndex.value < assetImagess.length - 1) {
      currentIndex.value++;
    } else {
      currentIndex.value = 0; // Revenir au début
    }
  }

  void previousImages() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    } else {
      currentIndex.value = assetImagess.length - 1; // Aller à la fin
    }
  }
}