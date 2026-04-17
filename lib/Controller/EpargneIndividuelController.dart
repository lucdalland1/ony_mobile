import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/Epargne/EpargneIndivituelle.dart';
import 'package:onyfast/View/Epargne/model/EpargneIndividuelleModel.dart';

class EpargneIndividuelleController extends GetxController {
  final EpargneIndividuelleService service;
  var detection=1.obs;

  // Observable pour le modèle
  var epargne = Rxn<EpargneIndividuelleModel>();

  // Indicateur de chargement
  var isLoading = false.obs;

  // Message d'erreur
  var errorMessage = ''.obs;

  EpargneIndividuelleController({required this.service});

  // Méthode pour charger les données
  Future<void> fetchEpargne() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Check if token exists
      final token = GetStorage().read('token');
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Pas de session active. Veuillez vous connecter.';
        isLoading.value = false;
        return;
      }

      final result = await service.fetchEpargneIndividuelleUser();
      if (result == null) {
        // Si le résultat est null, c'est soit une erreur, soit pas d'épargne
        if (errorMessage.value.isEmpty) {
          // Si pas d'erreur précédente, c'est qu'il n'y a pas d'épargne
          errorMessage.value = 'Vous n\'avez pas encore créé d\'épargne individuelle';
          epargne.value = null;
        }
      } else {
        epargne.value = result;
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement: $e';
      print('Error fetching epargne: $e');
    } finally {
      isLoading.value = false;
    }
  }

  createObjectif({
    required String nom,
    required String montantCible,
    required String endDate,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
       
      // Check if token exists
      final token = GetStorage().read('token');
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Pas de session active. Veuillez vous connecter.';
        isLoading.value = false;
        return;
      }

      final result = await service.createObjectif(nom: nom, montantCible: montantCible, endDate: endDate);
      if (result != null) {
        epargne.value = result;
      } else {
        errorMessage.value = 'Erreur lors du chargement des données. Vérifiez votre connexion.';
      }
    } catch (e) {
      errorMessage.value = 'Erreur: $e';
      print('Error fetching epargne: $e'); // Add logging
    } finally {
      isLoading.value = false;
    }
  }
}