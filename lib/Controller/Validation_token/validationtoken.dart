import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Services/push_notification_service.dart';
import 'package:onyfast/View/home.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/utils/testInternet.dart';

class ValidationTokenController extends GetxController {
  static ValidationTokenController get to => Get.find();
  final GetStorage storage = GetStorage();

  final Dio _dio = Dio();

  bool? _isChecking;
  Object isCheckingToken() => _isChecking ?? Null;

  Future<String?>? getDeviceIMEI() async {
    var imei = await FlutterDeviceImei.instance.getIMEI();

    // print("  ✅  ✅  ✅  ✅  ✅  ✅   Device IMEI/Identifier: $imei");

    return imei;
  }
  Future<String> getPublicIP() async {
  final response = await http.get(Uri.parse('https://api.ipify.org'));
  return response.body;
}
  /// Vérification du token côté backend
  Future<void> validateToken() async {
    bool isConnected = await hasInternetConnection();

    if (SecureTokenController.to.token.value == null) return;

    print('\x1B[2J\x1B[0;0H');

    if (isConnected) {
      print('✅ ✅  Connexion Internet disponible');
    } else {
      _isChecking = null;
      return;
    }

    try {
      final response = await _dio.get(
        '${ApiEnvironmentController.to.baseUrl}/user',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${SecureTokenController.to.token.value}',
          },
        ),
      );

      print(' 🔐🔐🔐🔐🔐🔐🔐🔐🔐🔐🔐🔐voila ${response.data}');

      if (response.statusCode == 200) {
        _isChecking = true;
        print(' 🔐🔐🔐🔐🔐🔐🔐🔐🔐🔐🔐🔐Token valide');
      } else {
        _isChecking = false;
        print(' 🔐🔐🔐🔐🔐🔐🔐🔐🔐🔐🔐🔐Token invalide');
      }
      // Optionnel : backend peut renvoyer une info utilisateur à jour
      // if (response.statusCode ==401) {
      //   await _forceLogout();
      // }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        SnackBarService.error(
          "⚠️ Votre session a expiré ! "
          "Pour des raisons de sécurité, vous devez vous reconnecter afin de continuer à utiliser l'application. Toutes les actions en cours non sauvegardées seront perdues.",
        );

        await _forceLogout();
        _isChecking = false;
        print("📦📦📦📦📦📦📦📦📦📦📦📦📦📦📦 status false ${e.toString()}");
      } else {
        _isChecking = false;
        print(
            "📦📦📦📦📦📦📦📦📦📦📦📦📦📦📦 Impossible de contacter le serveur ${e.toString()}");
      }
    } finally {}
  }

  /// Déconnexion forcée (utilisée partout)
  Future<void> _forceLogout() async {
    await SecureTokenController.to.clearSecureStorage();
    await storage.erase();

    await PushNotificationService.clearAllNotifications();
    Get.offAll(Home());
  }
}
