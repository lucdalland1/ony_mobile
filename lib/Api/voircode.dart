import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/OnypayController/onypayController.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Widget/dialog.dart';

class VoirPasswService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiEnvironmentController.to.baseUrl,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  /// Vérifie le mot de passe et affiche des alertes en cas d'erreur
  Future<Map<String, dynamic>> verify({
    required String telephone,
    required String password,
  }) async {
    try {
            var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
 var ip=await ValidationTokenController.to.getPublicIP();
      final response = await _dio.request(
        '/verify_password',
        options: Options(
          method: 'POST',
          validateStatus: (status) => status != null && status < 500,
        ),
        data: jsonEncode({
          "telephone": telephone,
          "password": password,
          'device':deviceskey,
          "ip":ip
        }),
      );

      print('voila les erreurs ');
      print(response.data);
      

      if (response.statusCode == 200) {
        await OnyPayController.to.loginAndLogoutAutomatique(telephone, password);
        
     //   Get.back();
        return {
          'success': true,
          'data': response.data,
        };
      } else {

        Get.dialog(
            AppDialog(
    title: "Erreur",
    body: response.data['message'] ?? "Mot de passe incorrect.",
    headerColor: Colors.red,
    actions: [
      AppDialogAction(
        label: "ok",
        isDestructive: true,
        onPressed: () => Get.back(),
      ),
    
    ],
  ),
        );

        // _showAppleAlert(
        //     "Erreur", response.data['message'] ?? "Mot de passe incorrect.");
        return {
          'success': false,
          'message': response.data['message'] ?? "Mot de passe incorrect.",
        };
      }
    } catch (e) {
      // _showAppleAlert("Erreur réseau", e.toString());
      return {
        'success': false,
        'message': "Erreur réseau : $e",
      };
    }
  }

  /// Fonction pour afficher une alerte iOS (Cupertino)
 
}
