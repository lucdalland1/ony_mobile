import 'package:get/get.dart';

class BankController extends GetxController {
  var currentIndex = 0.obs;
  var selectedImagePath = ''.obs;
  var selectedBankName = ''.obs;

  var assetImagess = [
    'asset/uba.png',
    'asset/bgfi_bank.jpg',
    'asset/ecobank.jpeg',
  ];

  var bankNames = [
    'UBA Bank',
    'BGFI Bank',
    'Ecobank',
  ];

  void nextImages() {
    if (currentIndex.value < assetImagess.length - 1) {
      currentIndex.value++;
    } else {
      currentIndex.value = 0; // Revenir au début
    }
    updateSelected();
    
  }

  void previousImages() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    } else {
      currentIndex.value = assetImagess.length - 1; // Aller à la fin
    }
    updateSelected();
  }

  void selectImage() {
    selectedImagePath.value = assetImagess[currentIndex.value];
    selectedBankName.value = bankNames[currentIndex.value];
  }

  void updateSelected() {
    selectedImagePath.value = assetImagess[currentIndex.value];
    selectedBankName.value = bankNames[currentIndex.value];
  }
}