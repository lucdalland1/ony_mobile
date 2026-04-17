import 'package:get/get.dart';

class AssetSliderController extends GetxController {
  // Liste des chemins vers les images dans les assets
  final List<String> assetImages = [
    'asset/Airtel.png',
    'asset/MTN_logo.png',
    'asset/Orange_Money.png',
  ];

  var currentIndex = 0.obs;

  void nextImage() {
    if (currentIndex.value < assetImages.length - 1) {
      currentIndex.value++;
    } else {
      currentIndex.value = 0; // Revenir au début
    }
  }

  void previousImage() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    } else {
      currentIndex.value = assetImages.length - 1; // Aller à la fin
    }
  }
}