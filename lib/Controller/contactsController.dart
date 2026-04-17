// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';
// import 'package:onyfast/Api/contacts_service.dart';
// import 'package:onyfast/model/contact_model.dart';
// import 'package:onyfast/model/user_model.dart';

// class ContactsController extends GetxController {
//   // Variables pour les frais
//   RxDouble selectedContactFrais = 0.0.obs;
//   RxDouble selectedContactTotal = 0.0.obs;
//   Rx<Map<String, dynamic>?> contactFraisConfig =
//       Rx<Map<String, dynamic>?>(null);
//   RxBool isLoading = false.obs;

//   // Variables pour la recherche d'utilisateur
//   RxBool isSearchingUser = false.obs;
//   Rx<UserModel?> searchedUser = Rx<UserModel?>(null);

//   // Variables pour les contacts du téléphone
//   RxList<ContactModel> phoneContacts = <ContactModel>[].obs;
//   RxList<ContactModel> onyfastContacts = <ContactModel>[].obs;
//   RxBool isLoadingContacts = false.obs;

//   // NOUVEAU: Variables pour les transferts externes
//   RxBool isExternalTransferMode = false.obs;
//   Rx<Map<String, dynamic>?> externalRecipient = Rx<Map<String, dynamic>?>(null);

//   // Configuration des frais mise en cache
//   Map<String, dynamic>? _cachedFraisConfig;
//   Map<String, dynamic>? _cachedGeneralFraisConfig;

//   String get contactFraisInfo {
//     if (contactFraisConfig.value == null) return '';

//     final config = contactFraisConfig.value!;

//     if (config['pourcentage'] != null && config['pourcentage'] != 0) {
//       return '${config['pourcentage']}%';
//     } else if (config['montant'] != null && config['montant'] != 0) {
//       return '${config['montant']} XAF (fixe)';
//     }
//     return '';
//   }

//   /// Obtient la configuration de frais mise en cache
//   Map<String, dynamic>? getCachedFraisConfig() {
//     return _cachedFraisConfig;
//   }

//   /// Obtient la configuration de frais généraux mise en cache
//   Map<String, dynamic>? getCachedGeneralFraisConfig() {
//     return _cachedGeneralFraisConfig;
//   }

//   /// Définit la configuration des frais pour le contact
//   void setContactFraisConfig(Map<String, dynamic> config) {
//     contactFraisConfig.value = config;
//   }

//   /// Définit les frais du contact sélectionné
//   void setSelectedContactFrais(double frais) {
//     selectedContactFrais.value = frais;
//   }

//   /// Définit le total du contact sélectionné
//   void setSelectedContactTotal(double total) {
//     selectedContactTotal.value = total;
//   }

//   /// Récupère la configuration des frais depuis l'API (version publique)
//   Future<Map<String, dynamic>?> getFraisConfigFromAPI(String type) async {
//     return await _getFraisConfigFromAPI(type);
//   }

//   /// Calcule les frais selon la configuration (version publique)
//   double calculerFraisAvecConfig(double montant, Map<String, dynamic> config) {
//     return _calculerFraisAvecConfig(montant, config);
//   }

//   /// MODIFIÉ: Précharge TOUTES les configurations des frais
//   Future<void> preloadFraisConfig() async {
//     try {
//       // Configuration pour transferts OnyFast
//       final onyfastConfig = await _getFraisConfigFromAPI('TRANSFERT');
//       if (onyfastConfig != null) {
//         _cachedFraisConfig = onyfastConfig;
//         print('✅ Configuration frais OnyFast préchargée');
//       }

//       // Configuration pour transferts généraux/externes
//       final generalConfig = await _getFraisConfigFromAPI('TRANSFERT_GENERAL');
//       if (generalConfig != null) {
//         _cachedGeneralFraisConfig = generalConfig;
//         print('✅ Configuration frais généraux préchargée');
//       } else {
//         // Fallback: utiliser la même config que OnyFast si pas de config générale
//         _cachedGeneralFraisConfig = onyfastConfig;
//         print('ℹ️ Utilisation config OnyFast pour transferts généraux');
//       }

//       // NOUVEAU: Configuration pour transferts externes
//       final externalConfig = await _getFraisConfigFromAPI('TRANSFERT_EXTERNE');
//       if (externalConfig != null) {
//         _cachedGeneralFraisConfig = externalConfig;
//         print('✅ Configuration frais externes préchargée');
//       }
//     } catch (e) {
//       print('❌ Erreur préchargement frais: $e');
//     }
//   }

//   /// Formatage de numéro de téléphone (version publique)
//   String formatPhoneNumber(String phone) {
//     return _formatPhoneNumber(phone);
//   }

//   /// Formate un numéro de téléphone pour matcher le format BD
//   String _formatPhoneNumber(String phone) {
//     if (phone.isEmpty) return '';

//     print('🔧 === DÉBUT FORMATAGE: "$phone" ===');

//     const String defaultCode = '242';
//     String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
//     print('🧹 Après nettoyage: "$cleaned"');

//     if (cleaned.startsWith('+')) {
//       cleaned = cleaned.substring(1);
//       print('➖ Après suppression +: "$cleaned"');
//     }

//     // Cas 1: Numéro local commençant par 0
//     if (cleaned.startsWith('0')) {
//       print('🎯 Cas 1: Numéro local avec 0');
//       if (cleaned.length >= 9) {
//         String formatted = '$defaultCode$cleaned';
//         print('✅ Formaté: "$formatted"');
//         return formatted;
//       } else {
//         print('❌ Numéro local trop court');
//         return '';
//       }
//     }

//     // Cas 2: Numéro avec code pays Congo déjà présent
//     else if (cleaned.startsWith(defaultCode)) {
//       print('🎯 Cas 2: Code Congo déjà présent');
//       if (cleaned.length >= 11) {
//         print('✅ Formaté: "$cleaned"');
//         return cleaned;
//       } else {
//         print('❌ Numéro Congo trop court');
//         return '';
//       }
//     }

//     // Cas 3: Numéro local sans 0
//     else if (cleaned.length >= 8 && cleaned.length <= 9) {
//       print('🎯 Cas 3: Numéro local sans 0');
//       String formatted = '${defaultCode}0$cleaned';
//       print('✅ Formaté avec 0: "$formatted"');
//       return formatted;
//     }

//     // Cas 4: Numéro international avec autre code pays
//     else if (cleaned.length >= 10) {
//       print('🎯 Cas 4: Numéro international');
//       print('✅ Gardé tel quel: "$cleaned"');
//       return cleaned;
//     }

//     print('❌ Format non reconnu: "$cleaned" (longueur: ${cleaned.length})');
//     return '';
//   }

//   /// MODIFIÉ: Recherche un utilisateur par numéro de téléphone avec fallback externe
//   Future<void> searchUserByPhone(String phone) async {
//     if (phone.length < 8) {
//       searchedUser.value = null;
//       _resetExternalMode();
//       return;
//     }

//     isSearchingUser.value = true;

//     try {
//       String formattedPhone = _formatPhoneNumber(phone);
//       if (formattedPhone.isEmpty) {
//         print('⚠️ Numéro invalide: $phone');
//         searchedUser.value = null;
//         _resetExternalMode();
//         isSearchingUser.value = false;
//         return;
//       }

//       print('🔍 Recherche utilisateur dans BD pour: $formattedPhone');
//       final user = await _searchUserAPI(formattedPhone);

//       if (user != null) {
//         searchedUser.value = user;
//         _resetExternalMode();
//         print('✅ Utilisateur OnyFast trouvé: ${user.name} (ID: ${user.id})');

//         // Calculer les frais OnyFast automatiquement si montant disponible
//         try {
//           final amountController =
//               Get.find<TextEditingController>(tag: 'amountController');
//           final amountText = amountController.text;
//           final amount = double.tryParse(amountText) ?? 0;
//           if (amount > 0) {
//             await selectContact(user.toMap(), amount);
//           }
//         } catch (e) {
//           print('Contrôleur de montant non trouvé: $e');
//         }
//       } else {
//         print('ℹ️ Aucun utilisateur OnyFast trouvé pour $formattedPhone');
//         searchedUser.value = null;

//         // NOUVEAU: Vérifier si le numéro peut recevoir un transfert externe
//         await _checkExternalTransferEligibility(formattedPhone);
//       }
//     } catch (e) {
//       print('❌ Erreur recherche utilisateur BD: $e');
//       searchedUser.value = null;
//       _resetExternalMode();

//       if (e.toString().contains('network') ||
//           e.toString().contains('timeout')) {
//         Get.snackbar(
//           'Erreur de connexion',
//           'Impossible de se connecter à la base de données',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//           duration: Duration(seconds: 3),
//         );
//       }
//     } finally {
//       isSearchingUser.value = false;
//     }
//   }

//   /// NOUVELLE MÉTHODE: Vérifie l'éligibilité pour transfert externe
//   Future<void> _checkExternalTransferEligibility(String formattedPhone) async {
//     try {
//       final validation = await validateRecipientNumber(formattedPhone);

//       if (validation['isValid'] == true && validation['isExternal'] == true) {
//         print('📱 Numéro éligible pour transfert externe: $formattedPhone');

//         isExternalTransferMode.value = true;
//         externalRecipient.value = {
//           'phone': formattedPhone,
//           'display_phone': '+$formattedPhone',
//           'name': 'Contact externe',
//           'is_external': true,
//           'can_receive_transfer': true,
//         };

//         // Calculer les frais externes automatiquement si montant disponible
//         try {
//           final amountController =
//               Get.find<TextEditingController>(tag: 'amountController');
//           final amountText = amountController.text;
//           final amount = double.tryParse(amountText) ?? 0;
//           if (amount > 0) {
//             await calculateGeneralFees(amount);
//           }
//         } catch (e) {
//           print('Contrôleur de montant non trouvé: $e');
//         }
//       } else {
//         print(
//             '❌ Numéro non éligible pour transferts: ${validation['message']}');
//         _resetExternalMode();
//       }
//     } catch (e) {
//       print('❌ Erreur vérification éligibilité externe: $e');
//       _resetExternalMode();
//     }
//   }

//   /// NOUVELLE MÉTHODE: Remet à zéro le mode externe
//   void _resetExternalMode() {
//     isExternalTransferMode.value = false;
//     externalRecipient.value = null;
//   }

//   /// Appel API pour rechercher un utilisateur
//   Future<UserModel?> _searchUserAPI(String phone) async {
//     try {
//       return await ContactsService.searchUserByPhone(phone);
//     } catch (e) {
//       print('❌ Erreur API recherche utilisateur: $e');
//       return null;
//     }
//   }

//   /// Récupère la configuration des frais depuis l'API
//   Future<Map<String, dynamic>?> _getFraisConfigFromAPI(String type) async {
//     try {
//       final response = await ContactsService.getFraisConfig(type);
//       return response;
//     } catch (e) {
//       print('❌ Erreur récupération config frais: $e');
//       return null;
//     }
//   }

//   /// MODIFIÉ: Sélectionne un contact et calcule les frais via l'API
//   Future<void> selectContact(
//       Map<String, dynamic> contact, double amount) async {
//     if (amount <= 0) return;

//     isLoading.value = true;
//     _resetExternalMode(); // S'assurer qu'on n'est pas en mode externe

//     try {
//       // Utiliser la configuration préchargée ou charger depuis l'API
//       Map<String, dynamic>? config = _cachedFraisConfig;
//       config ??= await _getFraisConfigFromAPI('TRANSFERT');

//       if (config != null) {
//         contactFraisConfig.value = config;

