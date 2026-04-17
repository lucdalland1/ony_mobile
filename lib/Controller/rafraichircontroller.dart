import 'package:get/get.dart';

class RefreshController extends GetxController {
  final data = <String>[].obs;
  final isLoading = false.obs;
  final balance = 0.obs; // Ajout d'un solde observable

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading(true);
      // Simuler un chargement de données
      await Future.delayed(Duration(seconds: 1));

      // Récupérer les données depuis l'API ou le stockage
      await fetchFromApiAndStorage();

      // Mettre à jour le solde (par exemple, depuis l'API)
      balance.value = await fetchBalance();

    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchFromApiAndStorage() async {
    // Simuler la récupération des données
    final randomData = List.generate(
      5,
      (index) => 'Item ${DateTime.now().second}.${index + 1}',
    );
    data.assignAll(randomData);
  }
  Future<int> fetchBalance() async {
    // Simuler la récupération du solde
    await Future.delayed(Duration(milliseconds: 500));
    return 100; // Remplacez par l'appel réel à votre API
  }

  void refreshData() {
    fetchData();
  }
}