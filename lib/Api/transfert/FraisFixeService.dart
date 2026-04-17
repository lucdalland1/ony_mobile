import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/model/transfert/frais_fixe_model.dart';

class FraisFixeService {
  static Future<FraisFixeModel?> fetchFraisFixe() async {
    final box = GetStorage();
    final token = box.read('token');

    final dio = Dio();
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await dio.request(
        '${ApiEnvironmentController.to.baseUrl}/transfer/frais/fixe',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return FraisFixeModel.fromJson(response.data['data']);
      } else {
        print('Erreur: ${response.statusMessage}');
      }
    } catch (e) {
      print('Exception: $e');
    }

    return null;
  }
}
