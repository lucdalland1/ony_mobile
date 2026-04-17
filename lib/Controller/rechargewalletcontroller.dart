import 'package:get/get.dart';
import 'package:onyfast/Controller/fraiscontroller.dart';

/// Contrôleur pour gérer les opérations de recharge et les montants des transactions
class RechargeWalletController extends GetxController {
  // Observables pour les montants
  var montant = 0.0.obs;
  var soldeActuel = 0.0.obs;
  var dernierMontantRecharge = 0.0.obs;

  // États de l'interface
  var isProcessing = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  // Historique des transactions
  var transactionHistory = <Map<String, dynamic>>[].obs;

  // Limites de montant
  static const double MONTANT_MINIMUM = 25.0;
  static const double MONTANT_MAXIMUM = 1000000.0;

  @override
  void onInit() {
    super.onInit();
    print('🏦 RechargeWalletController initialisé');

    // Initialiser avec des valeurs par défaut
    montant.value = 0.0;
    soldeActuel.value = 0.0;
    clearError();
  }

  /// Met à jour le montant de la transaction
  void updateMontant(double nouveauMontant) {
    try {
      // Validation du montant
      if (nouveauMontant < 0) {
        montant.value = 0.0;
        return;
      }

      if (nouveauMontant > MONTANT_MAXIMUM) {
        setError(
            'Le montant maximum autorisé est de ${MONTANT_MAXIMUM.toStringAsFixed(0)} FCFA');
        return;
      }

      montant.value = nouveauMontant;
      clearError();

      print('💰 Montant mis à jour: ${montant.value} FCFA');

      // Déclencher un événement pour informer les autres contrôleurs
      if (nouveauMontant >= MONTANT_MINIMUM) {
        Get.find<FraisController>().calculerFrais(nouveauMontant);
      }
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du montant: $e');
      setError('Erreur lors de la saisie du montant');
    }
  }

  /// Met à jour le solde actuel du portefeuille
  void updateSolde(double nouveauSolde) {
    try {
      soldeActuel.value = nouveauSolde;
      print('🏦 Solde mis à jour: ${soldeActuel.value} FCFA');
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du solde: $e');
    }
  }

  /// Valide si le montant est suffisant pour la transaction
  bool validateMontantForTransaction() {
    if (montant.value < MONTANT_MINIMUM) {
      setError(
          'Le montant minimum est de ${MONTANT_MINIMUM.toStringAsFixed(0)} FCFA');
      return false;
    }

    if (montant.value > MONTANT_MAXIMUM) {
      setError(
          'Le montant maximum est de ${MONTANT_MAXIMUM.toStringAsFixed(0)} FCFA');
      return false;
    }

    // Vérifier si le solde est suffisant (incluant les frais)
    try {
      final fraisController = Get.find<FraisController>();
      final montantTotal = montant.value + fraisController.frais.value;

      if (soldeActuel.value > 0 && montantTotal > soldeActuel.value) {
        setError(
            'Solde insuffisant. Montant requis: ${montantTotal.toStringAsFixed(0)} FCFA');
        return false;
      }
    } catch (e) {
      print('⚠️ Impossible de vérifier les frais: $e');
    }

    clearError();
    return true;
  }

