import 'package:get/get.dart';
import 'package:onyfast/Api/transfert/operator.dart';
import 'package:onyfast/View/Transfert/model/operator_model.dart';

class OperatorController extends GetxController {
  final OperatorService _service = OperatorService();

  var isLoading = false.obs;
  var operators = <Operator>[].obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
    var select = false.obs;
  var index = 0.obs;
  var select2 = false.obs;
  Future<void> loadOperators(int countryId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _service.fetchOperators(countryId).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          hasError.value = true;
          errorMessage.value = 'Le serveur est lent. Veuillez réessayer plus tard.';
          isLoading.value = false;
          throw Exception('Délai d\'attente dépassé');
        },
      );
      if (result != null && result.success) {
        operators.assignAll(result.operators);
        print('voila la nouvelle valeur du tableau ${operators.value.length}');
      } else {

        operators.clear();
        hasError.value = true;
        errorMessage.value = 'Erreur lors du chargement des opérateurs';

      }
    } catch (e) {
      operators.clear();
      hasError.value = true;
      errorMessage.value = 'Erreur réseau: Veuillez vous connecté';
    } finally {
      isLoading.value = false;
    }
  }
}
