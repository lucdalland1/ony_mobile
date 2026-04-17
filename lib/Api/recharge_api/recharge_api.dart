import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/model/recharge_wallet/transactionMobileMoney.dart';

class MobileMoneyService {
  static Future<TransactionMobileMoney?> sendMobileMoney({
    required String montant,
    required String typeTransactionId,
    required String telephone,
  }) async {
    final box = GetStorage();
    final token = box.read('token');

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    print("voici le token $token");
    print("voici le montant $montant");
    print("voici le type_transaction_id $typeTransactionId");
    print("voici le telephone $telephone");

    var deviceskey = await ValidationTokenController.to.getDeviceIMEI();
    var ip = await ValidationTokenController.to.getPublicIP();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiEnvironmentController.to.baseUrl}/mobilemoney'),
      );
      var cardId = ManageCardsController.to.currentCard?.cardID ?? '';
      request.fields.addAll({
        'montant': montant,
        'type_transaction_id': typeTransactionId,
        'telephone': telephone,
        'device': deviceskey ?? "",
        'ip': ip,
        'card_id': cardId,
      });

      request.headers.addAll(headers);
      final response = await request.send();

      final status = response.statusCode;
      final body = await response.stream.bytesToString();
      final decoded = json.decode(body);

      if (status == 200 || status == 201 || status == 202) {
        Get.back();
        final userMessage =
            decoded['status']?['message'] ?? 'Transaction en cours.';
        print("ℹ 202 Accepted : $userMessage");
        SnackBarService.success('$userMessage');

        return TransactionMobileMoney.fromJson(decoded);
      } else if (status == 400) {
        // Récupération du message contenu dans la réponse
        final userMessage =
            decoded['status']?['message'] ?? 'Requête incorrecte.';
        print("❌ Erreur 400 : $userMessage");
        SnackBarService.error(userMessage);

        return null;
      } else {
        print("❌ Erreur HTTP $status : $body");
        SnackBarService.error('${decoded['ko'] ?? 'Requête incorrecte.'}');
        return null;
      }
    } on SocketException catch (e) {
      print("🚫 Pas de connexion Internet : $e");
      SnackBarService.networkError();
      return null;
    } on TimeoutException catch (e) {
      print("⏰ Requête expirée : $e");
      SnackBarService.warning('La requête a expiré.');
      // Get.snackbar('Timeout', 'La requête a expiré.', snackPosition: SnackPosition.BOTTOM);
      return null;
    } catch (e) {
      print("🔥 Erreur inattendue : $e");
      // SnackBarService.error( 'Erreur inattendue.\nRéessayer  si le problème persiste, contacter le support.');
      return null;
    }
  }
}
