import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Api/piecesjustificatif_Api/voirjustificatifdomicileApi.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

class ListeJustificatifController extends GetxController {
  var chargementAccueil = false.obs;
  var documents = <dynamic>[].obs;
  var isLoading = false.obs;
  var total = 0.obs;
  var isAdmin = false.obs;
  var isVerified = false.obs;

  Future<void> chargerJustificatifs() async {
    final Dio dio = Dio();
    final token = GetStorage().read('token');

    try {
      isLoading.value = true;
      final response = await dio.get(
        '${ApiEnvironmentController.to.baseUrl}/justificatif-domicile',
        options: Options(headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print("nous y sommes ");
        total.value = response.data['total'];
        isAdmin.value = response.data['data'][0]['verification_admin'] as bool;
        isVerified.value = response.data['data'][0]['status'] as bool;
        print("voila l'admin $isAdmin");
        print("isVerified $isVerified");
      }
    } catch (e) {
      print('impossible de recuperer les justificatifs $e');
    } finally {
      isLoading.value = false;
    }
  }
}
