import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

class FcmTokenService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GetStorage storage = GetStorage();

  Future<void> sendTokenToServer() async {
    try {
      final bearerToken = storage.read('token');
      final userInfo = storage.read('userInfo') ?? {};
      String apiUrl = "${ApiEnvironmentController.to.baseUrl}/fcm-token";

      if (bearerToken == null) {
        throw Exception('Session expirée, veuillez vous reconnecter');
      }

      String? fmcToken = await _messaging.getToken();

      print('FCM Token: $fmcToken');
      print(userInfo['telephone']);

      print(bearerToken);
      var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
       var ip=await ValidationTokenController.to.getPublicIP();
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'telephone': userInfo['telephone'],
          'fmc_token': fmcToken,
          "device":deviceskey,
          "ip":ip
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Token FCM envoyé avec succès.');
      } else {
        print(
          '❌ Erreur lors de l\'envoi : ${response.statusCode} => ${response.body}',
        );
      }
    } catch (e) {
      print('❗ Exception lors de l\'envoi du token : $e');
    }
  }

  void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      print('🔁 Nouveau token FCM : $newToken');
      sendTokenToServer();
    });
  }
}
