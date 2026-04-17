import 'package:get/get.dart';
import 'package:onyfast/Api/pays_service/pays_service.dart';
import 'package:onyfast/View/Transfert/model/pays_model_api.dart';

class PaysController extends GetxController {
  var isLoading = false.obs;
  final countries = <Pays>[].obs;
  var selectedCountry = Rxn<Pays>();

  final PaysService _service = PaysService();

  @override
  void onInit() {
    fetchPays();
    super.onInit();
  }

  Future<void> fetchPays() async {
    isLoading.value = true;
    try {
      final result = await _service.fetchPays();
      countries.assignAll(result);
    } catch (e) {
      // Handle error
      print('Error fetching pays: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectCountry(Pays country) {
    selectedCountry.value = country;
  }
}
