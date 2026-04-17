import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:math';

class EncryptionController extends GetxController {
  final String secretKeyString =
      '8865380264a7533396636897f531bb4ccb7dc701552ae5bf94bfb6c466b3172f';

  // Génération de salt aléatoire
  Uint8List _generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(8, (i) => random.nextInt(256)));
  }

  // Implémentation correcte d'EVP_BytesToKey (compatible CryptoJS/OpenSSL)
  Map<String, Uint8List> _evpBytesToKey(
      String password, Uint8List salt, int keyLen, int ivLen) {
    List<int> d = [];
    List<int> dI = [];

    while (d.length < (keyLen + ivLen)) {
      List<int> md5Input = [];

      // Ajouter le hash précédent si ce n'est pas la première itération
      if (dI.isNotEmpty) {
        md5Input.addAll(dI);
      }

      // Ajouter le password
      md5Input.addAll(utf8.encode(password));

      // Ajouter le salt
      md5Input.addAll(salt);

      // Calculer MD5
      dI = md5.convert(md5Input).bytes;

      // Ajouter au résultat
      d.addAll(dI);
    }

    return {
      'key': Uint8List.fromList(d.sublist(0, keyLen)),
      'iv': Uint8List.fromList(d.sublist(keyLen, keyLen + ivLen)),
    };
  }

  // Fonction de chiffrement compatible avec CryptoJS
  String encryptData(String data) {
    try {
      print("🔐 === CHIFFREMENT (compatible CryptoJS/PHP) ===");
      print("📝 Données à chiffrer: $data");

      if (data.isEmpty) {
        throw Exception("Données vides à chiffrer");
      }

      // Créer la structure JSON comme en PHP
      Map<String, dynamic> dataMap = {'telephone': data};
      String jsonData = json.encode(dataMap);
      print("📋 JSON créé: $jsonData");

      // Générer un salt aléatoire (8 bytes)
      final salt = _generateSalt();
      print("🧂 Salt généré: ${base64.encode(salt)}");

      // Dérivation de clé avec EVP_BytesToKey (32 bytes key + 16 bytes IV)
      final derived = _evpBytesToKey(secretKeyString, salt, 32, 16);
      final key = derived['key']!;
      final iv = derived['iv']!;

      print("🔑 Clé dérivée: ${base64.encode(key)}");
      print("🎯 IV dérivé: ${base64.encode(iv)}");

      // Chiffrement AES-256-CBC
      final encrypter = encrypt.Encrypter(
          encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.cbc));

      final encrypted = encrypter.encrypt(jsonData, iv: encrypt.IV(iv));
      print("🔒 Données chiffrées: ${base64.encode(encrypted.bytes)}");

      // Format CryptoJS: "Salted__" + salt + données chiffrées
      final saltedPrefix = utf8.encode('Salted__');
      final result = Uint8List.fromList([
        ...saltedPrefix, // 8 bytes
        ...salt, // 8 bytes
        ...encrypted.bytes // données chiffrées
      ]);

      final base64Result = base64.encode(result);
      print("✅ Résultat base64: $base64Result");

      return base64Result;
    } catch (e) {
      print("❌ Erreur de chiffrement: $e");
      rethrow;
    }
  }

  // Fonction de déchiffrement compatible
  String decryptData(String encryptedData) {
    try {
      print("🔓 === DÉCHIFFREMENT (compatible CryptoJS/PHP) ===");
      print("📥 Données chiffrées reçues: $encryptedData");

      if (encryptedData.isEmpty) {
        throw Exception("Données chiffrées vides");
      }

      // Nettoyer et décoder le base64
      String cleanData = encryptedData.trim().replaceAll(RegExp(r'\s+'), '');

      // Ajouter padding si nécessaire
      while (cleanData.length % 4 != 0) {
        cleanData += '=';
      }

      Uint8List encryptedBytes;
      try {
        encryptedBytes = base64.decode(cleanData);
      } catch (e) {
        throw Exception("Erreur de décodage base64: $e");
      }

      print("📊 Taille des données décodées: ${encryptedBytes.length} bytes");

      // Vérifier la taille minimale (8 prefix + 8 salt + au moins 16 pour les données)
      if (encryptedBytes.length < 32) {
        throw Exception("Données trop courtes (minimum 32 bytes requis)");
      }

      // Vérifier le préfixe "Salted__"
      final expectedPrefix = utf8.encode('Salted__');
      final actualPrefix = encryptedBytes.sublist(0, 8);

      if (!_arraysEqual(actualPrefix, expectedPrefix)) {
        final prefixStr = String.fromCharCodes(actualPrefix);
        throw Exception("Préfixe 'Salted__' manquant. Trouvé: '$prefixStr'");
      }

      print("✅ Préfixe 'Salted__' vérifié");

      // Extraire le salt (8 bytes après le préfixe)
      final salt = encryptedBytes.sublist(8, 16);
      print("🧂 Salt extrait: ${base64.encode(salt)}");

      // Extraire les données chiffrées
      final cipherData = encryptedBytes.sublist(16);
      print("🔒 Données chiffrées: ${cipherData.length} bytes");

      if (cipherData.isEmpty) {
        throw Exception("Aucune donnée chiffrée trouvée");
      }

      // Dériver la clé et l'IV avec EVP_BytesToKey
      final derived = _evpBytesToKey(secretKeyString, salt, 32, 16);
      final key = derived['key']!;
      final iv = derived['iv']!;

      print("🔑 Clé redérivée: ${base64.encode(key)}");
      print("🎯 IV redérivé: ${base64.encode(iv)}");

      // Déchiffrement AES-256-CBC
      try {
        final encrypter = encrypt.Encrypter(
            encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.cbc));

        final encrypted = encrypt.Encrypted(cipherData);
        final decrypted = encrypter.decrypt(encrypted, iv: encrypt.IV(iv));

        print("✅ Déchiffrement réussi: $decrypted");
        return decrypted;
      } catch (e) {
        throw Exception("Erreur de déchiffrement AES: $e");
      }
    } catch (e) {
      print("❌ Erreur de déchiffrement: $e");
      rethrow;
    }
  }

  // Utilitaire pour comparer deux arrays
  bool _arraysEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // Fonction pour traiter les données du QR code
  String processQrCodeData(String qrData) {
    try {
      print("\n📱 === TRAITEMENT QR CODE ===");
      print("📥 Données QR: $qrData");

      // Détecter le type de données
      String dataType = _detectDataType(qrData);
      print("🔍 Type détecté: $dataType");

      switch (dataType) {
        case 'encrypted':
          // Données chiffrées, tenter le déchiffrement
          try {
            String decrypted = decryptData(qrData);
            print("✅ QR déchiffré: $decrypted");

            // Si c'est du JSON, extraire le téléphone
            try {
              Map<String, dynamic> jsonData = json.decode(decrypted);
              if (jsonData.containsKey('telephone')) {
                String phone = jsonData['telephone'].toString();
                print("📱 Téléphone extrait: $phone");
                return phone;
              }
            } catch (e) {
              print("ℹ️ Pas du JSON, retour du texte déchiffré");
            }

            return decrypted;
          } catch (e) {
            print("❌ Échec déchiffrement: $e");
            return qrData; // Retourner les données originales
          }

        case 'phone':
          print("📱 Numéro de téléphone direct");
          return qrData;

        case 'json':
          try {
            Map<String, dynamic> jsonData = json.decode(qrData);
            if (jsonData.containsKey('telephone')) {
              String phone = jsonData['telephone'].toString();
              print("📱 Téléphone extrait du JSON: $phone");
              return phone;
            }
          } catch (e) {
            print("⚠️ Erreur parsing JSON: $e");
          }
          return qrData;

        default:
          print("❓ Type inconnu, tentative de déchiffrement");
          try {
            return decryptData(qrData);
          } catch (e) {
            print("❌ Déchiffrement échoué, retour données originales");
            return qrData;
          }
      }
    } catch (e) {
      print("❌ Erreur traitement QR: $e");
      return qrData;
    }
  }

  // Détecter le type de données
  String _detectDataType(String data) {
    String cleanData = data.trim();

    // Vérifier si c'est un numéro de téléphone
    if (RegExp(r'^\+?[0-9]{8,15}$').hasMatch(cleanData)) {
      return 'phone';
    }

    // Vérifier si c'est du JSON
    try {
      json.decode(cleanData);
      return 'json';
    } catch (e) {
      // Pas du JSON
    }

    // Vérifier si c'est des données chiffrées (base64 avec préfixe Salted__)
    try {
      Uint8List decoded = base64.decode(cleanData);
      if (decoded.length >= 16) {
        String prefix = String.fromCharCodes(decoded.take(8));
        if (prefix == 'Salted__') {
          return 'encrypted';
        }
      }
    } catch (e) {
      // Pas du base64 valide
    }

    return 'unknown';
  }

  // Test de compatibilité avec validation croisée
  void testCompatibility() {
    try {
      print("\n🧪 === TEST DE COMPATIBILITÉ CryptoJS/PHP ===");

      // Test 1: Chiffrement/déchiffrement simple
      String testPhone = "0123456789";
      print("1️⃣ Test avec téléphone: $testPhone");

      String encrypted = encryptData(testPhone);
      print("🔒 Chiffré: $encrypted");

      String decrypted = decryptData(encrypted);
      print("🔓 Déchiffré: $decrypted");

      // Le résultat devrait être un JSON
      try {
        Map<String, dynamic> jsonResult = json.decode(decrypted);
        String extractedPhone = jsonResult['telephone'];
        bool success = extractedPhone == testPhone;
        print("✅ Test simple: ${success ? 'RÉUSSI' : 'ÉCHOUÉ'}");
        print("   Téléphone extrait: $extractedPhone");
      } catch (e) {
        print("❌ Test simple: ÉCHOUÉ - Pas du JSON valide");
      }

      // Test 2: Processus QR complet
      print("\n2️⃣ Test processus QR complet");
      String qrResult = processQrCodeData(encrypted);
      print("📱 Résultat final QR: $qrResult");

      bool qrSuccess = qrResult == testPhone;
      print("✅ Test QR: ${qrSuccess ? 'RÉUSSI' : 'ÉCHOUÉ'}");

      print("\n=== RÉSUMÉ DES TESTS ===");
      print("• Format de sortie: JSON avec clé 'telephone'");
      print("• Compatible avec: CryptoJS.AES.encrypt/decrypt");
      print("• Compatible avec: OpenSSL (PHP)");
      print("• Méthode de dérivation: EVP_BytesToKey");
      print("• Algorithme: AES-256-CBC");
      print("=== FIN DES TESTS ===\n");
    } catch (e) {
      print("❌ Erreur durant les tests: $e");
    }
  }

  // Fonction de test avec des données PHP (pour debug)
  void testWithPhpData(String phpEncryptedData) {
    print("\n🔬 === TEST AVEC DONNÉES PHP ===");
    print("📥 Données PHP: $phpEncryptedData");

    try {
      String result = processQrCodeData(phpEncryptedData);
      print("✅ Déchiffrement réussi!");
      print("📱 Téléphone extrait: $result");
    } catch (e) {
      print("❌ Erreur: $e");
      debugQrCode(phpEncryptedData);
    }
    print("=== FIN TEST PHP ===\n");
  }

  // Debug d'un QR code spécifique
  void debugQrCode(String qrData) {
    print("\n🔬 === DEBUG QR CODE ===");
    print("📥 Données: '$qrData'");
    print("📏 Longueur: ${qrData.length}");

    try {
      String cleanData = qrData.trim().replaceAll(RegExp(r'\s+'), '');

      // Ajouter padding si nécessaire
      while (cleanData.length % 4 != 0) {
        cleanData += '=';
      }

      Uint8List decoded = base64.decode(cleanData);
      print("📊 Taille décodée: ${decoded.length} bytes");

      if (decoded.length >= 16) {
        String prefix = String.fromCharCodes(decoded.take(8));
        Uint8List salt = decoded.sublist(8, 16);
        Uint8List cipher = decoded.sublist(16);

        print("🏷️ Préfixe: '$prefix'");
        print("🧂 Salt: ${base64.encode(salt)} (${salt.length} bytes)");
        print("🔒 Données chiffrées: ${cipher.length} bytes");

        if (prefix == 'Salted__') {
          print("✅ Format CryptoJS détecté");

          // Tester la dérivation de clé
          final derived = _evpBytesToKey(secretKeyString, salt, 32, 16);
          print("🔑 Clé test: ${base64.encode(derived['key']!)}");
          print("🎯 IV test: ${base64.encode(derived['iv']!)}");
        } else {
          print("❌ Préfixe incorrect, attendu 'Salted__'");
        }
      }
    } catch (e) {
      print("❌ Erreur debug: $e");
    }

    print("=== FIN DEBUG ===\n");
  }
}
