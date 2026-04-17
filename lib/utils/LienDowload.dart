import 'dart:io';

import 'package:onyfast/Widget/alerte.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> LienDowload() async {
  
     if(Platform.isAndroid){
                      final Uri whatsappUrl = Uri.parse('https://play.google.com/store/apps/details?id=com.onyfast.app&pli=1');

  if (await canLaunchUrl(whatsappUrl)) {
    final bool launched = await launchUrl(
      whatsappUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      SnackBarService.warning('Impossible d\'ouvrir PlayStore.');
    }
  } else {
    SnackBarService.warning('PlayStore n\'est pas disponible.');
  }

                  }
                  else if(Platform.isIOS){
                     final Uri whatsappUrl = Uri.parse('https://apps.apple.com/cg/app/onyfast/id6587572481?l=fr-FR');

  if (await canLaunchUrl(whatsappUrl)) {
    final bool launched = await launchUrl(
      whatsappUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      SnackBarService.warning('Impossible d\'ouvrir PlayStore.');
    }
  } else {
    SnackBarService.warning('PlayStore n\'est pas disponible.');
  }
                  }


}