import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/View/Transfert/model/pays_model_api.dart';
import 'package:onyfast/Widget/alerte.dart';

class PaysService {
  final Dio dio = Dio();

  Future<List<Pays>> fetchPays() async {
    final storage = GetStorage();
    final token = storage.read('token');

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await dio.request(
        '${ApiEnvironmentController.to.baseUrl}/transfer/countries',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.data is List) {
        final data = response.data as List;
        return data.map((e) => Pays.fromJson(e)).toList();
      } else {
        
        return [];
      }
    } on TimeoutException {
      SnackBarService.networkError();
      return [];
    } catch (e) {
      print("Erreur: $e");
      // Get.snackbar("Erreur", "Erreur récupération des pays : $e");
      return [];
    }
  }
}
