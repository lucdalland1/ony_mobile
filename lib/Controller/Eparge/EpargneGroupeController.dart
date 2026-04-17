import 'package:get/get.dart';
import 'package:onyfast/model/Epargne/epargnegroupe.dart';
import 'package:onyfast/Api/Epargne/EpargneGroupe.dart';

class EpargneGroupeController extends GetxController {
  final EpargneService service = EpargneService();

  var groupes = <Groupe>[].obs;
  var isLoading = false.obs;
  var error = false.obs;
  var errorMessage = ''.obs;

  Future<void> fetchMesGroupes() async {
    try {
      isLoading.value = true;
      error.value = false;
      final result = await service.fetchMesGroupes();
      groupes.assignAll(result);
    } catch (e) {
      print(e);
      error.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> creerGroupe(String nom, String typeGroupeId, String frequence) async {
    try {
      isLoading.value = true;
      error.value = false;
      await service.creerGroupeEpargne(nom: nom, typeGroupeId: typeGroupeId, frequence: frequence);
      await fetchMesGroupes();
    } catch (e) {
      print(e);
      error.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  int getFrequenceId(String frequence) {
    switch (frequence.toLowerCase()) {
      case 'quotidien':
        return 1;
      case 'hebdomadaire':
        return 2;
      case 'mensuel':
        return 3;
      case 'trimestriel':
        return 4;
      case 'annuel':
        return 5;
      default:
        return 0;
    }
  }
}
String getFrequenceLabel(int id) {
  switch (id) {
    case 1:
      return 'Quotidien';
    case 2:
      return 'Hebdomadaire';
    case 3:
      return 'Mensuel';
    case 4:
      return 'Trimestriel';
    case 5:
      return 'Annuel';
    default:
      return 'Inconnu';
  }
}