//         final frais = _calculerFraisAvecConfig(amount, config);
//         selectedContactFrais.value = frais;
//         selectedContactTotal.value = amount + frais;

//         print(
//             '✅ Frais OnyFast calculés: +$frais XAF (Total: ${amount + frais} XAF)');
//       } else {
//         print('ℹ️ Aucune configuration de frais OnyFast trouvée');
//         resetFrais();
//       }
//     } catch (e) {
//       print('❌ Erreur calcul des frais OnyFast: $e');
//       resetFrais();

//       Get.snackbar(
//         'Information',
//         'Impossible de calculer les frais actuellement',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//         duration: Duration(seconds: 2),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Calcule les frais selon la logique du backend PHP
//   double _calculerFraisAvecConfig(double montant, Map<String, dynamic> config) {
//     double fraisMontant = 0;

//     // Logique identique au backend PHP
//     if (config['montant'] != null && config['montant'] != 0) {
//       // Montant fixe
//       fraisMontant = double.tryParse(config['montant'].toString()) ?? 0;
//     } else if (config['pourcentage'] != null && config['pourcentage'] != 0) {
//       // Pourcentage
//       fraisMontant = (montant * config['pourcentage']) / 100;

//       // Appliquer les bornes min/max si définies
//       if (config['min'] != null && config['min'] != 0) {
//         final minValue = double.tryParse(config['min'].toString()) ?? 0;
//         if (minValue > 0) {
//           fraisMontant = fraisMontant < minValue ? minValue : fraisMontant;
//         }
//       }

//       if (config['max'] != null && config['max'] != 0) {
//         final maxValue = double.tryParse(config['max'].toString()) ?? 0;
//         if (maxValue > 0) {
//           fraisMontant = fraisMontant > maxValue ? maxValue : fraisMontant;
//         }
//       }
//     }

//     return fraisMontant;
//   }

//   /// Met à jour le montant et recalcule les frais
//   void updateAmount(double amount) {
//     if (contactFraisConfig.value != null && amount > 0) {
//       final frais = _calculerFraisAvecConfig(amount, contactFraisConfig.value!);
//       selectedContactFrais.value = frais;
//       selectedContactTotal.value = amount + frais;
//     } else {
//       resetFrais();
//     }
//   }

//   /// MODIFIÉ: Traite la transaction via l'API avec support automatique des transferts externes
//   Future<Map<String, dynamic>> processTransaction({
//     required dynamic recipientId,
//     required double amount,
//     required fromTel,
//     required toTel,
//     required double fees,
//     required double total,
//     bool isExternalTransfer = false,
//   }) async {
//     try {
//       // NOUVEAU: Détection automatique du type de transfert si pas spécifié
//       if (!isExternalTransfer &&
//           recipientId == null &&
//           externalRecipient.value != null) {
//         isExternalTransfer = true;
//         print('🔄 Mode transfert externe détecté automatiquement');
//       }

//       print(
//           '🚀 Traitement transaction: $amount XAF vers ${recipientId ?? "externe"} (Externe: $isExternalTransfer)');

//       final result = await ContactsService.processC2CTransaction(
//         recipientId: recipientId?.toString(),
//         amount: amount,
//         fromTel: fromTel,
//         toTel: _formatPhoneNumber(toTel),
//         fees: fees,
//         isExternalTransfer: isExternalTransfer,
//       );

//       if (result['success'] == true) {
//         print('✅ Transaction réussie: ${result['transactionId']}');

//         return {
//           'success': true,
//           'message': isExternalTransfer
//               ? 'Transfert externe initié avec succès'
//               : 'Transaction OnyFast effectuée avec succès',
//           'transactionId': result['transactionId'],
//           'data': result,
//           'isExternal': isExternalTransfer,
//         };
//       } else {
//         print('❌ Transaction échouée: ${result['message']}');
//         return {
//           'success': false,
//           'message': result['message'] ?? 'Erreur lors de la transaction',
//         };
//       }
//     } catch (e) {
//       print('❌ Erreur traitement transaction: $e');

//       String errorMessage = 'Erreur de connexion';
//       if (e.toString().contains('insufficient')) {
//         errorMessage = 'Solde insuffisant';
//       } else if (e.toString().contains('timeout')) {
//         errorMessage = 'Délai de connexion dépassé';
//       } else if (e.toString().contains('network')) {
//         errorMessage = 'Problème de réseau';
//       }

//       return {
//         'success': false,
//         'message': errorMessage,
//       };
//     }
//   }

//   /// MODIFIÉ: Calcule les frais généraux pour contacts sans OnyFast (transferts externes)
//   Future<void> calculateGeneralFees(double amount) async {
//     print('💰 Calcul des frais généraux/externes pour montant: $amount');

//     try {
//       isLoading.value = true;

//       // Utiliser la configuration préchargée ou charger depuis l'API
//       Map<String, dynamic>? config = _cachedGeneralFraisConfig;

//       config ??= await _getFraisConfigFromAPI('TRANSFERT_GENERAL');
//       config ??= await _getFraisConfigFromAPI('TRANSFERT_EXTERNE');

//       if (config != null) {
//         contactFraisConfig.value = config;

//         // Calculer les frais selon la configuration
//         final frais = _calculerFraisAvecConfig(amount, config);
//         selectedContactFrais.value = frais;
//         selectedContactTotal.value = amount + frais;

//         print(
//             '✅ Frais externes calculés: +$frais XAF (Total: ${amount + frais} XAF)');
//       } else {
//         print('ℹ️ Aucune configuration de frais externe trouvée');
//         resetFrais();
//       }
//     } catch (e) {
//       print('❌ Erreur calcul des frais externes: $e');
//       resetFrais();
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// MODIFIÉ: Valide si un numéro peut recevoir un transfert
//   Future<Map<String, dynamic>> validateRecipientNumber(String phone) async {
//     try {
//       String formattedPhone = _formatPhoneNumber(phone);
//       if (formattedPhone.isEmpty) {
//         return {
//           'isValid': false,
//           'canReceive': false,
//           'hasOnyfast': false,
//           'isExternal': false,
//           'message': 'Numéro invalide'
//         };
//       }

//       // Vérifier si le numéro a un compte OnyFast
//       final onyfastPhones =
//           await ContactsService.checkOnyfastUsers([formattedPhone]);
//       bool hasOnyfast = onyfastPhones.contains(formattedPhone);

//       if (hasOnyfast) {
//         return {
//           'isValid': true,
//           'canReceive': true,
//           'hasOnyfast': true,
//           'isExternal': false,
//           'transferType': 'onyfast',
//           'phone': formattedPhone,
//           'message': 'Compte OnyFast trouvé'
//         };
//       } else {
//         // MODIFIÉ: Vérifier si c'est un numéro externe valide
//         bool isValidExternal = _isValidForExternalTransfer(formattedPhone);

//         return {
//           'isValid': isValidExternal,
//           'canReceive': isValidExternal,
//           'hasOnyfast': false,
//           'isExternal': isValidExternal,
//           'transferType': isValidExternal ? 'external' : 'unsupported',
//           'phone': formattedPhone,
//           'message': isValidExternal
//               ? 'Numéro valide pour transfert externe'
//               : 'Numéro non supporté pour les transferts'
//         };
//       }
//     } catch (e) {
//       print('❌ Erreur validation numéro destinataire: $e');
//       return {
//         'isValid': false,
//         'canReceive': false,
//         'hasOnyfast': false,
//         'isExternal': false,
//         'message': 'Erreur de validation'
//       };
//     }
//   }

//   /// NOUVELLE MÉTHODE: Vérifie si un numéro est valide pour transfert externe
//   bool _isValidForExternalTransfer(String formattedPhone) {
//     // Vérifier la longueur minimale
//     if (formattedPhone.length < 10) {
//       return false;
//     }

//     // Codes pays supportés pour les transferts externes
//     List<String> supportedCountryCodes = [
//       '242', // Congo-Brazzaville
//       '243', // Congo-Kinshasa (RDC)
//       '237', // Cameroun
//       '241', // Gabon
//       '236', // République Centrafricaine
//       '235', // Tchad
//       '33', // France
//       '1', // USA/Canada
//       // Ajouter d'autres codes selon les besoins
//     ];

//     // Vérifier si le numéro commence par un code pays supporté
//     for (String code in supportedCountryCodes) {
//       if (formattedPhone.startsWith(code)) {
//         return true;
//       }
//     }

//     // Si aucun code pays reconnu, considérer comme non supporté
//     return false;
//   }

//   /// NOUVELLE MÉTHODE: Obtient les informations du destinataire externe
//   Map<String, dynamic>? getExternalRecipientInfo() {
//     return externalRecipient.value;
//   }

//   /// NOUVELLE MÉTHODE: Vérifie si on est en mode transfert externe
//   bool isInExternalMode() {
//     return isExternalTransferMode.value && externalRecipient.value != null;
//   }

//   /// NOUVELLE MÉTHODE: Force le mode transfert externe
//   void setExternalTransferMode(String phone, String name) {
//     String formattedPhone = _formatPhoneNumber(phone);

//     if (formattedPhone.isNotEmpty &&
//         _isValidForExternalTransfer(formattedPhone)) {
//       isExternalTransferMode.value = true;
//       externalRecipient.value = {
//         'phone': formattedPhone,
//         'display_phone': '+$formattedPhone',
//         'name': name,
//         'is_external': true,
//         'can_receive_transfer': true,
//       };

//       // Réinitialiser la recherche d'utilisateur OnyFast
//       searchedUser.value = null;

//       print('🔄 Mode transfert externe activé pour: $name ($formattedPhone)');
//     } else {
//       print('❌ Numéro non valide pour transfert externe: $phone');
//     }
//   }

//   /// NOUVELLE MÉTHODE: Obtient le type de transfert actuel
//   String getCurrentTransferType() {
//     if (isInExternalMode()) {
//       return 'external';
//     } else if (searchedUser.value != null) {
//       return 'onyfast';
//     } else {
//       return 'none';
//     }
//   }

//   /// NOUVELLE MÉTHODE: Obtient le nom du destinataire actuel
//   String getCurrentRecipientName() {
//     if (isInExternalMode()) {
//       return externalRecipient.value?['name'] ?? 'Contact externe';
//     } else if (searchedUser.value != null) {
//       return searchedUser.value!.name;
//     } else {
//       return '';
//     }
//   }

//   /// NOUVELLE MÉTHODE: Obtient le téléphone du destinataire actuel
//   String getCurrentRecipientPhone() {
//     if (isInExternalMode()) {
//       return externalRecipient.value?['phone'] ?? '';
//     } else if (searchedUser.value != null) {
//       return searchedUser.value!.telephone;
//     } else {
//       return '';
//     }
//   }

//   /// Charge les contacts du téléphone et filtre ceux qui ont OnyFast
//   Future<void> loadPhoneContacts() async {
//     isLoadingContacts.value = true;

//     try {
//       // Demander la permission
//       if (!await FlutterContacts.requestPermission()) {
//         Get.snackbar(
//           'Permission refusée',
//           'Veuillez autoriser l\'accès aux contacts dans les paramètres',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Get.theme.colorScheme.error,
//           colorText: Get.theme.colorScheme.onError,
//           duration: Duration(seconds: 4),
//         );
//         return;
//       }

//       // Récupérer les contacts du téléphone
//       final contacts = await ContactsService.getContacts(withThumbnails: false);

//       // Convertir en ContactModel avec gestion améliorée des numéros
//       final List<ContactModel> allContacts = [];
//       final List<String> phoneNumbers = [];

