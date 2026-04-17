import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/model/pays_onyfast/contryonyfastModel.dart';

class ContryOnyfastService {
  /// GET /api/contry_onyfasts (ou /api/contry_onyfast selon ta route)
  static Future<List<ContryOnyfast>> fetchAll({Map<String, dynamic>? query}) async {
    final box   = GetStorage();
    final token = box.read('token');

    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final dio = Dio();
      final resp = await dio.get(
        '${ApiEnvironmentController.to.baseUrl}/contry_onyfast', // ajuste le chemin si c'est /contry_onyfasts
        options: Options(headers: headers),
        queryParameters: query, // pour GET, pas de FormData
      );

      if (resp.statusCode == 200 && resp.data['success'] == true) {
        final List data = (resp.data['data'] as List?) ?? [];
        // print('Taille: ${data.length}');
        return data.map((e) => ContryOnyfast.fromJson(e)).toList();
      } else {
        final msg = resp.data['message']?.toString() ?? 'Erreur lors de la récupération.';
        throw Exception(msg);
      }
    } on DioException catch (e) {
      final apiMsg = e.response?.data is Map ? e.response?.data['message']?.toString() : null;
      final fallback = e.message?.toString() ?? 'Erreur réseau';
      final msg = apiMsg ?? fallback;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Get.showSnackbar(GetSnackBar(
        //   titleText: const Text('Erreur de chargement', style: TextStyle(fontWeight: FontWeight.bold)),
        //   messageText: Text(msg),
        //   duration: const Duration(seconds: 3),
        // ));
      });
      rethrow;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.showSnackbar(GetSnackBar(
          titleText: const Text('Erreur'),
          messageText: Text(e.toString()),
          duration: const Duration(seconds: 3),
        ));
      });
      rethrow;
    }
  }
}
