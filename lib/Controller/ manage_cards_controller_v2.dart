// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:onyfast/Services/token_service.dart';
// import 'package:onyfast/View/Activit%C3%A9/decharge.dart';
// import 'package:onyfast/View/Activit%C3%A9/recharge.dart';
// import 'package:onyfast/View/Gerer_cartes/CardDetailPage.dart';

// class ManageCardsController extends GetxController {
//   final TokenService _tokenService = Get.find<TokenService>();
//   final GetStorage storage = GetStorage();

//   // Observable variables
//   var isLoading = true.obs;
//   var isRefreshing = false.obs;
//   var currentCardIndex = 0.obs;
//   var userProfile = Rxn<UserProfile>();
//   var errorMessage = ''.obs;
//   var cards = <CardData>[].obs;
//   var toogle = false.obs;
//   var transactions = <Transaction>[].obs;

//   // Controller pour les pièces justificatives
//   final controllerTestPiece = Get.put(PiecesJustificativesController());

//   @override
//   void onInit() {
//     super.onInit();
//     _initializeController();
//   }

//   // Initialisation centralisée
//   void _initializeController() {
//     loadUserProfile();

//     // Écouter les changements d'état de connexion
//     ever(_tokenService.isLoggedIn, (isLoggedIn) {
//       if (!isLoggedIn) {
//         _clearUserData();
//       } else {
//         // Recharger les données lors de la reconnexion
//         loadUserProfile();
//       }
//     });
//   }

//   // Méthode centralisée pour effacer les données
//   void _clearUserData() {
//     userProfile.value = null;
//     cards.clear();
//     currentCardIndex.value = 0;
//     errorMessage.value = '';
//     transactions.clear();
//   }

//   // Navigation entre cartes avec validation
//   void nextCard() {
//     if (cards.isNotEmpty && currentCardIndex.value < cards.length - 1) {
//       currentCardIndex.value++;
//       // Optionnel: charger le solde de la nouvelle carte
//       updateCurrentCardBalance();
//     }
//   }

//   void previousCard() {
//     if (currentCardIndex.value > 0) {
//       currentCardIndex.value--;
//       // Optionnel: charger le solde de la nouvelle carte
//       updateCurrentCardBalance();
//     }
//   }

//   // Aller à une carte spécifique
//   void goToCard(int index) {
//     if (index >= 0 && index < cards.length) {
//       currentCardIndex.value = index;
//       updateCurrentCardBalance();
//     }
//   }

//   // Chargement du profil utilisateur avec retry automatique
//   Future<void> loadUserProfile({int retryCount = 0}) async {
//     const maxRetries = 3;

//     try {
//       if (retryCount == 0) {
//         isLoading.value = true;
//       }
//       errorMessage.value = '';

//       final phoneNumber = _tokenService.phoneNumber;
//       if (phoneNumber == null) {
//         throw Exception('Numéro de téléphone non disponible');
//       }

//       print(
//           '🔍 Chargement du profil pour le téléphone: $phoneNumber (tentative ${retryCount + 1})');

//       final response = await _tokenService
//           .get('user_card_profil_by_phone.php?phone=$phoneNumber')
//           .timeout(Duration(seconds: 30));

//       print('📱 Réponse reçue - Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data['status']['success'] == true) {
//           print('✅ Profil chargé avec succès');
//           userProfile.value = UserProfile.fromJson(data['data']);
//           _buildCardsFromProfile();

//           // Charger le solde de la première carte
//           if (cards.isNotEmpty) {
//             await updateCurrentCardBalance();
//           }
//         } else {
//           throw Exception(data['status']['message'] ?? 'Erreur serveur');
//         }
//       } else {
//         throw Exception('Erreur HTTP: ${response.statusCode}');
//       }
//     } on TokenExpiredException catch (e) {
//       print('🔄 Token expiré: $e');
//       _tokenService.handleSessionError();
//     } catch (e) {
//       print('❌ Erreur lors du chargement du profil: $e');

//       // Retry automatique pour les erreurs réseau
//       if (retryCount < maxRetries && _isNetworkError(e)) {
//         print('🔄 Nouvelle tentative dans 2 secondes...');
//         await Future.delayed(Duration(seconds: 2));
//         return loadUserProfile(retryCount: retryCount + 1);
//       }

//       errorMessage.value = _getErrorMessage(e);
//       _showErrorSnackbar('La connexion est instable');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // MODIFICATION PRINCIPALE: Construire la liste des cartes avec TOUTES les cartes (actives et bloquées)
//   void _buildCardsFromProfile() {
//     cards.clear();
//     final profile = userProfile.value;

//     if (profile == null) return;

//     final List<CardData> newCards = [];

//     // Carte physique - Ajouter si cardID existe (peu importe hasPhysicalCard ou statut actif)
//     if (profile.cardID > 0) {
//       newCards.add(CardData(
//         type: CardType.physical,
//         cardNumber: profile.cardLast4Digits ?? '****',
//         expiryDate: profile.cardExpireAt ?? '**/**',
//         cardID: profile.cardID.toString(),
//         isActive: profile.activePysique ==
//             1, // Garder le statut RÉEL (actif ou bloqué)
//         holderName: '${profile.firstName} ${profile.lastName}',
//         balance: null,
//       ));
//       print(
//           '✅ Carte physique ajoutée - ID: ${profile.cardID}, Active: ${profile.activePysique == 1}');
//     }

//     // Carte virtuelle - Ajouter si cardIDVirtual existe (peu importe hasVirtualCard ou statut actif)
//     if (profile.cardIDVirtual != null && profile.cardIDVirtual! > 0) {
//       newCards.add(CardData(
//         type: CardType.virtual,
//         cardNumber: profile.cardLast4DigitsVirtual ?? '****',
//         expiryDate: profile.cardExpireAtVirtual ?? '**/**',
//         cardID: profile.cardIDVirtual!.toString(),
//         isActive: profile.activeVirtuelle ==
//             1, // Garder le statut RÉEL (actif ou bloqué)
//         holderName: '${profile.firstName} ${profile.lastName}',
//         balance: null,
//       ));
//       print(
//           '✅ Carte virtuelle ajoutée - ID: ${profile.cardIDVirtual}, Active: ${profile.activeVirtuelle == 1}');
//     }

//     // Debugging: Afficher les valeurs du profil pour diagnostic
//     print('🔍 DEBUG - Profil utilisateur:');
//     print('   cardID: ${profile.cardID}');
//     print('   cardIDVirtual: ${profile.cardIDVirtual}');
//     print('   hasPhysicalCard: ${profile.hasPhysicalCard}');
//     print('   hasVirtualCard: ${profile.hasVirtualCard}');
//     print('   activePysique: ${profile.activePysique}');
//     print('   activeVirtuelle: ${profile.activeVirtuelle}');

//     // Si aucune carte trouvée, ajouter une carte par défaut
//     if (newCards.isEmpty) {
//       newCards.add(CardData(
//         type: CardType.none,
//         cardNumber: '****',
//         expiryDate: '**/**',
//         cardID: '',
//         isActive: false,
//         holderName: 'Aucune carte',
//         balance: null,
//       ));
//       print('⚠️ Aucune carte trouvée, carte par défaut ajoutée');
//     }

//     cards.assignAll(newCards);

//     // Réinitialiser l'index si nécessaire
//     if (currentCardIndex.value >= cards.length) {
//       currentCardIndex.value = 0;
//     }

