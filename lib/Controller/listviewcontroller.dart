import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onyfast/model/item.dart';

class ListController extends GetxController {
  final RxList<Item> items = <Item>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  void loadItems() {
    final List<Item> dummyItems = [
      Item(
        title: "Réunion Marketing".tr,
        subtitle: "Présentation nouveau campagne".tr,
        date: "10:00 AM".tr,
        icon: "👥",
        color: Colors.blue,
        progress: 0.7,
      ),
      Item(
        title: "Rapport Financier".tr,
        subtitle: "Analyse Q2 résultats".tr,
        date: "Hier".tr,
        icon: "📊",
        color: Colors.green,
        progress: 0.4,
      ),
      Item(
        title: "Entretien Technique".tr,
        subtitle: "Recrutement nouveau développeur".tr,
        date: "Demain".tr,
        icon: "💻",
        color: Colors.orange,
        progress: 0.9,
      ),
    ];
    items.assignAll(dummyItems);
  }

  void removeItem(int index) {
    items.removeAt(index);
    // Get.snackbar(
    //   "Supprimé".tr,
    //   "Élément supprimé avec succès".tr,
    //   snackPosition: SnackPosition.BOTTOM,
    // );
  }
}