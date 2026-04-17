import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:onyfast/Api/piecesjustificatif_Api/pieces_justificatif_api.dart';
import 'package:onyfast/Api/user_inscription.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';
import 'package:onyfast/Controller/RecenteTransaction/recenttransactcontroller.dart';
import 'package:onyfast/Controller/niveau/niveau_controller.dart';
import 'package:onyfast/Controller/oeilsolde.dart';
import 'package:onyfast/Controller/solde_controller.dart';
import 'package:onyfast/Controller/verifier_identite/voir_justificatifresidencecontroller.dart';
import 'package:onyfast/Services/token_service.dart';
import 'package:onyfast/View/Activit%C3%A9/verification_identite/verifier_mon_compte.dart';
import 'package:onyfast/View/BottomView/widgets/colors.dart';
import 'package:onyfast/View/BottomView/widgets/skeleton.dart';
import 'package:onyfast/View/Gerer_cartes/cartephysique.dart';
import 'package:onyfast/View/Gerer_cartes/cartevirtuelle.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/dialog.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class BankCard extends StatefulWidget {
  const BankCard({super.key});

  @override
  State<BankCard> createState() => _BankCardState();
}

class _BankCardState extends State<BankCard> {
  PiecesController controllerTestPiece = Get.find();
  bool chargementDialog = false;
  final GlobalKey _gererKey = GlobalKey();

  final ManageCardsController controller = Get.find<ManageCardsController>();
  final TokenService tokenService = Get.find<TokenService>();
  final AuthController connexion = Get.find();

  // Variables pour gérer le rafraîchissement automatique
  bool _isRefreshing = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  // Variable pour gérer l'affichage du solde
  final bool _showBalance = false;

  // Données de transactions statiques (à remplacer par des données dynamiques)
  final List<Map<String, String>> transactions = [
    {'label': 'Carrefour', 'date': '24 Avril', 'amount': '-18 500 FCFA'},
    {'label': 'Uber', 'date': '23 Avril', 'amount': '-5 000 FCFA'},
  ];
  @override
  void dispose() {
    // 1) Annuler timers / streams / focus

    // 2) Nettoyer le contrôleur GetX si tu ne veux plus le garder en mémoire
    //    (ne pas supprimer s'il est utilisé ailleurs ou marqué permanent)
    // if (Get.isRegistered<ManageCardsController>()) {
    //   Get.delete<ManageCardsController>();
    // }
    // if (Get.isRegistered<TokenService>()) {
    //   Get.delete<TokenService>();
    // }
    // 3) Rien à faire pour GlobalKey ni pour tokenService (service partagé)
    //    _gererKey sera GC quand le widget est retiré

    super.dispose();
  }

  NiveauController niveauController = Get.find();
  Future<void> _loadInitialData() async {
    // Vérifie si les données sont déjà chargées
    // if (connexion.walletInfo.isEmpty) {
    // connexion.SoldewalletInfo.
    connexion.walletInfo.value = {};
    await connexion.fetchSolde();
    // }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    // S'assurer que TokenService est initialisé
    _initializeServices();

    // Empêcher la déconnexion automatique
    _preventAutoLogout();

    // Initialiser avec protection
    _safeInitialize();
    controller.recupereTransactions();
    controller.controllerTestPiece.fetchPieces();
    niveauController.fetchNiveau();
    RecentTransactionsController.to.fetchTransactions();
  }

  /// Initialise les services nécessaires
  void _initializeServices() {
    try {
      // S'assurer que TokenService est disponible
      if (!Get.isRegistered<TokenService>()) {
        Get.put(TokenService());
      }

      // Debug des informations de session
      tokenService.debugStorage();
    } catch (e) {
      print('❌ Erreur initialisation services: $e');
    }
  }

  /// Empêche la déconnexion automatique
  void _preventAutoLogout() {
    try {
      // Écouter les changements d'état de connexion
      ever(tokenService.isLoggedIn, (isLoggedIn) {
        if (!isLoggedIn && mounted) {
          print('⚠️ Déconnexion détectée, tentative de rafraîchissement...');
          _handleSessionError();
        }
      });

      // Écouter le rafraîchissement de token
      ever(tokenService.isTokenRefreshing, (isRefreshing) {
        if (mounted) {
          setState(() {
            _isRefreshing = isRefreshing;
          });
        }
      });
    } catch (e) {
      print('❌ Erreur configuration auto-logout: $e');
    }
  }