//     print('📋 ${cards.length} carte(s) trouvée(s) au total:');
//     for (int i = 0; i < cards.length; i++) {
//       final card = cards[i];
//       print(
//           '   $i: ${card.typeLabel} - ID: ${card.cardID} - Active: ${card.isActive}');
//     }
//   }

//   // Récupération du solde avec cache temporaire
//   final Map<String, double> _balanceCache = {};
//   final Map<String, DateTime> _balanceCacheTime = {};
//   static const Duration _cacheValidDuration = Duration(minutes: 5);

//   // Future<double?> getCardBalance(String cardID,
//   //     {bool forceRefresh = false}) async {
//   //   if (cardID.isEmpty) return null;

//   //   // Vérifier le cache si pas de refresh forcé
//   //   if (!forceRefresh && _balanceCache.containsKey(cardID)) {
//   //     final cacheTime = _balanceCacheTime[cardID];
//   //     if (cacheTime != null &&
//   //         DateTime.now().difference(cacheTime) < _cacheValidDuration) {
//   //       print(
//   //           '💰 Solde récupéré depuis le cache: ${_balanceCache[cardID]} XAF');
//   //       return _balanceCache[cardID];
//   //     }
//   //   }

//   //   try {
//   //     print('💰 Récupération du solde pour la carte: $cardID');
//   //     print('entrer');

//   //     final response = await _tokenService
//   //         .get('balance.php?cardID=$cardID')
//   //         .timeout(Duration(seconds: 10));

//   //     if (response.statusCode == 200) {
//   //       final data = json.decode(response.body);
//   //       print(data);
//   //       if (data['status']['success'] == true && data['data'] != null) {
//   //         final balance = double.tryParse(data['data']['balance'].toString());
//   //         print(balance);
//   //         if (balance != null) {
//   //           // Mettre à jour le cache
//   //           _balanceCache[cardID] = balance;
//   //           _balanceCacheTime[cardID] = DateTime.now();
//   //           print('✅ Solde récupéré: $balance XAF');
//   //           return balance;
//   //         }
//   //       }
//   //     }
//   //   } catch (e) {
//   //     print('❌ Erreur lors de la récupération du solde: $e');
//   //     // Ne pas supprimer du cache en cas d'erreur, garder la dernière valeur connue
//   //   }
//   //   return null;
//   // }

//   Future<double?> getCardBalance(String cardID,
//       {bool forceRefresh = false}) async {
//     if (cardID.isEmpty) return null;

//     // Utilisation du cache
//     if (!forceRefresh && _balanceCache.containsKey(cardID)) {
//       final cacheTime = _balanceCacheTime[cardID];
//       if (cacheTime != null &&
//           DateTime.now().difference(cacheTime) < _cacheValidDuration) {
//         print('💰 Solde depuis cache: ${_balanceCache[cardID]} XAF');
//         return _balanceCache[cardID];
//       }
//     }

//     try {
//       print('💳 Génération du token pour la carte: $cardID');
//       final token = await _tokenService.createCardToken(cardID);

//       if (token == null) throw Exception("Token non obtenu pour $cardID");
//       final url = Uri.parse(
//           'https://api.dev.onyfastbank.com/v2/balance.php?cardID=$cardID');

//       print('🔑 Token utilisé: $token');

//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//           'User-Agent': 'Onyfast-Mobile-App',
//         },
//       ).timeout(Duration(seconds: 30));

//       print('📡 Requête balance status: ${response.statusCode}');

//       final data = json.decode(response.body);
//       print('🧪 JSON balance brut: ${json.encode(data)}');
//       if (response.statusCode == 200 &&
//           data['status']?['success'] == true &&
//           data['data'] != null) {
//         final balanceRaw = data['data']['balance'] ??
//             data['data']['amount'] ??
//             data['data']['solde'];
//         print(balanceRaw);
//         final balance = double.tryParse(balanceRaw.toString());
//         if (balance != null) {
//           _balanceCache[cardID] = balance;
//           _balanceCacheTime[cardID] = DateTime.now();
//           print('✅ Solde mis à jour: $balance XAF');
//           return balance;
//         } else {
//           throw Exception('Format balance invalide: $balanceRaw');
//         }
//       } else {
//         throw Exception(data['status']?['message'] ?? 'Erreur inconnue');
//       }
//     } catch (e) {
//       print('❌ Erreur getCardBalance(): $e');
//       _showErrorSnackbar('Erreur récupération du solde');
//     }

//     return null;
//   }

//   // Mise à jour du solde avec état de chargement
//   Future<void> updateCurrentCardBalance({bool showLoading = false}) async {
//     final card = currentCard;
//     if (card == null || card.cardID.isEmpty || card.type == CardType.none)
//       return;

//     if (showLoading) {
//       isRefreshing.value = true;
//     }

//     try {
//       print('🔄 Mise à jour du solde de la carte actuelle...');

//       final balance = await getCardBalance(card.cardID);
//       if (balance != null) {
//         final index = cards.indexWhere((c) => c.cardID == card.cardID);
//         if (index != -1) {
//           cards[index] = cards[index].copyWith(balance: balance);
//           print('✅ Solde mis à jour dans la liste des cartes');
//         }
//       }
//     } finally {
//       if (showLoading) {
//         isRefreshing.value = false;
//       }
//     }
//   }

//   // Mise à jour de tous les soldes
//   Future<void> updateAllBalances() async {
//     final futures = cards
//         .where((card) => card.cardID.isNotEmpty && card.type != CardType.none)
//         .map((card) async {
//       final balance = await getCardBalance(card.cardID, forceRefresh: true);
//       if (balance != null) {
//         final index = cards.indexWhere((c) => c.cardID == card.cardID);
//         if (index != -1) {
//           cards[index] = cards[index].copyWith(balance: balance);
//         }
//       }
//     });

//     await Future.wait(futures);
//     print('✅ Tous les soldes mis à jour');
//   }

//   // Rechargement complet avec indicateur
//   Future<void> refreshData() async {
//     print('🔄 Rechargement complet des données...');
//     isRefreshing.value = true;

//     try {
//       // Vider le cache des soldes pour forcer le refresh
//       _balanceCache.clear();
//       _balanceCacheTime.clear();

//       await loadUserProfile();
//       await updateAllBalances();
//       await recupereTransactions();

//       Get.snackbar(
//         'Succès',
//         'Données mises à jour',
//         snackPosition: SnackPosition.TOP,
//         duration: Duration(seconds: 2),
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//       // Get.snackbar(
//       //   'Succès',
//       //   'Données mises à jour',
//       //   snackPosition: SnackPosition.TOP,
//       //   duration: Duration(seconds: 2),
//       //   backgroundColor: Colors.green,
//       //   colorText: Colors.white,
//       // );
//     } catch (e) {
//       print('❌ Erreur lors du refresh: $e');
//     } finally {
//       isRefreshing.value = false;
//       print('✅ Rechargement terminé');
//     }
//   }

//   // MODIFICATION: Validation améliorée pour les transactions selon le type d'opération
//   bool _validateCardForTransaction(CardData? card, String operation) {
//     if (card == null) {
//       _showErrorSnackbar('Aucune carte sélectionnée pour $operation');
//       return false;
//     }

//     if (card.type == CardType.none) {
//       _showErrorSnackbar('Aucune carte disponible pour $operation');
//       return false;
//     }

