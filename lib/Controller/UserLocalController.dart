// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';

class UserLocalController extends GetxController {
  final _nom = ''.obs;
  final _prenom = ''.obs;
  final _adresse = ''.obs;
  final _email = ''.obs;
  final _profilePhotoUrl = ''.obs;
  final _telephone = ''.obs;

  final GetStorage _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();

    final userInfo = _storage.read('userInfo') ?? {};
    final tt = _storage.read('telephone') ?? '';

    _nom.value = userInfo['nom'] ?? '';
    _prenom.value = userInfo['prenom'] ?? '';
    _adresse.value = userInfo['adresse'] ?? '';
    _email.value = userInfo['email'] ?? '';
    _profilePhotoUrl.value = userInfo['profilePhotoUrl'] ?? '';
    _telephone.value = tt??userInfo['telephone'] ?? '';

    print('📦 Chargement userInfo: $userInfo');
    

    // Écouter les changements si écriture directe avec write(key, value)
    _storage.listenKey('nom', (value) => _nom.value = value ?? '');
    _storage.listenKey('prenom', (value) => _prenom.value = value ?? '');
    _storage.listenKey('adresse', (value) => _adresse.value = value ?? '');
    _storage.listenKey('email', (value) => _email.value = value ?? '');
    _storage.listenKey('telephone', (value) => _telephone.value = value ?? '');
    _storage.listenKey('profilePhotoUrl', (value) => _profilePhotoUrl.value = value ?? '');
  }

  // Getters
  String get nom => _nom.value;
  String get prenom => _prenom.value;
  String get adresse => _adresse.value;
  String get email => _email.value;
  String get profilePhotoUrl => _profilePhotoUrl.value;
  String get telephone => _telephone.value;

  // Setters
  set nom(String value) {
    _nom.value = value;
    _storage.write('nom', value);
  }
  set telephone(String value) {
    _telephone.value = value;
    _storage.write('telephone', value);
  }
  set prenom(String value) {
    _prenom.value = value;
    _storage.write('prenom', value);
  }

  set adresse(String value) {
    _adresse.value = value;
    _storage.write('adresse', value);
  }

  set email(String value) {
    _email.value = value;
    _storage.write('email', value);
  }

  set profilePhotoUrl(String value) {
    _profilePhotoUrl.value = value;
    _storage.write('profilePhotoUrl', value);
  }

  void updateTelephone(String value) {
    _telephone.value = value;
    _storage.write('telephone', value);
  }

  // Sauvegarder toutes les données utilisateur dans userInfo
  Future<void> saveAll() async {
    try {
      final updatedInfo = {
        'nom': _nom.value,
        'prenom': _prenom.value,
        'adresse': _adresse.value,
        'email': _email.value,
        'profilePhotoUrl': _profilePhotoUrl.value,
        'telephone': _telephone.value,
      };

      await _storage.write('userInfo', updatedInfo);

      // Pour compatibilité descendante
      await Future.wait([
        _storage.write('nom', _nom.value),
        _storage.write('prenom', _prenom.value),
        _storage.write('adresse', _adresse.value),
        _storage.write('email', _email.value),
        _storage.write('profilePhotoUrl', _profilePhotoUrl.value),
        _storage.write('telephone', _telephone.value),
      ]);

      


      print('✅ Données utilisateur sauvegardées');
    } catch (e) {
     
      rethrow;
    }
  }

  // Effacer toutes les données utilisateur
  Future<void> clearAll() async {
    try {
      await Future.wait([
        _storage.remove('nom'),
        _storage.remove('prenom'),
        _storage.remove('adresse'),
        _storage.remove('email'),
        _storage.remove('profilePhotoUrl'),
        _storage.remove('telephone'),
        _storage.remove('userInfo'),
      ]);
      print('🧹 Données utilisateur supprimées');
    } catch (e) {
     
      rethrow;
    }
  }
}