//       for (var contact in contacts) {
//         if (contact.phones.isNotEmpty) {
//           // Extraire TOUS les numéros valides du contact
//           List<String> contactPhones =
//               contact.phones.map((phone) => phone.number).toList();
//           List<String> validPhones = _extractValidNumbers(contactPhones);

//           // Créer un contact pour chaque numéro valide
//           for (String validPhone in validPhones) {
//             if (validPhone.isNotEmpty && !phoneNumbers.contains(validPhone)) {
//               phoneNumbers.add(validPhone);
//               allContacts.add(ContactModel(
//                 name: contact.displayName.isNotEmpty
//                     ? contact.displayName
//                     : 'Sans nom',
//                 phone: validPhone,
//                 isOnyfast: false,
//               ));
//             }
//           }
//         }
//       }

//       phoneContacts.value = allContacts;
//       print('📱 ${allContacts.length} contacts avec numéros valides extraits');

//       // Vérifier quels contacts ont OnyFast via l'API
//       if (phoneNumbers.isNotEmpty) {
//         try {
//           final onyfastPhones = await _checkOnyfastUsersAPI(phoneNumbers);

//           // Mettre à jour le statut OnyFast des contacts
//           for (var contact in allContacts) {
//             contact.isOnyfast = onyfastPhones.contains(contact.phone);
//           }

//           // Filtrer les contacts OnyFast
//           onyfastContacts.value =
//               allContacts.where((contact) => contact.isOnyfast).toList();

//           print(
//               '✅ Contacts chargés: ${allContacts.length} total, ${onyfastContacts.length} OnyFast');
//         } catch (e) {
//           print('❌ Erreur vérification contacts OnyFast: $e');
//         }
//       }
//     } catch (e) {
//       print('❌ Erreur chargement contacts: $e');
//       Get.snackbar(
//         'Erreur',
//         'Impossible de charger les contacts',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Get.theme.colorScheme.error,
//         colorText: Get.theme.colorScheme.onError,
//       );
//     } finally {
//       isLoadingContacts.value = false;
//     }
//   }

//   /// Extrait tous les numéros valides d'un contact
//   List<String> _extractValidNumbers(List<String> phoneNumbers) {
//     List<String> validNumbers = [];

//     for (String phone in phoneNumbers) {
//       String formatted = _formatPhoneNumber(phone);
//       if (formatted.isNotEmpty && !validNumbers.contains(formatted)) {
//         validNumbers.add(formatted);
//       }
//     }

//     return validNumbers;
//   }

//   /// Appel API pour vérifier les contacts OnyFast
//   Future<List<String>> _checkOnyfastUsersAPI(List<String> phoneNumbers) async {
//     try {
//       return await ContactsService.checkOnyfastUsers(phoneNumbers);
//     } catch (e) {
//       print('❌ Erreur API vérification OnyFast: $e');
//       return [];
//     }
//   }

//   /// Obtient des statistiques des frais
//   Future<Map<String, dynamic>?> getFeeStatistics() async {
//     try {
//       final stats = await ContactsService.getTransferStatistics();
//       return stats;
//     } catch (e) {
//       print('❌ Erreur récupération statistiques frais: $e');
//       return null;
//     }
//   }

//   /// Recherche unifiée de contacts (OnyFast + externes)
//   Future<List<Map<String, dynamic>>> searchAllContacts(String query) async {
//     try {
//       return await ContactsService.searchAllContacts(query);
//     } catch (e) {
//       print('❌ Erreur recherche unifiée: $e');
//       return [];
//     }
//   }

//   /// Valide les données avant transaction
//   Map<String, dynamic> validateTransactionData({
//     required String phone,
//     required double amount,
//     required double fees,
//     String? recipientId,
//     bool isExternal = false,
//   }) {
//     return ContactsService.validateTransactionData(
//       phone: phone,
//       amount: amount,
//       fees: fees,
//       recipientId: recipientId,
//       isExternal: isExternal,
//     );
//   }

//   /// Test de connectivité API
//   Future<bool> testConnectivity() async {
//     try {
//       return await ContactsService.testApiConnectivity();
//     } catch (e) {
//       print('❌ Erreur test connectivité: $e');
//       return false;
//     }
//   }

//   /// Obtient des suggestions pour un numéro invalide
//   Map<String, dynamic> getPhoneSuggestions(String phone) {
//     return ContactsService.validateAndSuggestPhone(phone);
//   }

//   /// Cache un favori avec son statut
//   Future<void> cacheFavoriteContact(Map<String, dynamic> contact) async {
//     try {
//       await ContactsService.cacheFavoriteWithStatus(contact);
//     } catch (e) {
//       print('❌ Erreur cache favori: $e');
//     }
//   }

//   /// Récupère les favoris depuis le cache
//   Future<List<Map<String, dynamic>>> getCachedFavorites() async {
//     try {
//       final favorites = await ContactsService.getCachedFavorites();
//       return favorites ?? [];
//     } catch (e) {
//       print('❌ Erreur récupération favoris: $e');
//       return [];
//     }
//   }

//   /// Supprime un favori du cache
//   Future<void> removeFavorite(String phone) async {
//     try {
//       await ContactsService.removeCachedFavorite(phone);
//     } catch (e) {
//       print('❌ Erreur suppression favori: $e');
//     }
//   }

//   /// Calcule des frais estimés pour preview
//   Future<Map<String, dynamic>?> getEstimatedFees({
//     required double amount,
//     required bool isExternal,
//     String? recipientId,
//   }) async {
//     try {
//       return await ContactsService.getEstimatedFees(
//         amount: amount,
//         isExternal: isExternal,
//         recipientId: recipientId,
//       );
//     } catch (e) {
//       print('❌ Erreur estimation frais: $e');
//       return null;
//     }
//   }

//   /// Analyse les contacts pour statistiques
//   Map<String, dynamic> analyzeContactsData(
//       List<Map<String, dynamic>> contacts) {
//     return ContactsService.analyzeContacts(contacts);
//   }

//   /// Recherche avancée avec filtres
//   List<Map<String, dynamic>> advancedContactSearch(
//     List<Map<String, dynamic>> contacts,
//     String query, {
//     bool onlyOnyfast = false,
//     bool onlyWithPhones = false,
//     bool onlyOnline = false,
//   }) {
//     return ContactsService.advancedSearch(
//       contacts,
//       query,
//       onlyOnyfast: onlyOnyfast,
//       onlyWithPhones: onlyWithPhones,
//       onlyOnline: onlyOnline,
//     );
//   }

//   /// Trie les contacts selon différents critères
//   List<Map<String, dynamic>> sortContactsList(
//     List<Map<String, dynamic>> contacts, {
//     String sortBy = 'name',
//     bool ascending = true,
//   }) {
//     return ContactsService.sortContacts(
//       contacts,
//       sortBy: sortBy,
//       ascending: ascending,
//     );
//   }

//   /// Nettoie et valide un contact
//   Map<String, dynamic> sanitizeContactData(Map<String, dynamic> contact) {
//     return ContactsService.sanitizeContact(contact);
//   }

//   /// MODIFIÉ: Remet à zéro les frais calculés
//   void resetFrais() {
//     selectedContactFrais.value = 0.0;
//     selectedContactTotal.value = 0.0;
//     contactFraisConfig.value = null;
//     isLoading.value = false;
//     _resetExternalMode(); // NOUVEAU: Aussi réinitialiser le mode externe
//   }

//   /// Efface l'utilisateur recherché
//   void clearSearchedUser() {
//     searchedUser.value = null;
//     _resetExternalMode(); // NOUVEAU: Aussi réinitialiser le mode externe
//   }

//   /// Recharge les contacts depuis le téléphone et l'API
//   Future<void> refreshContacts() async {
//     phoneContacts.clear();
//     onyfastContacts.clear();
//     ContactsService.clearContactsCache();
//     await loadPhoneContacts();
//   }

//   /// Nettoie tous les caches
//   void clearAllCaches() {
//     ContactsService.clearAllCache();
//     resetFrais();
//     clearSearchedUser();
//   }

//   /// MODIFIÉ: Réinitialise complètement le contrôleur
//   void resetController() {
//     clearAllCaches();
//     phoneContacts.clear();
//     onyfastContacts.clear();
//     _cachedFraisConfig = null;
//     _cachedGeneralFraisConfig = null;
//     _resetExternalMode();
//   }

//   /// MODIFIÉ: Obtient l'état du contrôleur
//   Map<String, dynamic> getControllerState() {
//     return {
//       'isLoading': isLoading.value,
//       'isSearchingUser': isSearchingUser.value,
//       'isLoadingContacts': isLoadingContacts.value,
//       'hasSearchedUser': searchedUser.value != null,
//       'hasFraisConfig': contactFraisConfig.value != null,
//       'currentFees': selectedContactFrais.value,
//       'currentTotal': selectedContactTotal.value,
//       'phoneContactsCount': phoneContacts.length,
//       'onyfastContactsCount': onyfastContacts.length,
//       'hasCachedOnyfastConfig': _cachedFraisConfig != null,
//       'hasCachedGeneralConfig': _cachedGeneralFraisConfig != null,
//       'isExternalMode': isExternalTransferMode.value,
//       'hasExternalRecipient': externalRecipient.value != null,
//       'currentTransferType': getCurrentTransferType(),
//       'currentRecipientName': getCurrentRecipientName(),
//       'currentRecipientPhone': getCurrentRecipientPhone(),
//     };
//   }

//   /// MODIFIÉ: Debug - affiche l'état complet
//   void debugControllerState() {
//     final state = getControllerState();
//     print('🐛 === DEBUG CONTACTS CONTROLLER ===');
//     state.forEach((key, value) {
//       print('   - $key: $value');
//     });

//     if (isInExternalMode()) {
//       print('   - External recipient details: ${externalRecipient.value}');
//     }

//     print('🐛 === FIN DEBUG ===');
//   }

//   /// NOUVELLE MÉTHODE: Bascule entre les modes de transfert
//   void toggleTransferMode() {
//     if (isInExternalMode()) {
//       // Passer en mode OnyFast
//       _resetExternalMode();
//       print('🔄 Basculé vers mode OnyFast');
//     } else {
//       // Passer en mode externe si possible
//       String currentPhone = getCurrentRecipientPhone();
//       if (currentPhone.isNotEmpty &&
//           _isValidForExternalTransfer(currentPhone)) {
//         setExternalTransferMode(currentPhone, 'Contact externe');
//         searchedUser.value = null;
//         print('🔄 Basculé vers mode externe');
//       }
//     }
//   }

//   /// NOUVELLE MÉTHODE: Obtient les frais pour les deux modes
//   Future<Map<String, dynamic>> getFeesComparison(double amount) async {
//     Map<String, dynamic> comparison = {
//       'onyfast_fees': 0.0,
//       'external_fees': 0.0,
//       'onyfast_total': amount,
//       'external_total': amount,
//       'has_onyfast_config': false,
//       'has_external_config': false,
//       'recommendation': 'onyfast', // Par défaut
//     };

//     try {
//       // Calculer les frais OnyFast
//       if (_cachedFraisConfig != null) {
//         double onyfastFees =
//             _calculerFraisAvecConfig(amount, _cachedFraisConfig!);
//         comparison['onyfast_fees'] = onyfastFees;
//         comparison['onyfast_total'] = amount + onyfastFees;
//         comparison['has_onyfast_config'] = true;
//       }

