import 'package:get/get_core/src/get_main.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/onypay/loginOnypay.dart';
import 'package:onyfast/Api/user_inscription.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/OnypayController/onypayController.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Services/push_notification_service.dart';
import 'package:onyfast/utils/logout.dart';

Future<void> logoutUser() async {
  final AuthController deconnexion = Get.find();
  final GetStorage storage = GetStorage();

  try {
    final GetStorage storage = GetStorage();
    // Ferme le modal dès que possible pour libérer l'UI

    await logout().timeout(const Duration(seconds: 10));
    deconnexion.logout(); // si async, sinon ok
    await storage.erase();
    await PushNotificationService.clearAllNotifications();
    await OnyPayController.to.logout();
  } catch (e) {
    print(' 🧹🧹🧹🧹 errreur supprimession ${e.toString()} ');
  }
  await SecureTokenController.to.clearSecureStorage();
  await ApiEnvironmentController.to
      .setIsProd(ApiEnvironmentController.to.isProd.value);
}
