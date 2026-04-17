import 'package:get/get.dart';
import 'package:onyfast/model/transfert/frais_fixe_model.dart';
import 'package:onyfast/Api/transfert/FraisFixeService.dart';

class FraisFixeController extends GetxController {
  Rx<FraisFixeModel?> fraisFixe = Rx<FraisFixeModel?>(null);
  RxBool isLoading = false.obs;

  Future<void> loadFraisFixe() async {
    isLoading.value = true;
    final result = await FraisFixeService.fetchFraisFixe();
    fraisFixe.value = result;
    isLoading.value = false;
  }
}