//     // Pour certaines opérations (comme la consultation), on n'a pas besoin que la carte soit active
//     final consultationOperations = [
//       'consultation',
//       'détails',
//       'pan',
//       'historique',
//       'gestion'
//     ];
//     if (consultationOperations
//         .any((op) => operation.toLowerCase().contains(op))) {
//       return true;
//     }

//     // Pour les opérations financières, la carte doit être active
//     if (!card.isActive) {
//       _showErrorSnackbar(
//           'Cette carte est bloquée. Débloquez-la pour effectuer un $operation');
//       return false;
//     }

//     return true;
//   }

//   // Actions sur les cartes avec validation renforcée
//   Future<void> depositToCard() async {
//     final card = currentCard;
//     if (!_validateCardForTransaction(card, 'dépôt')) return;

//     // Get.toNamed('/', arguments: {
//     //   'cardID': card!.cardID,
//     //   'cardType': card.type.name,
//     //   'cardNumber': card.maskedCardNumber,
//     //   'holderName': card.holderName,
//     //   'isActive': card.isActive,
//     // });

//     Get.to(() => RechargeCartePage(), arguments: {
//       'cardID': card!.cardID,
//       'cardType': card.type.name,
//       'cardNumber': card.maskedCardNumber,
//       'holderName': card.holderName,
//       'isActive': card.isActive,
//     });
//   }

//   Future<void> withdrawFromCard() async {
//     final card = currentCard;
//     if (!_validateCardForTransaction(card, 'retrait')) return;

//     // Vérifier le solde avant le retrait
//     await updateCurrentCardBalance(showLoading: true);
//     final updatedCard = currentCard;

//     if (updatedCard?.balance == null || updatedCard!.balance! <= 0) {
//       _showErrorSnackbar('Solde insuffisant pour effectuer un retrait');
//       return;
//     }

//     // Get.toNamed('/withdraw', arguments: {
//     //   'cardID': card!.cardID,
//     //   'cardType': card.type.name,
//     //   'cardNumber': card.maskedCardNumber,
//     //   'balance': updatedCard.balance,
//     //   'holderName': card.holderName,
//     //   'isActive': card.isActive,
//     // });

//     Get.to(() => DechargeCartePage(), arguments: {
//       'cardID': card!.cardID,
//       'cardType': card.type.name,
//       'cardNumber': card.maskedCardNumber,
//       'holderName': card.holderName,
//       'isActive': card.isActive,
//     });
//   }

//   Future<void> manageCard() async {
//     final card = currentCard;
//     // MODIFICATION: Permettre la gestion même pour les cartes bloquées
//     if (!_validateCardForTransaction(card, 'gestion')) return;

//     Get.toNamed('/card_management', arguments: {
//       'cardID': card!.cardID,
//       'cardType': card.type.name,
//       'cardNumber': card.maskedCardNumber,
//       'isActive': card.isActive,
//       'holderName': card.holderName,
//     });
//   }

//   // NOUVEAU: Méthode pour consulter les détails (disponible même pour cartes bloquées)
//   Future<void> viewCardDetails() async {
//     final card = currentCard;
//     if (!_validateCardForTransaction(card, 'consultation')) return;

//     CardExternalLauncher.launchCardDetails(
//       card!.cardID,
//       card.maskedCardNumber.replaceAll("•", "").replaceAll(" ", ""),
//     );
//   }

//   // Toggle du statut de carte avec confirmation
//   Future<void> toggleCardStatus() async {
//     final card = currentCard;
//     print('vous avez cliquer sur le bouton débloquer ');
//     print(card);
//     if (card == null || card.type == CardType.none) return;

//     // Confirmation avant l'action
//     final action = card.isActive ? 'bloquer' : 'débloquer';
//     final confirmed = await Get.dialog<bool>(
//           AlertDialog(
//             title: Text('Confirmation'),
//             content: Text('Voulez-vous vraiment $action cette carte ?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Get.back(result: false),
//                 child: Text('Annuler'),
//               ),
//               TextButton(
//                 onPressed: () => Get.back(result: true),
//                 child: Text('Confirmer'),
//               ),
//             ],
//           ),
//         ) ??
//         false;

//     if (!confirmed) return;

//     try {
//       isLoading.value = true;
//       print('🔄 Changement du statut de la carte...');

//       final profile = userProfile.value;
//       if (profile == null) return;

//       final phoneNumber = _tokenService.phoneNumber ?? profile.phone;

//       final response = await _tokenService
//           .get(
//               'toggle_card_status.php?accountId=${card.cardID}&last4Digits=${card.cardNumber}&phone=$phoneNumber&typeCarte=${card.type == CardType.physical ? 1 : 2}')
//           .timeout(Duration(seconds: 30));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           print('✅ Statut de la carte modifié avec succès');

//           // Recharger le profil pour mettre à jour les données
//           await loadUserProfile();

//           Get.snackbar(
//             'Succès',
//             data['message'] ?? 'Statut de la carte mis à jour',
//             snackPosition: SnackPosition.TOP,
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//           );
//         } else {
//           throw Exception(
//               data['message'] ?? 'Erreur lors du changement de statut');
//         }
//       } else {
//         throw Exception('Erreur HTTP: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ Erreur lors du changement de statut: $e');
//       _showErrorSnackbar(_getErrorMessage(e));
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // NOUVEAU: Récupération des transactions
//   Future<void> recupereTransactions() async {
//     final card = currentCard;
//     if (card == null || card.cardID.isEmpty || card.type == CardType.none) {
//       transactions.clear();
//       return;
//     }

//     try {
//       print('🔄 Récupération des transactions pour la carte: ${card.cardID}');

//       final response = await _tokenService
//           .get('transactions.php?cardID=${card.cardID}')
//           .timeout(Duration(seconds: 30));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           final List<Transaction> txList = [];
//           for (var txData in data['data']) {
//             txList.add(Transaction.fromJson(txData));
//           }
//           transactions.assignAll(txList);
//           print('✅ ${transactions.length} transactions récupérées');
//         }
//       }
//     } catch (e) {
//       print('❌ Erreur lors de la récupération des transactions: $e');
//       transactions.clear();
//     }
//   }

//   // Méthodes utilitaires privées
//   bool _isNetworkError(dynamic error) {
//     final errorStr = error.toString();
//     return errorStr.contains('SocketException') ||
//         errorStr.contains('TimeoutException') ||
//         errorStr.contains('ClientException');
//   }

//   void _showErrorSnackbar(String message) {
//     Get.snackbar(
//       'Erreur',
//       message,
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: Get.theme.colorScheme.error,
//       colorText: Get.theme.colorScheme.onError,
//       duration: Duration(seconds: 4),
//     );
//   }

//   // Getters améliorés
//   CardData? get currentCard =>
//       cards.isNotEmpty ? cards[currentCardIndex.value] : null;

//   bool get hasMultipleCards => cards.length > 1;
//   bool get canShowPrevious => currentCardIndex.value > 0;
//   bool get canShowNext => currentCardIndex.value < cards.length - 1;
//   bool get hasAnyCard => cards.isNotEmpty && cards.first.type != CardType.none;
//   bool get hasActiveCard => currentCard?.isActive == true;
//   bool get isLoadingOrRefreshing => isLoading.value || isRefreshing.value;

//   // Nouvelle méthode pour obtenir les statistiques des cartes
//   Map<String, dynamic> get cardStats {
//     return {
//       'total': cards.length,
//       'active': cards.where((c) => c.isActive).length,
//       'blocked':
//           cards.where((c) => !c.isActive && c.type != CardType.none).length,
//       'physical': cards.where((c) => c.type == CardType.physical).length,
//       'virtual': cards.where((c) => c.type == CardType.virtual).length,
//       'totalBalance': cards
//           .where((c) => c.balance != null)
//           .fold(0.0, (sum, card) => sum + card.balance!),
//     };
//   }

