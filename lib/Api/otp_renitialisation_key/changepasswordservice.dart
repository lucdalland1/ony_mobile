// lib/data/resources/verify_otp_resource.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData;                 // 🔔 GetX (snackbar)
import 'package:flutter/material.dart';        // 🔔 Colors/Icon
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/View/Connecter/View/connect.dart';
import 'package:onyfast/View/otp_mail.dart';
import 'package:onyfast/Widget/alerte.dart';

class VerifyOtpResource {
  final Dio _dio = Dio();
  var controler=Get.find<VerifOtpCode>();

  Future<Map<String, dynamic>> verifyOtp(String otp) async {
    final url = '${ApiEnvironmentController.to.baseUrl}/verify-otp';

    final storage = GetStorage();
    final userInfo = storage.read('userInfo');
    String telephone = userInfo['telephone'];

    try {
      // 🔔 info: début de vérification
     
     var token=await SecureTokenController.to.token.value;
     print('voila sont token $token ✅✅');

      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
        
        };
       var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
        var ip=await ValidationTokenController.to.getPublicIP();
      final form = FormData.fromMap({'telephone': telephone, 'otp': otp,
      "device":deviceskey??"",
      "ip":ip
      });

      final resp = await _dio.request(
        url,
        data: form,
        options: Options(method: 'POST', headers: headers),
      );

      // Réponses attendues: 200 (OK) ou 422/404/429 (erreurs métier)
      var data = resp.data;

      if (data is Map<String, dynamic>) {
        // 🔔 succès ou erreur métier côté backend
        if (resp.statusCode==200) {
           
          SnackBarService.success(
            data['message']?.toString() ?? "OTP validé.",
          );
          data={
            'success': true,
            "message":data['message']??''
          };
        } else {
               data={
            'success': false,
            "message":data['message']??''
          };
          controler.error.value=data['message'] ?? 'Échec de la vérification.';
          SnackBarService.warning(
            title: "${data['message'] ?? 'Échec de la vérification.'}",
            "${data['retry_after'] != null ? "\nRéessayer à : ${data['retry_after']}" : ""}",
            
          );
        }
        
        return data;
      } else if (data is String) {
        try {
          final parsed = json.decode(data) as Map<String, dynamic>;
          // 🔔 alerte selon success
          if (parsed['success'] == true) {
            SnackBarService.success(
              parsed['message']?.toString() ?? "OTP validé.",
            );
controler.verify.value=true;
          } else {
            controler.error.value=parsed['message'] ?? 'Échec de la vérification.';
            SnackBarService.warning(
              title:"${parsed['message'] ?? 'Échec de la vérification.'}",
              "${parsed['retry_after'] != null ? "\nRéessayer à : ${parsed['retry_after']}" : ""}",
             
            );
          }
          return parsed;
        } catch (_) {
          // 🔔 réponse non JSON
          controler.error.value="Réponse inattendue du serveur.";
         SnackBarService.networkError();
          return {
            'success': false,
            'message': 'Réponse inattendue du serveur.',
            'raw': data,
            'status': resp.statusCode
          };
        }
      } else {
        controler.error.value='Réponse inattendue du serveur.';
        // 🔔 cas non JSON
      SnackBarService.networkError();
        return {
          'success': false,
          'message': 'Réponse inattendue du serveur.',
          'status': resp.statusCode
        };
      }
    } on DioException catch (e) {
      // 🔔 erreur réseau côté Dio
      final res = e.response;
      final data = res?.data;
      
      if (data is Map<String, dynamic>) {
        controler.error.value='Erreur réseau (${data['message']?.toString()??'N/A'})}';
        SnackBarService.warning(
          "${data['message']?.toString() ?? 'Erreur réseau'}"
          "${data['retry_after'] != null ? "\nRéessayer à : ${data['retry_after']}" : ""}",
        
        );
        return {
          'success': data['success'] ?? false,
          'message': data['message']?.toString() ?? 'Erreur réseau',
          if (data.containsKey('retry_after')) 'retry_after': data['retry_after'],
          if (data.containsKey('token')) 'token': data['token'],
          if (data.containsKey('user')) 'user': data['user'],
          'status': res?.statusCode
        };
      }

    SnackBarService.networkError();

      return {
        'success': false,
        'message':
            'Erreur réseau (${res?.statusCode ?? 'N/A'})${e.message != null ? ' - ${e.message}' : ''}',
        'status': res?.statusCode
      };
    } catch (e) {
      // 🔔 crash imprévu
    SnackBarService.networkError();

      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }
}
