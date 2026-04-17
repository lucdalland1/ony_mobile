import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Widget/alerte.dart';

class RechargeDechargeService {
  static const String _endpointDeposit = '/card/deposit';
  static const String _endpointDecharge = '/card/withdraw';

  static Future<Map<String, dynamic>?> rechargeCarte({
    required String cardNumber,
    required String last4Digits,
    required String amount,
    required String token,
  }) async {
    final url = Uri.parse('${ApiEnvironmentController.to.baseUrl}$_endpointDeposit');

    // Supprimer les espaces
    String cleaned = last4Digits.replaceAll(' ', '');

    // Garder les 4 derniers chiffres
    String last4 = cleaned.substring(cleaned.length - 4);
     var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
      var ip=await ValidationTokenController.to.getPublicIP();
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'card_number': cardNumber,
          'last4Digits': last4,
          'amount': int.tryParse(amount) ?? 0,
          'device':deviceskey,
          'ip':ip
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is Map<String, dynamic> ? data : null;
      } else {
        print('Erreur HTTP: ${response.statusCode}');
        print('Réponse: ${response.body}');
                Get.back();
SnackBarService.error(json.decode(response.body)['message']);
        return null;
      }
    } catch (e) {
      print('Exception lors de la recharge: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> dechargeCarte({
    required String cardNumber,
    required String last4Digits,
    required String amount,
    required String token,
  }) async {
    final url = Uri.parse(
        '${ApiEnvironmentController.to.baseUrl}$_endpointDecharge'); // vérifie que c’est bien l’URL de withdraw

    try {
      // Sécuriser last4Digits (toujours 4 chiffres)
      String cleaned = last4Digits.replaceAll(RegExp(r'\s+'), '');
      String last4 =
          cleaned.length >= 4 ? cleaned.substring(cleaned.length - 4) : cleaned;
       var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
      // Construire le body JSON
      final body = jsonEncode({
        'card_number': cardNumber,
        'last4Digits': last4,
        'amount': double.tryParse(amount) ?? 0.0,
        'device':deviceskey
      });

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200  || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        print('$data');
        return data is Map<String, dynamic> ? data : null;
        Get.back();
        SnackBarService.success(data['message']);
      } else {
        print('Erreur HTTP: ${response.statusCode}');
        print('Réponse: ${response.body}');
          final data = jsonDecode(response.body);

          SnackBarService.error(title: data['error']
            ,data['message']);
        return {
          'success': false,
          'message': 'Erreur serveur (${response.statusCode})',
          'details': response.body,
        };
      }
    } catch (e) {
      print('Exception lors du retrait: $e');
      return {
        'success': false,
        'message': 'Erreur inattendue',
        'details': e.toString(),
      };
    }
  }
}
