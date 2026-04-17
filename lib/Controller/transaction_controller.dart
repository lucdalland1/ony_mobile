import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onyfast/Services/token_service.dart';
import 'package:onyfast/Widget/alerte.dart';

// Transaction Controller
class TransactionController extends GetxController {
  final TokenService _tokenService = Get.find<TokenService>();

  // Observable variables
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var errorMessage = ''.obs;
  var transactions = <TransactionData>[].obs;
  var filteredTransactions = <TransactionData>[].obs;
  var selectedDateRange = Rxn<DateTimeRange>();
  var selectedTransactionType = TransactionType.all.obs;
  var currentCardID = ''.obs;

  // Pagination
  var currentPage = 1.obs;
  var itemsPerPage = 50;
  var hasMoreData = true.obs;

  // Cache pour éviter les appels répétés
  final Map<String, List<TransactionData>> _transactionCache = {};
  final Map<String, DateTime> _cacheTime = {};
  static const Duration _cacheValidDuration = Duration(minutes: 10);

  @override
  void onInit() {
    super.onInit();
    // Écouter les changements de filtres
    ever(selectedTransactionType, (_) => _applyFilters());
    ever(selectedDateRange, (_) => _applyFilters());
  }

  // Charger les transactions pour une carte spécifique
  Future<void> loadTransactions(String cardID, {
    bool forceRefresh = false,
    String? startDate,
    String? endDate,
    int? numberOfTrans,
  }) async {
    if (cardID.isEmpty) {
      errorMessage.value = 'ID de carte invalide';
      return;
    }

    currentCardID.value = cardID;
    final cacheKey = _buildCacheKey(cardID, startDate, endDate, numberOfTrans);

    // Vérifier le cache si pas de refresh forcé
    if (!forceRefresh && _isDataCached(cacheKey)) {
      print('📦 Données récupérées depuis le cache');
      transactions.assignAll(_transactionCache[cacheKey]!);
      _applyFilters();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔄 Chargement des transactions pour la carte: $cardID');

      // Construire les paramètres de requête
      final queryParams = <String, String>{
        'cardID': cardID,
      };

      if (startDate != null) queryParams['StartDate'] = startDate;
      if (endDate != null) queryParams['EndDate'] = endDate;
      if (numberOfTrans != null) {
        queryParams['NumberOfTrans'] = numberOfTrans.toString();
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _tokenService
          .get('transactions.php?$queryString')
          .timeout(Duration(seconds: 30));

      print('📡 Réponse transactions - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status']['success'] == true && data['data'] != null) {
          final transactionList = data['data']['transactionActivities'] as List?;

          if (transactionList != null) {
            final parsedTransactions = transactionList
                .map((json) => TransactionData.fromJson(json))
                .toList();

            // Trier par date décroissante
            parsedTransactions.sort((a, b) => b.transactionDateTime.compareTo(a.transactionDateTime));

            // Mettre en cache
            _transactionCache[cacheKey] = parsedTransactions;
            _cacheTime[cacheKey] = DateTime.now();

            transactions.assignAll(parsedTransactions);
            _applyFilters();

            print('✅ ${parsedTransactions.length} transactions chargées');
          } else {
            transactions.clear();
            filteredTransactions.clear();
            print('📭 Aucune transaction trouvée');
          }
        } else {
          throw Exception(data['status']['message'] ?? 'Erreur serveur');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } on TokenExpiredException catch (e) {
      print('🔄 Token expiré: $e');
      _tokenService.handleSessionError();
    } catch (e) {
      print('❌ Erreur lors du chargement des transactions: $e');
      errorMessage.value = _getErrorMessage(e);
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Rafraîchir les transactions
  Future<void> refreshTransactions() async {
    if (currentCardID.value.isEmpty) return;

    isRefreshing.value = true;
    try {
      // Vider le cache pour cette carte
      _clearCacheForCard(currentCardID.value);
      await loadTransactions(currentCardID.value, forceRefresh: true);

      
    } finally {
      isRefreshing.value = false;
    }
  }

  // Charger plus de transactions (pagination)
  Future<void> loadMoreTransactions() async {
    if (!hasMoreData.value || isLoading.value || currentCardID.value.isEmpty) {
      return;
    }

    final newItemsPerPage = itemsPerPage * (currentPage.value + 1);
    await loadTransactions(
      currentCardID.value,
      numberOfTrans: newItemsPerPage,
    );
    currentPage.value++;
  }

  // Appliquer les filtres
  void _applyFilters() {
    var filtered = List<TransactionData>.from(transactions);

    // Filtre par type de transaction
    if (selectedTransactionType.value != TransactionType.all) {
      filtered = filtered.where((transaction) {
        switch (selectedTransactionType.value) {
          case TransactionType.income:
            return transaction.isIncome;
          case TransactionType.expense:
            return transaction.isExpense;
          case TransactionType.transfer:
            return transaction.isTransfer;
          case TransactionType.fee:
            return transaction.isFee;
          default:
            return true;
        }
      }).toList();
    }

    // Filtre par plage de dates
    if (selectedDateRange.value != null) {
      final range = selectedDateRange.value!;
      filtered = filtered.where((transaction) {
        final transactionDate = transaction.transactionDateTime;
        return transactionDate.isAfter(range.start.subtract(Duration(days: 1))) &&
               transactionDate.isBefore(range.end.add(Duration(days: 1)));
      }).toList();
    }

    filteredTransactions.assignAll(filtered);
  }

  // Définir un filtre de type de transaction
  void setTransactionTypeFilter(TransactionType type) {
    selectedTransactionType.value = type;
  }

  // Définir un filtre de plage de dates
  void setDateRangeFilter(DateTimeRange? range) {
    selectedDateRange.value = range;
  }

  // Effacer tous les filtres
  void clearFilters() {
    selectedTransactionType.value = TransactionType.all;
    selectedDateRange.value = null;
  }

  // Méthodes utilitaires privées
  String _buildCacheKey(String cardID, String? startDate, String? endDate, int? numberOfTrans) {
    return '$cardID-$startDate-$endDate-$numberOfTrans';
  }

  bool _isDataCached(String cacheKey) {
    if (!_transactionCache.containsKey(cacheKey)) return false;
    
    final cacheTime = _cacheTime[cacheKey];
    if (cacheTime == null) return false;
    
    return DateTime.now().difference(cacheTime) < _cacheValidDuration;
  }

  void _clearCacheForCard(String cardID) {
    final keysToRemove = _transactionCache.keys
        .where((key) => key.startsWith(cardID))
        .toList();
    
    for (final key in keysToRemove) {
      _transactionCache.remove(key);
      _cacheTime.remove(key);
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is TokenExpiredException) {
      return 'Session expirée, veuillez vous reconnecter';
    }

    final errorStr = error.toString();

    if (errorStr.contains('SocketException')) {
      return 'Problème de connexion réseau';
    }

    if (errorStr.contains('TimeoutException')) {
      return 'Délai d\'attente dépassé, vérifiez votre connexion';
    }

    if (errorStr.contains('FormatException')) {
      return 'Erreur de format des données reçues';
    }

    return errorStr.length > 100
        ? 'Une erreur technique est survenue'
        : errorStr;
  }

  void _showErrorSnackbar(String message) {
    SnackBarService.error(message);
  }

  // Getters
  bool get hasTransactions => filteredTransactions.isNotEmpty;
  bool get isLoadingOrRefreshing => isLoading.value || isRefreshing.value;
  
  // Statistiques des transactions
  Map<String, dynamic> get transactionStats {
    final filtered = filteredTransactions;
    
    return {
      'total': filtered.length,
      'income': filtered.where((t) => t.isIncome).length,
      'expenses': filtered.where((t) => t.isExpense).length,
      'transfers': filtered.where((t) => t.isTransfer).length,
      'fees': filtered.where((t) => t.isFee).length,
      'totalIncome': filtered
          .where((t) => t.isIncome)
          .fold(0.0, (sum, t) => sum + t.totalAmount.abs()),
      'totalExpenses': filtered
          .where((t) => t.isExpense)
          .fold(0.0, (sum, t) => sum + t.totalAmount.abs()),
      'totalFees': filtered
          .where((t) => t.isFee)
          .fold(0.0, (sum, t) => sum + t.fee.abs()),
    };
  }

  @override
  void onClose() {
    _transactionCache.clear();
    _cacheTime.clear();
    super.onClose();
  }
}

// Enum pour les types de transactions
enum TransactionType {
  all,
  income,
  expense,
  transfer,
  fee,
}

extension TransactionTypeExtension on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.all:
        return 'Toutes';
      case TransactionType.income:
        return 'Revenus';
      case TransactionType.expense:
        return 'Dépenses';
      case TransactionType.transfer:
        return 'Transferts';
      case TransactionType.fee:
        return 'Frais';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.all:
        return Icons.list;
      case TransactionType.income:
        return Icons.trending_up;
      case TransactionType.expense:
        return Icons.trending_down;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.fee:
        return Icons.receipt;
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.all:
        return Colors.grey;
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.blue;
      case TransactionType.fee:
        return Colors.orange;
    }
  }
}

