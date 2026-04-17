// controllers/merchant_controller.dart
import 'package:get/get.dart';
import 'package:onyfast/Api/merchant/merchant_api.dart';
import 'package:onyfast/model/merchant/merchant.dart';

class MerchantController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var merchants = <String, List<Merchant>>{}.obs;
  var filteredMerchants = <String, List<Merchant>>{}.obs;
  var errorMessage = ''.obs;
  var availableCategories = <String>[].obs;
  
  // Filters
  var selectedCategory = 'Tous'.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialiser les catégories par défaut
    availableCategories.value = ['Tous'];
  }

  // Charger les marchands depuis l'API
  Future<void> loadMerchants() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await MerchantService.fetchMerchants();

      if (response != null && response.success) {
        merchants.value = response.data;
        _extractCategories();
        _applyFilters();
        errorMessage.value = '';
      } else {
        errorMessage.value = 'Échec de récupération des marchands';
        merchants.clear();
        filteredMerchants.clear();
      }
    } catch (e) {
      errorMessage.value = 'Erreur de connexion: ${e.toString()}';
      merchants.clear();
      filteredMerchants.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Extraire les catégories uniques des marchands
  void _extractCategories() {
    Set<String> categories = {'Tous'};
    
    merchants.values.forEach((merchantList) {
      for (var merchant in merchantList) {
        if (merchant.categorie.isNotEmpty) {
          categories.add(merchant.categorie);
        }
      }
    });
    
    availableCategories.value = categories.toList()..sort();
  }

  // Appliquer les filtres de recherche et catégorie
  void _applyFilters() {
    Map<String, List<Merchant>> filtered = {};

    merchants.forEach((letter, merchantList) {
      List<Merchant> filteredList = merchantList.where((merchant) {
        // Filtre par catégorie
        bool matchesCategory = selectedCategory.value == 'Tous' || 
                              merchant.categorie == selectedCategory.value;
        
        // Filtre par recherche
        bool matchesSearch = searchQuery.value.isEmpty ||
                           merchant.nom.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                           merchant.telephone.contains(searchQuery.value) ||
                           merchant.categorie.toLowerCase().contains(searchQuery.value.toLowerCase());
        
        return matchesCategory && matchesSearch;
      }).toList();

      if (filteredList.isNotEmpty) {
        filtered[letter] = filteredList;
      }
    });

    filteredMerchants.value = filtered;
  }

  // Mettre à jour la catégorie sélectionnée
  void updateSelectedCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  // Mettre à jour la requête de recherche
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  // Obtenir tous les marchands sous forme de liste plate
  List<Merchant> getAllMerchants() {
    List<Merchant> allMerchants = [];
    merchants.values.forEach((merchantList) {
      allMerchants.addAll(merchantList);
    });
    return allMerchants;
  }

  // Obtenir le nombre total de marchands
  int get totalMerchantsCount {
    return getAllMerchants().length;
  }

  // Obtenir le nombre de marchands filtrés
  int get filteredMerchantsCount {
    int count = 0;
    filteredMerchants.values.forEach((merchantList) {
      count += merchantList.length;
    });
    return count;
  }

  // Obtenir le nombre de marchands par catégorie
  Map<String, int> getMerchantCountByCategory() {
    Map<String, int> counts = {};
    
    getAllMerchants().forEach((merchant) {
      final category = merchant.categorie.isEmpty ? 'Non défini' : merchant.categorie;
      counts[category] = (counts[category] ?? 0) + 1;
    });
    
    return counts;
  }

  // Réinitialiser les filtres
  void resetFilters() {
    selectedCategory.value = 'Tous';
    searchQuery.value = '';
    _applyFilters();
  }

  // Nettoyer les données
  void clear() {
    merchants.clear();
    filteredMerchants.clear();
    availableCategories.value = ['Tous'];
    errorMessage.value = '';
    selectedCategory.value = 'Tous';
    searchQuery.value = '';
  }

  @override
  void onClose() {
    clear();
    super.onClose();
  }
}