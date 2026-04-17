import 'package:get/get.dart';
import 'package:onyfast/model/abonnement/abonnementModel.dart';
import 'package:onyfast/Api/abonnement_api/abonnementApi.dart';

class AbonnementController extends GetxController {
  var abonnements = <Abonnement>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var souscription = ''.obs;
  var compte=0.obs;

  @override
  void onInit() {
    fetchAbonnements();
    super.onInit();
  }

  void fetchAbonnements() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await AbonnementService.fetchAbonnements();
      print(result);
      abonnements.assignAll(result);
    } catch (e) {
      errorMessage.value = "Impossible de charger les abonnements";
    } finally {
      isLoading.value = false;
    }
  }


  void souscrireAbonnement(String typeAbonnementId) async {
    isLoading.value = true;

    try {
      final result = await AbonnementService.souscrireAbonnement(typeAbonnementId);
      souscription.value = result;
      
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }
}
