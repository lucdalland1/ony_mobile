import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/user_inscription.dart';
import 'package:onyfast/Controller/FavoritesController.dart';
import 'package:onyfast/Controller/RecenteTransaction/recenttransactcontroller.dart';
import 'package:onyfast/Controller/contactsController.dart';
import 'package:onyfast/Controller/verou/verroucontroller.dart';

import 'dart:async';
import 'package:onyfast/View/C2C/contacts_onyfast_page.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:onyfast/model/user_model.dart';
import 'package:onyfast/verificationcode.dart';
import '../../Color/app_color_model.dart';
import '../Notification/notification.dart';

import 'package:flutter/cupertino.dart';

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  _SendMoneyPageState createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  CardFromApi? selectedRecipientCard;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final ContactsController contactsController = Get.put(ContactsController());
  final FavoritesController favoritesController = FavoritesController.instance;
  final GetStorage storage = GetStorage();

  Timer? _debounce;
  String currency = 'XAF';
  Map<String, dynamic>? selectedContact;

  // Variables pour gérer les transferts externes
  bool isExternalTransfer = false;
  Map<String, dynamic>? externalRecipient;

  @override
  void initState() {
    super.initState();

    Get.put(amountController, tag: 'amountController');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleContactParameters();
      _preloadAllFraisConfig();
    });
  }

  void _handleContactParameters() {
    final arguments = Get.arguments;

    if (arguments != null && arguments is Map<String, dynamic>) {
      print('📞 Paramètres reçus depuis ContactsOnyfastPage: $arguments');

      setState(() {
        selectedContact = arguments;

        final phoneToDisplay = arguments['display_phone'] ??
            (arguments['phone']?.isNotEmpty == true
                ? _formatPhoneForDisplay(arguments['phone'])
                : '');

        if (phoneToDisplay.isNotEmpty) {
          phoneController.text = phoneToDisplay;
          print('✅ Champ téléphone pré-rempli: "$phoneToDisplay"');
        }
      });

      if (arguments['phone']?.isNotEmpty == true) {
        _checkRecipientStatus(arguments['phone']);
      }
    }
  }

  Future<void> _preloadAllFraisConfig() async {
    try {
      await contactsController.preloadFraisConfig();
      print('✅ Configuration des frais préchargée');
    } catch (e) {
      print('❌ Erreur préchargement : $e');
    }
  }

  String _formatPhoneForDisplay(String phone) {
    if (phone.isEmpty) return phone;

    if (phone.startsWith('+')) {
      phone = phone.substring(1);
    }

    String formatted = contactsController.formatPhoneNumber(phone);
    return '+$formatted';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    phoneController.dispose();
    amountController.dispose();
    Get.delete<TextEditingController>(tag: 'amountController');
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    if (selectedContact != null) {
      setState(() {
        selectedContact = null;
        isExternalTransfer = false;
        externalRecipient = null;
        selectedRecipientCard = null; // ← ajoute ça
      });
      contactsController.resetFrais();
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (value.length >= 8) {
        _checkRecipientStatus(value);
      } else {
        contactsController.clearSearchedUser();
        setState(() {
          isExternalTransfer = false;
          externalRecipient = null;
        });
      }
    });
  }

  Future<void> _checkRecipientStatus(String phone) async {
    try {
      await contactsController.searchUserByPhone(phone);
      setState(() {
        selectedRecipientCard = null; // reset à chaque nouvelle recherche
      });

      if (contactsController.searchedUser.value == null) {
        final validation =
            await contactsController.validateRecipientNumber(phone);

        if (validation['isValid'] == true) {
          setState(() {
            isExternalTransfer = true;
            externalRecipient = {
              'phone': validation['phone'],
              'display_phone': _formatPhoneForDisplay(validation['phone']),
              'name': 'Contact externe',
              'is_external': true,
            };
          });

          print('📱 Destinataire externe valide: ${validation['phone']}');

          if (amountController.text.isNotEmpty) {
            final amount = double.tryParse(amountController.text) ?? 0;
            if (amount > 0) {
              await contactsController.calculateGeneralFees(
                  amount, validation['phone']);
            }
          }
        } else {
          print('❌ Numéro invalide: ${validation['message']}');
          setState(() {
            isExternalTransfer = false;
            externalRecipient = null;
          });
        }
      } else {
        setState(() {
          isExternalTransfer = false;
          externalRecipient = null;
        });
      }
    } catch (e) {
      print('❌ Erreur vérification destinataire: $e');
    }
  }

  void _updateFraisCalculation() {
    final amount = double.tryParse(amountController.text) ?? 0;

    if (amount <= 0) {
      contactsController.resetFrais();
      return;
    }

    if (isExternalTransfer && externalRecipient != null) {
      contactsController.calculateGeneralFees(
          amount, externalRecipient!['phone']);
    } else if (selectedContact != null) {
      contactsController.selectContact(selectedContact!, amount);
    } else if (contactsController.searchedUser.value != null) {
      contactsController.selectContact(
          contactsController.searchedUser.value!.toMap(), amount);
    }
  }

  void _handleContactSelection() async {
    AppSettingsController.to.setInactivity(false);
    try {
      print('🚀 Navigation vers ContactsOnyfastPage');
      final result = await Get.to(
        () => ContactsOnyfastPage(),
        arguments: null,
      );

      if (result != null) {
        print('✅ Contact retourné: $result');

        setState(() {
          selectedContact = result;
          isExternalTransfer = false;
          externalRecipient = null;

          final phoneToDisplay = result['display_phone'] ??
              (result['phone']?.isNotEmpty == true
                  ? _formatPhoneForDisplay(result['phone'])
                  : '');

          phoneController.text = phoneToDisplay;
        });

        contactsController.clearSearchedUser();

        if (result['phone']?.isNotEmpty == true) {
          _checkRecipientStatus(result['phone']);
        }

        _updateFraisCalculation();
      }
    } catch (e) {
      print('❌ Erreur navigation contacts: $e');
      Get.snackbar(
        'Erreur',
        'Impossible d\'accéder aux contacts',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    AppSettingsController.to.setInactivity(true);
  }

  void _selectFavorite(Map<String, dynamic> favorite) {
    print('🌟 Favori sélectionné: ${favorite['name']} (${favorite['phone']})');

    setState(() {
      selectedContact = {
        'id': favorite['user_id'],
        'name': favorite['name'],
        'phone': favorite['phone'],
        'display_phone': favorite['phone'],
        'email': favorite['email'],
        'avatar': favorite['avatar'],
        'has_phone': true,
      };

      isExternalTransfer = false;
      externalRecipient = null;

      phoneController.text = favorite['phone'] ?? '';
    });

    if (favorite['phone']?.isNotEmpty == true) {
      _checkRecipientStatus(favorite['phone']);
    }

    if (amountController.text.isNotEmpty) {
      _updateFraisCalculation();
    }

    Get.snackbar(
      'Favori sélectionné',
      '${favorite['name']} sélectionné depuis les favoris',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.withOpacity(0.9),
      colorText: Colors.white,
      duration: Duration(milliseconds: 800),
      icon: Icon(Icons.star, color: Colors.white, size: 20),
      margin: EdgeInsets.all(8),
    );
  }

  void _showFavoriteOptions(Map<String, dynamic> favorite, int index) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.orange.shade100,
                  backgroundImage: favorite['avatar'] != null &&
                          favorite['avatar'].isNotEmpty
                      ? NetworkImage(favorite['avatar'])
                      : null,
                  child:
                      favorite['avatar'] == null || favorite['avatar'].isEmpty
                          ? Text(
                              favorite['name']?.isNotEmpty == true
                                  ? favorite['name'][0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            )
                          : null,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        favorite['name'] ?? 'Inconnu',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        favorite['phone'] ?? '',
                        style: TextStyle(
                          fontSize: 12.sp
                          ,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (favorite['transaction_count'] != null)
                        Text(
                          '${favorite['transaction_count']} transaction(s)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            ListTile(
              leading:
                  Icon(Icons.person_add, color: AppColorModel.Bluecolor242),
              title: Text('Sélectionner ce contact'),
              onTap: () {
                Get.back();
                _selectFavorite(favorite);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Supprimer des favoris'),
              subtitle: Text('Cette action est irréversible'),
              onTap: () {
                Get.back();
                _confirmDeleteFavorite(favorite, index);
              },
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  void _confirmDeleteFavorite(Map<String, dynamic> favorite, int index) {
    Get.dialog(
      AlertDialog(
        title: Text('Supprimer le favori'),
        content: Text(
          'Voulez-vous vraiment supprimer "${favorite['name']}" de vos favoris ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              favoritesController.removeFavorite(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showFavoritesManagement() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Gestion des favoris',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.delete_sweep, color: Colors.red),
              title: Text('Supprimer tous les favoris'),
              subtitle: Text('Cette action supprimera tous vos favoris'),
              onTap: () {
                Get.back();
                _confirmClearAllFavorites();
              },
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  void _confirmClearAllFavorites() {
    Get.dialog(
      AlertDialog(
        title: Text('Supprimer tous les favoris'),
        content: Text(
          'Voulez-vous vraiment supprimer tous vos favoris ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              favoritesController.clearAllFavorites();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Tout supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionConfirmation() {
    final amount = double.tryParse(amountController.text) ?? 0;
    final phone = selectedContact?['phone'] ??
        externalRecipient?['phone'] ??
        phoneController.text;

    String name;
    bool hasValidRecipient = false;

    if (isExternalTransfer && externalRecipient != null) {
      name = 'Contact externe';
      hasValidRecipient = true;
    } else {
      final user = contactsController.searchedUser.value;
      name = selectedContact?['name'] ?? user?.name ?? 'Utilisateur';
      hasValidRecipient = user != null || selectedContact != null;
    }

    if (phone.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer un numéro de téléphone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (amount <= 0) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer un montant valide',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!hasValidRecipient) {
      Get.snackbar(
        'Destinataire non valide',
        'Ce numéro ne peut pas recevoir de transfert',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
      return;
    }

    if (contactsController.contactFraisConfig.value == null) {
      Get.snackbar(
        'Configuration manquante',
        'Aucune configuration de frais n\'est disponible',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    String transferType =
        isExternalTransfer ? 'Transfert externe' : 'Transfert OnyFast';

    Get.dialog(
      
      AlertDialog.adaptive(
        title: Text('Confirmer la transaction',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmationRow('Type', transferType),
            _buildConfirmationRow('Destinataire', name),
            _buildConfirmationRow('Numéro', _formatPhoneForDisplay(phone)),
            SizedBox(height: 12),
            _buildConfirmationRow('Montant', '$amount $currency'),
            _buildConfirmationRow('Frais',
                '+${contactsController.selectedContactFrais.value.toStringAsFixed(0)} $currency'),
            Divider(height: 20),
            _buildConfirmationRow(
              'Total à débiter:',
              '${contactsController.selectedContactTotal.value.toStringAsFixed(0)} $currency',
              isTotal: true,
            ),
            if (isExternalTransfer) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue.shade600, size: 12.sp),
                        SizedBox(width: 8),
                        Text(
                          'Procédure de retrait',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Le destinataire recevra un code OTP par SMS\n'
                      '• Il devra présenter ce code à un sous-distributeur',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.blue.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler', style: TextStyle(fontSize: 12.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _processTransaction();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorModel.Bluecolor242,
            ),
            child: Text('Confirmer', style: TextStyle(color: Colors.white, fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 10.sp : 9.sp,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.green.shade700 : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: isTotal ? 12.sp : 10.sp,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? Colors.green.shade700 : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processTransaction() async {

    // Après avoir défini recipientId, ajoute :
final cardId = selectedRecipientCard?.cardId;
print('💳 Card ID destinataire: $cardId');
    final amount = double.tryParse(amountController.text) ?? 0;
    final userInfo = storage.read('userInfo') ?? {};
    final fromTel = userInfo['telephone'];
    final toTel = phoneController.value.text;

    dynamic recipientId;
    String recipientName;

    if (isExternalTransfer && externalRecipient != null) {
      recipientId = null;
      recipientName = 'Contact externe';
    } else {
      final user = contactsController.searchedUser.value;
      recipientId = selectedContact?['id'] ?? user?.id;
      recipientName = selectedContact?['name'] ?? user?.name ?? 'Utilisateur';

      if (recipientId == null) {
        SnackBarService.error(
            'Impossible d\'identifier le destinataire dans la base de données');
        return;
      }
    }

    Get.dialog(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoActivityIndicator(
              color: Color(0xFF1D348C),
              radius: 15,
            ),
            SizedBox(height: 16),
            Text(isExternalTransfer
                ? 'Transfert externe en cours...'
                : 'Transaction en cours...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final result = await contactsController.processTransaction(
        recipientId: recipientId,
        amount: amount,
        fromTel: fromTel,
        toTel: toTel,
        fees: contactsController.selectedContactFrais.value,
        total: contactsController.selectedContactTotal.value,
        isExternalTransfer: isExternalTransfer,
        recipientCardId: cardId??'',

      );

      Get.back();

      if (result['success'] == true) {
        final contactPhone = isExternalTransfer
            ? externalRecipient!['phone']
            : (selectedContact?['phone'] ?? phoneController.text);
        final contactAvatar = isExternalTransfer
            ? null
            : (selectedContact?['avatar'] ??
                contactsController.searchedUser.value?.avatar);
        final contactEmail = isExternalTransfer
            ? null
            : (selectedContact?['email'] ??
                contactsController.searchedUser.value?.email);

        favoritesController.addOrUpdateFavorite(
          phone: contactPhone,
          name: recipientName,
          avatar: contactAvatar,
          email: contactEmail,
          userId: recipientId ?? 0,
        );

        print(
            '🌟 Contact ajouté/mis à jour dans les favoris (externe: $isExternalTransfer)');

        String successMessage;
        String otpMessage = '';

        if (isExternalTransfer) {
          successMessage = 'Transfert initié avec succès !';
          otpMessage =
              '\n\nLe destinataire va recevoir un code OTP par SMS pour retirer l\'argent chez un sous-distributeur.';
        } else {
          successMessage = 'Transaction effectuée avec succès !';
        }
        SnackBarService.success("$successMessage" "$otpMessage");

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            phoneController.clear();
            amountController.clear();
            selectedContact = null;
            isExternalTransfer = false;
            externalRecipient = null;
            selectedRecipientCard = null; // ← ajoute ça
          });
          contactsController.resetFrais();
          contactsController.clearSearchedUser();
        });
      } else {
        SnackBarService.error(
            title: '${result['message']}' ?? 'Erreur lors d\'enregistrement',
            '${result['error'] ?? ''}');
      }
    } catch (e) {
      Get.back();

      Get.snackbar(
        'Erreur de connexion',
        'Impossible de se connecter à la base de données. Veuillez réessayer.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    }

    AuthController connexion = Get.find();
    connexion.fetchSolde();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 600;

    final horizontalPadding =
        isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0);
    final titleFontSize = isSmallScreen ? 20.0 : 22.0;
    final cardPadding = isSmallScreen ? 10.0 : 12.0;

    return Scaffold(
      backgroundColor: AppColorModel.WhiteColor,
      appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Transfert Onyfast",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 600?18.sp : 16.sp,
              color: AppColorModel.WhiteColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          NotificationWidget(),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Envoyer',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),

                        ),
                        SizedBox(height: screenHeight * 0.025),

                        // Section favoris
                        Obx(() {
                          final recentFavorites =
                              favoritesController.getRecentFavorites(limit: 12);
                          if (recentFavorites.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: isSmallScreen ? 18.0 : 20.0,
                                    ),
                                    SizedBox(width: 8.0),
                                    Expanded(
                                      child: Text(
                                        'Favoris récents',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 12.0.sp : 10.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _showFavoritesManagement,
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: Colors.grey.shade600,
                                        size: isSmallScreen ? 18.0 : 20.0,
                                      ),
                                      padding: EdgeInsets.all(4),
                                      constraints: BoxConstraints(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.0),
                                SizedBox(
                                  height: isSmallScreen ? 70.0 : 80.0,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: recentFavorites.length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(width: 8.0),
                                    itemBuilder: (context, index) {
                                      final favorite = recentFavorites[index];
                                      return _buildFavoriteItem(
                                          favorite, index, isSmallScreen);
                                    },
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.025),
                              ],
                            );
                          }

                          return SizedBox.shrink();
                        }),

                        // Champ numéro de téléphone
                        TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          onChanged: _onPhoneChanged,
                          style:
                              TextStyle(fontSize: isSmallScreen ? 10.sp:12.sp),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Numéro du destinataire',
                            hintStyle: TextStyle(
                                fontSize: isSmallScreen ? 10.sp : 12.sp),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: AppColorModel.Bluecolor242,
                              size: isSmallScreen ? 20.0 : 24.0,
                            ),
                            suffixIcon: Obx(
                                () => contactsController.isSearchingUser.value
                                    ? Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: SizedBox(
                                          width: 16.0,
                                          height: 16.0,
                                          child: CupertinoActivityIndicator(
                                            color: Color(0xFF1D348C),
                                            radius: 15,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.person_search,
                                        color: Colors.grey,
                                        size: isSmallScreen ? 20.0 : 24.0,
                                      )),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: isSmallScreen ? 12.0 : 16.0,
                            ),
                          ),
                        ),

                        // Affichage des utilisateurs trouvés OU destinataire externe
                        Obx(() {
                          final user = contactsController.searchedUser.value;

                          // Afficher utilisateur OnyFast trouvé
                          // Afficher utilisateur OnyFast trouvé
                          if (user != null &&
                              selectedContact == null &&
                              !isExternalTransfer) {
                            return Column(
                              children: [
                                SizedBox(height: 12.0),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(cardPadding),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.green.shade200),
                                  ),
                                  child: Column(
                                    // ← passe de Row à Column pour empiler
                                    children: [
                                      // ── Infos utilisateur (ton Row existant) ──
                                      IntrinsicHeight(
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius:
                                                  isSmallScreen ? 18.0 : 20.0,
                                              backgroundColor:
                                                  Colors.green.shade100,
                                              backgroundImage: user.avatar !=
                                                          null &&
                                                      user.avatar!.isNotEmpty
                                                  ? NetworkImage(user.avatar!)
                                                  : null,
                                              child: user.avatar == null ||
                                                      user.avatar!.isEmpty
                                                  ? Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: isSmallScreen
                                                          ? 20.0
                                                          : 24.0,
                                                    )
                                                  : null,
                                            ),
                                            SizedBox(width: 12.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    user.name,
                                                    style: TextStyle(
                                                      fontSize: isSmallScreen
                                                          ? 12.sp
                                                          : 14.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  Text(
                                                    'Compte Onyfast trouvé',
                                                    style: TextStyle(
                                                      fontSize: isSmallScreen
                                                          ? 10.sp
                                                          : 12.sp,
                                                      color:
                                                          Colors.green.shade700,
                                                    ),
                                                  ),
                                                  if (user.telephone.isNotEmpty)
                                                    Text(
                                                      _formatPhoneForDisplay(
                                                          user.telephone),
                                                      style: TextStyle(
                                                        fontSize: isSmallScreen
                                                            ? 10.0
                                                            : 12.0,
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ── Sélection de carte (seulement si l'utilisateur a des cartes) ──
                                      if (user.cards.isNotEmpty) ...[
                                        SizedBox(height: 12.0),
                                        Divider(
                                            color: Colors.green.shade200,
                                            height: 1),
                                        SizedBox(height: 12.0),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Sélectionner une carte de destination',
                                            style: TextStyle(
                                              fontSize:
                                                  isSmallScreen ? 10.sp : 12.sp,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        DropdownButtonFormField<CardFromApi>(
                                          value: selectedRecipientCard,
                                          isExpanded: true,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 12.0,
                                              vertical:
                                                  isSmallScreen ? 8.0 : 10.0,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: Colors.green.shade300),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: Colors.green.shade300),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: Colors.green.shade500,
                                                  width: 1.5),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          hint: Text(
                                            'Choisir une carte',
                                            style: TextStyle(
                                              fontSize:
                                                  isSmallScreen ? 10.sp : 12.sp,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                          items: user.cards.map((card) {
                                            return DropdownMenuItem<
                                                CardFromApi>(
                                              value: card,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    card.type == 'physical'
                                                        ? Icons.credit_card
                                                        : card.type == 'virtual'
                                                            ? Icons
                                                                .credit_card_outlined
                                                            : Icons
                                                                .account_balance_wallet_outlined,
                                                    size: isSmallScreen
                                                        ? 16.0
                                                        : 18.0,
                                                    color:
                                                        Colors.green.shade600,
                                                  ),
                                                  SizedBox(width: 8.0),
                                                  Expanded(
                                                    child: Text(
                                                      '${card.label} - ****${card.last4}',
                                                      style: TextStyle(
                                                        fontSize: isSmallScreen
                                                            ? 10.sp
                                                            : 12.sp,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (CardFromApi? card) {
                                            setState(() {
                                              selectedRecipientCard = card;
                                            });
                                            print(
                                                '💳 Carte sélectionnée: ${card?.label} - ${card?.cardId}');
                                          },
                                        ),

                                        // Message si aucune carte sélectionnée
                                        if (selectedRecipientCard == null) ...[
                                          SizedBox(height: 6.0),
                                          Text(
                                            'Veuillez sélectionner une carte pour continuer',
                                            style: TextStyle(
                                              fontSize:
                                                  isSmallScreen ? 10.sp:12.sp,
                                              color: Colors.orange.shade600,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }

                          // Afficher destinataire externe avec information OTP
                          else if (isExternalTransfer &&
                              externalRecipient != null) {
                            return Column(
                              children: [
                                SizedBox(height: 12.0),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(cardPadding),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.orange.shade200),
                                  ),
                                  child: Column(
                                    children: [
                                      IntrinsicHeight(
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius:
                                                  isSmallScreen ? 18.0 : 20.0,
                                              backgroundColor:
                                                  Colors.orange.shade100,
                                              child: Icon(
                                                Icons.account_balance_wallet,
                                                color: Colors.orange.shade700,
                                                size:
                                                    isSmallScreen ? 20.0 : 24.0,
                                              ),
                                            ),
                                            SizedBox(width: 12.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Contact externe',
                                                    style: TextStyle(
                                                      fontSize: isSmallScreen
                                                          ? 10.sp
                                                          : 12.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  Text(
                                                    'Retrait via code OTP',
                                                    style: TextStyle(
                                                      fontSize: isSmallScreen
                                                            ? 12.0
                                                            : 14.0,
                                                      color: Colors
                                                          .orange.shade700,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    _formatPhoneForDisplay(
                                                        externalRecipient![
                                                            'phone']),
                                                    style: TextStyle(
                                                      fontSize: isSmallScreen
                                                            ? 10.0
                                                            : 12.0,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Container(
                                        padding: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.orange.shade700,
                                              size: isSmallScreen ? 14.0 : 16.0,
                                            ),
                                            SizedBox(width: 8.0),
                                            Expanded(
                                              child: Text(
                                                'Le destinataire recevra un code OTP par SMS pour retirer chez un sous-distributeur',
                                                style: TextStyle(
                                                  fontSize: isSmallScreen
                                                      ? 9.sp:10.sp,
                                                  color: Colors.orange.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }

                          return SizedBox.shrink();
                        }),

                        SizedBox(height: screenHeight * 0.025),

                        // Affichage des contacts sélectionnés
                        if (selectedContact != null) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(cardPadding),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  _buildContactAvatar(
                                      selectedContact!, isSmallScreen),
                                  SizedBox(width: 12.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          selectedContact!['name'] ??
                                              'Nom inconnu',
                                          style: TextStyle(
                                            fontSize:
                                                isSmallScreen ? 10.sp:12.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          selectedContact!['display_phone'] ??
                                              _formatPhoneForDisplay(
                                                  selectedContact!['phone'] ??
                                                      ''),
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize:
                                                isSmallScreen ? 10.sp:12.sp,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (selectedContact!['has_phone'] ==
                                            false)
                                          Text(
                                            'Contact sans numéro',
                                            style: TextStyle(
                                              color: Colors.orange.shade600,
                                              fontSize:
                                                  isSmallScreen ? 9.sp : 10.sp,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedContact = null;
                                        phoneController.clear();
                                        isExternalTransfer = false;
                                        externalRecipient = null;
                                      });
                                      contactsController.resetFrais();
                                      contactsController.clearSearchedUser();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.grey.shade600,
                                        size: isSmallScreen ? 16.0 : 18.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.025),
                        ],

                        // Champ montant
                        Text(
                          'MONTANT',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: isSmallScreen ? 12.sp : 10.sp,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            onChanged: (value) => _updateFraisCalculation(),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10.sp : 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Entrez le montant',
                              hintStyle: TextStyle(
                                fontSize: isSmallScreen ? 10.sp : 12.sp,
                                color: Colors.grey.shade400,
                              ),
                              suffixText: currency,
                              suffixStyle: TextStyle(
                                fontSize: isSmallScreen ? 10.sp : 12.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColorModel.Bluecolor242,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.025),

                        // SECTION CORRIGÉE: Affichage des frais avec support des frais à 0
                        Obx(() => Column(
                              children: [
                                if (contactsController.isLoading.value)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: isSmallScreen ? 16.0 : 20.0,
                                          height: isSmallScreen ? 16.0 : 20.0,
                                          child: CupertinoActivityIndicator(
                                            color: Color(0xFF1D348C),
                                            radius: 15,
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Flexible(
                                          child: Text(
                                            'Calcul des frais...',
                                            style: TextStyle(
                                              fontSize:
                                                  isSmallScreen ? 10.sp : 12.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                // CORRECTION: Afficher les frais même si ils sont à 0
                                else if (contactsController
                                            .contactFraisConfig.value !=
                                        null &&
                                    ((contactsController.searchedUser.value !=
                                                null ||
                                            selectedContact != null) ||
                                        (isExternalTransfer &&
                                            externalRecipient != null)) &&
                                    double.tryParse(amountController.text) !=
                                        null &&
                                    (double.tryParse(amountController.text) ??
                                            0) >
                                        0) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: isExternalTransfer
                                          ? Colors.orange.shade50
                                          : Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: isExternalTransfer
                                              ? Colors.orange.shade200
                                              : Colors.green.shade200),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              isExternalTransfer
                                                  ? Icons.mobile_friendly
                                                  : Icons
                                                      .account_balance_wallet,
                                              color: isExternalTransfer
                                                  ? Colors.orange.shade600
                                                  : Colors.green.shade600,
                                              size: isSmallScreen ? 14.0 : 16.0,
                                            ),
                                            const SizedBox(width: 8.0),
                                            Flexible(
                                              child: Text(
                                                isExternalTransfer
                                                    ? 'Frais transfert externe'
                                                    : 'Frais transfert OnyFast',
                                                style: TextStyle(
                                                  fontSize: isSmallScreen
                                                      ? 9.sp
                                                      : 10.sp,
                                                  color: isExternalTransfer
                                                      ? Colors.orange.shade600
                                                      : Colors.green.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12.0),
                                        _buildFeeRow(
                                            'Montant à ${isExternalTransfer ? "transférer" : "envoyer"}:',
                                            '${amountController.text} $currency',
                                            isSmallScreen),
                                        const SizedBox(height: 8.0),
                                        _buildFeeRow(
                                            'Frais:',
                                            // CORRECTION: Afficher même si frais = 0
                                            contactsController
                                                        .selectedContactFrais
                                                        .value ==
                                                    0
                                                ? 'Gratuit'
                                                : '+${contactsController.selectedContactFrais.value.toStringAsFixed(0)} $currency',
                                            isSmallScreen),
                                        Divider(
                                            height: 16.0,
                                            color: isExternalTransfer
                                                ? Colors.orange.shade300
                                                : Colors.green.shade300),
                                        _buildFeeRow(
                                          'Total à débiter:',
                                          '${contactsController.selectedContactTotal.value.toStringAsFixed(0)} $currency',
                                          isSmallScreen,
                                          isTotal: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  if (contactsController
                                          .contactFraisConfig.value !=
                                      null)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        '% frais: ${contactsController.contactFraisInfo}',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 10.sp : 12.sp,
                                          color: Colors.grey.shade600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  SizedBox(height: screenHeight * 0.025),
                                ] else if (contactsController
                                            .contactFraisConfig.value ==
                                        null &&
                                    ((contactsController.searchedUser.value !=
                                                null ||
                                            selectedContact != null) ||
                                        (isExternalTransfer &&
                                            externalRecipient != null)) &&
                                    double.tryParse(amountController.text) !=
                                        null &&
                                    (double.tryParse(amountController.text) ??
                                            0) >
                                        0) ...[
                                  Container(
                                    padding: EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.red.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red.shade600,
                                          size: isSmallScreen ? 10.sp:12.sp,
                                        ),
                                        SizedBox(width: 12.0),
                                        Expanded(
                                          child: Text(
                                            'Aucune configuration de frais trouvée pour ce type de transaction',
                                            style: TextStyle(
                                              fontSize:
                                                  isSmallScreen ? 10.sp : 12.sp,
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                ],
                              ],
                            )),

                        // CORRECTION: Bouton Continuer avec support des frais à 0
                        Obx(() => SizedBox(
                              width: double.infinity,
                              height: isSmallScreen ? 45.0 : 50.0,
                              child: ElevatedButton(
                                onPressed: contactsController
                                                .contactFraisConfig.value !=
                                            null &&
                                        contactsController
                                                .selectedContactFrais.value >=
                                            0 &&
                                        ((contactsController
                                                        .searchedUser.value !=
                                                    null ||
                                                selectedContact != null) ||
                                            (isExternalTransfer &&
                                                externalRecipient != null)) &&
                                        // ── NOUVEAU: carte obligatoire si user OnyFast avec cartes ──
                                        (contactsController
                                                    .searchedUser.value ==
                                                null ||
                                            contactsController.searchedUser
                                                .value!.cards.isEmpty ||
                                            selectedRecipientCard != null) &&
                                        (double.tryParse(
                                                    amountController.text) ??
                                                0) >
                                            0
                                    ? () {
                                        CodeVerification().show(context, () {
                                          _showTransactionConfirmation();
                                        });
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColorModel.Bluecolor242,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    isExternalTransfer
                                        ? 'Transférer'
                                        : 'Continuer',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 10.sp : 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColorModel.WhiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                        SizedBox(height: screenHeight * 0.02),

                        // Bouton contacts
                        Center(
                          child: TextButton.icon(
                            onPressed: _handleContactSelection,
                            icon: Icon(
                              Icons.contacts,
                              color: AppColorModel.Bluecolor242,
                              size: isSmallScreen ? 12.sp : 10.sp,
                            ),
                            label: Flexible(
                              child: Text(
                                'Choisir depuis mes contacts',
                                style: TextStyle(
                                  color: AppColorModel.Bluecolor242,
                                  fontSize: isSmallScreen ? 10.sp : 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, bool isSmallScreen,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal
                  ? (isSmallScreen ? 9.sp : 10.0.sp)
                  : (isSmallScreen ? 9.0.sp : 10.0.sp),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green.shade700 : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8.0),
        Flexible(
          flex: 2,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTotal
                  ? (isSmallScreen ? 10.0.sp : 12.sp)
                  : (isSmallScreen ? 10.0.sp : 12.0.sp),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.green.shade700 : Colors.black87,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteItem(
      Map<String, dynamic> favorite, int index, bool isSmallScreen) {
    final itemWidth = isSmallScreen ? 60.0 : 70.0;
    final avatarRadius = isSmallScreen ? 16.0 : 18.0;
    final starSize = isSmallScreen ? 8.0 : 10.0;

    return GestureDetector(
      onTap: () => _selectFavorite(favorite),
      onLongPress: () => _showFavoriteOptions(favorite, index),
      child: Container(
        width: itemWidth,
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.orange.shade100,
                  backgroundImage: favorite['avatar'] != null &&
                          favorite['avatar'].isNotEmpty
                      ? NetworkImage(favorite['avatar'])
                      : null,
                  child:
                      favorite['avatar'] == null || favorite['avatar'].isEmpty
                          ? Text(
                              favorite['name']?.isNotEmpty == true
                                  ? favorite['name'][0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10.sp:12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            )
                          : null,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: isSmallScreen ? 14.0 : 16.0,
                    height: isSmallScreen ? 14.0 : 16.0,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.white,
                      size: starSize,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Flexible(
              child: Text(
                favorite['name'] ?? 'Inconnu',
                style: TextStyle(
                  fontSize: isSmallScreen ? 9.0.sp : 10.0.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange.shade700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (favorite['transaction_count'] != null &&
                favorite['transaction_count'] > 1)
              Text(
                '${favorite['transaction_count']}x',
                style: TextStyle(
                  fontSize: isSmallScreen ? 7.0.sp : 8.0.sp,
                  color: Colors.orange.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactAvatar(Map<String, dynamic> contact, bool isSmallScreen) {
    final imageUrl = contact['avatar'] ?? contact['image'];
    final name = contact['name'] ?? 'U';
    final radius = isSmallScreen ? 18.0 : 20.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColorModel.Bluecolor242.withOpacity(0.1),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: AppColorModel.Bluecolor242,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
