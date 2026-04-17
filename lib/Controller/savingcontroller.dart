import 'package:get/get.dart';
import 'package:flutter/material.dart';

class VerrouillageController extends GetxController {
  var verrouillage = 'Aucune'.obs;
  var selectedDate = Rx<DateTime?>(null);
  var amount = ''.obs;
}
