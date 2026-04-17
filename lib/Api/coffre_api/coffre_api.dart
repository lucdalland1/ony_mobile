import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart' hide FormData;
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';
import 'package:onyfast/Controller/CoffreController.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/View/Coffre/model/coffreModel.dart';
import 'package:onyfast/Widget/alerte.dart';

class CoffreService {
  final Dio dio = Dio();

 
Future<CoffreModel?> fetchCoffre() async {
  final storage = GetStorage();
  final token = SecureTokenController.to.token.value;
  print('🎫 Token: $token');

  try {
    final response = await dio
        .get(
          '${ApiEnvironmentController.to.baseUrl}/coffres',
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ),
        )
        .timeout(const Duration(seconds: 10));

    print('📦 Réponse reçue: ${response.data}');

    if (response.statusCode == 200 &&
        response.data['data']?['coffre'] != null) {
      final coffreJson = response.data['data']['coffre'];
      print('✅ Données du coffre récupérées : $coffreJson');
      return CoffreModel.fromJson(coffreJson);
    } else {
      SnackBarService.warning("Veuillez vérifier votre connexion",
         );
    }
  } on TimeoutException {
    SnackBarService.warning("Veuillez vérifier votre connexion");
        //  );
  } catch (e) {
    
    print("❌ Erreur : Impossible de récupérer le coffre ");
    print('🔍 Détail de l’erreur : ${e.toString()}');
    // SnackBarService.warning("Veuillez vérifier votre connexion",
        // );
  }

