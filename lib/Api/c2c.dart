import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

class C2CController extends GetxController {
  var message = ''.obs;
  var isLoading = false.obs;
  final GetStorage _storage = GetStorage();
  Future<void> c2CTransaction(
      String fromTelephone, String toTelephone, String montant) async {
    isLoading.value = true;
    try {
      var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
            var ip=await ValidationTokenController.to.getPublicIP();

      final token = _storage.read('token');
      final response = await http.post(
        Uri.parse('${ApiEnvironmentController.to.baseUrl}/c2c'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "token": token,
          "type_transaction_id": 3,
          "from_telephone": fromTelephone,
          "to_telephone": toTelephone,
          "montant": montant,
          "device":deviceskey,
          'ip':ip
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        message.value = data['message'] ?? 'Transfert réussi';
      } else {
        final errorData = jsonDecode(response.body);
        message.value = errorData['message'] ?? 'Solde Insuffisant';
      }
    } catch (e) {
      message.value = 'Erreur de connexion';
    } finally {
      isLoading.value = false;
    }
  }
}
