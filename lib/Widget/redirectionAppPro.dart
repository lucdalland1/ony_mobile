import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:onyfast/Widget/dialog.dart';

void redirection() async {
  await Get.dialog(
    AppDialog(
      title: "Impossible",
      body: "Ce compte est professionnel, la connexion n’est pas possible ici. Si c’est bien le vôtre, cliquez sur « Confirmer » pour être redirigé vers l’application pro. ",
      actions: [
        AppDialogAction(
          label: "Annuler",
          onPressed: () => Get.back(),
        ),
        AppDialogAction(
          label: "Confirmer",
          isDestructive: true,
          onPressed: () async {
            Get.back();

            final uri = Uri.parse('https://onyfast.com/qr_pro.html');
            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
              Get.snackbar(
                'Erreur',
                'Impossible d’ouvrir la redirection pro pour le moment.',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
        ),
      ],
    ),
  );
}
