import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:get_storage/get_storage.dart';

class UpdateController extends GetxController {
  final Dio dio = Dio();
  var isLoading = false.obs;
  var responseData = {}.obs;

  Future<void> sendUpdate({
    String? buildProjet,
    String? updateNotes,
    bool? isAutomatique,
  }) async {
    isLoading.value = true;


    final storage = GetStorage();
  final token = storage.read('token');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final data = json.encode({
      if (buildProjet != null) "build_projet": buildProjet,
      if (updateNotes != null) "update_notes": updateNotes,
      if (isAutomatique != null) "is_automatique": isAutomatique,
    });

    try {
      final response = await dio.request(
        'http://192.168.100.166:8000/api/mise_a_jour',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );
      print('📡📡📡📡 Voila la reponse $response');
      if (response.statusCode == 200) {
        responseData.value = response.data;
        //Get.snackbar('Succès', 'Mise à jour enregistrée avec succès');
      } else {
       // Get.snackbar('Erreur', response.statusMessage ?? 'Erreur inconnue');
      }
    } catch (e) {
      //Get.snackbar('Erreur', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
