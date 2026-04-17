import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:math';

class SimpleEncryptionTest extends GetxController {
  final String secretKey =
      "8865380264a7533396636897f531bb4ccb7dc701552ae5bf94bfb6c466b3172f";

  // Test de chiffrement le plus simple possible
  String simpleEncrypt(String phone) {
    try {
      print("🔵 === DÉBUT CHIFFREMENT SIMPLE ===");
      print("📱 Téléphone: $phone");

      // Créer les données JSON
      final data = {'telephone': phone};
      final jsonData = json.encode(data);
      print("📄 JSON: $jsonData");

      // Créer la clé de 32 caractères
      final key32 = secretKey.padRight(32).substring(0, 32);
      print("🔑 Clé (32 chars): $key32");

      // Créer l'encrypteur
      final encrypter = encrypt.Encrypter(encrypt.AES(
        encrypt.Key.fromUtf8(key32),
        mode: encrypt.AESMode.cbc,
      ));
      print("✅ Encrypteur créé");

      // Générer IV aléatoire
      final iv = encrypt.IV.fromSecureRandom(16);
      print("🎯 IV: ${iv.base64}");

      // Chiffrer
      final encrypted = encrypter.encrypt(jsonData, iv: iv);
      print("🔒 Résultat: ${encrypted.base64}");

      print("🔵 === FIN CHIFFREMENT SIMPLE ===\n");
      return encrypted.base64;
    } catch (e) {
      print("❌ ERREUR CHIFFREMENT: $e");
      print("❌ Stack trace: ${StackTrace.current}");
      rethrow;
    }
  }

  // Test de déchiffrement le plus simple possible
  String simpleDecrypt(String encryptedText) {
    try {
      print("🟢 === DÉBUT DÉCHIFFREMENT SIMPLE ===");
      print("📥 Données: $encryptedText");

      // Créer la clé de 32 caractères
      final key32 = secretKey.padRight(32).substring(0, 32);
      print("🔑 Clé (32 chars): $key32");

      // Créer l'encrypteur
      final encrypter = encrypt.Encrypter(encrypt.AES(
        encrypt.Key.fromUtf8(key32),
        mode: encrypt.AESMode.cbc,
      ));
      print("✅ Encrypteur créé");

      // Décoder et déchiffrer
      final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
      final decryptedJson = encrypter.decrypt(encrypted);
      print("📝 JSON déchiffré: $decryptedJson");

      // Parser JSON
      final data = json.decode(decryptedJson);
      if (data is Map<String, dynamic> && data.containsKey('telephone')) {
        final phone = data['telephone'].toString();
        print("📱 Téléphone extrait: $phone");
        print("🟢 === FIN DÉCHIFFREMENT SIMPLE ===\n");
        return phone;
      }

      print("🟢 === FIN DÉCHIFFREMENT SIMPLE ===\n");
      return decryptedJson;
    } catch (e) {
      print("❌ ERREUR DÉCHIFFREMENT: $e");
      print("❌ Stack trace: ${StackTrace.current}");
      rethrow;
    }
  }

  // Test complet
  void runSimpleTest() {
    try {
      print("\n🚀 === DÉMARRAGE TEST SIMPLE ===");

      const testPhone = "+237123456789";
      print("1️⃣ Test avec: $testPhone");

      // Chiffrer
      final encrypted = simpleEncrypt(testPhone);
      print("2️⃣ Chiffré: $encrypted");

      // Déchiffrer
      final decrypted = simpleDecrypt(encrypted);
      print("3️⃣ Déchiffré: $decrypted");

      // Vérifier
      if (decrypted == testPhone) {
        print("✅ TEST RÉUSSI!");
      } else {
        print("❌ TEST ÉCHOUÉ!");
        print("   Attendu: $testPhone");
        print("   Obtenu: $decrypted");
      }

      print("🚀 === FIN TEST SIMPLE ===\n");
    } catch (e) {
      print("❌ ERREUR TEST: $e");
      print("❌ Stack trace: ${StackTrace.current}");
    }
  }

  // Test spécifique pour un QR code Vue.js
  void testVueJsQrCode(String qrCode) {
    try {
      print("\n🔍 === TEST QR CODE VUE.JS ===");
      print("📥 QR reçu: $qrCode");

      if (qrCode.isEmpty ||
          qrCode == "COLLEZ_ICI_LE_CONTENU_DE_VOTRE_QR_VUE_JS") {
        print("⚠️ Veuillez fournir un vrai QR code Vue.js");
        return;
      }

      // Tenter le déchiffrement
      try {
        final result = simpleDecrypt(qrCode);
        print("✅ Déchiffrement réussi: $result");
      } catch (e) {
        print("❌ Déchiffrement échoué: $e");

        // Analyser le format
        print("🔍 Analyse du format:");
        print("   Longueur: ${qrCode.length}");
        print("   Contient ':': ${qrCode.contains(':')}");
        print("   Est base64: ${_isBase64(qrCode)}");
        print("   Est numéro: ${_isPhoneNumber(qrCode)}");
      }

      print("🔍 === FIN TEST QR VUE.JS ===\n");
    } catch (e) {
      print("❌ ERREUR TEST VUE.JS: $e");
    }
  }

  // Utilitaires
  bool _isBase64(String str) {
    try {
      base64.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool _isPhoneNumber(String str) {
    return RegExp(r'^\+?[0-9]{8,15}$').hasMatch(str.trim());
  }

  // Test au démarrage
  @override
  void onInit() {
    super.onInit();

    // Démarrer le test après un court délai
    Future.delayed(Duration(milliseconds: 500), () {
      print("📱 === INITIALISATION SIMPLE ENCRYPTION TEST ===");
      runSimpleTest();
    });
  }
}