//       // Calculer les frais externes
//       if (_cachedGeneralFraisConfig != null) {
//         double externalFees =
//             _calculerFraisAvecConfig(amount, _cachedGeneralFraisConfig!);
//         comparison['external_fees'] = externalFees;
//         comparison['external_total'] = amount + externalFees;
//         comparison['has_external_config'] = true;
//       }

//       // Déterminer la recommandation
//       if (comparison['has_onyfast_config'] &&
//           comparison['has_external_config']) {
//         double onyfastTotal = comparison['onyfast_total'];
//         double externalTotal = comparison['external_total'];

//         if (onyfastTotal <= externalTotal) {
//           comparison['recommendation'] = 'onyfast';
//         } else {
//           comparison['recommendation'] = 'external';
//         }
//       }
//     } catch (e) {
//       print('❌ Erreur comparaison frais: $e');
//     }

//     return comparison;
//   }

//   /// NOUVELLE MÉTHODE: Valide si un transfert est possible
//   Future<Map<String, dynamic>> canProcessTransfer({
//     required String phone,
//     required double amount,
//   }) async {
//     try {
//       String formattedPhone = _formatPhoneNumber(phone);

//       if (formattedPhone.isEmpty) {
//         return {
//           'canProcess': false,
//           'reason': 'Numéro invalide',
//           'suggestedAction': 'Vérifiez le format du numéro'
//         };
//       }

//       if (amount <= 0) {
//         return {
//           'canProcess': false,
//           'reason': 'Montant invalide',
//           'suggestedAction': 'Entrez un montant supérieur à 0'
//         };
//       }

//       // Vérifier les configurations de frais
//       if (_cachedFraisConfig == null && _cachedGeneralFraisConfig == null) {
//         return {
//           'canProcess': false,
//           'reason': 'Configuration de frais manquante',
//           'suggestedAction': 'Veuillez réessayer plus tard'
//         };
//       }

//       // Vérifier si le destinataire existe ou si le transfert externe est possible
//       bool hasOnyfastAccount = false;
//       bool canExternalTransfer = false;

//       try {
//         final onyfastPhones =
//             await ContactsService.checkOnyfastUsers([formattedPhone]);
//         hasOnyfastAccount = onyfastPhones.contains(formattedPhone);
//       } catch (e) {
//         print('Erreur vérification compte OnyFast: $e');
//       }

//       if (!hasOnyfastAccount) {
//         canExternalTransfer = _isValidForExternalTransfer(formattedPhone);
//       }

//       if (!hasOnyfastAccount && !canExternalTransfer) {
//         return {
//           'canProcess': false,
//           'reason': 'Destinataire non supporté',
//           'suggestedAction':
//               'Vérifiez le numéro ou choisissez un autre destinataire'
//         };
//       }

//       return {
//         'canProcess': true,
//         'hasOnyfastAccount': hasOnyfastAccount,
//         'canExternalTransfer': canExternalTransfer,
//         'formattedPhone': formattedPhone,
//         'recommendedMode': hasOnyfastAccount ? 'onyfast' : 'external'
//       };
//     } catch (e) {
//       print('❌ Erreur validation transfert: $e');
//       return {
//         'canProcess': false,
//         'reason': 'Erreur de validation',
//         'suggestedAction': 'Veuillez réessayer'
//       };
//     }
//   }

//   /// Nettoie les ressources
//   @override
//   void onClose() {
//     super.onClose();
//     resetFrais();
//     clearSearchedUser();
//     _resetExternalMode();
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';
// import 'package:onyfast/Api/contacts_service.dart';
// import 'package:onyfast/model/contact_model.dart';
// import 'package:onyfast/model/user_model.dart';

// class ContactsController extends GetxController {
//   // Variables pour les frais
//   RxDouble selectedContactFrais = 0.0.obs;
//   RxDouble selectedContactTotal = 0.0.obs;
//   Rx<Map<String, dynamic>?> contactFraisConfig =
//       Rx<Map<String, dynamic>?>(null);
//   RxBool isLoading = false.obs;

//   // Variables pour la recherche d'utilisateur
//   RxBool isSearchingUser = false.obs;
//   Rx<UserModel?> searchedUser = Rx<UserModel?>(null);

//   // Variables pour les contacts du téléphone
//   RxList<ContactModel> phoneContacts = <ContactModel>[].obs;
//   RxList<ContactModel> onyfastContacts = <ContactModel>[].obs;
//   RxBool isLoadingContacts = false.obs;

//   // NOUVEAU: Variables pour les transferts externes
//   RxBool isExternalTransferMode = false.obs;
//   Rx<Map<String, dynamic>?> externalRecipient = Rx<Map<String, dynamic>?>(null);

//   // Configuration des frais mise en cache
//   Map<String, dynamic>? _cachedFraisConfig;
//   Map<String, dynamic>? _cachedGeneralFraisConfig;

//   String get contactFraisInfo {
//     if (contactFraisConfig.value == null) return '';

//     final config = contactFraisConfig.value!;

//     if (config['pourcentage'] != null && config['pourcentage'] != 0) {
//       return '${config['pourcentage']}%';
//     } else if (config['montant'] != null && config['montant'] != 0) {
//       return '${config['montant']} XAF (fixe)';
//     }
//     return '';
//   }

//   /// Obtient la configuration de frais mise en cache
//   Map<String, dynamic>? getCachedFraisConfig() {
//     return _cachedFraisConfig;
//   }

//   /// Obtient la configuration de frais généraux mise en cache
//   Map<String, dynamic>? getCachedGeneralFraisConfig() {
//     return _cachedGeneralFraisConfig;
//   }

//   /// Définit la configuration des frais pour le contact
//   void setContactFraisConfig(Map<String, dynamic> config) {
//     contactFraisConfig.value = config;
//   }

//   /// Définit les frais du contact sélectionné
//   void setSelectedContactFrais(double frais) {
//     selectedContactFrais.value = frais;
//   }

//   /// Définit le total du contact sélectionné
//   void setSelectedContactTotal(double total) {
//     selectedContactTotal.value = total;
//   }

//   /// Récupère la configuration des frais depuis l'API (version publique)
//   Future<Map<String, dynamic>?> getFraisConfigFromAPI(
//       String type, String? destinataire) async {
//     return await _getFraisConfigFromAPI(type, destinataire);
//   }

//   /// Calcule les frais selon la configuration (version publique)
//   double calculerFraisAvecConfig(double montant, Map<String, dynamic> config) {
//     return _calculerFraisAvecConfig(montant, config);
//   }

//   /// MODIFIÉ: Précharge TOUTES les configurations des frais
//   Future<void> preloadFraisConfig() async {
//     try {
//       // Configuration pour transferts OnyFast (pas de destinataire spécifique)
//       final onyfastConfig = await _getFraisConfigFromAPI('TRANSFERT', null);
//       if (onyfastConfig != null) {
//         _cachedFraisConfig = onyfastConfig;
//         print('✅ Configuration frais OnyFast préchargée');
//       }

//       // Configuration pour transferts généraux/externes
//       final generalConfig =
//           await _getFraisConfigFromAPI('TRANSFERT_GENERAL', null);
//       if (generalConfig != null) {
//         _cachedGeneralFraisConfig = generalConfig;
//         print('✅ Configuration frais généraux préchargée');
//       } else {
//         // Fallback: utiliser la même config que OnyFast si pas de config générale
//         _cachedGeneralFraisConfig = onyfastConfig;
//         print('ℹ️ Utilisation config OnyFast pour transferts généraux');
//       }

//       // NOUVEAU: Configuration pour transferts externes
//       final externalConfig =
//           await _getFraisConfigFromAPI('TRANSFERT_EXTERNE', null);
//       if (externalConfig != null) {
//         _cachedGeneralFraisConfig = externalConfig;
//         print('✅ Configuration frais externes préchargée');
//       }
//     } catch (e) {
//       print('❌ Erreur préchargement frais: $e');
//     }
//   }

//   /// Formatage de numéro de téléphone (version publique)
//   String formatPhoneNumber(String phone) {
//     return _formatPhoneNumber(phone);
//   }

//   /// Formate un numéro de téléphone pour matcher le format BD
//   String _formatPhoneNumber(String phone) {
//     if (phone.isEmpty) return '';

//     print('🔧 === DÉBUT FORMATAGE: "$phone" ===');

//     const String defaultCode = '242';
//     String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
//     print('🧹 Après nettoyage: "$cleaned"');

//     if (cleaned.startsWith('+')) {
//       cleaned = cleaned.substring(1);
//       print('➖ Après suppression +: "$cleaned"');
//     }

//     // Cas 1: Numéro local commençant par 0
//     if (cleaned.startsWith('0')) {
//       print('🎯 Cas 1: Numéro local avec 0');
//       if (cleaned.length >= 9) {
//         String formatted = '$defaultCode$cleaned';
//         print('✅ Formaté: "$formatted"');
//         return formatted;
//       } else {
//         print('❌ Numéro local trop court');
//         return '';
//       }
//     }

//     // Cas 2: Numéro avec code pays Congo déjà présent
//     else if (cleaned.startsWith(defaultCode)) {
//       print('🎯 Cas 2: Code Congo déjà présent');
//       if (cleaned.length >= 11) {
//         print('✅ Formaté: "$cleaned"');
//         return cleaned;
//       } else {
//         print('❌ Numéro Congo trop court');
//         return '';
//       }
//     }

//     // Cas 3: Numéro local sans 0
//     else if (cleaned.length >= 8 && cleaned.length <= 9) {
//       print('🎯 Cas 3: Numéro local sans 0');
//       String formatted = '${defaultCode}0$cleaned';
//       print('✅ Formaté avec 0: "$formatted"');
//       return formatted;
//     }

//     // Cas 4: Numéro international avec autre code pays
//     else if (cleaned.length >= 10) {
//       print('🎯 Cas 4: Numéro international');
//       print('✅ Gardé tel quel: "$cleaned"');
//       return cleaned;
//     }

//     print('❌ Format non reconnu: "$cleaned" (longueur: ${cleaned.length})');
//     return '';
//   }

//   /// MODIFIÉ: Recherche un utilisateur par numéro de téléphone avec fallback externe
//   Future<void> searchUserByPhone(String phone) async {
//     if (phone.length < 8) {
//       searchedUser.value = null;
//       _resetExternalMode();
//       return;
//     }

//     isSearchingUser.value = true;

//     try {
//       String formattedPhone = _formatPhoneNumber(phone);
//       if (formattedPhone.isEmpty) {
//         print('⚠️ Numéro invalide: $phone');
//         searchedUser.value = null;
//         _resetExternalMode();
//         isSearchingUser.value = false;
//         return;
//       }

//       print('🔍 Recherche utilisateur dans BD pour: $formattedPhone');
//       final user = await _searchUserAPI(formattedPhone);

//       if (user != null) {
//         searchedUser.value = user;
//         _resetExternalMode();
//         print('✅ Utilisateur OnyFast trouvé: ${user.name} (ID: ${user.id})');

//         // Calculer les frais OnyFast automatiquement si montant disponible
//         try {
//           final amountController =
//               Get.find<TextEditingController>(tag: 'amountController');
//           final amountText = amountController.text;
//           final amount = double.tryParse(amountText) ?? 0;
//           if (amount > 0) {
//             await selectContact(user.toMap(), amount);
//           }
//         } catch (e) {
//           print('Contrôleur de montant non trouvé: $e');
//         }
//       } else {
//         print('ℹ️ Aucun utilisateur OnyFast trouvé pour $formattedPhone');
//         searchedUser.value = null;

//         // NOUVEAU: Vérifier si le numéro peut recevoir un transfert externe
//         await _checkExternalTransferEligibility(formattedPhone);
//       }
//     } catch (e) {
//       print('❌ Erreur recherche utilisateur BD: $e');
//       searchedUser.value = null;
//       _resetExternalMode();