//   // Formatage amélioré des messages d'erreur
//   String _getErrorMessage(dynamic error) {
//     if (error is TokenExpiredException) {
//       return 'Session expirée, veuillez vous reconnecter';
//     }

//     final errorStr = error.toString();

//     if (errorStr.contains('SocketException')) {
//       return 'Problème de connexion réseau';
//     }

//     if (errorStr.contains('TimeoutException')) {
//       return 'Délai d\'attente dépassé, vérifiez votre connexion';
//     }

//     if (errorStr.contains('FormatException')) {
//       return 'Erreur de format des données reçues';
//     }

//     if (errorStr.contains('HandshakeException')) {
//       return 'Erreur de sécurité SSL';
//     }

//     return errorStr.length > 100
//         ? 'Une erreur technique est survenue'
//         : errorStr;
//   }

//   @override
//   void onClose() {
//     // Nettoyer les caches
//     _balanceCache.clear();
//     _balanceCacheTime.clear();
//     super.onClose();
//   }
// }

// // Modèles de données inchangés mais avec amélioration du UserProfile
// class UserProfile {
//   final int id;
//   final String phone;
//   final int cardID;
//   final String lastName;
//   final String firstName;
//   final String? cardLast4Digits;
//   final String? cardExpireAt;
//   final String email;
//   final String? cardLast4DigitsVirtual;
//   final String? cardExpireAtVirtual;
//   final int? cardIDVirtual;
//   final int activePysique;
//   final int activeVirtuelle;
//   final int actived;
//   final int suspended;
//   final bool hasPhysicalCard;
//   final bool hasVirtualCard;

//   UserProfile({
//     required this.id,
//     required this.phone,
//     required this.cardID,
//     required this.lastName,
//     required this.firstName,
//     this.cardLast4Digits,
//     this.cardExpireAt,
//     required this.email,
//     this.cardLast4DigitsVirtual,
//     this.cardExpireAtVirtual,
//     this.cardIDVirtual,
//     required this.activePysique,
//     required this.activeVirtuelle,
//     required this.actived,
//     required this.suspended,
//     required this.hasPhysicalCard,
//     required this.hasVirtualCard,
//   });

//   factory UserProfile.fromJson(Map<String, dynamic> json) {
//     // Debugging des données reçues
//     print('🔍 DEBUG - Données JSON reçues:');
//     print('   cardID: ${json['cardID']}');
//     print('   cardIDVirtual: ${json['cardIDVirtual']}');
//     print('   activePysique: ${json['activePysique']}');
//     print('   activeVirtuelle: ${json['activeVirtuelle']}');
//     print('   account_summary: ${json['account_summary']}');

//     // Gestion plus robuste du JSON
//     return UserProfile(
//       id: _parseIntSafely(json['id']),
//       phone: json['phone']?.toString() ?? '',
//       cardID: _parseIntSafely(json['cardID']),
//       lastName: json['lastName']?.toString() ?? '',
//       firstName: json['firstName']?.toString() ?? '',
//       cardLast4Digits: json['cardLast4Digits']?.toString(),
//       cardExpireAt: json['cardExpireAt']?.toString(),
//       email: json['email']?.toString() ?? '',
//       cardLast4DigitsVirtual: json['cardLast4DigitsVirtual']?.toString(),
//       cardExpireAtVirtual: json['cardExpireAtVirtual']?.toString(),
//       cardIDVirtual: _parseIntSafelyNullable(json['cardIDVirtual']),
//       activePysique: _parseIntSafely(json['activePysique']),
//       activeVirtuelle: _parseIntSafely(json['activeVirtuelle']),
//       actived: _parseIntSafely(json['actived']),
//       suspended: _parseIntSafely(json['suspended']),
//       // MODIFICATION: Utiliser les IDs de carte pour déterminer l'existence, pas account_summary
//       hasPhysicalCard: _parseIntSafely(json['cardID']) > 0,
//       hasVirtualCard: _parseIntSafelyNullable(json['cardIDVirtual']) != null &&
//           _parseIntSafelyNullable(json['cardIDVirtual'])! > 0,
//     );
//   }

//   static int _parseIntSafely(dynamic value, [int defaultValue = 0]) {
//     if (value == null) return defaultValue;
//     if (value is int) return value;
//     return int.tryParse(value.toString()) ?? defaultValue;
//   }

//   static int? _parseIntSafelyNullable(dynamic value) {
//     if (value == null) return null;
//     if (value is int) return value;
//     return int.tryParse(value.toString());
//   }

//   static bool _parseBoolSafely(dynamic value, [bool defaultValue = false]) {
//     if (value == null) return defaultValue;
//     if (value is bool) return value;
//     if (value is int) return value == 1;
//     if (value is String) return value.toLowerCase() == 'true' || value == '1';
//     return defaultValue;
//   }

//   String get fullName => '$firstName $lastName'.trim();
//   bool get isAccountActive => actived == 1 && suspended == 0;
// }

// enum CardType { physical, virtual, none }

// class CardData {
//   final CardType type;
//   final String cardNumber;
//   final String expiryDate;
//   final String cardID;
//   final bool isActive;
//   final String holderName;
//   final double? balance;

//   CardData({
//     required this.type,
//     required this.cardNumber,
//     required this.expiryDate,
//     required this.cardID,
//     required this.isActive,
//     required this.holderName,
//     this.balance,
//   });

//   CardData copyWith({
//     CardType? type,
//     String? cardNumber,
//     String? expiryDate,
//     String? cardID,
//     bool? isActive,
//     String? holderName,
//     double? balance,
//   }) {
//     return CardData(
//       type: type ?? this.type,
//       cardNumber: cardNumber ?? this.cardNumber,
//       expiryDate: expiryDate ?? this.expiryDate,
//       cardID: cardID ?? this.cardID,
//       isActive: isActive ?? this.isActive,
//       holderName: holderName ?? this.holderName,
//       balance: balance ?? this.balance,
//     );
//   }

//   String get maskedCardNumber {
//     if (cardNumber.length >= 4) {
//       return '•••• •••• •••• $cardNumber';
//     }
//     return '•••• •••• •••• ••••';
//   }

//   String get typeLabel {
//     switch (type) {
//       case CardType.physical:
//         return 'Physical ID:';
//       case CardType.virtual:
//         return 'Virtual ID:';
//       case CardType.none:
//         return 'Aucune carte';
//     }
//   }

//   String get formattedBalance {
//     if (balance == null) return '****';
//     return '${balance!.toStringAsFixed(0)} XAF';
//   }

//   String get statusLabel => isActive ? 'Active' : 'Bloquée';
//   Color get statusColor => isActive ? Colors.green : Colors.red;
// }

// // NOUVEAU: Classe Transaction
// class Transaction {
//   final String? transactionDate;
//   final dynamic totalAmount;
//   final String? description;
//   final String? type;

//   Transaction({
//     this.transactionDate,
//     this.totalAmount,
//     this.description,
//     this.type,
//   });

//   factory Transaction.fromJson(Map<String, dynamic> json) {
//     return Transaction(
//       transactionDate: json['transaction_date']?.toString(),
//       totalAmount: json['total_amount'],
//       description: json['description']?.toString(),
//       type: json['type']?.toString(),
//     );
//   }
// }

