// lib/controller/user_me_controller.dart
import 'package:get/get.dart';
import 'package:onyfast/Api/info_user/userservice.dart';

class UserMeController extends GetxController {
  final isLoading = false.obs;
  final user = Rxn<UserProfile>();
  final errorMessage = ''.obs;

  /// Charge le profil depuis l'API
  Future<void> loadMe({bool silent = false}) async {
    if (silent == false) isLoading.value = true;
    errorMessage.value = '';

    print("🔄 [UserMeController] Début du chargement du profil utilisateur...");

    final resp = await UserService.fetchMe();

    print(
        "📡 [UserMeController] Réponse reçue : success=${resp.success}, message=${resp.message}");

    if (resp.success && resp.data != null) {
      print(
          "✅ [UserMeController] Données utilisateur : ${resp.data!.toJson()}");
      user.value = resp.data;
      print('voici le user ${user.value?.prenom}');
    } else {
      print("❌ [UserMeController] Erreur : ${resp.message}");
      errorMessage.value = resp.message.isNotEmpty
          ? resp.message
          : 'Impossible de charger le profil';
      user.value = null;
    }

    if (!silent) isLoading.value = false;

    print("🏁 [UserMeController] Fin du chargement du profil");
  }

  /// Rafraîchir (idéal pour pull-to-refresh)
  Future<void> refreshMe() {
    print("🔄 [UserMeController] Rafraîchissement du profil...");
    return loadMe(silent: true);
  }

  void clear() {
    print("🧹 [UserMeController] Réinitialisation des données utilisateur");
    user.value = null;
    errorMessage.value = '';
    isLoading.value = false;
  }
}