  /// Simule une opération de recharge
  Future<bool> processRecharge(double montantRecharge,
      {String? methodePaiement}) async {
    try {
      isProcessing.value = true;
      clearError();

      print('🔄 Traitement de la recharge: $montantRecharge FCFA');

      // Simulation d'un appel API
      await Future.delayed(const Duration(seconds: 2));

      // Simuler succès/échec (90% succès)
      final success = DateTime.now().millisecond % 10 != 0;

      if (success) {
        dernierMontantRecharge.value = montantRecharge;
        soldeActuel.value += montantRecharge;

        // Ajouter à l'historique
        addToHistory({
          'type': 'recharge',
          'montant': montantRecharge,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'methode': methodePaiement ?? 'non_specifie',
          'status': 'success',
        });

        setSuccess(
            'Recharge de ${montantRecharge.toStringAsFixed(0)} FCFA effectuée avec succès');
        print('✅ Recharge réussie');
        return true;
      } else {
        setError('Échec de la recharge. Veuillez réessayer.');
        print('❌ Recharge échouée');
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors de la recharge: $e');
      setError('Erreur technique lors de la recharge');
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Simule une opération de débit pour transaction
  Future<bool> processTransaction(
      double montantTransaction, String destinataire) async {
    try {
      isProcessing.value = true;
      clearError();

      if (!validateMontantForTransaction()) {
        return false;
      }

      print(
          '🔄 Traitement de la transaction: $montantTransaction FCFA vers $destinataire');

      // Simulation d'un appel API
      await Future.delayed(const Duration(seconds: 1));

      // Calculer le montant total avec frais
      final fraisController = Get.find<FraisController>();
      final montantTotal = montantTransaction + fraisController.frais.value;

      // Déduire du solde
      if (soldeActuel.value >= montantTotal) {
        soldeActuel.value -= montantTotal;

        // Ajouter à l'historique
        addToHistory({
          'type': 'transaction',
          'montant': montantTransaction,
          'frais': fraisController.frais.value,
          'total': montantTotal,
          'destinataire': destinataire,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'status': 'success',
        });

        // Reset du montant après transaction
        resetMontant();

        setSuccess(
            'Transaction de ${montantTransaction.toStringAsFixed(0)} FCFA envoyée avec succès');
        print('✅ Transaction réussie');
        return true;
      } else {
        setError('Solde insuffisant pour cette transaction');
        print('❌ Solde insuffisant');
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors de la transaction: $e');
      setError('Erreur technique lors de la transaction');
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Ajoute une entrée à l'historique des transactions
  void addToHistory(Map<String, dynamic> transaction) {
    try {
      transactionHistory.insert(0, transaction); // Ajouter au début

      // Limiter l'historique à 50 entrées
      if (transactionHistory.length > 50) {
        transactionHistory.removeRange(50, transactionHistory.length);
      }

      print('📝 Transaction ajoutée à l\'historique');
    } catch (e) {
      print('❌ Erreur lors de l\'ajout à l\'historique: $e');
    }
  }

  /// Reset le montant à zéro
  void resetMontant() {
    montant.value = 0.0;
    clearError();
    print('🔄 Montant remis à zéro');
  }

  /// Reset complet du contrôleur
  void resetAll() {
    montant.value = 0.0;
    dernierMontantRecharge.value = 0.0;
    clearError();
    clearSuccess();
    print('🔄 Reset complet du RechargeWalletController');
  }

  /// Définit un message d'erreur
  void setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
    successMessage.value = '';
  }

  /// Définit un message de succès
  void setSuccess(String message) {
    hasError.value = false;
    errorMessage.value = '';
    successMessage.value = message;
  }

  /// Efface les messages d'erreur
  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }

  /// Efface les messages de succès
  void clearSuccess() {
    successMessage.value = '';
  }

  /// Efface tous les messages
  void clearAllMessages() {
    clearError();
    clearSuccess();
  }

  // Getters pour faciliter l'accès aux données

  /// Retourne le montant formaté en string
  String get montantFormatted => '${montant.value.toStringAsFixed(0)} FCFA';

  /// Retourne le solde formaté en string
  String get soldeFormatted => '${soldeActuel.value.toStringAsFixed(0)} FCFA';

  /// Vérifie si le montant est valide pour une transaction
  bool get isMontantValid =>
      montant.value >= MONTANT_MINIMUM && montant.value <= MONTANT_MAXIMUM;

  /// Vérifie si une opération est en cours
  bool get isOperationInProgress => isProcessing.value;

  /// Retourne le nombre de transactions dans l'historique
  int get historyCount => transactionHistory.length;

  /// Retourne l'historique des transactions du jour
  List<Map<String, dynamic>> get todayTransactions {
    final today = DateTime.now();
    final startOfDay =
        DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;

    return transactionHistory.where((transaction) {
      final timestamp = transaction['timestamp'] ?? 0;
      return timestamp >= startOfDay;
    }).toList();
  }

  /// Calcule le total des transactions du jour
  double get todayTransactionTotal {
    return todayTransactions.fold(0.0, (sum, transaction) {
      final montant = transaction['montant'] ?? 0.0;
      return sum + (montant as double);
    });
  }

  /// Retourne des statistiques rapides
  Map<String, dynamic> get quickStats => {
        'solde': soldeActuel.value,
        'derniere_recharge': dernierMontantRecharge.value,
        'transactions_aujourdhui': todayTransactions.length,
        'total_aujourdhui': todayTransactionTotal,
        'historique_total': transactionHistory.length,
      };

  @override
  void onClose() {
    print('🏦 RechargeWalletController fermé');
    super.onClose();
  }

  /// Méthode pour debug - affiche l'état actuel
  void debugPrintState() {
    print('🔍 État RechargeWalletController:');
    print('   Montant: ${montant.value}');
    print('   Solde: ${soldeActuel.value}');
    print('   En traitement: ${isProcessing.value}');
    print('   Erreur: ${hasError.value ? errorMessage.value : "Aucune"}');
    print('   Historique: ${transactionHistory.length} entrées');
  }
}