// // Placeholder pour PiecesJustificativesController
// class PiecesJustificativesController extends GetxController {
//   var Error = false.obs;
//   var pieces = <PieceJustificative>[].obs;

//   Future<void> fetchPieces() async {
//     // Implementation
//   }
// }

// class PieceJustificative {
//   final bool verificationAdmin;

//   PieceJustificative({required this.verificationAdmin});
// }

// class TokenExpiredException implements Exception {
//   final String message;
//   TokenExpiredException(this.message);

//   @override
//   String toString() => message;
// }

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:onyfast/Services/token_service.dart';
import 'package:onyfast/View/Activit%C3%A9/decharge.dart';
import 'package:onyfast/View/Activit%C3%A9/recharge.dart';
import 'package:onyfast/Widget/alerte.dart';

class ManageCardsController extends GetxController {
  final TokenService _tokenService = Get.find<TokenService>();
  final GetStorage storage = GetStorage();
  static ManageCardsController get to => Get.find();

  // Observable variables
  var isLoading = true.obs;
  var isRefreshing = false.obs;
  var currentCardIndex = 0.obs;
  var userProfile = Rxn<UserProfile>();
  var errorMessage = ''.obs;
  var cards = <CardData>[].obs;
  var toogle = false.obs;
  var transactions = <Transaction>[].obs;
  var TestUserNotFound = true.obs;

  /// pour verifier si l'utilisateur est trouvé ou non
  // Controller pour les pièces justificatives
  final controllerTestPiece = Get.put(PiecesJustificativesController());

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }
  // Ajoute ce getter dans ManageCardsController
