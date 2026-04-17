import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RechargeWalletController extends GetxController {
  var montant = 0.0.obs;

  final TextEditingController fromTelephoneController = TextEditingController();
  final TextEditingController toTelephoneController = TextEditingController();
  final TextEditingController montantController = TextEditingController();

  void updateMontant(double value) {
    montant.value = value;
  }
}