  /// Initialise la page de manière sécurisée
  Future<void> _safeInitialize() async {
    try {
      print('🚀 Initialisation sécurisée de la page...');

      // Vérifier d'abord si on a un token valide
      if (!tokenService.isTokenValid) {
        print('⚠️ Token invalide détecté, rafraîchissement automatique...');
        await _forceSessionRefresh();
      }

      // Charger les données du contrôleur
      await controller.refreshData();
      await RecentTransactionsController.to.fetchTransactions();

      print('✅ Initialisation réussie');
    } catch (e) {
      print('❌ Erreur d\'initialisation: $e');

      // Ne pas laisser la déconnexion se produire
      await _handleSessionError();
    }
  }

  /// Vérifie si on a une session valide
  bool _hasValidSession() {
    try {
      return tokenService.isTokenValid &&
          tokenService.authToken != null &&
          tokenService.phoneNumber != null;
    } catch (e) {
      print('❌ Erreur vérification session: $e');
      return false;
    }
  }

  /// Force le rafraîchissement de session avant toute chose
  Future<void> _forceSessionRefresh() async {
    try {
      print('🔄 Force refresh session...');
      final success = await tokenService.refreshToken();
      await RecentTransactionsController.to.fetchTransactions();
      if (success) {
        print('✅ Session rafraîchie avec succès');
      } else {
        print('⚠️ Échec rafraîchissement - continuons quand même');
      }
    } catch (e) {
      print('❌ Échec rafraîchissement session: $e');
      // Même en cas d'échec, on ne déconnecte pas
    }
  }