bool get isCardDisplayed =>
    !isLoading.value &&
    !isRefreshing.value &&
    TestUserNotFound.value == true &&
    errorMessage.value.isEmpty &&
    currentCard != null;
  // Initialisation centralisée
  void _initializeController() {
    loadUserProfile();

    // Écouter les changements d'état de connexion
    ever(_tokenService.isLoggedIn, (isLoggedIn) {
      if (!isLoggedIn) {
        _clearUserData();
      } else {
        // Recharger les données lors de la reconnexion
        loadUserProfile();
      }
    });
  }

  // Méthode centralisée pour effacer les données
  void _clearUserData() {
    userProfile.value = null;
    cards.clear();
    currentCardIndex.value = 0;
    errorMessage.value = '';
    transactions.clear();
  }

  // Navigation entre cartes avec validation
  void nextCard() {
    if (cards.isNotEmpty && currentCardIndex.value < cards.length - 1) {
      currentCardIndex.value++;
      // Optionnel: charger le solde de la nouvelle carte
      updateCurrentCardBalance();
    }
  }

  void previousCard() {
    if (currentCardIndex.value > 0) {
      currentCardIndex.value--;
      // Optionnel: charger le solde de la nouvelle carte
      updateCurrentCardBalance();
    }
  }

  // Aller à une carte spécifique
  void goToCard(int index) {
    if (index >= 0 && index < cards.length) {
      currentCardIndex.value = index;
      updateCurrentCardBalance();
    }
  }

  // Chargement du profil utilisateur avec retry automatique
  Future<void> loadUserProfile({int retryCount = 0}) async {
    const maxRetries = 3;
    TestUserNotFound.value = true;
    try {
      if (retryCount == 0) {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final phoneNumber = _tokenService.phoneNumber;
      if (phoneNumber == null) {
        throw Exception('Numéro de téléphone non disponible');
      }

      print(
          '🔍 Chargement du profil pour le téléphone: $phoneNumber (tentative ${retryCount + 1})');

      final response = await _tokenService
          .get('user_card_profil_by_phone_test.php?phone=$phoneNumber')
          .timeout(Duration(seconds: 30));

      print('📱 Réponse reçue - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status']['success'] == true) {
          print('✅ Profil chargé avec succès');
          userProfile.value = UserProfile.fromJson(data['data']);
          _buildCardsFromProfile();

          // Charger le solde de la première carte
          if (cards.isNotEmpty) {
            await updateCurrentCardBalance();
          }
        } else {
          throw Exception(data['status']['message'] ?? 'Erreur serveur');
        }
      } else {
        print('Nous sommes ici');
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } on TokenExpiredException catch (e) {
      print('🔄 Token expiré: $e');
      _tokenService.handleSessionError();
    } catch (e) {
      String message = e.toString().replaceFirst("Exception: ", "");

      print('❌ Erreur lors du chargement du profil: *$message*');

      // Vérifier si le message correspond exactement
      if (message == "Aucune carte trouvée") {
        TestUserNotFound.value = false;
      } else
        TestUserNotFound.value = true;
      // Retry automatique pour les erreurs réseau
      if (retryCount < maxRetries && _isNetworkError(e)) {
        print('🔄 Nouvelle tentative dans 2 secondes...');
        await Future.delayed(Duration(seconds: 2));
        return loadUserProfile(retryCount: retryCount + 1);
      }

      errorMessage.value =
          _getErrorMessage(e.toString().replaceFirst("Exception: ", ""));
      // _showErrorSnackbar('La connexion est instable');
    } finally {
      isLoading.value = false;
    }
  }

  // MODIFICATION PRINCIPALE: Construire la liste des cartes avec TOUTES les cartes (actives et bloquées)
  void _buildCardsFromProfile() {
    cards.clear();
    final profile = userProfile.value;

    if (profile == null) return;

    final List<CardData> newCards = [];

    // Carte physique - Ajouter si cardID existe (peu importe hasPhysicalCard ou statut actif)
    if (profile.cardID > 0) {
      newCards.add(CardData(
        type: CardType.physical,
        cardNumber: profile.cardLast4Digits ?? '****',
        expiryDate: profile.cardExpireAt ?? '**/**',
        cardID: profile.cardID.toString(),
        isActive: profile.activePysique ==
            1, // Garder le statut RÉEL (actif ou bloqué)
        holderName: '${profile.firstName} ${profile.lastName}',
        balance: null,
      ));
      print(
          '✅ Carte physique ajoutée - ID: ${profile.cardID}, Active: ${profile.activePysique == 1}');
    }

    // Carte virtuelle - Ajouter si cardIDVirtual existe (peu importe hasVirtualCard ou statut actif)
    if (profile.cardIDVirtual != null && profile.cardIDVirtual! > 0) {
      newCards.add(CardData(
        type: CardType.virtual,
        cardNumber: profile.cardLast4DigitsVirtual ?? '****',
        expiryDate: profile.cardExpireAtVirtual ?? '**/**',
        cardID: profile.cardIDVirtual!.toString(),
        isActive: profile.activeVirtuelle ==
            1, // Garder le statut RÉEL (actif ou bloqué)
        holderName: '${profile.firstName} ${profile.lastName}',
        balance: null,
      ));
      print(
          '✅ Carte virtuelle ajoutée - ID: ${profile.cardIDVirtual}, Active: ${profile.activeVirtuelle == 1}');
    }

    // Debugging: Afficher les valeurs du profil pour diagnostic
    print('🔍 DEBUG - Profil utilisateur:');
    print('   cardID: ${profile.cardID}');
    print('   cardIDVirtual: ${profile.cardIDVirtual}');
    print('   hasPhysicalCard: ${profile.hasPhysicalCard}');
    print('   hasVirtualCard: ${profile.hasVirtualCard}');
    print('   activePysique: ${profile.activePysique}');
    print('   activeVirtuelle: ${profile.activeVirtuelle}');

    // Si aucune carte trouvée, ajouter une carte par défaut
    if (newCards.isEmpty) {
      newCards.add(CardData(
        type: CardType.none,
        cardNumber: '****',
        expiryDate: '**/**',
        cardID: '',
        isActive: false,
        holderName: 'Aucune carte',
        balance: null,
      ));
      print('⚠️ Aucune carte trouvée, carte par défaut ajoutée');
    }

    cards.assignAll(newCards);

    // Réinitialiser l'index si nécessaire
    if (currentCardIndex.value >= cards.length) {
      currentCardIndex.value = 0;
    }

    print('📋 ${cards.length} carte(s) trouvée(s) au total:');
    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      print(
          '   $i: ${card.typeLabel} - ID: ${card.cardID} - Active: ${card.isActive}');
    }
  }

  // Récupération du solde avec cache temporaire
  final Map<String, double> _balanceCache = {};
  final Map<String, DateTime> _balanceCacheTime = {};
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Future<double?> getCardBalance(String cardID,
  //     {bool forceRefresh = false}) async {
  //   if (cardID.isEmpty) return null;

  //   // Vérifier le cache si pas de refresh forcé
  //   if (!forceRefresh && _balanceCache.containsKey(cardID)) {
  //     final cacheTime = _balanceCacheTime[cardID];
  //     if (cacheTime != null &&
  //         DateTime.now().difference(cacheTime) < _cacheValidDuration) {
  //       print(
  //           '💰 Solde récupéré depuis le cache: ${_balanceCache[cardID]} XAF');
  //       return _balanceCache[cardID];
  //     }
  //   }

  //   try {
  //     print('💰 Récupération du solde pour la carte: $cardID');
  //     print('entrer');

  //     final response = await _tokenService
  //         .get('balance.php?cardID=$cardID')
  //         .timeout(Duration(seconds: 10));

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       print(data);
  //       if (data['status']['success'] == true && data['data'] != null) {
  //         final balance = double.tryParse(data['data']['balance'].toString());
  //         print(balance);
  //         if (balance != null) {
  //           // Mettre à jour le cache
  //           _balanceCache[cardID] = balance;
  //           _balanceCacheTime[cardID] = DateTime.now();
  //           print('✅ Solde récupéré: $balance XAF');
  //           return balance;
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print('❌ Erreur lors de la récupération du solde: $e');
  //     // Ne pas supprimer du cache en cas d'erreur, garder la dernière valeur connue
  //   }
  //   return null;
  // }

  Future<double?> getCardBalance(String cardID,
      {bool forceRefresh = false}) async {
    if (cardID.isEmpty) return null;

    // Utilisation du cache
    if (!forceRefresh && _balanceCache.containsKey(cardID)) {
      final cacheTime = _balanceCacheTime[cardID];
      if (cacheTime != null &&
          DateTime.now().difference(cacheTime) < _cacheValidDuration) {
        print('💰 Solde depuis cache: ${_balanceCache[cardID]} XAF');
        return _balanceCache[cardID];
      }
    }

    try {
      print('💳 Génération du token pour la carte: $cardID');
      final token = await _tokenService.createCardToken(cardID);

      if (token == null) throw Exception("Token non obtenu pour $cardID");
      final url = Uri.parse(
          'https://api.dev.onyfastbank.com/v2/balance.php?cardID=$cardID');

      print('🔑 Token utilisé: $token');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'User-Agent': 'Onyfast-Mobile-App',
        },
      ).timeout(Duration(seconds: 30));

      print('📡 Requête balance status: ${response.statusCode}');

      final data = json.decode(response.body);
      print('🧪 JSON balance brut: ${json.encode(data)}');
      if (response.statusCode == 200 &&
          data['status']?['success'] == true &&
          data['data'] != null) {
        final balanceRaw = data['data']['balance'] ??
            data['data']['amount'] ??
            data['data']['solde'];
        print(balanceRaw);
        final balance = double.tryParse(balanceRaw.toString());
        if (balance != null) {
          _balanceCache[cardID] = balance;
          _balanceCacheTime[cardID] = DateTime.now();
          print('✅ Solde mis à jour: $balance XAF');
          return balance;
        } else {
          throw Exception('Format balance invalide: $balanceRaw');
        }
      } else {
        throw Exception(data['status']?['message'] ?? 'Erreur inconnue');
      }
    } catch (e) {
      print('❌ Erreur getCardBalance(): $e');
      // SnackBarService.warning('Erreur récupération du solde');
    }

    return null;
  }

  // Mise à jour du solde avec état de chargement
  Future<void> updateCurrentCardBalance({bool showLoading = false}) async {
    final card = currentCard;
    if (card == null || card.cardID.isEmpty || card.type == CardType.none)
      return;

    if (showLoading) {
      isRefreshing.value = true;
    }

    try {
      print('🔄 Mise à jour du solde de la carte actuelle...');

      final balance = await getCardBalance(card.cardID);
      if (balance != null) {
        final index = cards.indexWhere((c) => c.cardID == card.cardID);
        if (index != -1) {
          cards[index] = cards[index].copyWith(balance: balance);
          print('✅ Solde mis à jour dans la liste des cartes');
        }
      }
    } finally {
      if (showLoading) {
        isRefreshing.value = false;
      }
    }
  }

  // Mise à jour de tous les soldes
  Future<void> updateAllBalances() async {
    final futures = cards
        .where((card) => card.cardID.isNotEmpty && card.type != CardType.none)
        .map((card) async {
      final balance = await getCardBalance(card.cardID, forceRefresh: true);
      if (balance != null) {
        final index = cards.indexWhere((c) => c.cardID == card.cardID);
        if (index != -1) {
          cards[index] = cards[index].copyWith(balance: balance);
        }
      }
    });

    await Future.wait(futures);
    print('✅ Tous les soldes mis à jour');
  }

  // Rechargement complet avec indicateur
  Future<void> refreshData() async {
    print('🔄 Rechargement complet des données...');
    isRefreshing.value = true;

    try {
      // Vider le cache des soldes pour forcer le refresh
      _balanceCache.clear();
      _balanceCacheTime.clear();

      await loadUserProfile();
      await updateAllBalances();
      await recupereTransactions();

      // Get.snackbar(
      //   'Succès',
      //   'Données mises à jour',
      //   snackPosition: SnackPosition.TOP,
      //   duration: Duration(seconds: 2),
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      // );
    } catch (e) {
      print('❌ Erreur lors du refresh: $e');
    } finally {
      isRefreshing.value = false;
      print('✅ Rechargement terminé');
    }
  }

  // MODIFICATION: Validation améliorée pour les transactions selon le type d'opération
  bool _validateCardForTransaction(CardData? card, String operation) {
    if (card == null) {
      SnackBarService.info('Aucune carte sélectionnée pour $operation');
      return false;
    }

    if (card.type == CardType.none) {
      SnackBarService.info('Aucune carte disponible pour $operation');
      return false;
    }

    // Pour certaines opérations (comme la consultation), on n'a pas besoin que la carte soit active
    final consultationOperations = [
      'consultation',
      'détails',
      'pan',
      'historique',
      'gestion'
    ];
    if (consultationOperations
        .any((op) => operation.toLowerCase().contains(op))) {
      return true;
    }

    // Pour les opérations financières, la carte doit être active
    if (!card.isActive) {
      SnackBarService.info(
          'Cette carte est bloquée. Débloquez-la pour effectuer un $operation');
      return false;
    }

    return true;
  }

  // Actions sur les cartes avec validation renforcée
  Future<void> depositToCard() async {
    final card = currentCard;
    if (!_validateCardForTransaction(card, 'dépôt')) return;

    // Get.toNamed('/', arguments: {
    //   'cardID': card!.cardID,
    //   'cardType': card.type.name,
    //   'cardNumber': card.maskedCardNumber,
    //   'holderName': card.holderName,
    //   'isActive': card.isActive,
    // });

    Get.to(RechargeCartePage(), arguments: {
      'cardID': card!.cardID,
      'cardType': card.type.name,
      'cardNumber': card.maskedCardNumber,
      'holderName': card.holderName,
      'isActive': card.isActive,
    });
  }

  Future<void> withdrawFromCard() async {
    final card = currentCard;
    if (!_validateCardForTransaction(card, 'retrait')) return;

    // Vérifier le solde avant le retrait
    await updateCurrentCardBalance(showLoading: true);
    final updatedCard = currentCard;

    if (updatedCard?.balance == null || updatedCard!.balance! <= 0) {
      SnackBarService.warning('Solde insuffisant pour effectuer un retrait');
      return;
    }

    // Get.toNamed('/withdraw', arguments: {
    //   'cardID': card!.cardID,
    //   'cardType': card.type.name,
    //   'cardNumber': card.maskedCardNumber,
    //   'balance': updatedCard.balance,
    //   'holderName': card.holderName,
    //   'isActive': card.isActive,
    // });

    Get.to(DechargeCartePage(), arguments: {
      'cardID': card!.cardID,
      'cardType': card.type.name,
      'cardNumber': card.maskedCardNumber,
      'holderName': card.holderName,
      'isActive': card.isActive,
    });
  }

  Future<void> manageCard() async {
    final card = currentCard;
    // MODIFICATION: Permettre la gestion même pour les cartes bloquées
    if (!_validateCardForTransaction(card, 'gestion')) return;

    Get.toNamed('/card_management', arguments: {
      'cardID': card!.cardID,
      'cardType': card.type.name,
      'cardNumber': card.maskedCardNumber,
      'isActive': card.isActive,
      'holderName': card.holderName,
    });
  }

  // NOUVEAU: Méthode pour consulter les détails (disponible même pour cartes bloquées)
  Future<void> viewCardDetails() async {
    final card = currentCard;
    if (!_validateCardForTransaction(card, 'consultation')) return;

    Get.toNamed('/card_details', arguments: {
      'cardID': card!.cardID,
      'cardType': card.type.name,
      'cardNumber': card.maskedCardNumber,
      'holderName': card.holderName,
      'isActive': card.isActive,
      'balance': card.balance,
    });
  }

  // Toggle du statut de carte avec confirmation
  Future<void> toggleCardStatus() async {
    final card = currentCard;
    print('vous avez cliquer sur le bouton débloquer ');
    print(card);
    if (card == null || card.type == CardType.none) return;

    // Confirmation avant l'action
    final action = card.isActive ? 'bloquer' : 'débloquer';
    final confirmed = await Get.dialog<bool>(
         Theme.of(Get.context!).platform == TargetPlatform.iOS
      ? CupertinoAlertDialog(
          title: const Text('Confirmation'),
          content: Text(
            'Vous serez débité de 500 FCFA pour cette opération\n\nVoulez-vous vraiment $action cette carte ?',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Get.back(result: false),
              child: const Text('Annuler'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Get.back(result: true),
              child: const Text('Confirmer'),
            ),
          ],
        )
      : AlertDialog(
          title: const Text('Confirmation'),
          content: Text(
            'Vous serez débité de 500 FCFA pour cette opération\n\nVoulez-vous vraiment $action cette carte ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Confirmer'),
            ),
          ],
        ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      isLoading.value = true;
      print('🔄 Changement du statut de la carte...');

      final profile = userProfile.value;
      if (profile == null) return;

      final phoneNumber = _tokenService.phoneNumber ?? profile.phone;

      final response = await _tokenService
          .get(
              'toggle_card_status.php?accountId=${card.cardID}&last4Digits=${card.cardNumber}&phone=$phoneNumber&typeCarte=${card.type == CardType.physical ? 1 : 2}')
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Statut de la carte modifié avec succès');

          // Recharger le profil pour mettre à jour les données
          await loadUserProfile();

          // Get.snackbar(
          //   'Succès',
          //   data['message'] ?? 'Statut de la carte mis à jour',
          //   snackPosition: SnackPosition.TOP,
          //   backgroundColor: Colors.green,
          //   colorText: Colors.white,
          // );
        } else {
          final data = json.decode(response.body);
          SnackBarService.error(data['message'] ?? 'Erreur lors du changement de statut ');
          throw Exception(
              data['message'] ?? 'Erreur lors du changement de statut');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur lors du changement de statut: ${e.toString()}');
      // _showErrorSnackbar(_getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  // NOUVEAU: Récupération des transactions
  Future<void> recupereTransactions() async {
    final card = currentCard;
    if (card == null || card.cardID.isEmpty || card.type == CardType.none) {
      transactions.clear();
      return;
    }
    var token = await _tokenService.createCardAuthToken(card.cardID);

    print('token transaction');
    print(token);

    try {
      print('🔄 Récupération des transactions pour la carte: ${card.cardID}');

      var headers = {
        'Authorization': 'Bearer $token',
        "Accept": "application/json",
        'X-Device-Key': 'b08Zhc601YHR4LCV2gSD2cppAT0Ex+7wwbwAb/Y2thg=',
        'X-Client': 'OnyFast-Mobile-App'
      };
      var dio = Dio();
      var response = await dio.request(
        'https://api.dev.onyfastbank.com/v2/transaction.php?cardID=${card.cardID}',
        options: Options(method: 'GET', headers: headers),
      );

      // if (response.statusCode == 200) {
      //   print(json.encode(response.data));
      // } else {
      //   print(response.statusMessage);
      // }

      // final response = await _tokenService
      //     .get('transaction.php?cardID=${card.cardID}')
      //     .timeout(Duration(seconds: 30));

      // print('📡 Requête transaction status: ${json.decode(response.body)}');

      // if (response.statusCode == 200) {
      //   final data = json.decode(response.data);
      //   if (data['success'] == true && data['data'] != null) {
      //     final List<Transaction> txList = [];
      //     for (var txData in data['data']) {
      //       txList.add(Transaction.fromJson(txData));
      //     }
      //     transactions.assignAll(txList);
      //     print('✅ ${transactions.length} transactions récupérées');
      //   }
      // }

      if (response.statusCode == 200) {
        final data = response.data; // pas besoin de json.decode

        if (data['status'] != null &&
            data['status']['success'] == true &&
            data['data'] != null &&
            data['data']['transactionActivities'] != null) {
          final List<Transaction> txList = [];
          for (var txData in data['data']['transactionActivities']) {
            txList.add(Transaction.fromJson(txData));
          }

          transactions.assignAll(txList);
          print('✅ ${transactions.length} transactions récupérées');
        } else {
          print('⚠️ Aucune transaction trouvée');
        }
      } else {
        print('❌ Erreur API : ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des transactions: $e');
      transactions.clear();
    }
  }

  // Méthodes utilitaires privées
  bool _isNetworkError(dynamic error) {
    final errorStr = error.toString();
    return errorStr.contains('SocketException') ||
        errorStr.contains('TimeoutException') ||
        errorStr.contains('ClientException');
  }

  // Getters améliorés
  CardData? get currentCard =>
      cards.isNotEmpty ? cards[currentCardIndex.value] : null;

  bool get hasMultipleCards => cards.length > 1;
  bool get canShowPrevious => currentCardIndex.value > 0;
  bool get canShowNext => currentCardIndex.value < cards.length - 1;
  bool get hasAnyCard => cards.isNotEmpty && cards.first.type != CardType.none;
  bool get hasActiveCard => currentCard?.isActive == true;
  bool get isLoadingOrRefreshing => isLoading.value || isRefreshing.value;

  // Nouvelle méthode pour obtenir les statistiques des cartes
  Map<String, dynamic> get cardStats {
    return {
      'total': cards.length,
      'active': cards.where((c) => c.isActive).length,
      'blocked':
          cards.where((c) => !c.isActive && c.type != CardType.none).length,
      'physical': cards.where((c) => c.type == CardType.physical).length,
      'virtual': cards.where((c) => c.type == CardType.virtual).length,
      'totalBalance': cards
          .where((c) => c.balance != null)
          .fold(0.0, (sum, card) => sum + card.balance!),
    };
  }

  // Formatage amélioré des messages d'erreur
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

    if (errorStr.contains('HandshakeException')) {
      return 'Erreur de sécurité SSL';
    }

    return errorStr.length > 100
        ? 'Une erreur technique est survenue'
        : errorStr;
  }

  @override
  void onClose() {
    // Nettoyer les caches
    _balanceCache.clear();
    _balanceCacheTime.clear();
    super.onClose();
  }
}

