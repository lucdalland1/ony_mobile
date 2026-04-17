import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controller pour la gestion de la langue
class LangueController extends GetxController {
  // Variable réactive pour la langue actuelle
  var locale = const Locale('fr', 'FR').obs; // Par défaut, le français

  // Méthode pour changer la langue
  void changeLanguage(String languageCode, String countryCode) {
    locale.value = Locale(languageCode, countryCode);
    Get.updateLocale(locale.value); // Mettre à jour la locale dans GetX
  }

  // Méthode pour obtenir la langue actuelle
  String get currentLanguage => locale.value.languageCode;

  // Méthode pour obtenir la traduction d'une clé
  String translate(String key) {
    return key.tr; // Utilise la méthode `tr` de GetX pour traduire la clé
  }
}