import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/View/Transfert/model/operator_model.dart';
import 'package:onyfast/Widget/alerte.dart';
import '../../Api/const.dart';

class OperatorService {
  final Dio dio = Dio();

  Future<OperatorModel?> fetchOperators(int countryId) async {
    try {
      final token = GetStorage().read("token");

      final response = await dio.get(
        "${ApiEnvironmentController.to.baseUrl}/transfer/countries/$countryId/operators",
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return OperatorModel.fromJson(response.data);
      } else {
        // SnackBarService.war
        // Get.snackbar("Erreur", "Échec de récupération des opérateurs");
        return null;
      }
    } catch (e) {
      SnackBarService.info("Impossible de récupération des opérateurs");
      return null;
    }
  }
}
