import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:get/get.dart';
import 'package:onyfast/Crypte%20&%20Decrypte/crypte.dart';

import 'package:encrypt/encrypt.dart';

import '../Api/user_inscription.dart';

class Decrypte {
  final AuthController connexion = Get.find();
  final String secretKey =
      "8865380264a7533396636897f531bb4ccb7dc701552ae5bf94bfb6c466b3172f";

  String decryptData(String encryptedText) {
    // Générer une clé à partir de la clé secrète
    final key =
        Key.fromUtf8(secretKey.substring(0, 32)); // La clé doit faire 32 octets
    final iv = IV.fromLength(16); // Initialisation vector

    // Créer un decryptor AES
    final encrypter = Encrypter(AES(key));

    // Déchiffrer le texte
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted; // Retourner le texte déchiffré
  }
}

final AuthController connexion = Get.find();
var user = connexion.getUser();
final phone = user?.telephone;
