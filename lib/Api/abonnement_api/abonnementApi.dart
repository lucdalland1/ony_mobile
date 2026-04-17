import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/model/abonnement/abonnementModel.dart';

class AbonnementService {
  static Future<List<Abonnement>> fetchAbonnements() async {
    final box = GetStorage();
    final token = box.read('token');

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      var dio = Dio();
      final response = await dio.get(
        "${ApiEnvironmentController.to.baseUrl}/abonnements/types",
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> data = response.data['data'];
        return data.map((e) => Abonnement.fromJson(e)).toList();
        print("voila la taille ${data.length}");
      } else {
        print("\n\n\nErreur lors de la récupération des abonnements.");
        print("voila le message ${response.data['message']}");
        throw Exception("Erreur lors de la récupération des abonnements.");
      }
    } catch (e) {
      print("\n\n\nErreur AbonnementService : $e");
      rethrow;
    }
  }
static Future<dynamic> souscrireAbonnement(String typeAbonnementId) async {
  final box = GetStorage();
  final token = box.read('token');

  final headers = {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
    // Ne force pas multipart ici, Dio le mettra pour FormData
  };
            var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
 var ip=await ValidationTokenController.to.getPublicIP();
  final data = FormData.fromMap({
    'type_abonnement_id': typeAbonnementId,
    'device':deviceskey,
    'ip':ip
  });

  try {
    final dio = Dio();
    final response = await dio.post(
      "${ApiEnvironmentController.to.baseUrl}/abonnements/souscrire",
      options: Options(headers: headers),
      data: data,
    );

    final ok = response.statusCode == 202 || response.data?['success'] == true;
    if (ok) {
      SnackBarService.success(
        response.data?['message']?.toString() ?? "Souscription réussie.",
      );
      return response.data;
    } else {
      final msg = response.data?['message']?.toString() ?? "Échec de la souscription.";
      SnackBarService.success(
        title: "Échec de la souscription",
         msg,
        
      );
      return response.data;
    }
  } on DioException catch (e) {
    final apiMsg = e.response?.data is Map
        ? (e.response?.data['message']?.toString())
        : null;
    final fallback = e.message?.toString() ?? "Erreur réseau";
    final msg = apiMsg ?? fallback;

    // Affiche après le 1er frame si nécessaire
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SnackBarService.info(
          title: "Échec de la souscription",
           msg,
      );
       
    });

    return false;
  } catch (e) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.showSnackbar(GetSnackBar(
        titleText: const Text("Erreur"),
        messageText: Text(e.toString()),
        duration: const Duration(seconds: 3),
      ));
    });
    return false;
  }
}

}
