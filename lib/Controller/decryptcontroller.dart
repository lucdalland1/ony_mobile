import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScanController extends GetxController {
  var scannedValue = ''.obs;

  void scanValue() {
    String encryptedData = "encryptedData"; // This would be the scanned value
    String decryptedValue = decryptData(encryptedData);
    debugPrint("Code-barres scanné : $decryptedValue");
    print("Voici la donnée déchiffrée : $decryptedValue");

    // Update the scanned value
    scannedValue.value = decryptedValue;
  }

  String decryptData(String encryptedData) {
    // Replace this with your actual decryption logic
    return "decryptedData";
  }
}