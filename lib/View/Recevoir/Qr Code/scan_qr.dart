// Ajoutez cette dépendance dans votre pubspec.yaml :
// mobile_scanner: ^3.5.6

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:onyfast/Api/transactionwallet.dart';
import 'package:onyfast/Api/user_inscription.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';

import 'package:onyfast/Controller/transactionwalletcontroller.dart';
import 'package:onyfast/Controller/fraiscontroller.dart';
import 'package:onyfast/Controller/verou/verroucontroller.dart';
import 'package:onyfast/View/C2C/send_money_page.dart';
import 'package:onyfast/View/Notification/notification.dart';
import 'package:onyfast/View/Transfert/transfert.dart' as transfert;
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Widget/dialog.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:onyfast/utils/testInternet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../Color/app_color_model.dart';
import '../../../Crypte & Decrypte/crypte.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:onyfast/main.dart' show routeObserver;

class ScanQr extends StatefulWidget {
  const ScanQr({super.key});

  @override
  State<ScanQr> createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> with RouteAware {
  final ManageCardsController cardsController =
      Get.find<ManageCardsController>();
  var selectedCard = Rxn<CardData>();
  var scannedCardID = ''.obs; // ← AJOUTE ÇA

  final TextEditingController textController = TextEditingController();
  final TextEditingController beneficiaryController = TextEditingController();
  final TextEditingController montantController = TextEditingController();

  final GetStorage storage = GetStorage();
  final EncryptionController controller = Get.put(EncryptionController());
  final RechargeWalletController rechargeController =
      Get.put(RechargeWalletController());
  final FraisController fraisController = Get.put(FraisController());

  var isLoading = false.obs;
  MobileScannerController? scannerController;

  @override
  void initState() {
    super.initState();
    NoScreenshot.instance.screenshotOff();

    // Initialiser les contrôleurs avec des valeurs par défaut
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final cards = cardsController.cards
            .where((c) => c.type != CardType.none)
            .toList();
        if (cards.isNotEmpty) {
          selectedCard.value = cards.first;
        }
        rechargeController.updateMontant(0);
        fraisController.reset();
      } catch (e) {
        debugPrint('Erreur lors de l\'initialisation: $e');
      }
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    NoScreenshot.instance.screenshotOn();

    textController.dispose();
    beneficiaryController.dispose();
    montantController.dispose();
    scannerController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPush() {
    NoScreenshot.instance.screenshotOff();
  }

  @override
  void didPopNext() {
    // Revenu sur cette page
    NoScreenshot.instance.screenshotOff();
  }

  @override
  void didPushNext() {
    // On quitte cette page
    NoScreenshot.instance.screenshotOn();
  }

  @override
  void didPop() {
    NoScreenshot.instance.screenshotOn();
  }

  Future<void> handleTransaction() async {
    print("💳 💳 ");
    print(scannedCardID.value);
    print(
        '💳 Carte courante du controller: ${cardsController.currentCard?.cardID}');

    if (isLoading.value) return;

    isLoading.value = true;

    try {
      bool isConnected = await hasInternetConnection();

      if (isConnected) {
        print('Connexion Internet disponible');
      } else {
        SnackBarService.error('Pas de connexion Internet');
        return;
      }

      //         final service = FeaturesService();
      //  final isActive = await service.isFeatureActive(AppFeature.);

      //             if (isActive) {
      //               print('✅ La recharge MoMo est disponible');
      //             } else {
      //               Get.back();
      //               SnackBarService.error('❌ La recharge MoMo est désactivée');

      //               return ;
      //             }

      final userInfo = storage.read('userInfo') ?? {};

      if (beneficiaryController.text.isEmpty ||
          montantController.text.isEmpty) {
        SnackBarService.warning(
          'Veuillez remplir tous les champs',
        );
        return;
      }

      final amount = double.tryParse(montantController.text);
      if (amount == null || amount < 25) {
        SnackBarService.info(
          'Le montant minimum est de 25 FCFA',
        );
        return;
      }

      await TransactionService().makeTransaction(
        fromTelephone: userInfo['telephone'] ?? '',
        toTelephone: beneficiaryController.text,
        amount: montantController.text,
        context: context,
        to_card_id: scannedCardID.value,
      );

      if (mounted) {
        Navigator.of(context).pop();
        //  SnackBarService.warning( 'Transaction effectuée avec succès',
        //     );

        beneficiaryController.clear();
        montantController.clear();
        rechargeController.updateMontant(0);
        fraisController.reset();
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.error(
          'Une erreur est survenue ,\nSi le problème persiste contactez le support',
        );
      }
    } finally {
      if (mounted) {
        isLoading.value = false;
      }

      AuthController connexion = Get.find();
      connexion.fetchSolde();
    }
  }

  // Widget d'information cache amélioré avec info destinataire
  Widget _buildCacheInfoWidget() {
    return Obx(() {
      try {
        // ✅ Capturer toutes les valeurs en une seule fois pour éviter concurrent modification
        final controllerState = {
          'isUsingCache': fraisController.isUsingCache,
          'statusMessage': fraisController.statusMessage,
          'isConfigLoaded': fraisController.isConfigLoaded,
          'debugInfo': fraisController.debugInfo,
          'hasDestinataireFrais': fraisController.hasDestinataireSpecificFrais,
          'currentDestinataire': fraisController.currentDestinataireNumber,
        };

        final isUsingCache = controllerState['isUsingCache'] as bool;
        final statusMessage = controllerState['statusMessage'] as String;
        final isConfigLoaded = controllerState['isConfigLoaded'] as bool;
        final debugInfo = controllerState['debugInfo'] as String;
        final hasDestinataireFrais =
            controllerState['hasDestinataireFrais'] as bool;

        return Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: hasDestinataireFrais
                ? Colors.blue.shade50
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
                color: hasDestinataireFrais
                    ? Colors.blue.shade200
                    : Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    hasDestinataireFrais
                        ? Icons.person_pin
                        : (isUsingCache ? Icons.memory : Icons.cloud),
                    size: 14,
                    color: hasDestinataireFrais
                        ? Colors.blue.shade700
                        : (isUsingCache ? Colors.green : Colors.blue),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      statusMessage,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color:
                            hasDestinataireFrais ? Colors.blue.shade700 : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (isConfigLoaded) ...[
                const SizedBox(height: 4),
                Text(
                  'Config: $debugInfo',
                  style: TextStyle(
                      fontSize: 9.sp,
                      color: hasDestinataireFrais
                          ? Colors.blue.shade600
                          : Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (hasDestinataireFrais) ...[
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Frais spécifiques appliqués',
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      } catch (e) {
        debugPrint('Erreur dans _buildCacheInfoWidget: $e');
        return Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Text(
            'Erreur de chargement des informations',
            style: TextStyle(fontSize: 9.sp, color: Colors.red),
          ),
        );
      }
    });
  }

  // Méthode pour charger les frais spécifiques au destinataire
  Future<void> _loadDestinataireSpecificFrais(String destinataire) async {
    try {
      debugPrint('🎯 Chargement des frais pour: $destinataire');
      await fraisController.loadFraisForDestinataire(destinataire);

      // Recalculer les frais si on a déjà un montant
      final montantActuel = double.tryParse(montantController.text) ?? 0;
      if (montantActuel >= 25) {
        fraisController.calculerFrais(montantActuel);
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des frais destinataire: $e');
    }
  }

  Widget _buildTransactionDialog(BuildContext dialogContext, String labelText) {
    return AlertDialog.adaptive(
      title: Text("Envoyer de l'argent de façon sécurisée",
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              style: TextStyle(fontSize: 10.sp),
              controller: beneficiaryController,
              enabled: labelText != 'Bénéficiaire',
              decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10.sp),
                labelText: labelText,
                border: const OutlineInputBorder(),
                hintText: labelText == 'Entrer le code'
                    ? 'Saisissez le code reçu'
                    : labelText == 'Numéro du Bénéficiaire'
                        ? 'Ex: +237123456789'
                        : null,
              ),
              keyboardType: labelText == 'Numéro du Bénéficiaire'
                  ? TextInputType.phone
                  : TextInputType.text,
              onChanged: (value) {
                // Charger les frais spécifiques quand le numéro change
                if (labelText == 'Numéro du Bénéficiaire' && value.isNotEmpty) {
                  _loadDestinataireSpecificFrais(value);
                }
              },
            ),

            const SizedBox(height: 16),
            Obx(() {
              return TextField(
                style: TextStyle(fontSize: 10.sp),
                enabled: !isLoading.value,
                maxLength: 10,
                buildCounter: (
                  BuildContext context, {
                  required int currentLength,
                  required bool isFocused,
                  required int? maxLength,
                }) {
                  return null; // 🔥 Aucun widget = aucune trace du compteur
                },
                controller: montantController,
                onChanged: (value) {
                  try {
                    final montant = double.tryParse(value) ?? 0;
                    rechargeController.updateMontant(montant);
                    if (montant >= 25) {
                      fraisController.calculerFrais(montant);
                    } else {
                      fraisController.resetAmounts();
                    }
                  } catch (e) {
                    debugPrint('Erreur lors du calcul du montant: $e');
                  }
                },
                decoration:  InputDecoration(
                  hintStyle: TextStyle(fontSize: 9.sp),
                  labelText: 'Montant',
                  hintText: "À partir de 25 FCFA",
                  border: OutlineInputBorder(),
                  prefixText: 'FCFA ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              );
            }),
            const SizedBox(height: 12),

            // Info cache avec gestion d'erreur améliorée
            _buildCacheInfoWidget(),

            // Affichage des frais avec gestion d'erreur
            Obx(() {
              try {
                final isLoading = fraisController.isLoading.value;
                final hasError = fraisController.hasError.value;
                final errorMessage = fraisController.errorMessage.value;
                final isUsingCache = fraisController.isUsingCache;
                final isConfigLoaded = fraisController.isConfigLoaded;
                final montantValue = rechargeController.montant.value;
                final fraisValue = fraisController.frais.value;
                final totalValue = fraisController.total.value;
                final hasDestinataireFrais =
                    fraisController.hasDestinataireSpecificFrais;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicateur de chargement
                    if (isLoading)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CupertinoActivityIndicator(radius: 15),
                            ),
                            SizedBox(width: 8),
                            Text('Chargement des frais...',
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 9.sp)),
                          ],
                        ),
                      ),

                    // Message d'erreur avec boutons d'action
                    if (hasError && !isLoading)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber,
                                    color: Colors.orange.shade600, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontSize: 9.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Bouton Réessayer
                                GestureDetector(
                                  onTap: () {
                                    try {
                                      fraisController.forceReloadConfig();
                                    } catch (e) {
                                      debugPrint(
                                          'Erreur lors du rechargement: $e');
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Réessayer',
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Bouton Nettoyer Cache
                                if (isUsingCache)
                                  GestureDetector(
                                    onTap: () {
                                      try {
                                        fraisController.clearCacheAndReload();
                                      } catch (e) {
                                        debugPrint(
                                            'Erreur lors du nettoyage du cache: $e');
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Vider cache',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Affichage des frais calculés
                    if (montantValue >= 25 && !isLoading && isConfigLoaded) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: hasDestinataireFrais
                              ? Colors.blue.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: hasDestinataireFrais
                                  ? Colors.blue.shade200
                                  : Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasDestinataireFrais) ...[
                              Row(
                                children: [
                                  Icon(Icons.verified_user,
                                      color: Colors.blue.shade600, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Frais optimisés pour ce destinataire',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Montant:',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 9.sp),
                                ),
                                Text(
                                  '${NumberFormat("#,##0", "fr_FR").format(double.tryParse(montantValue.toStringAsFixed(0)) ?? 0.0)} FCFA',
                                  style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  hasDestinataireFrais
                                      ? 'Frais spéciaux:'
                                      : 'Frais:',
                                  style: TextStyle(
                                      color: hasDestinataireFrais
                                          ? Colors.blue.shade700
                                          : Colors.black54,
                                      fontSize: 9.sp,
                                      fontWeight: hasDestinataireFrais
                                          ? FontWeight.w600
                                          : FontWeight.normal),
                                ),
                                Text(
                                  '${NumberFormat("#,##0", "fr_FR").format(double.tryParse(fraisValue.toStringAsFixed(0)) ?? 0.0)} FCFA',
                                  style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w500,
                                      color: hasDestinataireFrais
                                          ? Colors.blue.shade700
                                          : null),
                                ),
                              ],
                            ),
                            const Divider(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total à débiter:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9.sp),
                                ),
                                Text(
                                  '${NumberFormat("#,##0", "fr_FR").format(double.tryParse(totalValue.toStringAsFixed(0)) ?? 0.0)} FCFA',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 3.w,
                                    color: hasDestinataireFrais
                                        ? Colors.blue.shade700
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Message si montant insuffisant
                    if (montantValue > 0 && montantValue < 25 && !isLoading)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.yellow.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info,
                                color: Colors.yellow.shade700, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Montant minimum: 25 FCFA',
                              style: TextStyle(
                                color: Colors.yellow.shade700,
                                fontSize: 9.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              } catch (e) {
                debugPrint('Erreur dans Obx des frais: $e');
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    'Erreur lors du chargement des frais',
                    style: TextStyle(fontSize: 9.sp, color: Colors.red),
                  ),
                );
              }
            }),

            const SizedBox(height: 30),
            Obx(() {
              try {
                final montantValue = rechargeController.montant.value;
                final isConfigLoaded = fraisController.isConfigLoaded;
                final canProceed = !isLoading.value &&
                    montantValue >= 25 &&
                    beneficiaryController.text.isNotEmpty &&
                    isConfigLoaded;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canProceed ? handleTransaction : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          canProceed ? AppColorModel.DeepPurple : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isLoading.value == true
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CupertinoActivityIndicator(
                                radius: 15, color: Colors.white),
                          )
                        : Text("Effectuer la transaction".tr,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            )),
                  ),
                );
              } catch (e) {
                debugPrint('Erreur dans le bouton de transaction: $e');
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Erreur - Réessayez',
                    ),
                  ),
                );
              }
            }),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                try {
                  beneficiaryController.clear();
                  montantController.clear();
                  rechargeController.updateMontant(0);
                  fraisController.reset();
                  Navigator.of(dialogContext).pop();
                } catch (e) {
                  debugPrint('Erreur lors de la fermeture: $e');
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(
                'Fermer',
                style: TextStyle(fontSize: 9.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDialog(String labelText) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) =>
          _buildTransactionDialog(dialogContext, labelText),
    );
  }

  void _showWoltModal() {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) =>
          [_buildWoltModalSheetPage(modalSheetContext)],
    );
  }

  WoltModalSheetPage _buildWoltModalSheetPage(BuildContext modalSheetContext) {
    return WoltModalSheetPage(
      hasSabGradient: false,
      stickyActionBar: Padding(padding: EdgeInsets.all(8.dp)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(20.dp),
            Center(
              child: Text('Options de transfert',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorModel.black)),
            ),
            Gap(10.dp),
            // const Divider(),
            // ListTile(
            //   leading: _actionItem(Icons.send, Colors.blue),
            //   title: Text("Transfert par code",
            //       style:
            //           TextStyle(fontSize: 16.dp, color: AppColorModel.black)),
            //   subtitle: const Text('Saisissez un code de transfert'),
            //   onTap: () {
            //     Navigator.of(modalSheetContext).pop();
            //     _showTransactionDialog('Entrer le code');
            //   },
            // ),
            // const Divider(),
            // ListTile(
            //   leading: _actionItem(Icons.contacts, Colors.deepPurpleAccent),
            //   title: Text("Transfert par numéro de téléphone",
            //       style:
            //           TextStyle(fontSize: 16.dp, color: AppColorModel.black)),
            //   subtitle: const Text('Saisissez le numéro du bénéficiaire'),
            //   onTap: () {
            //     Navigator.of(modalSheetContext).pop();
            //     _showTransactionDialog("Numéro du Bénéficiaire");
            //   },
            // ),
            // const Divider(),
            ListTile(
              leading: _actionItem(
                Icons.swap_horiz,
                Colors.orange,
              ),
              title: Text("Transfert Onyfast",
                  style:
                      TextStyle(fontSize: 10.sp, color: AppColorModel.black)),
              subtitle: Text('Saisissez le numéro du bénéficiaire',
                  style: TextStyle(fontSize: 8.sp)),
              onTap: () {
                Navigator.of(modalSheetContext).pop();
                Get.to(SendMoneyPage());
                // _showTransactionDialog("Numéro du Bénéficiaire");
              },
            ),
            const Divider(),
            ListTile(
              leading: _actionItem(
                  Icons.sync_alt, const Color.fromARGB(255, 3, 36, 184)),
              title: Text("Autre Transfert",
                  style:
                      TextStyle(fontSize: 10.sp, color: AppColorModel.black)),
              subtitle: Text('Saisissez le numéro du bénéficiaire',
                  style: TextStyle(fontSize: 8.sp)),
              onTap: () {
                Navigator.of(modalSheetContext).pop();
                Get.dialog(
                  AppDialog(
                    title: "Bientôt disponible",
                    body: "Cette fonctionnalité sera disponible prochainement",
                    actions: [
                      AppDialogAction(
                        label: "OK",
                        isDestructive: true,
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                );
                // Navigator.push(
                //   context,
                //   CupertinoPageRoute(
                //       builder: (context) => transfert.Transfert()),
                // ); //Navigator.of(modalSheetContext).pop();
                // Get.to(SendMoneyPage());
                // _showTransactionDialog("Numéro du Bénéficiaire");
              },
            ),
            const Divider(),
            Gap(30.dp),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(modalSheetContext).pop(),
                child: Text('Annuler', style: TextStyle(fontSize: 9.sp)),
              ),
            ),
            Gap(20.dp),
          ],
        ),
      ),
    );
  }

  Widget _actionItem(IconData icon, Color color) => Column(
        children: [
          CircleAvatar(
              backgroundColor: color,
              // radius: 17,
              child: Icon(icon, color: Colors.white)),
        ],
      );

  // Page de scan QR avec mobile_scanner
  Widget _buildQRScannerPage() {
    AppSettingsController.to.setInactivity(false);

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Scanner QR Code',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize:
                  MediaQuery.of(Get.context!).size.width > 600 ? 18.sp : 16.sp,
            ),
          ),
          backgroundColor: AppColorModel.Bluecolor242,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon:
                Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(scannerController?.torchEnabled == true
                  ? Icons.flash_on
                  : Icons.flash_off),
              onPressed: () => scannerController?.toggleTorch(),
            ),
            IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              onPressed: () => scannerController?.switchCamera(),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              MobileScanner(
                controller: scannerController,
                onDetect: (BarcodeCapture barcodeCapture) {
                  final List<Barcode> barcodes = barcodeCapture.barcodes;

                  if (barcodes.isNotEmpty) {
                    final String? scannedValue = barcodes.first.rawValue;
                    debugPrint('QR Code scanné: $scannedValue');

                    if (scannedValue != null && scannedValue.isNotEmpty) {
                      // Arrêter le scanner pour éviter les scans multiples
                      scannerController?.stop();

                      try {
                        String decryptedValue =
                            controller.decryptData(scannedValue);
                        final Map<String, dynamic> data =
                            jsonDecode(decryptedValue);

                        if (data.containsKey('telephone')) {
                          // ── Vérifier si telephone est une String JSON ou une valeur directe ──
                          final telephoneRaw = data['telephone'];

                          String destinataire;
                          String cardID;

                          // Si telephone contient lui-même un JSON (double encodage)
                          if (telephoneRaw is String &&
                              telephoneRaw.startsWith('{')) {
                            final innerData = jsonDecode(telephoneRaw);
                            destinataire =
                                innerData['telephone']?.toString() ?? '';
                            cardID = innerData['cardID']?.toString() ?? '';

                            print('📞 Téléphone  $destinataire  $cardID');
                          } else {
                            // Cas normal
                            destinataire = telephoneRaw.toString();
                            cardID = data['cardID']?.toString() ?? '';
                          }

                          print('📞 Téléphone final: $destinataire');
                          print('💳 CardID final: $cardID');
                          scannedCardID.value = cardID; // ← ICI on stocke

                          beneficiaryController.text = destinataire;
                          _loadDestinataireSpecificFrais(destinataire);

                          Navigator.of(context).pop();
                          SnackBarService.warning(
                            title: 'QR Code scanné',
                            'Destinataire détecté - Chargement des frais spécifiques...',
                          );
                          _showTransactionDialog("Bénéficiaire");
                        } else {
                          Navigator.of(context).pop();
                          SnackBarService.error(
                            'Code QR invalide',
                          );
                        }
                      } catch (e) {
                        Navigator.of(context).pop();
                        SnackBarService.warning(
                          'Déchiffrement échoué: ${e.toString()}',
                        );
                      }
                    } else {
                      SnackBarService.info(
                        'Aucun code QR détecté',
                      );
                    }
                  }
                },
              ),
              // Overlay pour améliorer l'UX
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // Instructions améliorées
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Placez le code QR dans le cadre pour le scanner',
                        style: TextStyle(color: Colors.white, fontSize: 9.sp),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Les frais seront calculés automatiquement',
                        style: TextStyle(color: Colors.white70, fontSize: 9.sp),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> _scanQRCode() async {
    try {
      scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => _buildQRScannerPage(),
        ),
      );
      AppSettingsController.to.setInactivity(true);
      // ❌ SUPPRIMEZ TOUT LE BLOC FINALLY
    } catch (e) {
      SnackBarService.warning(
        'Impossible d\'ouvrir le scanner: ${e.toString()}',
      );
    }
    // PAS DE FINALLY - le dispose() dans votre méthode dispose() de la classe suffit
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = storage.read('userInfo') ?? {};
    final phoneNumber =
        userInfo['telephone']?.toString() ?? "Numéro indisponible";
    final userName = userInfo['name']?.toString() ?? "Utilisateur";

    return Scaffold(
      backgroundColor: AppColorModel.WhiteColor,
      appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        leading: const BackButton(color: Colors.white),
        title: Text("Transfert",
            style: TextStyle(
                fontSize:
                    MediaQuery.of(context).size.width > 600 ? 18.sp : 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        actions: [
          NotificationWidget(),
        ],
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.dp),
          child: Center(
            child: SingleChildScrollView(
                child: Column(
              spacing: 20.dp,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ 1. SÉLECTEUR DE CARTE (NOUVEAU - avant le QR)
                // Remplace l'Obx du sélecteur par ceci :
                Obx(() {
                  final cards = cardsController.cards
                      .where((c) => c.type != CardType.none)
                      .toList();

                  if (cards.isEmpty) return const SizedBox.shrink();

                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: cards.map((card) {
                        final isSelected =
                            selectedCard.value?.cardID == card.cardID;
                        final isPhysical = card.type == CardType.physical;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => selectedCard.value = card,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isPhysical
                                        ? Icons.credit_card
                                        : Icons.credit_card_outlined,
                                    size: 16,
                                    color: isSelected
                                        ? (isPhysical
                                            ? Colors.blue
                                            : Colors.deepPurpleAccent)
                                        : Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isPhysical ? 'Physique' : 'Virtuelle',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: isSelected
                                              ? Colors.black87
                                              : Colors.grey.shade500,
                                        ),
                                      ),
                                      // Badge actif/bloqué
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: card.isActive
                                              ? Colors.green.shade50
                                              : Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          card.isActive ? 'Active' : 'Bloquée',
                                          style: TextStyle(
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.w600,
                                            color: card.isActive
                                                ? Colors.green.shade600
                                                : Colors.red.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),

                // ✅ 2. CONTAINER QR CODE (inchangé)
                Center(
                  child: Container(
                    width: 60.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Obx(() {
                            final cardID = selectedCard.value?.cardID ?? '';
                            return QrImageView(
                              data: controller.encryptData(jsonEncode({
                                'telephone': phoneNumber,
                                'cardID': cardID,
                              })),
                              version: QrVersions.auto,
                              backgroundColor: Colors.white,
                              errorCorrectionLevel: QrErrorCorrectLevel.M,
                            );
                          }),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: AppColorModel.WhiteColor,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                "asset/logo.png",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.account_balance_wallet,
                                    color: AppColorModel.Bluecolor242,
                                    size: 20,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ✅ 3. INFOS UTILISATEUR (inchangé)
                Column(
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      phoneNumber,
                      style: TextStyle(fontSize: 9.sp, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                // ✅ 4. BOUTON SCANNER (inchangé)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _scanQRCode,
                    icon: Icon(Icons.qr_code_scanner),
                    label: Text(
                      'Scanner un QR Code',
                      style: TextStyle(fontSize: 9.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorModel.Bluecolor242,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.dp),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                  ),
                ),

                // ✅ 5. BOUTON TRANSFERT (inchangé)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showWoltModal,
                    icon: const Icon(Icons.send),
                    label: Text(
                      'Options de transfert',
                      style: TextStyle(fontSize: 9.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorModel.Bluecolor242,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.dp),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            )),
          )),
    );
  }
}
