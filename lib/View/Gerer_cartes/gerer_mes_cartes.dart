import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:onyfast/Api/piecesjustificatif_Api/pieces_justificatif_api.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';
import 'package:onyfast/Controller/niveau/niveau_controller.dart';
import 'package:onyfast/Controller/verifier_identite/voir_justificatifresidencecontroller.dart';
import 'package:onyfast/Services/token_service.dart';
import 'package:onyfast/View/Activit%C3%A9/verification_identite/verifier_mon_compte.dart';
import 'package:onyfast/View/Gerer_cartes/CardDetailPage.dart';
import 'package:onyfast/View/Gerer_cartes/cartephysique.dart';
import 'package:onyfast/View/Gerer_cartes/cartevirtuelle.dart';
import 'package:onyfast/View/Notification/notification.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:onyfast/verificationcode.dart';
import 'package:onyfast/View/const.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class ManageCardsPage extends StatefulWidget {
  const ManageCardsPage({super.key});

  @override
  State<ManageCardsPage> createState() => _ManageCardsPageState();
}

class _ManageCardsPageState extends State<ManageCardsPage> {
  PiecesController controllerTestPiece = Get.find();
  bool chargementDialog = false;
  final GlobalKey _gererKey = GlobalKey();

  final ManageCardsController controller = Get.put(ManageCardsController());
  final TokenService tokenService = Get.find<TokenService>();

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
    //    (ne pas supprimer s’il est utilisé ailleurs ou marqué permanent)
    if (Get.isRegistered<ManageCardsController>()) {
      Get.delete<ManageCardsController>();
    }
    if (Get.isRegistered<TokenService>()) {
      Get.delete<TokenService>();
    }
    // 3) Rien à faire pour GlobalKey ni pour tokenService (service partagé)
    //    _gererKey sera GC quand le widget est retiré

