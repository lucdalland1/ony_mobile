import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:onyfast/Api/user_inscription.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Widget/alerte.dart';
class TransactionService {
  final String apiUrl = "${ApiEnvironmentController.to.baseUrl}/c2c";
  //final String token = "QEPeqzn2QM9V63y7Tk7qthDkWFyN8aKM0kLD9WKge3c141eb";
  final AuthController _authController = Get.find();
  final GetStorage storage = GetStorage();
  final AuthController connexion = Get.find();

  Future<void> makeTransaction({
    required String fromTelephone,
    required String toTelephone,
    required String amount,
    required BuildContext context,
    required String to_card_id
  }) async {
    // Vérifier si les champs sont vides ou incorrects
    if (fromTelephone.isEmpty || toTelephone.isEmpty || amount.isEmpty) {
      SnackBarService.error("Veuillez remplir tous les champs.", title: "Erreur");
      return;
    }

    // Vérification de la conversion des valeurs
    int? fromTel = int.tryParse(fromTelephone);
    int? toTel = int.tryParse(toTelephone);
    int? montant = int.tryParse(amount);
    print("numéro du recepteur : $toTelephone");
    print("numéro de l'xpediteur : $fromTelephone");
    print("montant à envoyer : $amount");

    if (fromTel == null || toTel == null || montant == null || montant <= 0) {
      SnackBarService.error("Veuillez entrer des valeurs valides.", title: "Erreur");
      return;
    }

    try {
      final token = storage.read('token');
      if (token == null) {
        throw Exception('Session expirée, veuillez vous reconnecter');
      }
      var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
       var ip=await ValidationTokenController.to.getPublicIP();
       var card_id = ManageCardsController.to.currentCard?.cardID ?? '';
       var donnee={
          // 'token': token,
          'token': token,
          "type_transaction_id": 7,
          "from_telephone": fromTel,
          "to_telephone": toTel,
          "montant": montant,
          "device":deviceskey,
          'card_id':card_id,
          'to_card_id':to_card_id,
          "ip":ip
        };
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(donnee),
      );
      print("detail de la transaction :${response.body}");
      print('🔐 🔐  $card_id');
      print('donnee : ${donnee.toString()}');

      if (response.statusCode == 201) {
        print("les data de la transaction :${response.body}");
        print(" transaction éffectuer avec succès : ${response.statusCode}");

        // Message de succès avec Get.snackbar


        SnackBarService.success("Vous avez envoyé $montant FCFA à $toTelephone", title: "Transfert réussi");

       
      } else {
        var data = jsonDecode(response.body);
        var erreur=data["error"];
        if(erreur!=null){
           SnackBarService.error(erreur);
           return ;
        }
        // Message d'erreur avec Get.snackbar
        SnackBarService.error("Erreur lors de l\'envoi à $toTelephone  vérifier votre solde...voici votre solde $montant", title: "Échec du transfert");
    
      }
    } catch (e) {
      // Gestion des exceptions (erreurs réseau, JSON mal formé, etc.)
      print("Erreur lors de la transaction: $e");
      SnackBarService.networkError();
    }
  }

  // Fonction pour afficher un message Snackbar
}