// Modèle de données pour les transactions
class TransactionData {
  final int transactionId;
  final DateTime transactionDateTime;
  final double baseAmount;
  final double fee;
  final double totalAmount;
  final double runningBalance;
  final String transactionDesc;
  final String? referenceInformation;
  final String? merchantCountry;
  final String? extendedInformation;

  TransactionData({
    required this.transactionId,
    required this.transactionDateTime,
    required this.baseAmount,
    required this.fee,
    required this.totalAmount,
    required this.runningBalance,
    required this.transactionDesc,
    this.referenceInformation,
    this.merchantCountry,
    this.extendedInformation,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    // Parser la date et l'heure
    final dateStr = json['transactionDate'] as String;
    final timeStr = json['transactionTimeHH24'] as String;
    
    DateTime transactionDateTime;
    try {
      // Format: "26-JUL-2025" et "12:16:37"
      final dateParts = dateStr.split('-');
      final timeParts = timeStr.split(':');
      
      final day = int.parse(dateParts[0]);
      final monthName = dateParts[1];
      final year = int.parse(dateParts[2]);
      
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final second = int.parse(timeParts[2]);
      
      // Convertir le nom du mois en numéro
      final monthMap = {
        'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
        'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12,
      };
      final month = monthMap[monthName] ?? 1;
      
      transactionDateTime = DateTime(year, month, day, hour, minute, second);
    } catch (e) {
      print('❌ Erreur parsing date: $e');
      transactionDateTime = DateTime.now();
    }

    return TransactionData(
      transactionId: _parseIntSafely(json['transactionId']),
      transactionDateTime: transactionDateTime,
      baseAmount: _parseDoubleSafely(json['baseAmount']),
      fee: _parseDoubleSafely(json['fee']),
      totalAmount: _parseDoubleSafely(json['totalAmount']),
      runningBalance: _parseDoubleSafely(json['runningBalance']),
      transactionDesc: json['transactionDesc']?.toString() ?? '',
      referenceInformation: json['referenceInformation']?.toString(),
      merchantCountry: json['merchantCountry']?.toString(),
      extendedInformation: json['extendedInformation']?.toString(),
    );
  }

  static int _parseIntSafely(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  static double _parseDoubleSafely(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? defaultValue;
  }

  // Getters utilitaires
  bool get isIncome => totalAmount > 0 && !isTransfer;
  bool get isExpense => totalAmount < 0 && !isTransfer && !isFee;
  bool get isTransfer => transactionDesc.toLowerCase().contains('transfer');
  bool get isFee => transactionDesc.toLowerCase().contains('fee') || 
                   transactionDesc.toLowerCase().contains('charge');

  String get formattedAmount {
    final sign = totalAmount >= 0 ? '+' : '';
    return '$sign${totalAmount.toStringAsFixed(0)} XAF';
  }

  String get formattedBalance {
    return '${runningBalance.toStringAsFixed(2)} XAF';
  }

  String get formattedDate {
    return '${transactionDateTime.day.toString().padLeft(2, '0')}/'
           '${transactionDateTime.month.toString().padLeft(2, '0')}/'
           '${transactionDateTime.year}';
  }

  String get formattedTime {
    return '${transactionDateTime.hour.toString().padLeft(2, '0')}:'
           '${transactionDateTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDateTime {
    return '$formattedDate à $formattedTime';
  }

  Color get amountColor {
    if (isIncome) return Colors.green;
    if (isExpense || isFee) return Colors.red;
    return Colors.blue; // Transfers
  }

  IconData get transactionIcon {
    if (isIncome) return Icons.add_circle;
    if (isExpense) return Icons.remove_circle;
    if (isTransfer) return Icons.swap_horiz;
    if (isFee) return Icons.receipt;
    return Icons.help_outline;
  }

  String get shortDescription {
    if (transactionDesc.length <= 30) return transactionDesc;
    return '${transactionDesc.substring(0, 27)}...';
  }

  // Pour l'affichage des détails
  Map<String, String> get detailsMap {
    return {
      'ID Transaction': transactionId.toString(),
      'Date': formattedDateTime,
      'Description': transactionDesc,
      'Montant de base': '${baseAmount.toStringAsFixed(0)} XAF',
      'Frais': '${fee.toStringAsFixed(0)} XAF',
      'Montant total': formattedAmount,
      'Solde après': formattedBalance,
      if (referenceInformation != null) 'Référence': referenceInformation!,
      if (merchantCountry != null) 'Pays marchand': merchantCountry!,
      if (extendedInformation != null) 'Infos étendues': extendedInformation!,
    };
  }
}