//       if (e.toString().contains('network') ||
//           e.toString().contains('timeout')) {
//         Get.snackbar(
//           'Erreur de connexion',
//           'Impossible de se connecter à la base de données',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//           duration: Duration(seconds: 3),
//         );
//       }
//     } finally {
//       isSearchingUser.value = false;
//     }
//   }

//   /// NOUVELLE MÉTHODE: Vérifie l'éligibilité pour transfert externe
//   Future<void> _checkExternalTransferEligibility(String formattedPhone) async {
//     try {
//       final validation = await validateRecipientNumber(formattedPhone);

//       if (validation['isValid'] == true && validation['isExternal'] == true) {
//         print('📱 Numéro éligible pour transfert externe: $formattedPhone');

//         isExternalTransferMode.value = true;
//         externalRecipient.value = {
//           'phone': formattedPhone,
//           'display_phone': '+$formattedPhone',
//           'name': 'Contact externe',
//           'is_external': true,
//           'can_receive_transfer': true,
//         };

//         // Calculer les frais externes automatiquement si montant disponible
//         try {
//           final amountController =
//               Get.find<TextEditingController>(tag: 'amountController');
//           final amountText = amountController.text;
//           final amount = double.tryParse(amountText) ?? 0;
//           if (amount > 0) {
//             await calculateGeneralFees(amount, formattedPhone);
//           }
//         } catch (e) {
//           print('Contrôleur de montant non trouvé: $e');
//         }
//       } else {
//         print(
//             '❌ Numéro non éligible pour transferts: ${validation['message']}');
//         _resetExternalMode();
//       }
//     } catch (e) {
//       print('❌ Erreur vérification éligibilité externe: $e');
//       _resetExternalMode();
//     }
//   }

//   /// NOUVELLE MÉTHODE: Remet à zéro le mode externe
//   void _resetExternalMode() {
//     isExternalTransferMode.value = false;
//     externalRecipient.value = null;
//   }

//   /// Appel API pour rechercher un utilisateur
//   Future<UserModel?> _searchUserAPI(String phone) async {
//     try {
//       return await ContactsService.searchUserByPhone(phone);
//     } catch (e) {
//       print('❌ Erreur API recherche utilisateur: $e');
//       return null;
//     }
//   }

//   /// MODIFIÉ: Récupère la configuration des frais depuis l'API avec destinataire
//   Future<Map<String, dynamic>?> _getFraisConfigFromAPI(
//       String type, String? destinataire) async {
//     try {
//       final response = await ContactsService.getFraisConfig(type, destinataire);
//       return response;
//     } catch (e) {
//       print('❌ Erreur récupération config frais: $e');
//       return null;
//     }
//   }

//   /// MODIFIÉ: Sélectionne un contact et calcule les frais via l'API
//   Future<void> selectContact(
//       Map<String, dynamic> contact, double amount) async {
//     if (amount <= 0) return;

//     isLoading.value = true;
//     _resetExternalMode(); // S'assurer qu'on n'est pas en mode externe

//     try {
//       // Récupérer le numéro de téléphone du destinataire
//       String destinatairePhone = contact['phone'] ?? contact['telephone'] ?? '';
//       if (destinatairePhone.isEmpty) {
//         print('❌ Numéro de téléphone manquant pour le contact');
//         resetFrais();
//         return;
//       }

//       // Formater le numéro
//       String formattedPhone = _formatPhoneNumber(destinatairePhone);
//       if (formattedPhone.isEmpty) {
//         print('❌ Numéro de téléphone invalide: $destinatairePhone');
//         resetFrais();
//         return;
//       }

//       // Utiliser la configuration préchargée ou charger depuis l'API avec le destinataire
//       Map<String, dynamic>? config = _cachedFraisConfig;
//       config ??= await _getFraisConfigFromAPI('TRANSFERT', formattedPhone);

//       if (config != null) {
//         contactFraisConfig.value = config;

//         final frais = _calculerFraisAvecConfig(amount, config);
//         selectedContactFrais.value = frais;
//         selectedContactTotal.value = amount + frais;

//         print(
//             '✅ Frais OnyFast calculés pour $formattedPhone: +$frais XAF (Total: ${amount + frais} XAF)');
//       } else {
//         print(
//             'ℹ️ Aucune configuration de frais OnyFast trouvée pour $formattedPhone');
//         resetFrais();
//       }
//     } catch (e) {
//       print('❌ Erreur calcul des frais OnyFast: $e');
//       resetFrais();

//       Get.snackbar(
//         'Information',
//         'Impossible de calculer les frais actuellement',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//         duration: Duration(seconds: 2),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Calcule les frais selon la logique du backend PHP
//   double _calculerFraisAvecConfig(double montant, Map<String, dynamic> config) {
//     double fraisMontant = 0;

//     // Logique identique au backend PHP
//     if (config['montant'] != null && config['montant'] != 0) {
//       // Montant fixe
//       fraisMontant = double.tryParse(config['montant'].toString()) ?? 0;
//     } else if (config['pourcentage'] != null && config['pourcentage'] != 0) {
//       // Pourcentage
//       fraisMontant = (montant * config['pourcentage']) / 100;

//       // Appliquer les bornes min/max si définies
//       if (config['min'] != null && config['min'] != 0) {
//         final minValue = double.tryParse(config['min'].toString()) ?? 0;
//         if (minValue > 0) {
//           fraisMontant = fraisMontant < minValue ? minValue : fraisMontant;
//         }
//       }

//       if (config['max'] != null && config['max'] != 0) {
//         final maxValue = double.tryParse(config['max'].toString()) ?? 0;
//         if (maxValue > 0) {
//           fraisMontant = fraisMontant > maxValue ? maxValue : fraisMontant;
//         }
//       }
//     }

//     return fraisMontant;
//   }

//   /// Met à jour le montant et recalcule les frais
//   void updateAmount(double amount) {
//     if (contactFraisConfig.value != null && amount > 0) {
//       final frais = _calculerFraisAvecConfig(amount, contactFraisConfig.value!);
//       selectedContactFrais.value = frais;
//       selectedContactTotal.value = amount + frais;
//     } else {
//       resetFrais();
//     }
//   }

//   /// MODIFIÉ: Traite la transaction via l'API avec support automatique des transferts externes
//   Future<Map<String, dynamic>> processTransaction({
//     required dynamic recipientId,
//     required double amount,
//     required fromTel,
//     required toTel,
//     required double fees,
//     required double total,
//     bool isExternalTransfer = false,
//   }) async {
//     try {
//       // NOUVEAU: Détection automatique du type de transfert si pas spécifié
//       if (!isExternalTransfer &&
//           recipientId == null &&
//           externalRecipient.value != null) {
//         isExternalTransfer = true;
//         print('🔄 Mode transfert externe détecté automatiquement');
//       }

//       print(
//           '🚀 Traitement transaction: $amount XAF vers ${recipientId ?? "externe"} (Externe: $isExternalTransfer)');

//       final result = await ContactsService.processC2CTransaction(
//         recipientId: recipientId?.toString(),
//         amount: amount,
//         fromTel: fromTel,
//         toTel: _formatPhoneNumber(toTel),
//         fees: fees,
//         isExternalTransfer: isExternalTransfer,
//       );

//       if (result['success'] == true) {
//         print('✅ Transaction réussie: ${result['transactionId']}');

//         return {
//           'success': true,
//           'message': isExternalTransfer
//               ? 'Transfert externe initié avec succès'
//               : 'Transaction OnyFast effectuée avec succès',
//           'transactionId': result['transactionId'],
//           'data': result,
//           'isExternal': isExternalTransfer,
//         };
//       } else {
//         print('❌ Transaction échouée: ${result['message']}');
//         return {
//           'success': false,
//           'message': result['message'] ?? 'Erreur lors de la transaction',
//         };
//       }
//     } catch (e) {
//       print('❌ Erreur traitement transaction: $e');

//       String errorMessage = 'Erreur de connexion';
//       if (e.toString().contains('insufficient')) {
//         errorMessage = 'Solde insuffisant';
//       } else if (e.toString().contains('timeout')) {
//         errorMessage = 'Délai de connexion dépassé';
//       } else if (e.toString().contains('network')) {
//         errorMessage = 'Problème de réseau';
//       }

//       return {
//         'success': false,
//         'message': errorMessage,
//       };
//     }
//   }

//   /// MODIFIÉ: Calcule les frais généraux pour contacts sans OnyFast (transferts externes)
//   Future<void> calculateGeneralFees(double amount, String destinataire) async {
//     print(
//         '💰 Calcul des frais généraux/externes pour montant: $amount, destinataire: $destinataire');

//     try {
//       isLoading.value = true;

//       // Formater le numéro du destinataire
//       String formattedDestinataire = _formatPhoneNumber(destinataire);
//       if (formattedDestinataire.isEmpty) {
//         print('❌ Numéro destinataire invalide: $destinataire');
//         resetFrais();
//         return;
//       }

//       // Utiliser la configuration préchargée ou charger depuis l'API avec le destinataire
//       Map<String, dynamic>? config = _cachedGeneralFraisConfig;

//       config ??= await _getFraisConfigFromAPI(
//           'TRANSFERT_GENERAL', formattedDestinataire);
//       config ??= await _getFraisConfigFromAPI(
//           'TRANSFERT_EXTERNE', formattedDestinataire);

//       if (config != null) {
//         contactFraisConfig.value = config;

//         // Calculer les frais selon la configuration
//         final frais = _calculerFraisAvecConfig(amount, config);
//         selectedContactFrais.value = frais;
//         selectedContactTotal.value = amount + frais;

//         print(
//             '✅ Frais externes calculés pour $formattedDestinataire: +$frais XAF (Total: ${amount + frais} XAF)');
//       } else {
//         print(
//             'ℹ️ Aucune configuration de frais externe trouvée pour $formattedDestinataire');
//         resetFrais();
//       }
//     } catch (e) {
//       print('❌ Erreur calcul des frais externes: $e');
//       resetFrais();
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// MODIFIÉ: Valide si un numéro peut recevoir un transfert
//   Future<Map<String, dynamic>> validateRecipientNumber(String phone) async {
//     try {
//       String formattedPhone = _formatPhoneNumber(phone);
//       if (formattedPhone.isEmpty) {
//         return {
//           'isValid': false,
//           'canReceive': false,
//           'hasOnyfast': false,
//           'isExternal': false,
//           'message': 'Numéro invalide'
//         };
//       }

//       // Vérifier si le numéro a un compte OnyFast
//       final onyfastPhones =
//           await ContactsService.checkOnyfastUsers([formattedPhone]);
//       bool hasOnyfast = onyfastPhones.contains(formattedPhone);

//       if (hasOnyfast) {
//         return {
//           'isValid': true,
//           'canReceive': true,
//           'hasOnyfast': true,
//           'isExternal': false,
//           'transferType': 'onyfast',
//           'phone': formattedPhone,
//           'message': 'Compte OnyFast trouvé'
//         };
//       } else {
//         // MODIFIÉ: Vérifier si c'est un numéro externe valide
//         bool isValidExternal = _isValidForExternalTransfer(formattedPhone);

