import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:onyfast/Api/carte_api/carte_physique_api.dart';
import 'package:onyfast/Color/app_color_model.dart';

class EmmettreCartePhysiqueController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final response = Rxn<EmmettreCartePhysiqueResponse>();
  final statusEnvois=false.obs;
  Future<void> emmettreCartePhysique({
    required String phone,
    required String cardID,
    required String email,
    required String cardLast4Digits,
    required String cardExpireAt,
    required String firstName,
    required String lastName,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    statusEnvois.value=false;
    print("=== Début appel API: emmettreCartePhysique ===");
    print("Paramètres envoyés :");
    print("phone: $phone");
    print("cardID: $cardID");
    print("email: $email");
    print("cardLast4Digits: $cardLast4Digits");
    print("cardExpireAt: $cardExpireAt");
    print("firstName: $firstName");
    print("lastName: $lastName");

    try {
      var headers = {'Accept': 'application/json'};
      var dio = Dio();




      var url =
          "https://api.dev.onyfastbank.com/v1/admin-users.php?method=add_card"
          "&phone=$phone"
          "&cardID=$cardID"
          "&email=$email"
          "&cardLast4Digits=$cardLast4Digits"
          "&cardExpireAt=$cardExpireAt"
          "&firstName=$firstName"
          "&lastName=$lastName";

      print("URL générée : $url");
      print("Appel en cours...");

      final res = await dio.get(url, options: Options(headers: headers));

      print("Réponse reçue (status: ${res.statusCode})");

      if (res.statusCode == 200) {
        response.value = EmmettreCartePhysiqueResponse.fromJson(res.data);
        print("Réponse JSON parsée avec succès ✅");
        print("Réponse brute : ${json.encode(res.data)}");
          var body=res.data;
          if(body['status']['code']==404){
            statusEnvois.value=true;
          
           
          }
              
          
      } else {
        errorMessage.value = res.statusMessage ?? "Erreur inconnue";
        print("Erreur côté serveur ❌ : ${errorMessage.value}");
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print("Exception capturée ❌ : $e");
    } finally {
      isLoading.value = false;
      print("=== Fin appel API: emmettreCartePhysique ===");
    }
  }
}