  return null;
}
Future<void> ajouterObjectif({
  required int coffreId,
  required String nom,
  required String montantCible,
  required String dateLimite,
}) async {
  final storage = GetStorage();
  final token = storage.read('token');

  final headers = {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
 var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
  var ip=await ValidationTokenController.to.getPublicIP();
  final formData = FormData.fromMap({
    'nom': nom,
    'montant_cible': montantCible,
    'date_limite': dateLimite,
    'device':deviceskey,
    'ip':ip
  });
           

  try {
    final response = await dio.post(
      '${ApiEnvironmentController.to.baseUrl}/coffres/$coffreId/objectifs',
      data: formData,
      options: Options(headers: headers),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.back();
      SnackBarService.success("Objectif ajouté avec succès !");
      print("✅ ${response.data}");
    } else {
      print("❌ Status Code: ${response.statusCode}");
      Get.snackbar("Erreur", "Ajout échoué : ${response.data}");
    }
  } on DioException catch (e) {
    print("❌ DioException : ${e.response?.data}");
    SnackBarService.info(e.response?.data['message'] ?? 'Veuillez vous abonnez d\'abord');
  } catch (e) {
    print("❌ Erreur inconnue : $e");
    SnackBarService.networkError();
  }
}


Future<void> modifierObjectif({
  required int objectifId,
  required String nom,
  required int montantCible,
  required String dateLimite,
}) async {
  print("🔄 Début de la modification de l’objectif...");
  print("📦 Données envoyées :");
  print("- ID objectif : $objectifId");
  print("- Nom : $nom");
  print("- Montant cible : $montantCible");
  print("- Date limite : $dateLimite");

  final storage = GetStorage();
  final token = storage.read('token');

  if (token == null) {
    print("❌ Token manquant dans GetStorage !");
    SnackBarService.info("Token non trouvé. Veuillez vous reconnecter.");
    return;
  }

  final headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
   var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
    var ip=await ValidationTokenController.to.getPublicIP();
  final data = json.encode({
    "nom": nom,
    "montant_cible": montantCible,
    "date_limite": dateLimite,
    "device":deviceskey,
    "ip":ip
  });

  print("📤 Envoi de la requête PUT à l’API...");
  try {
    final dio = Dio();
    final response = await dio.put(
      '${ApiEnvironmentController.to.baseUrl}/coffres/update/objectifs/$objectifId',
      options: Options(headers: headers),
      data: data,
    );

    print("📬 Réponse reçue (status : ${response.statusCode})");

    if (response.statusCode == 200) {
      print("✅ Objectif modifié avec succès !");
      print("🧾 Données réponse : ${response.data}");
      Get.back();
      SnackBarService.success("Objectif modifié avec succès !");
    } else {
      print("❌ Erreur API : Status ${response.statusCode}");
      print("🧾 Données erreur : ${response.data}");
      Get.snackbar("Erreur", "Échec de la modification : ${response.data}");
    }
  } on DioException catch (e) {
    print("❌ DioException levée !");
    print("🧾 Réponse erreur : ${e.response?.data}");
    // SnackBarService.info(e.response?.data['message'] ?? "Erreur lors de la modification");
  } catch (e) {
    print("❌ Erreur inattendue : $e");
    SnackBarService.networkError();
  }
}

Future<void> supprimerObjectif({required int objectifId}) async {
    final storage = GetStorage();
    final token = storage.read('token');

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await dio.request(
        '${ApiEnvironmentController.to.baseUrl}/coffres/objectifs/$objectifId/delete',
        options: Options(
          method: 'DELETE',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        print(json.encode(response.data));
        SnackBarService.success(
          "Objectif supprimé avec succès !",
        );
      } else {
        print(response.statusMessage);
        SnackBarService.error(
          "Suppression échouée : ${response.statusMessage ?? 'Erreur inconnue'}",
          
        );
      }
    } catch (e) {
      if (e is DioError) {
        SnackBarService.warning("Erreur Probleme technique");
        
        // Get.snackbar(
        //   "Erreur Dio",
        //   e.response?.data['message'] ?? 'Erreur inconnue',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.redAccent,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 3),
        // );
        print("DioError : ${e.response?.data}");
      } else {
       
        print("Erreur inconnue : $e");
      }
    }
  }

////// Ajouter Api
  ///
  ///
  Future<void> ajouterMontantObjectif({
    required int objectifId,
    required String montant,
  }) async {
    final storage = GetStorage();
    final token = storage.read('token');

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
 var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
 var card_id = ManageCardsController.to.currentCard?.cardID ?? '';
  var ip=await ValidationTokenController.to.getPublicIP();
    final formData = FormData.fromMap({
      'montant': montant,
      "device":deviceskey,
      'ip':ip,
      'card_id':card_id
    });

    try {
      final response = await dio.post(
        '${ApiEnvironmentController.to.baseUrl}/coffres/objectifs/$objectifId/ajouter',
        data: formData,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarService.success(
          "Montant ajouté à l'objectif avec succès !",
        );
        print("✅ ${response.data}");
      } else {
        print("Erreur status code: ${response.statusCode}");
        SnackBarService.warning(
          "Échec : Probleme technique",
        );
      }
    } catch (e) {
      if (e is DioError) {
        print("DioError: ${e.response?.data}");
        SnackBarService.warning(
          e.response?.data['message'] ?? 'Erreur inconnue',
        );
      } else {
        print("Erreur inconnue: $e");
        SnackBarService.networkError();
      }
    }
  }

  Future<void> retraitC2W({required int montant}) async {
    final storage = GetStorage();
    final token = storage.read('token');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
     var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
      var ip=await ValidationTokenController.to.getPublicIP();
             var card_id = ManageCardsController.to.currentCard?.cardID ?? '';

    final data = jsonEncode({
      "montant": montant,
      "device":deviceskey,
      "card_id":card_id,
      'ip':ip
    });

    try {
      final response = await dio.request(
        '${ApiEnvironmentController.to.baseUrl}/transactions/retrait-C2W',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        SnackBarService.success(
          "Retrait effectué avec succès !",
          
        );
        print("✅ ${response.data}");
      } else {
        print("Erreur status code: ${response.statusCode}");
        SnackBarService.warning(     
          "Échec du retrait : ${response.statusMessage}",
        );
      }
      CoffreController.to.fetchCoffre();
    } catch (e) {
      if (e is DioError) {
        print("DioError: ${e.response?.data}");
        SnackBarService.warning(
          e.response?.data['message'] ?? 'Erreur inconnue',
        );
      } else {
        SnackBarService.networkError();
      }
    }
  }
}