//         return {
//           'isValid': isValidExternal,
//           'canReceive': isValidExternal,
//           'hasOnyfast': false,
//           'isExternal': isValidExternal,
//           'transferType': isValidExternal ? 'external' : 'unsupported',
//           'phone': formattedPhone,
//           'message': isValidExternal
//               ? 'Numéro valide pour transfert externe'
//               : 'Numéro non supporté pour les transferts'
//         };
//       }
//     } catch (e) {
//       print('❌ Erreur validation numéro destinataire: $e');
//       return {
//         'isValid': false,
//         'canReceive': false,
//         'hasOnyfast': false,
//         'isExternal': false,
//         'message': 'Erreur de validation'
//       };
//     }
//   }

//   /// NOUVELLE MÉTHODE: Vérifie si un numéro est valide pour transfert externe
//   bool _isValidForExternalTransfer(String formattedPhone) {
//     // Vérifier la longueur minimale
//     if (formattedPhone.length < 10) {
//       return false;
//     }

//     // Codes pays supportés pour les transferts externes
//     List<String> supportedCountryCodes = [
//       '242', // Congo-Brazzaville
//       '243', // Congo-Kinshasa (RDC)
//       '237', // Cameroun
//       '241', // Gabon
//       '236', // République Centrafricaine
//       '235', // Tchad
//       '33', // France
//       '1', // USA/Canada
//       // Ajouter d'autres codes selon les besoins
//     ];

//     // Vérifier si le numéro commence par un code pays supporté
//     for (String code in supportedCountryCodes) {
//       if (formattedPhone.startsWith(code)) {
//         return true;
//       }
//     }

//     // Si aucun code pays reconnu, considérer comme non supporté
//     return false;
//   }

//   // [Le reste des méthodes reste inchangé...]

//   /// MODIFIÉ: Remet à zéro les frais calculés
//   void resetFrais() {
//     selectedContactFrais.value = 0.0;
//     selectedContactTotal.value = 0.0;
//     contactFraisConfig.value = null;
//     isLoading.value = false;
//     _resetExternalMode(); // NOUVEAU: Aussi réinitialiser le mode externe
//   }

//   /// Efface l'utilisateur recherché
//   void clearSearchedUser() {
//     searchedUser.value = null;
//     _resetExternalMode(); // NOUVEAU: Aussi réinitialiser le mode externe
//   }

//   @override
//   void onClose() {
//     super.onClose();
//     resetFrais();
//     clearSearchedUser();
//     _resetExternalMode();
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:onyfast/Api/contacts_service.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/model/contact_model.dart';
import 'package:onyfast/model/user_model.dart';

class ContactsController extends GetxController {
  // Variables pour les frais
  RxDouble selectedContactFrais = 0.0.obs;
  RxDouble selectedContactTotal = 0.0.obs;
  Rx<Map<String, dynamic>?> contactFraisConfig =
      Rx<Map<String, dynamic>?>(null);
  RxBool isLoading = false.obs;

  // Variables pour la recherche d'utilisateur
  RxBool isSearchingUser = false.obs;
  Rx<UserModel?> searchedUser = Rx<UserModel?>(null);

  // Variables pour les contacts du téléphone
  RxList<ContactModel> phoneContacts = <ContactModel>[].obs;
  RxList<ContactModel> onyfastContacts = <ContactModel>[].obs;
  RxBool isLoadingContacts = false.obs;

  // NOUVEAU: Variables pour les transferts externes
  RxBool isExternalTransferMode = false.obs;
  Rx<Map<String, dynamic>?> externalRecipient = Rx<Map<String, dynamic>?>(null);

  // Configuration des frais mise en cache - MODIFIÉ: avec destinataire
  final Map<String, Map<String, dynamic>> _cachedFraisConfigs = {};
  String? _lastRecipientPhone; // Pour éviter les appels API redondants

  String get contactFraisInfo {
    if (contactFraisConfig.value == null) return '';

    final config = contactFraisConfig.value!;

    if (config['pourcentage'] != null && config['pourcentage'] != 0) {
      return '${config['pourcentage']}%';
    } else if (config['montant'] != null && config['montant'] != 0) {
      return '${config['montant']} XAF (fixe)';
    }
    return '';
  }

  /// MODIFIÉ: Obtient la configuration de frais avec destinataire
  Map<String, dynamic>? getCachedFraisConfig(String? destinataire) {
    if (destinataire == null || destinataire.isEmpty) return null;
    return _cachedFraisConfigs[destinataire];
  }

  /// Définit la configuration des frais pour le contact
  void setContactFraisConfig(Map<String, dynamic> config) {
    contactFraisConfig.value = config;
  }

  /// Définit les frais du contact sélectionné
  void setSelectedContactFrais(double frais) {
    selectedContactFrais.value = frais;
  }

  /// Définit le total du contact sélectionné
  void setSelectedContactTotal(double total) {
    selectedContactTotal.value = total;
  }

  /// Récupère la configuration des frais depuis l'API (version publique)
  Future<Map<String, dynamic>?> getFraisConfigFromAPI(
      String type, String? destinataire) async {
    return await _getFraisConfigFromAPI(type, destinataire);
  }

  /// Calcule les frais selon la configuration (version publique)
  double calculerFraisAvecConfig(double montant, Map<String, dynamic> config) {
    return _calculerFraisAvecConfig(montant, config);
  }

  /// MODIFIÉ: Précharge les configurations des frais génériques (sans destinataire spécifique)
  Future<void> preloadFraisConfig() async {
    try {
      print('🔄 Préchargement des configurations de frais génériques...');

      // Configuration générale pour transferts OnyFast (sans destinataire spécifique)
      final onyfastConfig = await _getFraisConfigFromAPI('TRANSFERT', null);
      if (onyfastConfig != null) {
        _cachedFraisConfigs['TRANSFERT_GENERAL'] = onyfastConfig;
        print('✅ Configuration frais OnyFast générale préchargée');
      }

      // Configuration générale pour transferts externes
      final externalConfig =
          await _getFraisConfigFromAPI('TRANSFERT_EXTERNE', null);
      if (externalConfig != null) {
        _cachedFraisConfigs['EXTERNE_GENERAL'] = externalConfig;
        print('✅ Configuration frais externe générale préchargée');
      }
    } catch (e) {
      print('❌ Erreur préchargement frais: $e');
    }
  }

  /// Formatage de numéro de téléphone (version publique)
  String formatPhoneNumber(String phone) {
    return _formatPhoneNumber(phone);
  }

  /// Formate un numéro de téléphone pour matcher le format BD
  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return '';

    print('🔧 === DÉBUT FORMATAGE: "$phone" ===');