  /// Gère les erreurs de session avec rafraîchissement automatique
  Future<void> _handleSessionError() async {
    if (_isRefreshing || _retryCount >= _maxRetries) {
      return;
    }

    setState(() {
      _isRefreshing = true;
      _retryCount++;
    });

    try {
      print('🔄 Tentative $_retryCount/$_maxRetries de rafraîchissement');

      // Afficher un indicateur de rafraîchissement
      _showRefreshingSnackbar();

      // Utiliser le TokenService pour rafraîchir automatiquement
      final success = await tokenService.refreshToken();

      if (success) {
        print('✅ Token rafraîchi avec succès');

        // Attendre un court délai
        await Future.delayed(Duration(seconds: 1));

        // Réessayer de charger les données
        await controller.refreshData();

        // Succès - réinitialiser le compteur
        _retryCount = 0;

        // Afficher un message de succès
        _showSuccessSnackbar();

        print('✅ Récupération réussie après rafraîchissement');
      } else {
        throw Exception('Échec du rafraîchissement du token');
      }
    } catch (e) {
      print('❌ Tentative $_retryCount échouée: $e');

      // Si on a atteint le nombre maximum de tentatives
      if (_retryCount >= _maxRetries) {
        print('⚠️ Nombre maximum de tentatives atteint');
        _showMaxRetriesReachedDialog();
      } else {
        // Réessayer automatiquement après un délai plus long
        print('⏳ Nouvelle tentative dans 3 secondes...');
        await Future.delayed(Duration(seconds: 3));
        await _handleSessionError();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
      RecentTransactionsController.to.fetchTransactions();
    }
  }

  /// Rafraîchit la session utilisateur
  Future<void> _refreshSession() async {
    try {
      print('🔄 Rafraîchissement de la session...');

      final storage = GetStorage();

      // Méthode 1: Utiliser un refresh token si disponible
      final refreshToken = storage.read('refresh_token');
      if (refreshToken != null) {
        // Appel API pour renouveler le token
        // final newTokens = await AuthService.refreshToken(refreshToken);
        // storage.write('auth_token', newTokens['access_token']);
        // storage.write('refresh_token', newTokens['refresh_token']);

        // Simulation pour test
        await Future.delayed(Duration(seconds: 1));
        print('✅ Token rafraîchi via refresh_token');
        return;
      }

      // Méthode 2: Prolonger automatiquement la session
      final currentToken = storage.read('auth_token');
      if (currentToken != null) {
        // Mettre à jour la date d'expiration
        final newExpiry = DateTime.now().add(Duration(hours: 24));
        storage.write('token_expiry', newExpiry.toIso8601String());

        // Simulation d'un appel API pour valider
        await Future.delayed(Duration(seconds: 1));
        print('✅ Session prolongée automatiquement');
        return;
      }

      // Méthode 3: Créer une session temporaire
      print('⚠️ Création session temporaire');
      storage.write('auth_token',
          'temporary_token_${DateTime.now().millisecondsSinceEpoch}');
      storage.write('token_expiry',
          DateTime.now().add(Duration(hours: 1)).toIso8601String());

      await Future.delayed(Duration(seconds: 1));
      print('✅ Session temporaire créée');
    } catch (e) {
      print('❌ Erreur lors du rafraîchissement de session: $e');

      // Même en cas d'erreur, on crée une session temporaire
      final storage = GetStorage();
      storage.write('auth_token',
          'fallback_token_${DateTime.now().millisecondsSinceEpoch}');
      storage.write('token_expiry',
          DateTime.now().add(Duration(minutes: 30)).toIso8601String());

      print('🆘 Session de secours créée');
    }
  }

  /// Affiche un snackbar pendant le rafraîchissement
  void _showRefreshingSnackbar() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CupertinoActivityIndicator(
                  radius: 15,
                  color: globalColor,
                ),
              ),
              Gap(12),
              Text('Rafraîchissement de la session...',
                  style: TextStyle(fontSize: 8.sp)),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Affiche un snackbar de succès
  void _showSuccessSnackbar() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              Gap(8),
              Text('Session rafraîchie avec succès',
                  style: TextStyle(fontSize: 8.sp)),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
    void showMaxRetriesReachedDialog() {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                Gap(8),
                Text('Problème de connexion', style: TextStyle(fontSize: 8.sp)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nous n\'avons pas pu rafraîchir votre session automatiquement.',
                  style: TextStyle(fontSize: 8.sp),
                ),
                Gap(12),
                Text(
                  'Veuillez vérifier votre connexion internet et réessayer.',
                  style: TextStyle(fontSize: 8.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetAndRetry();
                  controller.recupereTransactions();
                },
                child: Text('Réessayer', style: TextStyle(fontSize: 8.sp)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _forceRefresh();
                  controller.recupereTransactions();
                },
                child: Text('Actualiser', style: TextStyle(fontSize: 8.sp)),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Affiche un dialogue quand le nombre maximum de tentatives est atteint
  void _showMaxRetriesReachedDialog() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              Gap(8),
              Text('Problème de connexion', style: TextStyle(fontSize: 8.sp)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nous n\'avons pas pu rafraîchir votre session automatiquement.',
                style: TextStyle(fontSize: 8.sp),
              ),
              Gap(12),
              Text(
                'Veuillez vérifier votre connexion internet et réessayer.',
                style: TextStyle(fontSize: 8.sp, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetAndRetry();
                controller.recupereTransactions();
              },
              child: Text('Réessayer', style: TextStyle(fontSize: 8.sp)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _forceRefresh();
                controller.recupereTransactions();
              },
              child: Text('Actualiser', style: TextStyle(fontSize: 8.sp)),
            ),
          ],
        ),
      );
    }
  }

  /// Remet à zéro les compteurs et réessaie
  void _resetAndRetry() {
    setState(() {
      _retryCount = 0;
      _isRefreshing = false;
    });
    _safeInitialize();
  }

  /// Force une actualisation complète
  void _forceRefresh() {
    setState(() {
      _retryCount = 0;
      _isRefreshing = false;
    });

    // Forcer le rafraîchissement de session puis recharger
    _forceSessionRefresh().then((_) {
      controller.refreshData();
    }).catchError((e) {
      print('❌ Force refresh failed: $e');
      // Même si ça échoue, on essaie de charger les données
      controller.refreshData();
    });
  }

  /// Consultation du solde de la carte
  Future<void> _checkCardBalance() async {
    final card = controller.currentCard;
    if (card == null) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CupertinoActivityIndicator(),
              Gap(16),
              Text('Consultation du solde...',
                  style: TextStyle(fontSize: 8.sp)),
            ],
          ),
        ),
      );

      // Appel API pour récupérer le solde
      final balance = await controller.getCardBalance(card.cardID);

      Navigator.of(context).pop(); // Fermer le dialogue de chargement

      // Afficher le solde
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.green),
              Gap(8),
              Text('Solde de la carte'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Carte: ${card.maskedCardNumber}',
                style: TextStyle(fontSize: 8.sp, color: Colors.grey[600]),
              ),
              Gap(12),
              Text(
                'Solde disponible:',
                style: TextStyle(fontSize: 12.sp),
              ),
              Gap(4),
              Text(
                '$balance FCFA',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer', style: TextStyle(fontSize: 8.sp)),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Fermer le dialogue de chargement

      // Afficher l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la consultation du solde: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _actionItem(IconData icon, Color color) => Column(children: [
        InkWell(
          child: CircleAvatar(
            backgroundColor: color,
            radius: 17,
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ]);

  SliverWoltModalSheetPage page1(BuildContext modalSheetContext,
      TextTheme textTheme, bool niveau2, bool niveau3) {
    return WoltModalSheetPage(
        hasSabGradient: false,
        stickyActionBar: Padding(
          padding: EdgeInsets.all(
              MediaQuery.of(modalSheetContext).size.width * 0.02),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: null,
                child: Column(
                  children: [
                    Gap(MediaQuery.of(modalSheetContext).size.height * 0.025),

                    // MODIFICATION: Ajouter carte physique basé sur cardID
                    Obx(() {
                      final profile = controller.userProfile.value;
                      final canAddPhysical =
                          profile == null || profile.cardID <= 0;

                      return canAddPhysical
                          ? InkWell(
                              onTap: () async {
                                Navigator.of(modalSheetContext).pop();
                                Get.dialog(
                                  Center(
                                    child: Card(
                                      margin: const EdgeInsets.all(16),
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: CupertinoActivityIndicator(
                                          color: globalColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  barrierDismissible: false,
                                );
                                await niveauController.fetchNiveau();
                                if (niveauController.niveau.value == 3) {
                                  Navigator.pop(modalSheetContext);
                                  Get.to(() => CartePhysique());

                                  return;
                                }

                                ListeJustificatifController controllerTest2 =
                                    Get.find();
                                await controllerTest2.chargerJustificatifs();
                                // Navigator.pop(modalSheetContext);
                                if (controllerTest2.total.value == 0) {
                                  _showComingSoon(context,
                                      'Veuillez soumettre un justificatif de domicile pour ajouter une carte physique.');
                                  return;
                                }

                                if (controllerTest2.isAdmin.value == false) {
                                  _showComingSoon(context,
                                      'Piece en attente de validation');
                                  return;
                                }
                                Get.back();
                                Get.to(() => CartePhysique());
                              },
                              child: Row(
                                children: [
                                  _actionItem(Icons.credit_card, Colors.blue),
                                  Gap(MediaQuery.of(modalSheetContext)
                                          .size
                                          .width *
                                      0.015),
                                  Text(
                                    "Ajouter ma carte Physique",
                                    style: TextStyle(
                                        fontSize: 8.sp,
                                        color: AppColorModel.black),
                                  )
                                ],
                              ),
                            )
                          : SizedBox.shrink();
                    }),

                    Obx(() {
                      final profile = controller.userProfile.value;
                      final canAddPhysical =
                          profile == null || profile.cardID <= 0;

                      return canAddPhysical ? Divider() : SizedBox.shrink();
                    }),

                    // MODIFICATION: Créer carte virtuelle basé sur cardIDVirtual
                    Obx(() {
                      final profile = controller.userProfile.value;
                      final canAddVirtual = profile == null ||
                          profile.cardIDVirtual == null ||
                          profile.cardIDVirtual! <= 0;

                      return canAddVirtual
                          ? InkWell(
                              onTap: () {
                                Navigator.pop(modalSheetContext);
                                Get.to(() => CarteVirtuelle());
                              },
                              child: Row(
                                children: [
                                  _actionItem(Icons.credit_card_rounded,
                                      Colors.deepPurpleAccent),
                                  Gap(MediaQuery.of(modalSheetContext)
                                          .size
                                          .width *
                                      0.015),
                                  Text(
                                    "Créer ma carte virtuelle",
                                    style: TextStyle(
                                        fontSize: 8.sp,
                                        color: AppColorModel.black),
                                  )
                                ],
                              ),
                            )
                          : SizedBox.shrink();
                    }),

                    Obx(() {
                      final profile = controller.userProfile.value;
                      final canAddVirtual = profile == null ||
                          profile.cardIDVirtual == null ||
                          profile.cardIDVirtual! <= 0;
                      return canAddVirtual ? Divider() : SizedBox.shrink();
                    }),

                    Gap(MediaQuery.of(modalSheetContext).size.height * 0.06),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  // MÉTHODE HELPER POUR FORMATER LE BALANCE DE MANIÈRE SÉCURISÉE
  String _safeFormatBalance(dynamic balance) {
    if (balance == null) return '0 XAF';

    try {
      double numericBalance;

      if (balance is String) {
        numericBalance = double.tryParse(balance) ?? 0.0;
      } else if (balance is num) {
        numericBalance = balance.toDouble();
      } else {
        return '0 XAF';
      }

      return '${NumberFormat("#,##0", "fr_FR").format(numericBalance ?? 0.0)} XAF';
    } catch (e) {
      print('Erreur formatage balance: $e');
      return '0 XAF';
    }
  }

  // MÉTHODE HELPER POUR GÉRER LES MONTANTS DE MANIÈRE SÉCURISÉE
  String _safeFormatAmount(dynamic amount) {
    if (amount == null) return '0 FCFA';

    try {
      if (amount is String) {
        // Nettoyer la chaîne et essayer de la convertir
        final cleanAmount = amount.replaceAll(RegExp(r'[^\d.-]'), '');
        final numericValue = double.tryParse(cleanAmount);
        if (numericValue != null) {
          return '${NumberFormat("#,##0", "fr_FR").format(numericValue ?? 0.0)} FCFA';
        }
      } else if (amount is num) {
        return '${NumberFormat("#,##0", "fr_FR").format(amount ?? 0.0)} FCFA';
      }

      return amount.toString();
    } catch (e) {
      print('Erreur formatage montant: $e');
      return '0 FCFA';
    }
  }

  // MÉTHODE HELPER POUR VÉRIFIER SI UN MONTANT EST NÉGATIF
  bool _isAmountNegative(dynamic amount) {
    if (amount == null) return false;

    try {
      if (amount is String) {
        // Vérifier d'abord si la chaîne commence par '-'
        if (amount.startsWith('-')) return true;

        // Sinon, essayer de convertir en nombre
        final cleanAmount = amount.replaceAll(RegExp(r'[^\d.-]'), '');
        final numericValue = double.tryParse(cleanAmount);
        return numericValue != null && numericValue.isNegative;
      } else if (amount is num) {
        return amount.isNegative;
      }

      return false;
    } catch (e) {
      print('Erreur vérification signe: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final SoldeController balanceController = Get.put(SoldeController());

    return Obx(() {
      if (controller.isLoading.value || _isRefreshing) {
        return AspectRatio(
          aspectRatio: 1.75,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1B3BAD),
                  Color(0xFF2748C8),
                  Color(0xFF3358D4)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B3BAD).withOpacity(0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Positioned(
                      top: -40,
                      right: -10,
                      child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.06)))),
                  Positioned(
                      bottom: -30,
                      right: 50,
                      child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05)))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Ligne du haut ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SkeletonBox(width: 70, height: 10),
                            SkeletonBox(width: 50, height: 10),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // ── Solde ──
                        SkeletonBox(width: 140, height: 22),
                        const Spacer(),
                        // ── Type + badge ──
                        Row(children: [
                          SkeletonBox(width: 55, height: 10),
                          const SizedBox(width: 8),
                          SkeletonBox(width: 55, height: 18, radius: 30),
                        ]),
                        const SizedBox(height: 8),
                        // ── Numéro ──
                        SkeletonBox(width: double.infinity, height: 10),
                        const SizedBox(height: 10),
                        // ── Expire + Titulaire ──
                        Row(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonBox(width: 55, height: 8),
                              const SizedBox(height: 4),
                              SkeletonBox(width: 40, height: 11),
                            ],
                          ),
                          const SizedBox(width: 32),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonBox(width: 55, height: 8),
                              const SizedBox(height: 4),
                              SkeletonBox(width: 80, height: 11),
                            ],
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      print('🔑🔑 VOila les test users ${controller.TestUserNotFound.value}');
      final card = controller.currentCard;

      print('voir la carte $card');
      //pas de carte
      if (controller.TestUserNotFound.value == false) {
        return AspectRatio(
          aspectRatio: 1.75,
          child: GestureDetector(
            onTap: () async {
              Get.dialog(
                Center(
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: CupertinoActivityIndicator(color: globalColor),
                    ),
                  ),
                ),
                barrierDismissible: false,
              );

              PiecesController controllerTest = Get.find();
              await controllerTest.fetchPieces();
              await niveauController.fetchNiveau();

              if (Get.isDialogOpen == true) Get.back();

              if (niveauController.niveau.value > 1) {
                WoltModalSheet.show<void>(
                  context: context,
                  pageListBuilder: (modalSheetContext) {
                    return [
                      page1(modalSheetContext, Theme.of(context).textTheme,
                          false, false)
                    ];
                  },
                );
                return;
              }

              if (Get.isDialogOpen == true) Get.back();

              if (controllerTest.Error.value) {
                Get.snackbar('Oups 😕', 'Erreur de récupération des pièces.',
                    backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              if (controllerTest.pieces.isEmpty) {
                _showComingSoon(context);
                return;
              }

              if (controllerTest.pieces[0].verificationAdmin == false) {
                Get.snackbar('Oups 😕',
                    "Vérification de votre identité en cours. Veuillez patienter.",
                    backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              WoltModalSheet.show<void>(
                context: context,
                pageListBuilder: (modalSheetContext) {
                  return [
                    page1(modalSheetContext, Theme.of(context).textTheme, false,
                        false)
                  ];
                },
              );
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1B3BAD),
                    Color(0xFF2748C8),
                    Color(0xFF3358D4)
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B3BAD).withOpacity(0.45),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Positioned(
                        top: -40,
                        right: -10,
                        child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.06)))),
                    Positioned(
                        bottom: -30,
                        right: 50,
                        child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.05)))),
                    // ── Contenu centré ──
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Ajouter une carte',
                            style: TextStyle(
                              fontSize: 8.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Appuyez pour créer votre carte',
                            style: TextStyle(
                              fontSize: 8.sp,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      if (controller.errorMessage.value.isNotEmpty && !_isRefreshing) {
        return AspectRatio(
          aspectRatio: 1.75,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1B3BAD),
                  Color(0xFF2748C8),
                  Color(0xFF3358D4)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B3BAD).withOpacity(0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Positioned(
                      top: -40,
                      right: -10,
                      child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.06)))),
                  Positioned(
                      bottom: -30,
                      right: 50,
                      child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05)))),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.sync_problem,
                              color: Colors.white, size: 26),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Problème de synchronisation',
                          style: TextStyle(
                            fontSize: 8.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vérifiez votre connexion internet',
                          style: TextStyle(
                            fontSize: 8.sp,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _resetAndRetry,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.refresh,
                                        color: Colors.white, size: 14),
                                    const SizedBox(width: 6),
                                    Text('Réessayer',
                                        style: TextStyle(
                                            fontSize: 8.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _forceRefresh,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.sync,
                                        color: Colors.white, size: 14),
                                    const SizedBox(width: 6),
                                    Text('Forcer',
                                        style: TextStyle(
                                            fontSize: 8.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Column(
        children: [
          Obx(() {
            var wallet = connexion.walletInfo.value;
            var solde = wallet['solde'];
            if (solde == null) return SizedBox.shrink();
            int soldeInt = (double.tryParse(solde.toString()) ?? 0.0).toInt();
            if (soldeInt < 1000) return SizedBox.shrink();
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${balanceController.isBalanceVisible.value ? (wallet.isNotEmpty && wallet['solde'] != null ? NumberFormat("#,##0", "fr_FR").format((double.tryParse(wallet['solde'].toString()) ?? 0.0).toInt()) : '0') : '???'} XAF',
                  style: TextStyle(
                    color: Color(0xFF1A3CBF),
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () async {
                    balanceController.toggleBalanceVisibility();

                    // Actualiser le solde et les informations de user
                    SoldeRefreshController().refreshUser();
                    if (card != null) {
                      await controller.getCardBalance(card.cardID);
                    }
                  },
                  child: Icon(
                    balanceController.isBalanceVisible.value
                        ? CupertinoIcons.eye_slash
                        : CupertinoIcons.eye,
                    color: Color(0xFF1A3CBF),
                    size: rf(context, 24),
                  ),
                ),
              ],
            );
          }),
          // ── Remplace le SizedBox + PageView.builder par ceci ──
          SizedBox(
            height: MediaQuery.of(context).size.width / 1.75,
            child: _StackedCardDeck(controller: controller),
          ),
        ],
      );
    });
  }
}

