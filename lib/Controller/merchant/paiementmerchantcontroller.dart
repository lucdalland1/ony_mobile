import 'dart:convert';

import 'package:get/get.dart';
import 'package:onyfast/Api/merchant/paiement_merchant.dart';
import 'package:onyfast/Widget/alerte.dart';

class PaiementController extends GetxController {
  var isLoading = false.obs;
  var paiementReussi = false.obs;
  var transaction = Rxn<TransactionPaiement>();

  Future<void>  envoyerPaiement({
    required String toTelephone,
    required String montant,
    required int typeTransactionId,
  }) async {
    try {
      isLoading.value = true;
      final result = await PaiementService.effectuerPaiement(
        toTelephone: toTelephone,
        montant: montant,
        typeTransactionId: typeTransactionId,
      );
      isLoading.value = false;

      if (result != null) {
        transaction.value = result;
        paiementReussi.value = true;
         SnackBarService.success("Transaction réussie");
      } else { 
        paiementReussi.value = false;
        //  SnackBarService.warning("Échec de la transaction");
      }
    } catch (e, stack) {
      isLoading.value = false;
      paiementReussi.value = false;
      print("Erreur lors du paiement : $e");
      print(stack); // utile en debug
       SnackBarService.warning("Une erreur inattendue s'est produite \n Si le problème persiste contacter le service client");
    }
  }
}
