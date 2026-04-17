// controllers/identity_form_controller.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:onyfast/Widget/alerte.dart';

class IdentityFormController extends GetxController {
  // Variables observables
  var selectedIdType = ''.obs;
  var idFile = Rxn<PlatformFile>();
  var isLoading = false.obs;

  // Liste des types de pièces d'identité
  final List<String> idTypes = [
    'Passeport', 
    "Carte Nationale d'identité", 
    'Permis de conduire', 
    'Autre',
    "NIU",
    "Carte de séjour"
  ];

  // Méthode pour sélectionner le type de pièce d'identité
  void selectIdType(String type) {
    selectedIdType.value = type;
  }

  // Méthode pour sélectionner un fichier (PDF ou image)
  Future<void> pickIdFile() async {
    try {
      isLoading(true);
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'heic', 'webp'],
      );

      if (result != null) {
        idFile.value = result.files.first;
      } else {
        SnackBarService.warning('Aucun fichier sélectionné');
      }
    } catch (e) {
      SnackBarService.error( 'Impossible de sélectionner le fichier: $e');
    } finally {
      isLoading(false);
    }
  }

  // Méthode pour soumettre le formulaire
  void submitForm() {
    if (selectedIdType.isEmpty) {
      SnackBarService.warning('Veuillez sélectionner un type de pièce d\'identité');
    } else if (idFile.value == null) {
      SnackBarService.warning( 'Veuillez sélectionner un fichier');
    } else {
      // Traitement des données ici
      SnackBarService.success(
       title:  'Succès', 'Formulaire soumis avec succès');
      print('Type de pièce: ${selectedIdType.value}');
      print('Fichier: ${idFile.value?.name}');
      print('Extension: ${idFile.value?.extension}');
      // Vous pouvez envoyer ces données à votre API ici
    }
  }
}