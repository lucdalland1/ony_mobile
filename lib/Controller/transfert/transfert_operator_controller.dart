import 'package:get/get.dart';
import 'package:onyfast/View/Transfert/model/transferepreviewmodel.dart';
import 'package:onyfast/Api/transfert/transfertOperator.dart';
import 'package:onyfast/View/Transfert/recuoperateur.dart';

class TransferController extends GetxController {
  final isLoading = false.obs;
  final transferResponse = Rxn<TransferPreviewResponse>();
  final errorMessage = ''.obs;
  final operatorId = ''.obs;
  final countryId = ''.obs;

  final TransferService _service = TransferService();

  Future<void> previewTransfer({
    required int operatorId,
    required int countryId,
    required double amount,
    required String phoneNumber,
    required String nom,
    required double pourcentage,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    this.operatorId.value = operatorId.toString();
    this.countryId.value = countryId.toString();

    final result = await _service.previewTransfer(
      operatorId: operatorId,
      countryId: countryId,
      amount: amount,
      phoneNumber: phoneNumber,
      beneficiary_name:nom
    );

    if (result != null && result.status) {
      transferResponse.value = result;
      print("voila le result ${result}");
    } else {
      errorMessage.value = result?.message ?? 'Erreur inconnue';
      print("voila le error ${errorMessage.value}");
    }

    isLoading.value = false;
    Get.to(RecuOperateur(nom: nom, pourcentage: pourcentage));
  }
}
//+242+242069591700