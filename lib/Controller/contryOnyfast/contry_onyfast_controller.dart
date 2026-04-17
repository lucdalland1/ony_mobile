import 'package:get/get.dart';
import 'package:onyfast/Api/ContryOnyfast/contry_onyfast_service.dart';
import 'package:onyfast/model/pays_onyfast/contryonyfastModel.dart';

class ContryOnyfastController extends GetxController {
  final isLoading     = false.obs;
  final errorMessage  = RxString('');
  final countries     = <ContryOnyfast>[].obs;
  final filtered      = <ContryOnyfast>[].obs;
  final tabCountrycode =<String>[].obs;
  

  @override
  Future<void> onInit() async {
    super.onInit();
    print("[ContryOnyfastController] onInit()");
    await load();
  }

  Future<void> load({Map<String, dynamic>? query}) async {
  isLoading.value = true;
  errorMessage.value = '';
  print("[ContryOnyfastController] Chargement des pays… query=$query");

  try {
    final list = await ContryOnyfastService.fetchAll(query: query);
    print("[ContryOnyfastController] Succès: ${list.length} pays récupérés");

    countries.assignAll(list);
    filtered.assignAll(list);

    // 🔥 Affiche tous les pays en détail

    
    for (final c in list) {

      tabCountrycode.add(c.code);
      print("---- Pays Onyfast ----");
      print("ID: ${c.id}");
      print("Désignation: ${c.designation}");
      print("Programme: ${c.programme}");
      print("Code: ${c.code}");
      print("Indicatif: ${c.indicatif}");
      print("User ID: ${c.userId}");
      print("Start: ${c.startDate}");
      print("End: ${c.endDate}");
      print("DeletedAt: ${c.deletedAt}");
      print("Créé le: ${c.createdAt}");
      print("MAJ le: ${c.updatedAt}");
      print("----------------------\n");
    }
  } catch (e) {
    errorMessage.value = e.toString();
    print("[ContryOnyfastController] Erreur lors du fetch: $e");
  } finally {
    isLoading.value = false;
    print("[ContryOnyfastController] Fin du chargement. isLoading=${isLoading.value}");
  }
}

  void refreshList() {
    print("[ContryOnyfastController] Refresh list demandé");
    load();
  }

  /// Recherche par nom/code/indicatif
  void search(String q) {
    final query = q.trim().toLowerCase();
    print("[ContryOnyfastController] Recherche '$q' (normalisé: '$query')");
    if (query.isEmpty) {
      filtered.assignAll(countries);
      print("[ContryOnyfastController] Query vide → reset filtrage (${countries.length} pays)");
      return;
    }

    final results = countries.where((c) =>
        c.designation.toLowerCase().contains(query) ||
        c.code.toLowerCase().contains(query) ||
        c.programme.toLowerCase().contains(query) ||
        c.indicatif.toLowerCase().contains(query)).toList();

    filtered.assignAll(results);
    print("[ContryOnyfastController] Résultats trouvés: ${results.length}");
  }

  ContryOnyfast? getByCode(String code3) {
    final lc = code3.toLowerCase();
    print("[ContryOnyfastController] Recherche par code: $lc");
    final found = countries.firstWhereOrNull((c) => c.code.toLowerCase() == lc);
    if (found != null) {
      print("[ContryOnyfastController] Trouvé: ${found.designation} (${found.code})");
    } else {
      print("[ContryOnyfastController] Aucun pays trouvé avec code=$lc");
    }
    return found;
  }

  /// Exemple utilitaire : renvoyer un indicatif sans '+', sans espaces
  String normalizeDial(String dial) {
    final norm = dial.replaceAll('+', '').replaceAll(' ', '');
    print("[ContryOnyfastController] normalizeDial('$dial') → '$norm'");
    return norm;
  }
}
