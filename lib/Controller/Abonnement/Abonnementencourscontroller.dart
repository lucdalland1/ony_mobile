import 'package:get/get.dart';
import 'package:onyfast/Api/abonnement_api/abonnementEnCoursApi.dart';
import 'package:onyfast/model/abonnement/abonnementEnCours.dart';

class AbonnementEncoursController extends GetxController {
  static AbonnementEncoursController get to => Get.find();

  final AbonnementEncoursService _service = AbonnementEncoursService();

  // L'abonnement en cours (Rxn pour pouvoir être null)
  var abonnement = Rxn<AbonnementEnCours>();

  // Indicateur de chargement
  var isLoading = false.obs;

  // Message d'erreur
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAbonnement();
  }

  /// Récupère l'abonnement en cours depuis le service
  void fetchAbonnement() async {
    print("✅✅✅✅✅ fetchAbonnement En cours");
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _service.getAbonnementEnCours();
      if (result != null) {
        abonnement.value = result;
        print("✅ Abonnement trouvé🔐🔐🔐🔐🔐🔐🔐🔐🔐🔐🔐🔐");
        print("✅ Abonnement: ${abonnement.value?.type}");
      } else {

        errorMessage.value = 'Aucun abonnement trouvé.';
         print("⚠️ Aucun abonnement trouvé");
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors de la récupération : $e';
      print("❌ Erreur fetchAbonnement : $e");
    } finally {
      isLoading.value = false;
    }
  }
}
