
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData;
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Widget/alerte.dart';

class PaiementService {
  static Future<TransactionPaiement?> effectuerPaiement({
    required String toTelephone,
    required String montant,
    required int typeTransactionId,
  }) async {
    final dio = Dio();
    final box = GetStorage();
    final token = box.read('token');

    if (token == null) {
      // Get.snackbar('Authentification', 'Token manquant. Veuillez vous reconnecter.',
      //     snackPosition: SnackPosition.BOTTOM);
      return null;
    }

    try {
       var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
        var ip=await ValidationTokenController.to.getPublicIP();
      final response = await dio.post(
        '${ApiEnvironmentController.to.baseUrl}/paiement',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: FormData.fromMap({
          'to_telephone': toTelephone,
          'montant': montant,
          'type_transaction_id': typeTransactionId.toString(),
          'device':deviceskey,
          'card_id': ManageCardsController.to.currentCard?.cardID ?? '',
          'ip':ip
        }),
      );

      if (response.statusCode == 201 && response.data['transaction'] != null) {
        print("✅ Paiement effectué avec succès.");
        return TransactionPaiement.fromJson(response.data['transaction']);
      } else {
        print(' response.data ${response.data}');
        final message = response.data['message'] ?? 'Une erreur est survenue.';
        final error = response.data['error'] ?? '';
        Get.snackbar('Erreur', '$message\n$error',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
            colorText: Get.theme.colorScheme.error);
        return null;
      }

    } on DioException catch (e) {
      String title = 'Erreur réseau';
      String message = 'Une erreur s\'est produite.';

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          message = "Connexion expirée.";
          break;
        case DioExceptionType.sendTimeout:
          message = "Envoi de requête trop lent.";
          break;
        case DioExceptionType.receiveTimeout:
          message = "Temps de réponse dépassé.";
          break;
        case DioExceptionType.badCertificate:
          message = "Certificat SSL invalide.";
          break;
        case DioExceptionType.badResponse:
          final data = e.response?.data;
          final serverMessage = data?['message'] ?? '';
          final errorDetails = data?['error'] ?? '';
          message = "$serverMessage\n$errorDetails";
          break;
        case DioExceptionType.cancel:
          message = "Requête annulée.";
          break;
        case DioExceptionType.unknown:
          if (e.error is SocketException) {
            message = "Aucune connexion Internet.";
          } else {
            message = "Erreur inconnue : ${e.message}";
          }
          break;
        default:
          message = "Erreur inattendue.";
      }

      SnackBarService.error( message,
         );

      return null;

    } catch (e) {
      print("💥 Erreur non gérée : $e");
      Get.snackbar('Exception', 'Erreur inattendue ,Si l\'erreur persiste contacter le service abilité',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
          colorText: Get.theme.colorScheme.error);
      return null;
    }
  }
}



class TransactionPaiement {
  final int id;
  final int typeTransactionId;
  final int fromWallet;
  final int toWallet;
  final String montant;
  final String from;
  final String to;
  final String codeInterne;
  final int userId;
  final String startDate;
  final String createdAt;
  final String updatedAt;

  TransactionPaiement({
    required this.id,
    required this.typeTransactionId,
    required this.fromWallet,
    required this.toWallet,
    required this.montant,
    required this.from,
    required this.to,
    required this.codeInterne,
    required this.userId,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionPaiement.fromJson(Map<String, dynamic> json) {
    return TransactionPaiement(
      id: json['id'],
      typeTransactionId: json['type_transaction_id'],
      fromWallet: json['from_wallet'],
      toWallet: json['to_wallet'],
      montant: json['montant'],
      from: json['from'],
      to: json['to'],
      codeInterne: json['codeInterne'],
      userId: json['user_id'],
      startDate: json['startDate'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
