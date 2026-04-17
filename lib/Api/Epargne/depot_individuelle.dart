import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/const.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Widget/alerte.dart';

class DepotController extends GetxController {
  var isLoading = false.obs;

  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10), // Timeout de connexion
      receiveTimeout: const Duration(seconds: 10), // Timeout de réponse
    ),
  );

  Future<void> faireDepot({
    required int objetId,
    required double montant,
  }) async {
    isLoading.value = true;
    final storage = GetStorage();
    final token = storage.read<String>('token');

    if (token == null) {
      SnackBarService.warning(
        'Token non trouvé dans le stockage local',
      );
      isLoading.value = false;
      return;
    }

    var headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
   var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
    var ip=await ValidationTokenController.to.getPublicIP();
    var data = jsonEncode({
      'objet_id': objetId,
      'montant': montant,
      'device':deviceskey,
      'ip':ip
    });

    try {
      var response = await dio.request(
        '${ApiEnvironmentController.to.baseUrl}/epargnes/individuelle/depots',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 201) {
        final responseData = response.data;

        if (responseData is String) {
          // Cas : réponse texte brute
          SnackBarService.success('Succès');
        } else if (responseData is Map && responseData.containsKey('message')) {
          // Cas : message dans la réponse
          SnackBarService.success( responseData['message'].toString());
        } else if (responseData is Map && responseData.containsKey('data')) {
          // Cas : objet data
          final data = responseData['data'];
          final montant = data['montant'] ?? 'N/A';
          SnackBarService.success('Montant déposé : $montant FCFA');
        } else {
          // Réponse inattendue
          SnackBarService.success( 'Dépôt effectué avec succès.');
        }

        print('📦 Réponse brute : $responseData');
      } else {
       
      }

    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        SnackBarService.networkError();
      } else if (e.response != null) {
        final status = e.response?.statusCode ?? 0;
        final message = e.response?.data['message'] ?? 'Une erreur est survenue.';

        // Get.snackbar(
        //   'Erreur $status',
        //   message.toString(),
        // );
      } else {
        // Get.snackbar(
        //   'Erreur réseau',
        //   e.message ?? 'Impossible de contacter le serveur',
        // );
      }

    } catch (e) {
      // SnackBarService.warning(
      //   'Erreur inconnue',
      // );
    } finally {
      isLoading.value = false;
    }
  }
}