    const String defaultCode = '242';
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
    print('🧹 Après nettoyage: "$cleaned"');

    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
      print('➖ Après suppression +: "$cleaned"');
    }

    // Cas 1: Numéro local commençant par 0
    if (cleaned.startsWith('0')) {
      print('🎯 Cas 1: Numéro local avec 0');
      if (cleaned.length >= 9) {
        String formatted = '$defaultCode$cleaned';
        print('✅ Formaté: "$formatted"');
        return formatted;
      } else {
        print('❌ Numéro local trop court');
        return '';
      }
    }

    // Cas 2: Numéro avec code pays Congo déjà présent
    else if (cleaned.startsWith(defaultCode)) {
      print('🎯 Cas 2: Code Congo déjà présent');
      if (cleaned.length >= 11) {
        print('✅ Formaté: "$cleaned"');
        return cleaned;
      } else {
        print('❌ Numéro Congo trop court');
        return '';
      }
    }

    // Cas 3: Numéro local sans 0
    else if (cleaned.length >= 8 && cleaned.length <= 9) {
      print('🎯 Cas 3: Numéro local sans 0');
      String formatted = '${defaultCode}0$cleaned';
      print('✅ Formaté avec 0: "$formatted"');
      return formatted;
    }

    // Cas 4: Numéro international avec autre code pays
    else if (cleaned.length >= 10) {
      print('🎯 Cas 4: Numéro international');
      print('✅ Gardé tel quel: "$cleaned"');
      return cleaned;
    }

    print('❌ Format non reconnu: "$cleaned" (longueur: ${cleaned.length})');
    return '';
  }

  /// MODIFIÉ: Recherche un utilisateur par numéro de téléphone avec fallback externe
  Future<void> searchUserByPhone(String phone) async {
    if (phone.length < 8) {
      searchedUser.value = null;
      _resetExternalMode();
      return;
    }

    isSearchingUser.value = true;

    try {
      String formattedPhone = _formatPhoneNumber(phone);
      if (formattedPhone.isEmpty) {
        print('⚠️ Numéro invalide: $phone');
        searchedUser.value = null;
        _resetExternalMode();
        isSearchingUser.value = false;
        return;
      }

      print('🔍 Recherche utilisateur dans BD pour: $formattedPhone');
      final user = await _searchUserAPI(formattedPhone);

      if (user != null) {
        searchedUser.value = user;
        _resetExternalMode();
        print('✅ Utilisateur OnyFast trouvé: ${user.name} (ID: ${user.id})');

        // Calculer les frais OnyFast automatiquement si montant disponible
        try {
          final amountController =
              Get.find<TextEditingController>(tag: 'amountController');
          final amountText = amountController.text;
          final amount = double.tryParse(amountText) ?? 0;
          if (amount > 0) {
            await selectContact(user.toMap(), amount);
          }
        } catch (e) {
          print('Contrôleur de montant non trouvé: $e');
        }
      } else {
        print('ℹ️ Aucun utilisateur OnyFast trouvé pour $formattedPhone');
        searchedUser.value = null;

        // NOUVEAU: Vérifier si le numéro peut recevoir un transfert externe
        await _checkExternalTransferEligibility(formattedPhone);
      }
    } catch (e) {
      print('❌ Erreur recherche utilisateur BD: $e');
      searchedUser.value = null;
      _resetExternalMode();

      if (e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        SnackBarService.warning(
          'Impossible de se connecter à la base de données',        
        );
      }
    } finally {
      isSearchingUser.value = false;
    }
  }

  /// NOUVELLE MÉTHODE: Vérifie l'éligibilité pour transfert externe
  Future<void> _checkExternalTransferEligibility(String formattedPhone) async {
    try {
      final validation = await validateRecipientNumber(formattedPhone);

      if (validation['isValid'] == true && validation['isExternal'] == true) {
        print('📱 Numéro éligible pour transfert externe: $formattedPhone');

        isExternalTransferMode.value = true;
        externalRecipient.value = {
          'phone': formattedPhone,
          'display_phone': '+$formattedPhone',
          'name': 'Contact externe',
          'is_external': true,
          'can_receive_transfer': true,
        };

        // Calculer les frais externes automatiquement si montant disponible
        try {
          final amountController =
              Get.find<TextEditingController>(tag: 'amountController');
          final amountText = amountController.text;
          final amount = double.tryParse(amountText) ?? 0;
          if (amount > 0) {
            await calculateGeneralFees(amount, formattedPhone);
          }
        } catch (e) {
          print('Contrôleur de montant non trouvé: $e');
        }
      } else {
        print(
            '❌ Numéro non éligible pour transferts: ${validation['message']}');
        _resetExternalMode();
      }
    } catch (e) {
      print('❌ Erreur vérification éligibilité externe: $e');
      _resetExternalMode();
    }
  }

  /// NOUVELLE MÉTHODE: Remet à zéro le mode externe
  void _resetExternalMode() {
    isExternalTransferMode.value = false;
    externalRecipient.value = null;
  }

  /// Appel API pour rechercher un utilisateur
  Future<UserModel?> _searchUserAPI(String phone) async {
    try {
      return await ContactsService.searchUserByPhone(phone);
    } catch (e) {
      print('❌ Erreur API recherche utilisateur: $e');
      return null;
    }
  }

  /// MODIFIÉ: Récupère la configuration des frais depuis l'API avec destinataire
  Future<Map<String, dynamic>?> _getFraisConfigFromAPI(
      String type, String? destinataire) async {
    try {
      // Créer une clé de cache incluant le type et le destinataire
      String cacheKey = destinataire != null ? '${type}_$destinataire' : type;

      // Vérifier le cache d'abord
      if (_cachedFraisConfigs.containsKey(cacheKey)) {
        print('💾 Configuration frais trouvée dans le cache pour: $cacheKey');
        return _cachedFraisConfigs[cacheKey];
      }

      print(
          '🌐 Récupération config frais API: type=$type, destinataire=$destinataire');
      final response = await ContactsService.getFraisConfig(type, destinataire);

      if (response != null) {
        // Mettre en cache la configuration
        _cachedFraisConfigs[cacheKey] = response;
        print('✅ Configuration frais mise en cache pour: $cacheKey');
      }

      return response;
    } catch (e) {
      print('❌ Erreur récupération config frais: $e');
      return null;
    }
  }

  /// MODIFIÉ: Sélectionne un contact et calcule les frais via l'API avec destinataire
  Future<void> selectContact(
      Map<String, dynamic> contact, double amount) async {
    if (amount <= 0) return;

    isLoading.value = true;
    _resetExternalMode(); // S'assurer qu'on n'est pas en mode externe

    try {
      // Récupérer le numéro de téléphone du destinataire
      String destinatairePhone = contact['phone'] ?? contact['telephone'] ?? '';
      if (destinatairePhone.isEmpty) {
        print('❌ Numéro de téléphone manquant pour le contact');
        resetFrais();
        return;
      }

      // Formater le numéro
      String formattedPhone = _formatPhoneNumber(destinatairePhone);
      if (formattedPhone.isEmpty) {
        print('❌ Numéro de téléphone invalide: $destinatairePhone');
        resetFrais();
        return;
      }

      print('💰 Calcul frais OnyFast pour destinataire: $formattedPhone');

      // MODIFIÉ: Toujours récupérer la config avec le destinataire spécifique
      Map<String, dynamic>? config =
          await _getFraisConfigFromAPI('TRANSFERT', formattedPhone);

      if (config != null) {
        contactFraisConfig.value = config;
        _lastRecipientPhone =
            formattedPhone; // Sauvegarder pour éviter les appels redondants

        final frais = _calculerFraisAvecConfig(amount, config);
        selectedContactFrais.value = frais;
        selectedContactTotal.value = amount + frais;

        print(
            '✅ Frais OnyFast calculés pour $formattedPhone: +$frais XAF (Total: ${amount + frais} XAF)');
      } else {
        print(
            'ℹ️ Aucune configuration de frais OnyFast trouvée pour $formattedPhone');
        resetFrais();
      }
    } catch (e) {
      print('❌ Erreur calcul des frais OnyFast: $e');
      resetFrais();

      SnackBarService.warning(
        'Impossible de calculer les frais actuellement',    
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Calcule les frais selon la logique du backend PHP
  double _calculerFraisAvecConfig(double montant, Map<String, dynamic> config) {
    double fraisMontant = 0;

    // Logique identique au backend PHP
    if (config['montant'] != null && config['montant'] != 0) {
      // Montant fixe
      fraisMontant = double.tryParse(config['montant'].toString()) ?? 0;
      print('📊 Frais fixe appliqué: $fraisMontant XAF');
    } else if (config['pourcentage'] != null && config['pourcentage'] != 0) {
      // Pourcentage
      double pourcentage =
          double.tryParse(config['pourcentage'].toString()) ?? 0;
      fraisMontant = (montant * pourcentage) / 100;
      print('📊 Frais pourcentage ($pourcentage%): $fraisMontant XAF');

      // Appliquer les bornes min/max si définies
      if (config['min'] != null && config['min'] != 0) {
        final minValue = double.tryParse(config['min'].toString()) ?? 0;
        if (minValue > 0 && fraisMontant < minValue) {
          fraisMontant = minValue;
          print('📊 Frais min appliqué: $fraisMontant XAF');
        }
      }

      if (config['max'] != null && config['max'] != 0) {
        final maxValue = double.tryParse(config['max'].toString()) ?? 0;
        if (maxValue > 0 && fraisMontant > maxValue) {
          fraisMontant = maxValue;
          print('📊 Frais max appliqué: $fraisMontant XAF');
        }
      }
    }

    return fraisMontant;
  }

  /// MODIFIÉ: Met à jour le montant et recalcule les frais avec le bon destinataire
  void updateAmount(double amount) {
    if (amount <= 0) {
      resetFrais();
      return;
    }

    // Identifier le destinataire actuel
    String? currentPhone;
    if (isExternalTransferMode.value && externalRecipient.value != null) {
      currentPhone = externalRecipient.value!['phone'];
    } else if (searchedUser.value != null) {
      currentPhone = searchedUser.value!.telephone;
    }

    if (currentPhone != null && contactFraisConfig.value != null) {
      final frais = _calculerFraisAvecConfig(amount, contactFraisConfig.value!);
      selectedContactFrais.value = frais;
      selectedContactTotal.value = amount + frais;
      print('🔄 Frais recalculés pour $currentPhone: $frais XAF');
    } else {
      resetFrais();
    }
  }

  /// MODIFIÉ: Traite la transaction via l'API avec support automatique des transferts externes
  Future<Map<String, dynamic>> processTransaction({
    required dynamic recipientId,
    required double amount,
    required fromTel,
    required toTel,
    required double fees,
    required double total,
    bool isExternalTransfer = false,
    required String recipientCardId
  }) async {
    try {
      // NOUVEAU: Détection automatique du type de transfert si pas spécifié
      if (!isExternalTransfer &&
          recipientId == null &&
          externalRecipient.value != null) {
        isExternalTransfer = true;
        print('🔄 Mode transfert externe détecté automatiquement');
      }

      String formattedToTel = _formatPhoneNumber(toTel);
      print(
          '🚀 Traitement transaction: $amount XAF vers ${recipientId ?? "externe"} (Tel: $formattedToTel, Externe: $isExternalTransfer)');

      final result = await ContactsService.processC2CTransaction(
        recipientId: recipientId?.toString(),
        amount: amount,
        fromTel: fromTel,
        toTel: formattedToTel,
        fees: fees,
        isExternalTransfer: isExternalTransfer,
        recipientCardId: recipientCardId,
      );


      if (result['success'] == true) {
        print('✅ Transaction réussie: ${result['transactionId']}');

        return {
          'success': true,
          'message': isExternalTransfer
              ? 'Transfert externe initié avec succès'
              : 'Transaction OnyFast effectuée avec succès',
          'transactionId': result['transactionId'],
          'data': result,
          'isExternal': isExternalTransfer,
        };
      } else {
        print('❌ Transaction échouée: ${result['message']}');
        return {
          'success': false,
          'message': result['message'] ?? 'Erreur lors de la transaction',
          'error': result['error'] ?? 'Erreur lors de la transaction',
        };
      }
    } catch (e) {
      print('❌ Erreur traitement transaction: $e');

      String errorMessage = 'Erreur de connexion';
      if (e.toString().contains('insufficient')) {
        errorMessage = 'Solde insuffisant';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Délai de connexion dépassé';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Problème de réseau';
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  /// MODIFIÉ: Calcule les frais généraux pour contacts sans OnyFast (transferts externes)
  Future<void> calculateGeneralFees(double amount, String destinataire) async {
    print(
        '💰 Calcul des frais généraux/externes pour montant: $amount, destinataire: $destinataire');

    try {
      isLoading.value = true;

      // Formater le numéro du destinataire
      String formattedDestinataire = _formatPhoneNumber(destinataire);
      if (formattedDestinataire.isEmpty) {
        print('❌ Numéro destinataire invalide: $destinataire');
        resetFrais();
        return;
      }

      // MODIFIÉ: Toujours récupérer la config avec le destinataire spécifique
      Map<String, dynamic>? config = await _getFraisConfigFromAPI(
          'TRANSFERT_EXTERNE', formattedDestinataire);
      config ??= await _getFraisConfigFromAPI(
          'TRANSFERT_GENERAL', formattedDestinataire);

      if (config != null) {
        contactFraisConfig.value = config;
        _lastRecipientPhone =
            formattedDestinataire; // Sauvegarder pour éviter les appels redondants

        // Calculer les frais selon la configuration
        final frais = _calculerFraisAvecConfig(amount, config);
        selectedContactFrais.value = frais;
        selectedContactTotal.value = amount + frais;

        print(
            '✅ Frais externes calculés pour $formattedDestinataire: +$frais XAF (Total: ${amount + frais} XAF)');
      } else {
        print(
            'ℹ️ Aucune configuration de frais externe trouvée pour $formattedDestinataire');
        resetFrais();
      }
    } catch (e) {
      print('❌ Erreur calcul des frais externes: $e');
      resetFrais();
    } finally {
      isLoading.value = false;
    }
  }

  /// MODIFIÉ: Valide si un numéro peut recevoir un transfert
  Future<Map<String, dynamic>> validateRecipientNumber(String phone) async {
    try {
      String formattedPhone = _formatPhoneNumber(phone);
      if (formattedPhone.isEmpty) {
        return {
          'isValid': false,
          'canReceive': false,
          'hasOnyfast': false,
          'isExternal': false,
          'message': 'Numéro invalide'
        };
      }

      // Vérifier si le numéro a un compte OnyFast
      final onyfastPhones =
          await ContactsService.checkOnyfastUsers([formattedPhone]);
      bool hasOnyfast = onyfastPhones.contains(formattedPhone);

      if (hasOnyfast) {
        return {
          'isValid': true,
          'canReceive': true,
          'hasOnyfast': true,
          'isExternal': false,
          'transferType': 'onyfast',
          'phone': formattedPhone,
          'message': 'Compte OnyFast trouvé'
        };
      } else {
        // MODIFIÉ: Vérifier si c'est un numéro externe valide
        bool isValidExternal = _isValidForExternalTransfer(formattedPhone);

        return {
          'isValid': isValidExternal,
          'canReceive': isValidExternal,
          'hasOnyfast': false,
          'isExternal': isValidExternal,
          'transferType': isValidExternal ? 'external' : 'unsupported',
          'phone': formattedPhone,
          'message': isValidExternal
              ? 'Numéro valide pour transfert externe'
              : 'Numéro non supporté pour les transferts'
        };
      }
    } catch (e) {
      print('❌ Erreur validation numéro destinataire: $e');
      return {
        'isValid': false,
        'canReceive': false,
        'hasOnyfast': false,
        'isExternal': false,
        'message': 'Erreur de validation'
      };
    }
  }

  /// NOUVELLE MÉTHODE: Vérifie si un numéro est valide pour transfert externe
  bool _isValidForExternalTransfer(String formattedPhone) {
    // Vérifier la longueur minimale
    if (formattedPhone.length < 10) {
      return false;
    }

    // Codes pays supportés pour les transferts externes
    List<String> supportedCountryCodes = [
      '242', // Congo-Brazzaville
      '243', // Congo-Kinshasa (RDC)
      '237', // Cameroun
      '241', // Gabon
      '236', // République Centrafricaine
      '235', // Tchad
      '33', // France
      '1', // USA/Canada
      // Ajouter d'autres codes selon les besoins
    ];

    // Vérifier si le numéro commence par un code pays supporté
    for (String code in supportedCountryCodes) {
      if (formattedPhone.startsWith(code)) {
        return true;
      }
    }

    // Si aucun code pays reconnu, considérer comme non supporté
    return false;
  }

  /// NOUVELLE MÉTHODE: Obtient les informations du destinataire externe
  Map<String, dynamic>? getExternalRecipientInfo() {
    return externalRecipient.value;
  }

  /// NOUVELLE MÉTHODE: Vérifie si on est en mode transfert externe
  bool isInExternalMode() {
    return isExternalTransferMode.value && externalRecipient.value != null;
  }

  /// NOUVELLE MÉTHODE: Force le mode transfert externe
  void setExternalTransferMode(String phone, String name) {
    String formattedPhone = _formatPhoneNumber(phone);

    if (formattedPhone.isNotEmpty &&
        _isValidForExternalTransfer(formattedPhone)) {
      isExternalTransferMode.value = true;
      externalRecipient.value = {
        'phone': formattedPhone,
        'display_phone': '+$formattedPhone',
        'name': name,
        'is_external': true,
        'can_receive_transfer': true,
      };

      // Réinitialiser la recherche d'utilisateur OnyFast
      searchedUser.value = null;

      print('🔄 Mode transfert externe activé pour: $name ($formattedPhone)');
    } else {
      print('❌ Numéro non valide pour transfert externe: $phone');
    }
  }

  /// NOUVELLE MÉTHODE: Obtient le type de transfert actuel
  String getCurrentTransferType() {
    if (isInExternalMode()) {
      return 'external';
    } else if (searchedUser.value != null) {
      return 'onyfast';
    } else {
      return 'none';
    }
  }

  /// NOUVELLE MÉTHODE: Obtient le nom du destinataire actuel
  String getCurrentRecipientName() {
    if (isInExternalMode()) {
      return externalRecipient.value?['name'] ?? 'Contact externe';
    } else if (searchedUser.value != null) {
      return searchedUser.value!.name;
    } else {
      return '';
    }
  }

  /// NOUVELLE MÉTHODE: Obtient le téléphone du destinataire actuel
  String getCurrentRecipientPhone() {
    if (isInExternalMode()) {
      return externalRecipient.value?['phone'] ?? '';
    } else if (searchedUser.value != null) {
      return searchedUser.value!.telephone;
    } else {
      return '';
    }
  }

  /// Charge les contacts du téléphone et filtre ceux qui ont OnyFast
  Future<void> loadPhoneContacts() async {
    isLoadingContacts.value = true;

    try {
      // Demander la permission
      if (!await FlutterContacts.requestPermission()) {
        SnackBarService.warning(
          title:  'Permission refusée',
          'Veuillez autoriser l\'accès aux contacts dans les paramètres',
         
        );
        return;
      }

      // Récupérer les contacts du téléphone
      final contacts = await ContactsService.getContacts(withThumbnails: false);

      // Convertir en ContactModel avec gestion améliorée des numéros
      final List<ContactModel> allContacts = [];
      final List<String> phoneNumbers = [];

      for (var contact in contacts) {
        if (contact.phones.isNotEmpty) {
          // Extraire TOUS les numéros valides du contact
          List<String> contactPhones =
              contact.phones.map((phone) => phone.number).toList();
          List<String> validPhones = _extractValidNumbers(contactPhones);

          // Créer un contact pour chaque numéro valide
          for (String validPhone in validPhones) {
            if (validPhone.isNotEmpty && !phoneNumbers.contains(validPhone)) {
              phoneNumbers.add(validPhone);
              allContacts.add(ContactModel(
                name: contact.displayName.isNotEmpty
                    ? contact.displayName
                    : 'Sans nom',
                phone: validPhone,
                isOnyfast: false,
              ));
            }
          }
        }
      }

      phoneContacts.value = allContacts;
      print('📱 ${allContacts.length} contacts avec numéros valides extraits');

      // Vérifier quels contacts ont OnyFast via l'API
      if (phoneNumbers.isNotEmpty) {
        try {
          final onyfastPhones = await _checkOnyfastUsersAPI(phoneNumbers);

          // Mettre à jour le statut OnyFast des contacts
          for (var contact in allContacts) {
            contact.isOnyfast = onyfastPhones.contains(contact.phone);
          }

          // Filtrer les contacts OnyFast
          onyfastContacts.value =
              allContacts.where((contact) => contact.isOnyfast).toList();

          print(
              '✅ Contacts chargés: ${allContacts.length} total, ${onyfastContacts.length} OnyFast');
        } catch (e) {
          print('❌ Erreur vérification contacts OnyFast: $e');
        }
      }
    } catch (e) {
      print('❌ Erreur chargement contacts: $e');
      SnackBarService.warning(
       title:  'Erreur',
        'Impossible de charger les contacts',
      );
    } finally {
      isLoadingContacts.value = false;
    }
  }

  /// Extrait tous les numéros valides d'un contact
  List<String> _extractValidNumbers(List<String> phoneNumbers) {
    List<String> validNumbers = [];

    for (String phone in phoneNumbers) {
      String formatted = _formatPhoneNumber(phone);
      if (formatted.isNotEmpty && !validNumbers.contains(formatted)) {
        validNumbers.add(formatted);
      }
    }

    return validNumbers;
  }

  /// Appel API pour vérifier les contacts OnyFast
  Future<List<String>> _checkOnyfastUsersAPI(List<String> phoneNumbers) async {
    try {
      return await ContactsService.checkOnyfastUsers(phoneNumbers);
    } catch (e) {
      print('❌ Erreur API vérification OnyFast: $e');
      return [];
    }
  }

  /// Obtient des statistiques des frais
  Future<Map<String, dynamic>?> getFeeStatistics() async {
    try {
      final stats = await ContactsService.getTransferStatistics();
      return stats;
    } catch (e) {
      print('❌ Erreur récupération statistiques frais: $e');
      return null;
    }
  }

  /// Recherche unifiée de contacts (OnyFast + externes)
  Future<List<Map<String, dynamic>>> searchAllContacts(String query) async {
    try {
      return await ContactsService.searchAllContacts(query);
    } catch (e) {
      print('❌ Erreur recherche unifiée: $e');
      return [];
    }
  }

  /// Valide les données avant transaction
  Map<String, dynamic> validateTransactionData({
    required String phone,
    required double amount,
    required double fees,
    String? recipientId,
    bool isExternal = false,
  }) {
    return ContactsService.validateTransactionData(
      phone: phone,
      amount: amount,
      fees: fees,
      recipientId: recipientId,
      isExternal: isExternal,
    );
  }

  /// Test de connectivité API
  Future<bool> testConnectivity() async {
    try {
      return await ContactsService.testApiConnectivity();
    } catch (e) {
      print('❌ Erreur test connectivité: $e');
      return false;
    }
  }

  /// Obtient des suggestions pour un numéro invalide
  Map<String, dynamic> getPhoneSuggestions(String phone) {
    return ContactsService.validateAndSuggestPhone(phone);
  }

  /// Cache un favori avec son statut
  Future<void> cacheFavoriteContact(Map<String, dynamic> contact) async {
    try {
      await ContactsService.cacheFavoriteWithStatus(contact);
    } catch (e) {
      print('❌ Erreur cache favori: $e');
    }
  }

  /// Récupère les favoris depuis le cache
  Future<List<Map<String, dynamic>>> getCachedFavorites() async {
    try {
      final favorites = await ContactsService.getCachedFavorites();
      return favorites ?? [];
    } catch (e) {
      print('❌ Erreur récupération favoris: $e');
      return [];
    }
  }

  /// Supprime un favori du cache
  Future<void> removeFavorite(String phone) async {
    try {
      await ContactsService.removeCachedFavorite(phone);
    } catch (e) {
      print('❌ Erreur suppression favori: $e');
    }
  }

  /// Calcule des frais estimés pour preview
  Future<Map<String, dynamic>?> getEstimatedFees({
    required double amount,
    required bool isExternal,
    String? recipientId,
  }) async {
    try {
      return await ContactsService.getEstimatedFees(
        amount: amount,
        isExternal: isExternal,
        recipientId: recipientId,
      );
    } catch (e) {
      print('❌ Erreur estimation frais: $e');
      return null;
    }
  }

  /// Analyse les contacts pour statistiques
  Map<String, dynamic> analyzeContactsData(
      List<Map<String, dynamic>> contacts) {
    return ContactsService.analyzeContacts(contacts);
  }

  /// Recherche avancée avec filtres
  List<Map<String, dynamic>> advancedContactSearch(
    List<Map<String, dynamic>> contacts,
    String query, {
    bool onlyOnyfast = false,
    bool onlyWithPhones = false,
    bool onlyOnline = false,
  }) {
    return ContactsService.advancedSearch(
      contacts,
      query,
      onlyOnyfast: onlyOnyfast,
      onlyWithPhones: onlyWithPhones,
      onlyOnline: onlyOnline,
    );
  }

  /// Trie les contacts selon différents critères
  List<Map<String, dynamic>> sortContactsList(
    List<Map<String, dynamic>> contacts, {
    String sortBy = 'name',
    bool ascending = true,
  }) {
    return ContactsService.sortContacts(
      contacts,
      sortBy: sortBy,
      ascending: ascending,
    );
  }

  /// Nettoie et valide un contact
  Map<String, dynamic> sanitizeContactData(Map<String, dynamic> contact) {
    return ContactsService.sanitizeContact(contact);
  }

  /// MODIFIÉ: Remet à zéro les frais calculés
  void resetFrais() {
    selectedContactFrais.value = 0.0;
    selectedContactTotal.value = 0.0;
    contactFraisConfig.value = null;
    isLoading.value = false;
    _lastRecipientPhone = null;
    _resetExternalMode(); // NOUVEAU: Aussi réinitialiser le mode externe
  }

  /// Efface l'utilisateur recherché
  void clearSearchedUser() {
    searchedUser.value = null;
    _resetExternalMode(); // NOUVEAU: Aussi réinitialiser le mode externe
  }

  /// NOUVELLE MÉTHODE: Nettoie le cache des frais
  void clearFeesCache() {
    _cachedFraisConfigs.clear();
    _lastRecipientPhone = null;
    print('🧹 Cache des frais vidé');
  }

  /// NOUVELLE MÉTHODE: Obtient les statistiques du cache
  Map<String, dynamic> getCacheStats() {
    return {
      'cached_configs_count': _cachedFraisConfigs.length,
      'cached_keys': _cachedFraisConfigs.keys.toList(),
      'last_recipient': _lastRecipientPhone,
      'has_current_config': contactFraisConfig.value != null,
    };
  }

  /// MODIFIÉ: Debug - affiche l'état complet
  void debugControllerState() {
    print('🐛 === DEBUG CONTACTS CONTROLLER ===');
    print('   - isLoading: ${isLoading.value}');
    print('   - isSearchingUser: ${isSearchingUser.value}');
    print('   - hasSearchedUser: ${searchedUser.value != null}');
    print('   - isExternalMode: ${isExternalTransferMode.value}');
    print('   - hasExternalRecipient: ${externalRecipient.value != null}');
    print('   - currentFees: ${selectedContactFrais.value}');
    print('   - currentTotal: ${selectedContactTotal.value}');
    print('   - hasFraisConfig: ${contactFraisConfig.value != null}');
    print('   - lastRecipientPhone: $_lastRecipientPhone');

    final cacheStats = getCacheStats();
    cacheStats.forEach((key, value) {
      print('   - cache_$key: $value');
    });

    print('🐛 === FIN DEBUG ===');
  }

  @override
  void onClose() {
    super.onClose();
    resetFrais();
    clearSearchedUser();
    clearFeesCache();
    _resetExternalMode();
  }
}
