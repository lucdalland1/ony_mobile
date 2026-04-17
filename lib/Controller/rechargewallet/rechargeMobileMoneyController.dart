
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:onyfast/Api/recharge_api/recharge_api.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/model/recharge_wallet/transactionMobileMoney.dart';

class MobileMoneyController extends GetxController {
  var isLoading = false.obs;
  var transaction = Rxn<Transaction>();
  var message = ''.obs;

  Future<void> envoyerDepot({
    required String montant,
    required String typeTransactionId,
    required String telephone,
  }) async {
    isLoading.value = true;
    try {
      final result = await MobileMoneyService.sendMobileMoney(
        montant: montant,
        typeTransactionId: typeTransactionId,
        telephone: telephone,
      );

      if (result != null) {
        transaction.value = result.transaction;
        message.value = result.message;
         SnackBarService.success(result.message);
      } else {
         SnackBarService.warning('Échec de la transaction');
      }
    } catch (e) {
      SnackBarService.warning('Une erreur inattendue s\'est produite \n Si le problème persiste contacter le service client');
    } finally {
      isLoading.value = false;
    }
  }
}