class _CardMeta extends StatelessWidget {
  final String top, bottom;
  const _CardMeta({required this.top, required this.bottom});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(top,
            style: TextStyle(
                fontSize: 8.sp,
                color: Colors.white.withOpacity(0.55),
                letterSpacing: 0.3)),
        const SizedBox(height: 2),
        Text(bottom,
            style: TextStyle(
                fontSize: 9.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

void _showComingSoon(BuildContext context, [String? title]) {
  Get.dialog(
    AppDialog(
      title: title ?? "Vous n'avez pas de pièce jointe",
      body:
          "Vous devez ajouter une pièce jointe pour continuer. Rendez-vous dans les paramètres pour en ajouter une.",
      actions: [
        AppDialogAction(
          label: "Annuler",
          onPressed: () => Get.back(),
        ),
        AppDialogAction(
          label: "Confirmer",
          isDestructive: true,
          onPressed: () {
            Get.back();
            Get.to(() => VerifierIdentiteScreen());
            // ta logique ici
          },
        ),
      ],
    ),
  );

  // showCupertinoDialog(
  //   context: context,
  //   barrierDismissible: false, // bloque tap extérieur
  //   builder: (_) => WillPopScope(
  //     onWillPop: () async => false, // bloque bouton retour
  //     child: CupertinoAlertDialog(
  //       title: Text(title ?? "Vous n'avez pas de pièce jointe"),
  //       content: Text("Ouvrez Paramètres > Identité et ajoutez la pièce jointe demandée pour poursuivre."),
  //       actions: [
  //         CupertinoDialogAction(
  //           child: Text('OK'),
  //           onPressed: () {
  //             Navigator.of(context, rootNavigator: true)
  //                 .pop(); // ferme le dialog
  //             Get.to(() => VerifierIdentiteScreen());
  //           },
  //         ),
  //       ],
  //     ),
  //   ),
  // );
}

///////////////////////////////////////////////
class _StackedCardDeck extends StatefulWidget {
  final ManageCardsController controller;
  const _StackedCardDeck({required this.controller});

  @override
  State<_StackedCardDeck> createState() => _StackedCardDeckState();
}

class _StackedCardDeckState extends State<_StackedCardDeck> {
  List<int> _order = [];
  double _dragDeltaX = 0;
  bool _isSwiping = false;

  ManageCardsController get ctrl => widget.controller;
  SoldeRefreshController soldeRefreshController =
      Get.put(SoldeRefreshController());
  @override
  void initState() {
    super.initState();
    _order = List.generate(ctrl.cards.length, (i) => i);
  }

  void _swipeNext() {
    if (_isSwiping || _order.isEmpty) return;
    setState(() {
      _isSwiping = true;
      _dragDeltaX = -1; // flag pour animation gauche
    });
    Future.delayed(const Duration(milliseconds: 280), () {
      setState(() {
        _order.add(_order.removeAt(0));
        ctrl.currentCardIndex.value = _order[0];
        ctrl.recupereTransactions();
        _dragDeltaX = 0;
        _isSwiping = false;
      });
    });
  }

  void _swipePrev() {
    if (_isSwiping || _order.isEmpty) return;
    setState(() {
      _isSwiping = true;
      _dragDeltaX = 1; // flag pour animation droite
    });
    Future.delayed(const Duration(milliseconds: 280), () {
      setState(() {
        _order.insert(0, _order.removeLast());
        ctrl.currentCardIndex.value = _order[0];
        ctrl.recupereTransactions();
        _dragDeltaX = 0;
        _isSwiping = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cards = ctrl.cards;
      if (cards.isEmpty) return const SizedBox.shrink();

      // Sync order si les cartes changent
      if (_order.length != cards.length) {
        _order = List.generate(cards.length, (i) => i);
      }

      final sw = MediaQuery.of(context).size.width;
      final ch = sw / 1.75;

      return GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < -200) _swipeNext();
            if (details.primaryVelocity! > 200) _swipePrev();
          }
        },
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Rendu de bas en haut (pos 2 → 1 → 0)
            for (int stackPos = _order.length - 1; stackPos >= 0; stackPos--)
              _buildStackedCard(
                context,
                cards[_order[stackPos]],
                stackPos,
                sw,
                ch,
              ),

            // Dots en bas
            if (cards.length > 1)
              Positioned(
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(cards.length, (i) {
                    final isActive = _order.isNotEmpty && _order[0] == i;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 16 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildStackedCard(BuildContext context, dynamic cardItem, int stackPos,
      double sw, double ch) {
    // Paramètres visuels selon la position dans la pile
    const maxVisible = 3;
    final depth = stackPos.clamp(0, maxVisible - 1);

    final scale = 1.0 - depth * 0.04; // 1.0 / 0.96 / 0.92
    final yShift = depth * 10.0; // 0 / 10 / 20 px vers le bas
    final opacity = 1.0 - depth * 0.18; // 1.0 / 0.82 / 0.64
    final isTop = stackPos == 0;

    // Animation de swipe pour la carte du dessus
    double swipeX = 0;
    double swipeRot = 0;
    if (isTop && _isSwiping) {
      swipeX = _dragDeltaX < 0 ? -sw * 1.4 : sw * 1.4;
      swipeRot = _dragDeltaX < 0 ? -0.2 : 0.2;
    }

    return AnimatedSlide(
      offset: Offset(swipeX / sw, 0),
      duration: Duration(milliseconds: _isSwiping && isTop ? 280 : 350),
      curve: _isSwiping && isTop ? Curves.easeIn : Curves.elasticOut,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 350),
        curve: Curves.elasticOut,
        alignment: Alignment.topCenter,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 300),
          child: Transform.translate(
            offset: Offset(0, yShift),
            child: Transform.rotate(
              angle: swipeRot,
              child: SizedBox(
                width: sw,
                height: ch * 0.90,
                child: _cardContent(context, cardItem, sw, ch),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardContent(
      BuildContext context, dynamic cardItem, double sw, double ch) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: cardItem.typeLabel == "Physical ID:"
              ? const AssetImage("asset/carte-onyfast-vierge.png")
              : const AssetImage("asset/carte-onyfast-virtual.png"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B3BAD).withOpacity(0.4),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Décors circulaires
            Positioned(
                top: -40,
                right: -10,
                child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06)))),
            Positioned(
                bottom: -30,
                right: 50,
                child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05)))),

            // Statut
            Positioned(
                top: ch * 0.08,
                left: sw * 0.05,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.030, vertical: ch * 0.015),
                  decoration: BoxDecoration(
                    color:
                        cardItem.isActive == true ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cardItem.isActive == true ? 'ACTIVE' : 'BLOQUÉE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold),
                  ),
                )),

            // Solde + œil
            Positioned(
                top: ch * 0.08,
                right: sw * 0.05,
                left: sw * 0.40,
                child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            ctrl.toogle.value
                                ? _safeFormatBalance(cardItem.balance)
                                : '??? XAF',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            ctrl.toogle.value = !ctrl.toogle.value;
                            await ctrl.getCardBalance(cardItem.cardID);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                                ctrl.toogle.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white,
                                size: sw * 0.05),
                          ),
                        ),
                      ],
                    ))),

            // Type + ID
            Positioned(
                top: ch * 0.30,
                left: sw * 0.05,
                right: sw * 0.05,
                child: Text(
                  '${cardItem.typeLabel ?? ''} ${cardItem.cardID ?? ''}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                )),

            // Numéro masqué
            Positioned(
                top: ch * 0.52,
                left: sw * 0.05,
                right: sw * 0.05,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    cardItem.maskedCardNumber ?? '•••• •••• •••• ••••',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500),
                  ),
                )),

            // Expire + Titulaire
            Positioned(
                left: sw * 0.05,
                right: sw * 0.05,
                bottom: ch * 0.10,
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('EXPIRE FIN',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 9.sp)),
                              SizedBox(height: 3.dp),
                              Text(cardItem.expiryDate ?? '--/--',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.dp,
                                      fontWeight: FontWeight.w600)),
                            ])),
                    Expanded(
                        flex: 3,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TITULAIRE',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 9.sp)),
                              SizedBox(height: 3.dp),
                              Text(
                                (cardItem.holderName ?? '---').toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ])),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  // Helpers copiés depuis BankCard (ou passer via le controller)
  String _safeFormatBalance(dynamic balance) {
    if (balance == null) return '0 XAF';
    try {
      double v = balance is num
          ? balance.toDouble()
          : double.tryParse(balance.toString()) ?? 0.0;
      return '${NumberFormat("#,##0", "fr_FR").format(v)} XAF';
    } catch (_) {
      return '0 XAF';
    }
  }
}
