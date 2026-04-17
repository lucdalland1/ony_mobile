import 'package:get/get.dart';
import 'package:onyfast/Api/history/history_Api.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/model/history/historymodel.dart';

class TransactionsController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxList<TransactionData> transactions = <TransactionData>[].obs;
  RxList<TransactionData> allTransactions = <TransactionData>[].obs; // Toutes les transactions
  
  // Variables pour la pagination locale (simulation)
  int currentDisplayedCount = 20;
  final int itemsPerPage = 20;
  bool hasMoreData = true;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  // Méthode principale pour charger toutes les transactions
  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      currentDisplayedCount = itemsPerPage;
      transactions.clear();
      allTransactions.clear();
    }
    
    isLoading.value = true;
    
    try {
      final response = await TransactionApiService.fetchTransactionHistory(
        page: 1,
        limit: 1000, // Charger beaucoup de transactions d'un coup
        period: '',
      );
      
      if (response != null && response.data.isNotEmpty) {
        allTransactions.assignAll(response.data);
        
        // Afficher seulement les premières transactions
        int endIndex = currentDisplayedCount;
        if (endIndex > allTransactions.length) {
          endIndex = allTransactions.length;
          hasMoreData = false;
        } else {
          hasMoreData = allTransactions.length > currentDisplayedCount;
        }
        
        transactions.assignAll(allTransactions.take(endIndex).toList());
        
        print('Total transactions récupérées: ${allTransactions.length}');
        print('Transactions affichées: ${transactions.length}');
        print('Peut charger plus: $hasMoreData');
      } else {
        hasMoreData = false;
        // Get.snackbar("Erreur", "Impossible de charger les transactions");
      }
    } catch (e) {
      print('Erreur lors du chargement: $e');
      // Get.snackbar("Erreur", "Une erreur s'est produite");
      hasMoreData = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Méthode pour charger plus de transactions (simulation de pagination)
  Future<bool> loadMoreTransactions() async {
    if (!hasMoreData || isLoadingMore.value) return false;
    
    isLoadingMore.value = true;
    
    try {
      // Simuler un délai de chargement
      await Future.delayed(Duration(milliseconds: 800));
      
      // Calculer les indices pour les nouvelles transactions à afficher
      int startIndex = currentDisplayedCount;
      int endIndex = startIndex + itemsPerPage;
      
      if (startIndex >= allTransactions.length) {
        hasMoreData = false;
        return false;
      }
      
      if (endIndex > allTransactions.length) {
        endIndex = allTransactions.length;
        hasMoreData = false;
      } else {
        hasMoreData = allTransactions.length > endIndex;
      }
      
      // Ajouter les nouvelles transactions à la liste affichée
      List<TransactionData> newTransactions = allTransactions
          .skip(startIndex)
          .take(endIndex - startIndex)
          .toList();
      
      transactions.addAll(newTransactions);
      currentDisplayedCount = endIndex;
      
      print('Nouvelles transactions ajoutées: ${newTransactions.length}');
      print('Total transactions affichées: ${transactions.length}');
      print('Peut encore charger: $hasMoreData');
      
      return hasMoreData;
    } catch (e) {
      print('Erreur lors du chargement de plus de transactions: $e');
      return false;
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Méthode pour rafraîchir toutes les transactions
  Future<void> refreshTransactions() async {
    await loadTransactions(refresh: true);
  }

  // Méthode pour charger les transactions avec filtrage par période
  Future<void> loadTransactionsByPeriod(String period) async {
    currentDisplayedCount = itemsPerPage;
    transactions.clear();
    allTransactions.clear();
    hasMoreData = true;
    
    isLoading.value = true;
    
    try {
      final response = await TransactionApiService.fetchTransactionHistory(
        page: 1,
        limit: 1000,
        period: period,
      );
      
      if (response != null && response.data.isNotEmpty) {
        allTransactions.assignAll(response.data);
        
        // Afficher seulement les premières transactions
        int endIndex = currentDisplayedCount;
        if (endIndex > allTransactions.length) {
          endIndex = allTransactions.length;
          hasMoreData = false;
        } else {
          hasMoreData = allTransactions.length > currentDisplayedCount;
        }
        
        transactions.assignAll(allTransactions.take(endIndex).toList());
        
        print('Transactions filtrées par $period: ${transactions.length}/${allTransactions.length}');
      } else {
        hasMoreData = false;
        //  SnackBarService.info("Aucune transaction trouvée pour cette période");
      }
    } catch (e) {
      print('Erreur lors du filtrage: $e');
      // SnackBarService.error("Impossible de filtrer les transactions");
      hasMoreData = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Méthodes utilitaires
  bool get canLoadMore => hasMoreData && !isLoadingMore.value;

  void resetPagination() {
    currentDisplayedCount = itemsPerPage;
    hasMoreData = true;
    transactions.clear();
    allTransactions.clear();
  }

  // Méthode pour obtenir les statistiques
  Map<String, int> getTransactionStats() {
    Map<String, int> stats = {
      'total': allTransactions.length,
      'displayed': transactions.length,
      'positive': 0,
      'negative': 0,
    };

    for (var transaction in allTransactions) {
      if (transaction.signe == '+') {
        stats['positive'] = stats['positive']! + 1;
      } else {
        stats['negative'] = stats['negative']! + 1;
      }
    }

    return stats;
  }
}