// Modèles de données inchangés mais avec amélioration du UserProfile
class UserProfile {
  final int id;
  final String phone;
  final int cardID;
  final String lastName;
  final String firstName;
  final String? cardLast4Digits;
  final String? cardExpireAt;
  final String email;
  final String? cardLast4DigitsVirtual;
  final String? cardExpireAtVirtual;
  final int? cardIDVirtual;
  final int activePysique;
  final int activeVirtuelle;
  final int actived;
  final int suspended;
  final bool hasPhysicalCard;
  final bool hasVirtualCard;

  UserProfile({
    required this.id,
    required this.phone,
    required this.cardID,
    required this.lastName,
    required this.firstName,
    this.cardLast4Digits,
    this.cardExpireAt,
    required this.email,
    this.cardLast4DigitsVirtual,
    this.cardExpireAtVirtual,
    this.cardIDVirtual,
    required this.activePysique,
    required this.activeVirtuelle,
    required this.actived,
    required this.suspended,
    required this.hasPhysicalCard,
    required this.hasVirtualCard,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Debugging des données reçues
    print('🔍 DEBUG - Données JSON reçues:');
    print('   cardID: ${json['cardID']}');
    print('   cardIDVirtual: ${json['cardIDVirtual']}');
    print('   activePysique: ${json['activePysique']}');
    print('   activeVirtuelle: ${json['activeVirtuelle']}');
    print('   account_summary: ${json['account_summary']}');

    // Gestion plus robuste du JSON
    return UserProfile(
      id: _parseIntSafely(json['id']),
      phone: json['phone']?.toString() ?? '',
      cardID: _parseIntSafely(json['cardID']),
      lastName: json['lastName']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      cardLast4Digits: json['cardLast4Digits']?.toString(),
      cardExpireAt: json['cardExpireAt']?.toString(),
      email: json['email']?.toString() ?? '',
      cardLast4DigitsVirtual: json['cardLast4DigitsVirtual']?.toString(),
      cardExpireAtVirtual: json['cardExpireAtVirtual']?.toString(),
      cardIDVirtual: _parseIntSafelyNullable(json['cardIDVirtual']),
      activePysique: _parseIntSafely(json['activePysique']),
      activeVirtuelle: _parseIntSafely(json['activeVirtuelle']),
      actived: _parseIntSafely(json['actived']),
      suspended: _parseIntSafely(json['suspended']),
      // MODIFICATION: Utiliser les IDs de carte pour déterminer l'existence, pas account_summary
      hasPhysicalCard: _parseIntSafely(json['cardID']) > 0,
      hasVirtualCard: _parseIntSafelyNullable(json['cardIDVirtual']) != null &&
          _parseIntSafelyNullable(json['cardIDVirtual'])! > 0,
    );
  }

  static int _parseIntSafely(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  static int? _parseIntSafelyNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _parseBoolSafely(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }

  String get fullName => '$firstName $lastName'.trim();
  bool get isAccountActive => actived == 1 && suspended == 0;
}

enum CardType { physical, virtual, none }

class CardData {
  final CardType type;
  final String cardNumber;
  final String expiryDate;
  final String cardID;
  final bool isActive;
  final String holderName;
  final double? balance;

  CardData({
    required this.type,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardID,
    required this.isActive,
    required this.holderName,
    this.balance,
  });

  CardData copyWith({
    CardType? type,
    String? cardNumber,
    String? expiryDate,
    String? cardID,
    bool? isActive,
    String? holderName,
    double? balance,
  }) {
    return CardData(
      type: type ?? this.type,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cardID: cardID ?? this.cardID,
      isActive: isActive ?? this.isActive,
      holderName: holderName ?? this.holderName,
      balance: balance ?? this.balance,
    );
  }

  String get maskedCardNumber {
    if (cardNumber.length >= 4) {
      return '•••• •••• •••• $cardNumber';
    }
    return '•••• •••• •••• ••••';
  }

  String get typeLabel {
    switch (type) {
      case CardType.physical:
        return 'Physical ID:';
      case CardType.virtual:
        return 'Virtual ID:';
      case CardType.none:
        return 'Aucune carte';
    }
  }

  String get formattedBalance {
    if (balance == null) return '****';
    return '${balance!.toStringAsFixed(0)} XAF';
  }

  String get statusLabel => isActive ? 'Active' : 'Bloquée';
  Color get statusColor => isActive ? Colors.green : Colors.red;
}

// NOUVEAU: Classe Transaction
// class Transaction {
//   final String? transactionDate;
//   final dynamic totalAmount;
//   final String? description;
//   final String? type;

//   Transaction({
//     this.transactionDate,
//     this.totalAmount,
//     this.description,
//     this.type,
//   });

//   factory Transaction.fromJson(Map<String, dynamic> json) {
//     return Transaction(
//       transactionDate: json['transaction_date']?.toString(),
//       totalAmount: json['total_amount'],
//       description: json['description']?.toString(),
//       type: json['type']?.toString(),
//     );
//   }
// }

class Transaction {
  final String? transactionDate;
  final dynamic totalAmount;
  final String? description;
  final String? type;

  Transaction({
    this.transactionDate,
    this.totalAmount,
    this.description,
    this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionDate: json['transactionDate']?.toString(),
      totalAmount: json['totalAmount'],
      description: json['transactionDesc']?.toString(),
      type: json['referenceInformation']?.toString(),
    );
  }
}

// Placeholder pour PiecesJustificativesController
class PiecesJustificativesController extends GetxController {
  var Error = false.obs;
  var pieces = <PieceJustificative>[].obs;

  Future<void> fetchPieces() async {
    // Implementation
  }
}

class PieceJustificative {
  final bool verificationAdmin;

  PieceJustificative({required this.verificationAdmin});
}

class TokenExpiredException implements Exception {
  final String message;
  TokenExpiredException(this.message);

  @override
  String toString() => message;
}