    super.dispose();
  }

  NiveauController niveauController = Get.find();

  @override
  void initState() {
    super.initState();

    // S'assurer que TokenService est initialisé
    _initializeServices();

    // Empêcher la déconnexion automatique
    _preventAutoLogout();

    // Initialiser avec protection
    _safeInitialize();
    controller.recupereTransactions();
    controller.controllerTestPiece.fetchPieces();
    niveauController.fetchNiveau();
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
              Text('Rafraîchissement de la session...'),
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
              Text('Session rafraîchie avec succès'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
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
              Text('Problème de connexion'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nous n\'avons pas pu rafraîchir votre session automatiquement.',
                style: TextStyle(fontSize: 16),
              ),
              Gap(12),
              Text(
                'Veuillez vérifier votre connexion internet et réessayer.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
              child: Text('Réessayer'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _forceRefresh();
                controller.recupereTransactions();
              },
              child: Text('Actualiser'),
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
              Text('Problème de connexion'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nous n\'avons pas pu rafraîchir votre session automatiquement.',
                style: TextStyle(fontSize: 16),
              ),
              Gap(12),
              Text(
                'Veuillez vérifier votre connexion internet et réessayer.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
              child: Text('Réessayer'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _forceRefresh();
                controller.recupereTransactions();
              },
              child: Text('Actualiser'),
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
              Text('Consultation du solde...'),
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
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Gap(12),
              Text(
                'Solde disponible:',
                style: TextStyle(fontSize: 16),
              ),
              Gap(4),
              Text(
                '$balance FCFA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
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
                                        fontSize:
                                            MediaQuery.of(modalSheetContext)
                                                    .size
                                                    .width *
                                                0.04,
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
                                        fontSize:
                                            MediaQuery.of(modalSheetContext)
                                                    .size
                                                    .width *
                                                0.04,
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
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        title: Hero(
            tag: "carte",
            child: Text(
              "Gérer mes cartes Visa",
              style: TextStyle(
                  fontSize: screenSize.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: AppColorModel.WhiteColor),
            )),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        actions: [
          // Indicateur de rafraîchissement dans l'AppBar
          if (_isRefreshing)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CupertinoActivityIndicator(
                    radius: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          NotificationWidget(),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value || _isRefreshing) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoActivityIndicator(),
                Gap(screenSize.height * 0.02),
                Text(_isRefreshing
                    ? 'Rafraîchissement en cours...'
                    : 'Chargement de vos cartes...'),
                if (_isRefreshing && _retryCount > 1)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Tentative $_retryCount/$_maxRetries',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        print('🔑🔑 VOila les test users ${controller.TestUserNotFound.value}');
        final card = controller.currentCard;

        print('voir la carte $card');

        if (controller.TestUserNotFound.value == false) {
          return Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
              child: Column(children: [
                Gap(screenSize.height * 0.01),
                _buildNoCardContainer(screenSize),
                Gap(10.h),
                // _buildAddCardButton(context,screenSize),
              ]),
            ),
          );
        }
        if (controller.errorMessage.value.isNotEmpty && !_isRefreshing) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sync_problem,
                    size: screenSize.width * 0.15, color: Colors.orange),
                Gap(screenSize.height * 0.02),
                Text(
                  'Problème de synchronisation',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Gap(screenSize.height * 0.01),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Tentative de rafraîchissement automatique...',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: screenSize.width * 0.035),
                  ),
                ),
                Gap(screenSize.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _resetAndRetry,
                      icon: Icon(Icons.refresh),
                      label: Text('Réessayer'),
                    ),
                    Gap(12),
                    OutlinedButton.icon(
                      onPressed: _forceRefresh,
                      icon: Icon(Icons.sync),
                      label: Text('Forcer'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            try {
              // Toujours rafraîchir la session avant les données
              await _forceSessionRefresh();
              await controller.refreshData();
              if (mounted) setState(() {});
            } catch (e) {
              print('❌ Erreur refresh indicator: $e');
              // Ne pas laisser l'erreur remonter, essayer de récupérer
              await _handleSessionError();
            }
          },
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: SingleChildScrollView(
              primary: true,

              physics: const AlwaysScrollableScrollPhysics(),
// ou AlwaysScrollableScrollPhysics()
              child: Column(
                children: [
                  // Bannière d'information si en cours de rafraîchissement
                  if (_retryCount > 0 && !_isRefreshing)
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue, size: 20),
                          Gap(8),
                          Expanded(
                            child: Text(
                              'Session rafraîchie automatiquement',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Bannière d'état de connexion
                  Obx(() {
                    if (!tokenService.isLoggedIn.value) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CupertinoActivityIndicator(
                                color: Colors.orange,
                              ),
                            ),
                            Gap(8),
                            Expanded(
                              child: Text(
                                'Reconnexion en cours...',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                  Gap(screenSize.height * 0.01),
                  // Conteneur de carte dynamique
                  _buildCardContainer(context, screenSize),

                  Gap(screenSize.height * 0.02),

                  // Actions de carte
                  _buildCardActions(context, screenSize),

                  Gap(screenSize.height * 0.025),

                  // Bouton ajouter carte
                  (controller.currentCard?.typeLabel == 'Aucune carte')
                      ? SizedBox.shrink()
                      : _buildAddCardButton(context, screenSize),

                  Gap(screenSize.height * 0.025),

                  // Historique des transactions
                  _buildTransactionHistory(context, screenSize),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCardContainer(BuildContext context, Size screenSize) {
    return Obx(() {
      final card = controller.currentCard;
      if (card == null) {
        return SizedBox.shrink();
      }

      if (card.typeLabel == 'Aucune carte') {
        return _buildNoCardContainer(screenSize);
      }

      return Container(
        height: screenSize.height * 0.32,
        margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: card.typeLabel == "Physical ID:"
                ? AssetImage("asset/carte-onyfast-vierge.png")
                : AssetImage("asset/carte-onyfast-virtual.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Navigation arrows placées en haut
            if (controller.hasMultipleCards)
              Positioned(
                top: screenSize.height * 0.01,
                left: screenSize.width * 0.02,
                right: screenSize.width * 0.02,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      elevation: 6,
                      shape: CircleBorder(),
                      color: controller.canShowPrevious
                          ? AppColorModel.Bluecolor242
                          : AppColorModel.Bluecolor242.withOpacity(0.3),
                      child: InkWell(
                        onTap: controller.canShowPrevious
                            ? () {
                                controller.previousCard();
                                controller.recupereTransactions();
                              }
                            : null,
                        customBorder: CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.all(screenSize.width * 0.025),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: AppColorModel.WhiteColor,
                            size: screenSize.width * 0.05,
                          ),
                        ),
                      ),
                    ),
                    Material(
                      elevation: 6,
                      shape: CircleBorder(),
                      color: controller.canShowNext
                          ? AppColorModel.Bluecolor242
                          : AppColorModel.Bluecolor242.withOpacity(0.3),
                      child: InkWell(
                        onTap: controller.canShowNext
                            ? () {
                                controller.nextCard();
                                controller.recupereTransactions();
                              }
                            : null,
                        customBorder: CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.all(screenSize.width * 0.025),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: AppColorModel.WhiteColor,
                            size: screenSize.width * 0.05,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

            // Balance section - repositionné pour éviter les débordements
            Positioned(
              top: screenSize.height * 0.05,
              right: screenSize.width * 0.03,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenSize.width * 0.45,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      constraints: BoxConstraints(
                        minWidth: screenSize.width * 0.08,
                        minHeight: screenSize.width * 0.08,
                      ),
                      padding: EdgeInsets.all(screenSize.width * 0.01),
                      color: Colors.white,
                      icon: Icon(
                        !controller.toogle.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: screenSize.width * 0.045,
                      ),
                      onPressed: () async {
                        controller.toogle.value = !controller.toogle.value;
                        // _checkCardBalance();
                        await controller.getCardBalance(card.cardID);
                      },
                    ),
                    Flexible(
                      child: Text(
                        controller.toogle.value
                            ? _safeFormatBalance(card.balance)
                            : "??? XAF",
                        style: TextStyle(
                          color: AppColorModel.WhiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: screenSize.width * 0.035,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ),
            ),

            // MODIFICATION PRINCIPALE: Card status indicator avec couleurs correctes
            Positioned(
              top: screenSize.height * 0.095,
              left: screenSize.width * 0.05,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.025,
                  vertical: screenSize.height * 0.005,
                ),
                decoration: BoxDecoration(
                  color: card.isActive
                      ? Colors.green
                      : Colors.red, // Rouge pour bloquée
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  card.isActive ? 'ACTIVE' : 'BLOQUÉE', // Texte plus clair
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenSize.width * 0.028,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Card type
            Positioned(
              top: screenSize.height * 0.135,
              left: screenSize.width * 0.05,
              right: screenSize.width * 0.05,
              child: Text(
                "${card.typeLabel} ${card.cardID}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenSize.width * 0.038,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Card number
            Positioned(
              top: screenSize.height * 0.17,
              left: screenSize.width * 0.05,
              right: screenSize.width * 0.05,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  card.maskedCardNumber,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenSize.width * 0.055,
                    letterSpacing: screenSize.width * 0.005,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Expiry date and holder name
            Positioned(
              left: screenSize.width * 0.05,
              right: screenSize.width * 0.05,
              top: screenSize.height * 0.22,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXPIRE FIN',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: screenSize.width * 0.025,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.003),
                        Text(
                          card.expiryDate,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenSize.width * 0.035,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: screenSize.width * 0.05),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TITULAIRE',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: screenSize.width * 0.025,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.003),
                        Text(
                          card.holderName.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenSize.width * 0.032,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card indicator dots
            if (controller.hasMultipleCards)
              Positioned(
                bottom: screenSize.height * 0.015,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.cards.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.01),
                      width: screenSize.width * 0.02,
                      height: screenSize.width * 0.02,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == controller.currentCardIndex.value
                            ? Colors.white
                            : Colors.blueGrey,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildNoCardContainer(Size screenSize) {
    return Container(
      height: screenSize.height * 0.32,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "asset/carte-onyfast-vierge.png",
          ),
          fit: BoxFit.cover,
        ),
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400, width: 2),
      ),
      child: Center(
          child: Material(
        color: Colors.white, // fond blanc
        shape: const CircleBorder(), // forme circulaire
        elevation: 4, // petite ombre
        child: IconButton(
          icon: const Icon(Icons.add, color: Colors.black), // icône +
          onPressed: () async {
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

            controller.isLoading.value = true;
            controller.controllerTestPiece.fetchPieces();
            controller.isLoading.value = false;

            PiecesController controllerTest = Get.find();
            await controllerTest.fetchPieces();
            await niveauController.fetchNiveau();
            if (Get.isDialogOpen == true) {
  Get.back(); // ferme le dialogue
}
            if (niveauController.niveau.value > 1) {
              print('🔑🔑 🔑🔑 vous avez appuyer');
                if (Get.isDialogOpen == true) {
  Get.back(); // ferme le dialogue
}
              WoltModalSheet.show<void>(
                context: context,
                pageListBuilder: (modalSheetContext) {
                  final textTheme = Theme.of(context).textTheme;
                  return [
                    page1(modalSheetContext, textTheme, false, false),
                  ];
                },
              );
              return;
            }
            if (Get.isDialogOpen == true) {
  Get.back(); // ferme le dialogue
}
            if (controllerTest.Error.value) {
              Get.snackbar(
                'Oups 😕',
                'Erreur de récupération des pièces.\nSi le problème persiste, contactez la direction.',
                snackPosition: SnackPosition.TOP,
                snackStyle: SnackStyle.FLOATING,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                icon: const Icon(Icons.error_outline, color: Colors.white),
                margin: const EdgeInsets.all(12),
                borderRadius: 12,
                duration: const Duration(seconds: 4),
                isDismissible: true,
                forwardAnimationCurve: Curves.easeOutBack,
                boxShadows: [
                  BoxShadow(
                      blurRadius: 8,
                      offset: Offset(0, 4),
                      color: Colors.black12),
                ],
              );
              return;
            }

            if (controllerTest.pieces.isEmpty) {
              _showComingSoon(context);
              if (Get.isDialogOpen == true) {
  Get.back(); // ferme le dialogue
}
              return;
            }

            if (controllerTest.pieces[0].verificationAdmin == false) {
              Get.snackbar(
                'Oups 😕',
                "Veuillez patienter, la vérification de votre identité est en cours de traitement. Vous accéderez à cette fonctionnalité une fois celle-ci validée. \nPour plus d'informations, veuillez contacter notre service client.",
                snackPosition: SnackPosition.TOP,
                snackStyle: SnackStyle.FLOATING,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                icon: const Icon(Icons.error_outline, color: Colors.white),
                margin: const EdgeInsets.all(12),
                borderRadius: 12,
                duration: const Duration(seconds: 4),
                isDismissible: true,
                forwardAnimationCurve: Curves.easeOutBack,
                boxShadows: [
                  BoxShadow(
                      blurRadius: 8,
                      offset: Offset(0, 4),
                      color: Colors.black12),
                ],
              );
              return;
            }
             
            // if(testPiece.isEmpty){
            //  _showComingSoon(context);
            //  return ;
            // }

            WoltModalSheet.show<void>(
              context: context,
              pageListBuilder: (modalSheetContext) {
                final textTheme = Theme.of(context).textTheme;
                return [
                  page1(modalSheetContext, textTheme, false, false),
                ];
              },
            );

// //
          },
        ),
      )
          // child: Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Icon(
          //       Icons.credit_card_off,
          //       size: screenSize.width * 0.15,
          //       color: Colors.white,
          //     ),
          //     Gap(screenSize.height * 0.01),
          //     Text(
          //       'Aucune carte disponible',
          //       style: TextStyle(
          //         fontSize: screenSize.width * 0.045,
          //         color: Colors.white,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //     Gap(screenSize.height * 0.005),
          //     Text(
          //       'Ajoutez votre première carte',
          //       style: TextStyle(
          //         fontSize: screenSize.width * 0.035,
          //         color: Colors.white,
          //       ),
          //     ),
          //   ],
          // ),
          ),
    );
  }

  // MODIFICATION PRINCIPALE: Actions différenciées selon le statut de la carte
  Widget _buildCardActions(BuildContext context, Size screenSize) {
    return Obx(() {
      final card = controller.currentCard;

      if (card?.typeLabel == 'Aucune carte') {
        return SizedBox.shrink();
      }

      if (card == null) return SizedBox.shrink();

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInBack,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.2, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Row(
          key: ValueKey(card.typeLabel ?? ''),
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Actions financières - dépend du statut de la carte
            _cardAction(
              Icons.upload,
              'Dépôt',
              screenSize,
              onTap: card.isActive ? () => controller.depositToCard() : null,
              isEnabled: card.isActive,
              showBlockedHint: !card.isActive,
            ),
            _cardAction(
              Icons.download,
              'Retrait',
              screenSize,
              onTap: card.isActive ? () => controller.withdrawFromCard() : null,
              isEnabled: card.isActive,
              showBlockedHint: !card.isActive,
            ),

            // Actions de consultation - disponibles même pour cartes bloquées
            if (card.typeLabel == "Virtual ID:")
              _cardAction(
                Icons.info,
                'Pan',
                screenSize,
                onTap: () async {
                  CodeVerification().show(context, () async {
                    CardExternalLauncher.launchCardDetails(
                        card.cardID,
                        card.maskedCardNumber
                            .replaceAll("•", "")
                            .replaceAll(" ", ""));
                  });
                },
                isEnabled: card != null, // Toujours disponible
              ),

            // Action de gestion - disponible même pour cartes bloquées
            _cardAction(
              Icons.settings,
              'Gérer',
              screenSize,
              onTap: () async {
                final RenderBox renderBox =
                    _gererKey.currentContext!.findRenderObject() as RenderBox;
                final Offset offset = renderBox.localToGlobal(Offset.zero);
                final Size size = renderBox.size;

                final menuItems = <PopupMenuItem<String>>[];

                // Ajouter l'option de blocage/déblocage selon le statut
                if (card.isActive) {
                  menuItems.add(PopupMenuItem(
                      value: 'bloquer', child: Text('Bloquer la carte')));
                } else {
                  menuItems.add(PopupMenuItem(
                      value: 'debloquer', child: Text('Débloquer la carte')));
                }

                // Autres options toujours disponibles
                menuItems.addAll([
                  if (card.typeLabel == "Virtual ID:")
                    PopupMenuItem(
                        value: 'details', child: Text('Voir détails')),
                  // PopupMenuItem(
                  //     value: 'historique', child: Text('Historique')),
                ]);

                final selected = await showMenu<String>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    offset.dx,
                    offset.dy + size.height,
                    offset.dx + size.width,
                    offset.dy,
                  ),
                  items: menuItems,
                );

                switch (selected) {
                  case 'bloquer':
                  case 'debloquer':
                    controller.toggleCardStatus();
                    break;
                  case 'details':
                    CodeVerification().show(context, () async {
                      CardExternalLauncher.launchCardDetails(
                          card.cardID,
                          card.maskedCardNumber
                              .replaceAll("•", "")
                              .replaceAll(" ", ""));
                    });
                    break;
                  case 'historique':
                    // Afficher l'historique
                    break;
                }
              },
              isEnabled: card != null, // Toujours disponible
              key: _gererKey,
            )
          ],
        ),
      );
    });
  }

  Widget _buildAddCardButton(BuildContext context, Size screenSize) {
    return Obx(() {
      final profile = controller.userProfile.value;
      final card = controller.currentCard;
      if (card == null) return SizedBox.shrink();

      // MODIFICATION: Vérifier les IDs de carte directement au lieu de hasPhysicalCard/hasVirtualCard
      bool canAddPhysical = profile == null || profile.cardID <= 0;
      bool canAddVirtual = profile == null ||
          profile.cardIDVirtual == null ||
          profile.cardIDVirtual! <= 0;
      final canAddCard = canAddPhysical || canAddVirtual;

      // Debug des valeurs
      if (profile != null) {
        print('🔍 DEBUG - Bouton ajout carte:');
        print('   cardID: ${profile.cardID}');
        print('   cardIDVirtual: ${profile.cardIDVirtual}');
        print('   canAddPhysical: $canAddPhysical');
        print('   canAddVirtual: $canAddVirtual');
        print('   canAddCard: $canAddCard');
      }

      if (!canAddCard) {
        return SizedBox.shrink();
      }

      return OutlinedButton.icon(
        onPressed: () async {
          // controller.isLoading.value = true;

          // await controller.controllerTestPiece.fetchPieces();
          // controller.isLoading.value = false;
          // // print(contr)
          // if (controller.controllerTestPiece.Error.value != false) {
          //   Get.snackbar('connexion instable',
          //       'Veuillez vérifier votre connexion internet',
          //       backgroundColor: Colors.red);
          // } else if (controller.controllerTestPiece.pieces.isEmpty) {
          //   _showComingSoon(context);
          // } else if (controller.controllerTestPiece.pieces.isNotEmpty) {

          //   var VerificationAdminNiveau2 =
          //       controller.controllerTestPiece.pieces[0].verificationAdmin;

          //   var VerificationAdminNiveau3 = true;

          //   if (VerificationAdminNiveau2 == false)
          //     Get.snackbar('En attente de vérification',
          //         'Veuillez patienter que vos pieces sont soient validées ',
          //         backgroundColor: Colors.red);
          //   else if (VerificationAdminNiveau3)
          //     Get.snackbar('En attente de vérification', 'Veuillez patienter',
          //         backgroundColor: Colors.red);
          //   else

          //     WoltModalSheet.show<void>(
          //       context: context,
          //       pageListBuilder: (modalSheetContext) {
          //         final textTheme = Theme.of(context).textTheme;
          //         return [
          //           page1(modalSheetContext, textTheme,
          //               VerificationAdminNiveau2, VerificationAdminNiveau3),
          //         ];
          //       },
          //     );
          // }
          WoltModalSheet.show<void>(
            context: context,
            pageListBuilder: (modalSheetContext) {
              final textTheme = Theme.of(context).textTheme;
              return [
                page1(modalSheetContext, textTheme, true, true),
              ];
            },
          );
        },
        icon: Icon(Icons.add),
        label: Text('Plus'),
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, screenSize.height * 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  Widget _buildTransactionHistory(BuildContext context, Size screenSize) {
    return Obx(() {
      final card = controller.currentCard;

      // Ne pas afficher s'il n'y a pas de carte
      if (card == null || card.typeLabel == 'Aucune carte') {
        return const SizedBox.shrink();
      }

      final transactions = controller.transactions;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Historique des transactions',
              style: TextStyle(
                fontSize: screenSize.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Gap(screenSize.height * 0.01),
          SizedBox(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 10.h,
                        ),
                        Icon(
                          Icons.receipt_long,
                          size: screenSize.width * 0.12,
                          color: Colors.grey.shade400,
                        ),
                        Gap(screenSize.height * 0.01),
                        Text(
                          'Aucune transaction',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: screenSize.width * 0.04,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(), // ✅ Activer le scroll

                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final totalAmount = tx.totalAmount;
                      final amountText = totalAmount.toString();
                      final isDebit = _isAmountNegative(totalAmount);

                      return ListTile(
                        title: Text(
                          isDebit ? 'Débit' : 'Crédit',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          tx.transactionDate ?? 'Date inconnue',
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          _safeFormatAmount(totalAmount),
                          style: TextStyle(
                            color: isDebit ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: screenSize.width * 0.035,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  // MODIFICATION PRINCIPALE: Widget _cardAction avec support des hints pour cartes bloquées
  Widget _cardAction(
    IconData icon,
    String label,
    Size screenSize, {
    VoidCallback? onTap,
    bool isEnabled = true,
    bool showBlockedHint = false,
    Key? key,
  }) =>
      GestureDetector(
        key: key,
        onTap: isEnabled
            ? onTap
            : () {
                if (showBlockedHint) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Carte bloquée - Débloquez-la pour utiliser cette fonction'),
                      backgroundColor: Colors.orange,
                      action: SnackBarAction(
                        label: 'Débloquer',
                        textColor: Colors.white,
                        onPressed: () => controller.toggleCardStatus(),
                      ),
                    ),
                  );
                }
              },
        child: Opacity(
          opacity:
              isEnabled ? 1.0 : 0.6, // Légèrement moins opaque au lieu de 0.5
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        isEnabled ? Colors.grey.shade200 : Colors.grey.shade100,
                    radius: screenSize.width * 0.06,
                    child: Icon(
                      icon,
                      color: isEnabled ? Colors.black : Colors.grey.shade400,
                      size: screenSize.width * 0.05,
                    ),
                  ),
                  // Indicateur de blocage
                  if (showBlockedHint)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Icon(
                          Icons.lock,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              Gap(screenSize.height * 0.008),
              Text(
                label,
                style: TextStyle(
                  fontSize: screenSize.width * 0.025,
                  color: isEnabled ? Colors.black : Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  // CORRECTION PRINCIPALE: Utilisation du type de carte du contrôleur directement
  Color _getCardColor(dynamic cardType) {
    // Conversion sécurisée du type de carte
    String typeString = cardType.toString().toLowerCase();

    if (typeString.contains('physical')) {
      return AppColorModel.Bluecolor242;
    } else if (typeString.contains('virtual')) {
      return AppColorModel.BlueColor;
    } else {
      return Colors.grey.shade400;
    }
  }

  void _showComingSoon(BuildContext context, [String? title]) {
    showCupertinoDialog(
  context: context,
  barrierDismissible: false, // bloque tap extérieur
  builder: (_) => WillPopScope(
    onWillPop: () async => false, // bloque bouton retour
    child: CupertinoAlertDialog(
      title: Text(title ?? "Vous n'avez pas de pièce jointe"),
      content: Text("Allez dans paramètre afin d'en ajouter"),
      actions: [
        CupertinoDialogAction(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop(); // ferme le dialog
            Get.off(() => VerifierIdentiteScreen());
          },
        ),
      ],
    ),
  ),
);

  }
}
