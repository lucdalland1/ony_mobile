import 'dart:io';
import 'package:get/get.dart';
import 'package:onyfast/Api/piecesjustificatif_Api/justificatifdomicile.dart';
import 'package:onyfast/Controller/verifier_identite/voir_justificatifresidencecontroller.dart';
import 'package:onyfast/Widget/alerte.dart';

class SoumissionJustificatifController extends GetxController {
  var isSubmitting = false.obs;

  Future<void> soumettre({
    required File fichier,
    required String typeIdString,
    // required String numero,
  }) async {
    isSubmitting.value = true;

    int? typeId = int.tryParse(typeIdString);
    if (typeId == null) {
       SnackBarService.warning  ( "Type de justificatif invalide");
      isSubmitting.value = false;
      return;
    }

    final response = await JustificatifDomicileService.envoyerJustificatif(
      fichier: fichier,
      typeId: typeId,
      // numeroDocument: numero,
    );

    isSubmitting.value = false;

    if (response['success'] == true) {
      final listeController = Get.find<ListeJustificatifController>();
      listeController.chargerJustificatifs();
      Get.back();
       SnackBarService.success("Justificatif soumis avec succès");
    } else {
       SnackBarService.warning(response['message'] ?? "Échec lors de la soumission");
    }
  }
}
