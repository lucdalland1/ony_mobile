import 'package:get/get.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

void checkVersion() async {


  // Récupère dynamiquement l'ID de l'app
  final info = await PackageInfo.fromPlatform();

  final newVersionPlus = NewVersionPlus(
    iOSId: info.packageName,
    androidId: info.packageName,
  );

  // Récupère le status de version depuis le store
  final status = await newVersionPlus.getVersionStatus();

  if (status != null && status.canUpdate) {
    // Affiche le dialogue de mise à jour personnalisé
    newVersionPlus.showUpdateDialog(
      context: Get.context!,
      versionStatus: status, // ← ici c’est l’instance récupérée
      dialogTitle: 'Mise à jour disponible',
      dialogText:
          'Une nouvelle version (${status.storeVersion}) de l’application est disponible. Veuillez mettre à jour pour continuer à utiliser l’app.',
      updateButtonText: 'Mettre à jour',
      dismissButtonText: 'Plus tard',
       allowDismissal: false, // ❌ empêche la fermeture, pas de bouton "Plus tard"
      // dismissAction: () {
      //   // action si l’utilisateur ferme le dialogue (optionnel)
      //   print('L’utilisateur a ignoré la mise à jour.');
      // },
    );
  }
}
