// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:encrypt/encrypt.dart' as encrypt;

// class CardExternalLauncher {
//   static const String _secretKey =
//       'f9D#3a1B7c!8E42f5D6a9B1c3E7f4D8a2B6c5E7f1D9a3B4c6E8f2D7a1B3c9E5f0A!@#';

//   static String _generateSecurityHash(
//       String cardID, String last4Digits, int timestamp) {
//     final data = cardID + last4Digits + timestamp.toString();
//     final key = utf8.encode(_secretKey);
//     final bytes = utf8.encode(data);
//     return Hmac(sha256, key).convert(bytes).toString();
//   }

//   static Uri _generateUri(String cardID, String last4Digits) {
//     final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//     final hash = _generateSecurityHash(cardID, last4Digits, timestamp);

//     final queryParams = <String, String>{
//       'cardID': cardID,
//       'last4Digits': last4Digits,
//       'security_hash': hash,
//       'timestamp': timestamp.toString(),
//     };

//     final encryptedData = encryptParams(queryParams,
//         "N4gF7vR2L2Xp8MzT5YwR1JkV9HsB3UeD0-QaC6_LtW8.PnX7~RbF2GjH5KyM1VzS4DcQ9UwE6-TfL3AhJ0R8KmV2ZtY6PnQ1XrB4");

//     return Uri.https(
//       'onyfast.com',
//       '/secure-card-details.php?data=$encryptedData'
//     );
//   }

//   static Future<void> launchCardDetails(
//       String cardID, String last4Digits) async {
//     try {
//       final uri = _generateUri(cardID, last4Digits);
//       final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
//       if (!ok) {
//         throw Exception("Aucun navigateur trouvé pour ouvrir l'URL");
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Erreur',
//         'Impossible d’ouvrir la page: $e',
//         backgroundColor: Colors.red.withOpacity(0.8),
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//         duration: const Duration(seconds: 4),
//         icon: const Icon(Icons.error, color: Colors.white),
//       );
//     }
//   }

//   String encryptParams(Map<String, String> queryParams, String secretKey) {
//     // Convertir en JSON
//     final jsonData = jsonEncode(queryParams);

//     // Clé AES 32 bytes (256 bits)
//     final key = encrypt.Key.fromUtf8(secretKey.substring(0, 32));
//     final iv =
//         encrypt.IV.fromLength(16); // ⚠️ en prod → utilise un IV aléatoire

//     final encrypter =
//         encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

//     final encrypted = encrypter.encrypt(jsonData, iv: iv);

//     return base64UrlEncode(encrypted.bytes);
//   }
// }

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';
class CardExternalLauncher {
late WebViewController webViewController;

  static const String _secretKey =
      'f9D#3a1B7c!8E42f5D6a9B1c3E7f4D8a2B6c5E7f1D9a3B4c6E8f2D7a1B3c9E5f0A!@#';

  static String _generateSecurityHash(
      String cardID, String last4Digits, int timestamp) {
    final data = cardID + last4Digits + timestamp.toString();
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(data);
    return Hmac(sha256, key).convert(bytes).toString();
  }

  static Uri _generateUri(String cardID, String last4Digits) {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final hash = _generateSecurityHash(cardID, last4Digits, timestamp);

    final queryParams = <String, String>{
      'cardID': cardID,
      'last4Digits': last4Digits,
      'security_hash': hash,
      'timestamp': timestamp.toString(),
    };

    final encryptedData = encryptParams(queryParams,
        "N4gF7vR2L2Xp8MzT5YwR1JkV9HsB3UeD0-QaC6_LtW8.PnX7~RbF2GjH5KyM1VzS4DcQ9UwE6-TfL3AhJ0R8KmV2ZtY6PnQ1XrB4");
print('Voila le lien ${Uri.https(
      'onyfast.com',
      '/secure-card-details-no-session.php',
      {'data': encryptedData},
    )}');
    
    return Uri.https(
     ApiEnvironmentController.to.baseUrl.replaceAll("https://", "").replaceAll("/api", ""),
      '/card/details',
      {'data': encryptedData},
    );
  }
static Future<void> launchCardDetails(
    String cardID, String last4Digits) async {
  try {
    final uri = _generateUri(cardID, last4Digits);
    late WebViewController webViewController;
    
    showCupertinoModalPopup(
      context: Get.context!,
      builder: (BuildContext context) => Container(
        height: Get.height * 0.9,
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    child: const Icon(CupertinoIcons.xmark_circle_fill),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // WebView with Pull-to-Refresh
            Expanded(
  child: RefreshIndicator(
    onRefresh: () async {
      await webViewController.reload();
    },
    child: ListView(
      // Force une surface scrollable même si la WebView prend tout l’espace
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: Get.height * 0.9 - 56, // ajuste selon la hauteur du header
          child: WebViewWidget(
            controller: webViewController = WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setBackgroundColor(const Color(0x00000000))
              ..loadRequest(uri),
          ),
        ),
      ],
    ),
  ),
),
          ],
        ),
      ),
    );
  } catch (e) {
    Get.snackbar(
      'Erreur',
      'Impossible d afficher la page: $e',
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }
}  
  static String encryptParams(
      Map<String, String> queryParams, String secretKey) {
    // 1️⃣ Convertir la map en JSON
    final jsonData = jsonEncode(queryParams);

    // 2️⃣ Clé AES 32 bytes (utilise les 32 premiers caractères)
    final key = encrypt.Key.fromUtf8(secretKey.substring(0, 32));

    // 3️⃣ IV fixe de 16 bytes (\0 répété 16 fois comme en PHP)
    // Méthode alternative: créer directement avec des zéros
    final iv = encrypt.IV
        .fromBase64('AAAAAAAAAAAAAAAAAAAAAA=='); // 16 bytes de zéros en base64

    // 4️⃣ Création de l'encrypteur AES-CBC
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    // 5️⃣ Chiffrement
    final encrypted = encrypter.encrypt(jsonData, iv: iv);

    // 6️⃣ Encode en Base64 URL-safe sans padding
    String base64UrlSafe = base64Encode(encrypted.bytes)
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', ''); // Supprime padding

    return base64UrlSafe;
  }
}
