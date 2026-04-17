import 'dart:async';
import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/model/user_model.dart';

class ContactsService {
  static final GetStorage _storage = GetStorage();

  // Durée de validité du cache pour les contacts : 30 minutes
  static const int CONTACTS_CACHE_DURATION = 30 * 60 * 1000;

  /// Headers avec authentification
  static Map<String, String> get _headers {
    final token = _storage.read('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Formate un numéro pour matcher le format BD (242066367034 - sans le +)
  static String formatPhoneForDB(String phone) {
    if (phone.isEmpty) return '';

    const String defaultCode = '242'; // Code pays Congo

    // Nettoyer le numéro : supprimer espaces, tirets, parenthèses, points
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');

    // Supprimer le + au début s'il existe pour traitement uniforme
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }

    print('📞 Formatage pour BD: "$phone" → "$cleaned"');

    // Cas 1: Numéro local commençant par 0 (ex: 061234567 → 242061234567)
    if (cleaned.startsWith('0')) {
      if (cleaned.length >= 9) {
        String formatted = '$defaultCode$cleaned'; // Garder le 0 !
        print('✅ Format BD avec 0 gardé: "$phone" → "$formatted"');
        return formatted;
      }
      return ''; // Numéro trop court
    }

    // Cas 2: Numéro avec code pays Congo déjà présent (ex: 242061234567)
    else if (cleaned.startsWith(defaultCode)) {
      if (cleaned.length >= 11) {
        print('✅ Format BD déjà correct: "$phone" → "$cleaned"');
        return cleaned;
      }
      return ''; // Numéro trop court
    }

    // Cas 3: Numéro international avec autre code pays (ex: 33123456789)
    else if (cleaned.length >= 10 && !cleaned.startsWith(defaultCode)) {
      print('✅ Format BD international: "$phone" → "$cleaned"');
      return cleaned;
    }

    // Cas 4: Numéro local sans 0 (ex: 61234567 → 242061234567)
    else if (cleaned.length >= 8 && cleaned.length <= 9) {
      String formatted = '${defaultCode}0$cleaned';
      print('✅ Format BD avec 0 ajouté: "$phone" → "$formatted"');
      return formatted;
    }

    // Cas 5: Numéro court (probablement invalide)
    else if (cleaned.length < 8) {
      print('⚠️ Numéro trop court ignoré: $phone');
      return ''; // Ignorer les numéros trop courts
    }

    // Cas par défaut : traiter comme numéro local et ajouter 0
    String formatted = '${defaultCode}0$cleaned';
    print('✅ Format BD défaut avec 0: "$phone" → "$formatted"');
    return formatted;
  }

  /// 🔹 Récupère la liste des contacts Onyfast via l'API
  static Future<List<Map<String, dynamic>>> getOnyfastContacts() async {
    final String cacheKey = 'onyfast_contacts';
    final String timestampKey = 'onyfast_contacts_timestamp';

    final cachedContacts = _storage.read(cacheKey);
    final cachedTimestamp = _storage.read(timestampKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cachedContacts != null &&
        (now - cachedTimestamp) < CONTACTS_CACHE_DURATION) {
      print('📱 Contacts depuis le cache');
      return List<Map<String, dynamic>>.from(cachedContacts);
    }

    try {
      final response = await http
          .get(
        Uri.parse('${ApiEnvironmentController.to.baseUrl}/contacts/onyfast'),
        headers: _headers,
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
              'Timeout de connexion', const Duration(seconds: 10));
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['contacts'] != null) {
          final rawContacts = List<Map<String, dynamic>>.from(data['contacts']);

          final List<Map<String, dynamic>> contacts = rawContacts
              .map((contact) => {
                    'id': contact['user_id'] ?? contact['id'],
                    'name': contact['name'] ?? 'Nom inconnu',
                    'phone': contact['telephone'] ?? contact['phone'] ?? '',
                    'telephone': contact['telephone'] ?? contact['phone'] ?? '',
                    'email': contact['email'] ?? '',
                    'avatar': contact['avatar'] ?? contact['profile_picture'],
                    'is_online': contact['is_online'] ?? false,
                    'created_at': contact['created_at'],
                  })
              .toList();

          _storage.write(cacheKey, contacts);
          _storage.write(timestampKey, now);

          print(
              '🌐 Contacts récupérés depuis l\'API: ${contacts.length} contacts');
          return contacts;
        } else {
          print('⚠️ Réponse API sans contacts');
          return [];
        }
      } else if (response.statusCode == 404) {
        print('ℹ️ Aucun contact trouvé');
        return [];
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des contacts: $e');
      if (cachedContacts != null) {
        print('⚠️ Utilisation du cache expiré');
        return List<Map<String, dynamic>>.from(cachedContacts);
      }
      rethrow;
    }
  }

  /// 🔎 Recherche des contacts Onyfast par nom ou téléphone
  static Future<List<Map<String, dynamic>>> searchContacts(String query) async {
    if (query.isEmpty) return await getOnyfastContacts();

    try {
      final response = await http
          .get(
            Uri.parse(
                '${ApiEnvironmentController.to.baseUrl}/contacts/onyfast/search?q=${Uri.encodeQueryComponent(query)}'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['contacts'] != null) {
          final rawContacts = List<Map<String, dynamic>>.from(data['contacts']);

          return rawContacts
              .map((contact) => {
                    'id': contact['user_id'] ?? contact['id'],
                    'name': contact['name'] ?? 'Nom inconnu',
                    'phone': contact['telephone'] ?? contact['phone'] ?? '',
                    'telephone': contact['telephone'] ?? contact['phone'] ?? '',
                    'email': contact['email'] ?? '',
                    'created_at': contact['created_at'],
                  })
              .toList();
        }
      }
    } catch (e) {
      print('❌ Erreur recherche API: $e');
    }

    // Fallback: recherche locale dans le cache
    final contacts = await getOnyfastContacts();
    return contacts.where((contact) {
      final name = contact['name']?.toString().toLowerCase() ?? '';
      final phone = contact['phone']?.toString().toLowerCase() ?? '';
      final telephone = contact['telephone']?.toString().toLowerCase() ?? '';
      final email = contact['email']?.toString().toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();

      return name.contains(searchQuery) ||
          phone.contains(searchQuery) ||
          telephone.contains(searchQuery) ||
          email.contains(searchQuery);
    }).toList();
  }

  /// 👤 Recherche un utilisateur par numéro de téléphone (teste plusieurs formats)
  static Future<UserModel?> searchUserByPhone(String phone) async {
    if (phone.isEmpty) return null;

    // Générer plusieurs formats possibles pour la recherche
    List<String> possibleFormats = _generatePossibleFormats(phone);

    print(
        '🔍 Recherche utilisateur pour "$phone" avec ${possibleFormats.length} formats possibles:');
    for (int i = 0; i < possibleFormats.length; i++) {
      print('   ${i + 1}. ${possibleFormats[i]}');
    }

    // Tester chaque format jusqu'à trouver un résultat
    for (String formattedPhone in possibleFormats) {
      if (formattedPhone.isEmpty) continue;

      try {
        print('🔍 Test recherche avec: "$formattedPhone"');
        final response = await http
            .get(
              Uri.parse(
                  '${ApiEnvironmentController.to.baseUrl}/users/search?phone=${Uri.encodeQueryComponent(formattedPhone)}'),
              headers: _headers,
            )
            .timeout(const Duration(seconds: 10));

        print(
            '📥 Réponse pour "$formattedPhone" (status ${response.statusCode}): ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['user'] != null) {
            print('✅ Utilisateur trouvé avec le format: $formattedPhone');
            return UserModel.fromMap(data['user']);
          } else {
            print(
                'ℹ️ Pas d\'utilisateur dans la réponse pour: $formattedPhone');
          }
        } else if (response.statusCode == 404) {
          print('ℹ️ 404 - Utilisateur non trouvé pour: $formattedPhone');
        } else {
          print('❌ Erreur HTTP ${response.statusCode} pour $formattedPhone');
        }
      } catch (e) {
        print('❌ Erreur recherche utilisateur avec $formattedPhone: $e');
      }
    }

    print(
        '❌ Aucun utilisateur trouvé pour tous les formats testés de "$phone"');
    return null;
  }

  /// Génère tous les formats possibles pour un numéro donné
  static List<String> _generatePossibleFormats(String phone) {
    Set<String> formats = {};

    // Nettoyer le numéro de base
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Format principal
    String mainFormat = formatPhoneForDB(phone);
    if (mainFormat.isNotEmpty) {
      formats.add(mainFormat);
    }

    // Si le numéro commence par 0, tester aussi sans le 0
    if (cleaned.startsWith('0') && cleaned.length > 8) {
      String withoutZero = cleaned.substring(1);
      formats.add('242$withoutZero');
      formats.add(withoutZero);
    }

    // Si le numéro ne commence pas par 242, tester avec 242
    if (!cleaned.startsWith('242') && cleaned.length >= 8) {
      formats.add('242$cleaned');
    }

    // Tester le numéro tel que saisi (nettoyé)
    if (cleaned.length >= 8) {
      formats.add(cleaned);
    }

    // Tester avec + au début
    for (String format in List.from(formats)) {
      formats.add('+$format');
    }

    return formats.where((f) => f.isNotEmpty).toList();
  }

  /// ✅ Vérifie quels numéros ont un compte OnyFast
  static Future<List<String>> checkOnyfastUsers(
      List<String> phoneNumbers) async {
    List<String> formattedNumbers = phoneNumbers
        .map((phone) => formatPhoneForDB(phone))
        .where((phone) => phone.isNotEmpty)
        .toList();

    if (formattedNumbers.isEmpty) {
      print('⚠️ Aucun numéro valide à vérifier');
      return [];
    }

    print(
        '🔍 Vérification OnyFast pour ${formattedNumbers.length} numéros formatés');

    try {
      var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
       var ip=await ValidationTokenController.to.getPublicIP();
      final requestBody = {'phones': formattedNumbers,
      'device':deviceskey,
      'ip':ip
      };
      print('📤 Corps de la requête: ${jsonEncode(requestBody)}');
      
      final response = await http
          .post(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/users/check-onyfast'),
            headers: _headers,
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      print('📥 Réponse API (status ${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<String> onyfastPhones =
              List<String>.from(data['onyfast_phones'] ?? []);
          print(
              '✅ ${onyfastPhones.length} comptes OnyFast trouvés dans la réponse');
          return onyfastPhones;
        } else {
          print(
              '❌ Réponse API avec success=false: ${data['message'] ?? 'Pas de message'}');
        }
      } else {
        print('❌ Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur vérification contacts OnyFast: $e');
    }
    return [];
  }

  /// 💰 Récupère la configuration des frais généraux
  static Future<Map<String, dynamic>?> getFraisConfig(
      String type, destinataire) async {
    try {
      // String url = '$baseUrl/frais/config?type=$type';
      final response = await http
          .get(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/frais/user/config/$type/$destinataire'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['config'] != null) {
          return Map<String, dynamic>.from(data['config']);
        }
      } else if (response.statusCode == 404) {
        return null;
      }
    } catch (e) {
      print('❌ Erreur récupération config frais: $e');
    }
    return null;
  }

  /// 💰 Récupère les frais d'un utilisateur spécifique pour un type de transaction
  static Future<Map<String, dynamic>?> getUserFraisConfig(
      int userId, String transactionType) async {
    final String cacheKey = 'user_frais_${userId}_$transactionType';
    final String timestampKey =
        'user_frais_${userId}_${transactionType}_timestamp';

    final cachedConfig = _storage.read(cacheKey);
    final cachedTimestamp = _storage.read(timestampKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cachedConfig != null &&
        (now - cachedTimestamp) < (24 * 60 * 60 * 1000)) {
      print('💰 Frais utilisateur depuis le cache');
      return Map<String, dynamic>.from(cachedConfig);
    }

    try {
      final response = await http
          .get(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/frais/user/$userId?type=$transactionType'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['config'] != null) {
          final config = data['config'];

          _storage.write(cacheKey, config);
          _storage.write(timestampKey, now);

          print('🌐 Frais utilisateur récupérés depuis l\'API');
          return Map<String, dynamic>.from(config);
        }
      } else if (response.statusCode == 404) {
        return null;
      }
    } catch (e) {
      print('❌ Erreur frais utilisateur: $e');
      if (cachedConfig != null) {
        return Map<String, dynamic>.from(cachedConfig);
      }
    }
    return null;
  }

  /// 💳 MODIFIÉ: Traite une transaction C2C avec support complet des transferts externes
  static Future<Map<String, dynamic>> processC2CTransaction({
    String? recipientId,
    required double amount,
    required fromTel,
    required toTel,
    required double fees,
    bool isExternalTransfer = false,
    required String recipientCardId
  }) async {
    print('📤 Traitement transaction:');
    print('   - Type: ${isExternalTransfer ? "EXTERNE" : "ONYFAST"}');
    print('   - Expéditeur: $fromTel');
    print('   - Destinataire: $toTel');
    print('   - Montant: $amount');
    print('   - Frais: $fees');
    print('   - ID destinataire: ${recipientId ?? "N/A (externe)"}');

    try {
       var ip=await ValidationTokenController.to.getPublicIP();
      // MODIFIÉ: Corps de requête adaptatif selon le type de transfert
      Map<String, dynamic> requestBody;
      var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
      if (isExternalTransfer) {
        // Pour les transferts externes
        requestBody = {
          "type_transaction_id": 8, // ID pour transferts externes
          'fees': fees,
          "from_telephone": fromTel,
          "to_telephone": toTel,
          "montant": amount,
          "is_external": true,
          "recipient_type": "external",
          "external_provider": _detectMobileProvider(toTel), // NOUVEAU
          "external_country": _detectCountryFromPhone(toTel), // NOUVEAU
          "device":deviceskey,
          "ip":ip
        };
      } else {
        // Pour les transferts OnyFast (existant)
         var card_id = ManageCardsController.to.currentCard?.cardID ?? '';

        requestBody = {
          "type_transaction_id": 7, // ID existant pour OnyFast
          'fees': fees,
          "from_telephone": fromTel,
          "to_telephone": toTel,
          "montant": amount,
          "recipient_id": recipientId,
          "is_external": false,
          "recipient_type": "onyfast",
          "device":deviceskey,
          "ip":ip,
          'card_id':card_id,
          "to_card_id":recipientCardId
        };
      }

      print('📋 Corps de la requête: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/c2c'),
            headers: _headers,
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Réponse API (status ${response.statusCode}): ${response.body}');

      final data = jsonDecode(response.body);


      if (response.statusCode == 200 || response.statusCode == 201) {
        String successMessage;
        if (isExternalTransfer) {
          String provider = _detectMobileProvider(toTel);
          successMessage = provider.isNotEmpty
              ? 'Transfert $provider initié avec succès'
              : 'Transfert externe initié avec succès';
        } else {
          successMessage = 'Transaction OnyFast réussie';
        }

        return {
          'success': true,
          'transactionId': data['transaction_id'] ?? data['id'],
          'message': data['message'] ?? successMessage,
          'data': data,
          'isExternal': isExternalTransfer,
          'provider': isExternalTransfer ? _detectMobileProvider(toTel) : null,
          'estimatedDeliveryTime':
              isExternalTransfer ? '2-5 minutes' : 'Immédiat',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la transaction',
          'error_code': response.statusCode,
          'isExternal': isExternalTransfer,
          "error":data['error'] ??''
        };
      }
    } catch (e) {
      print('❌ Erreur transaction: $e');

      String errorMessage;
      if (isExternalTransfer) {
        errorMessage = 'Erreur de connexion lors du transfert externe';
      } else {
        errorMessage = 'Erreur de connexion lors de la transaction OnyFast';
      }

      return {
        'success': false,
        'message': errorMessage,
        'isExternal': isExternalTransfer,
      };
    }
  }

  /// NOUVELLE MÉTHODE: Détecte le fournisseur mobile money depuis un numéro
  static String _detectMobileProvider(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Codes des opérateurs Congo-Brazzaville
    if (cleaned.startsWith('242')) {
      String localNumber = cleaned.substring(3);

      // MTN Congo
      if (localNumber.startsWith('064') ||
          localNumber.startsWith('065') ||
          localNumber.startsWith('066') ||
          localNumber.startsWith('067')) {
        return 'MTN Mobile Money';
      }

      // Airtel Congo
      if (localNumber.startsWith('062') || localNumber.startsWith('063')) {
        return 'Airtel Money';
      }

      // Moov Congo
      if (localNumber.startsWith('061')) {
        return 'Moov Money';
      }

      return 'Mobile Money Congo';
    }

    // Codes des opérateurs RDC
    if (cleaned.startsWith('243')) {
      return 'Mobile Money RDC';
    }

    // Autres pays
    if (cleaned.startsWith('237')) {
      return 'Mobile Money Cameroun';
    }

    if (cleaned.startsWith('241')) {
      return 'Mobile Money Gabon';
    }

    return 'Mobile Money';
  }

  /// NOUVELLE MÉTHODE: Détecte le pays depuis un numéro
  static String _detectCountryFromPhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    if (cleaned.startsWith('242')) return 'Congo-Brazzaville';
    if (cleaned.startsWith('243')) return 'République Démocratique du Congo';
    if (cleaned.startsWith('237')) return 'Cameroun';
    if (cleaned.startsWith('241')) return 'Gabon';
    if (cleaned.startsWith('236')) return 'République Centrafricaine';
    if (cleaned.startsWith('235')) return 'Tchad';
    if (cleaned.startsWith('33')) return 'France';
    if (cleaned.startsWith('1')) return 'Amérique du Nord';

    return 'International';
  }

  /// 💰 NOUVELLE MÉTHODE: Récupère la configuration des frais généraux pour transferts externes
  static Future<Map<String, dynamic>?> getGeneralFraisConfig() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/frais/config?type=TRANSFERT_GENERAL'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['config'] != null) {
          print('✅ Configuration frais généraux récupérée');
          return Map<String, dynamic>.from(data['config']);
        }
      } else if (response.statusCode == 404) {
        print('ℹ️ Pas de configuration générale, utiliser celle par défaut');
        return null;
      }
    } catch (e) {
      print('❌ Erreur récupération config frais généraux: $e');
    }
    return null;
  }

  /// 📊 MODIFIÉ: Valide un numéro pour transfert externe avec support étendu
  static bool isValidExternalNumber(String phone) {
    String formatted = formatPhoneForDB(phone);

    if (formatted.isEmpty || formatted.length < 10) {
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
      '229', // Bénin
      '228', // Togo
      '225', // Côte d'Ivoire
      '221', // Sénégal
      '223', // Mali
      '226', // Burkina Faso
      '227', // Niger
      '33', // France
      '1', // USA/Canada
    ];

    // Vérifier si le numéro commence par un code pays supporté
    for (String code in supportedCountryCodes) {
      if (formatted.startsWith(code)) {
        // Vérifications supplémentaires selon le pays
        if (code == '242' || code == '243') {
          // Pour le Congo, vérifier les préfixes d'opérateurs mobile money
          return _hasValidMobileMoneyPrefix(formatted, code);
        }
        return true;
      }
    }

    return false;
  }

  /// NOUVELLE MÉTHODE: Vérifie si un numéro a un préfixe mobile money valide
  static bool _hasValidMobileMoneyPrefix(String phone, String countryCode) {
    if (countryCode == '242') {
      // Congo-Brazzaville: vérifier les préfixes des opérateurs
      String localPart = phone.substring(3);
      return localPart.startsWith('061') || // Moov
          localPart.startsWith('062') || // Airtel
          localPart.startsWith('063') || // Airtel
          localPart.startsWith('064') || // MTN
          localPart.startsWith('065') || // MTN
          localPart.startsWith('066') || // MTN
          localPart.startsWith('067'); // MTN
    }

    if (countryCode == '243') {
      // RDC: préfixes mobile money courants
      String localPart = phone.substring(3);
      return localPart.startsWith('081') || // Vodacom
          localPart.startsWith('082') || // Vodacom
          localPart.startsWith('083') || // Vodacom
          localPart.startsWith('084') || // Orange
          localPart.startsWith('085') || // Orange
          localPart.startsWith('089') || // Orange
          localPart.startsWith('097') || // Tigo
          localPart.startsWith('098') || // Tigo
          localPart.startsWith('099'); // Airtel
    }

    return true; // Pour les autres pays, accepter par défaut
  }

  /// 🔍 MODIFIÉ: Vérifie le statut d'un numéro (OnyFast ou externe) avec détails étendus
  static Future<Map<String, dynamic>> checkNumberStatus(String phone) async {
    try {
      String formattedPhone = formatPhoneForDB(phone);
      if (formattedPhone.isEmpty) {
        return {
          'isValid': false,
          'hasOnyfast': false,
          'isExternal': false,
          'message': 'Numéro invalide'
        };
      }

      // Vérifier si le numéro a un compte OnyFast
      final onyfastPhones = await checkOnyfastUsers([formattedPhone]);
      bool hasOnyfast = onyfastPhones.contains(formattedPhone);

      if (hasOnyfast) {
        return {
          'isValid': true,
          'hasOnyfast': true,
          'isExternal': false,
          'phone': formattedPhone,
          'message': 'Compte OnyFast trouvé',
          'transferType': 'onyfast',
          'country': _detectCountryFromPhone(formattedPhone),
        };
      } else if (isValidExternalNumber(formattedPhone)) {
        String provider = _detectMobileProvider(formattedPhone);
        String country = _detectCountryFromPhone(formattedPhone);

        return {
          'isValid': true,
          'hasOnyfast': false,
          'isExternal': true,
          'phone': formattedPhone,
          'message': 'Numéro externe valide pour transfert',
          'transferType': 'external',
          'provider': provider,
          'country': country,
          'estimatedDeliveryTime': '2-5 minutes',
        };
      } else {
        return {
          'isValid': false,
          'hasOnyfast': false,
          'isExternal': false,
          'message': 'Numéro non supporté pour les transferts',
          'suggestions': _getNumberSuggestions(phone),
        };
      }
    } catch (e) {
      print('❌ Erreur vérification statut numéro: $e');
      return {
        'isValid': false,
        'hasOnyfast': false,
        'isExternal': false,
        'message': 'Erreur de vérification'
      };
    }
  }

  /// NOUVELLE MÉTHODE: Obtient des suggestions pour un numéro invalide
  static List<String> _getNumberSuggestions(String phone) {
    List<String> suggestions = [];
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Si le numéro semble être congolais mais mal formaté
    if (cleaned.length >= 8 && cleaned.length <= 10) {
      if (!cleaned.startsWith('242') && !cleaned.startsWith('0')) {
        suggestions.add('242$cleaned'); // Ajouter code pays
        suggestions.add('2420$cleaned'); // Ajouter code pays + 0
      }

      if (cleaned.startsWith('0') && cleaned.length == 9) {
        suggestions.add('242$cleaned'); // Code pays + numéro avec 0
      }
    }

    return suggestions;
  }

  /// 📋 MODIFIÉ: Obtient les frais estimés pour un transfert avec détails du provider
  static Future<Map<String, dynamic>?> getEstimatedFees({
    required double amount,
    required bool isExternal,
    String? recipientId,
  }) async {
    try {
      final endpoint = isExternal ? 'external' : 'onyfast';
      var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
       var ip=await ValidationTokenController.to.getPublicIP();
      final response = await http
          .post(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/frais/estimate/$endpoint'),
            headers: _headers,
            body: jsonEncode({
              'ip':'ip',
              'amount': amount,
              "device":deviceskey,
              if (!isExternal && recipientId != null)
                'recipient_id': recipientId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'fees': data['fees'] ?? 0.0,
            'total': data['total'] ?? amount,
            'config': data['config'],
            'isExternal': isExternal,
            'transferType': isExternal ? 'external' : 'onyfast',
            'estimatedDeliveryTime': isExternal ? '2-5 minutes' : 'Immédiat',
          };
        }
      }
    } catch (e) {
      print('❌ Erreur estimation frais: $e');
    }
    return null;
  }

  /// 📱 Formate un numéro pour affichage utilisateur
  static String formatPhoneForDisplay(String phone) {
    if (phone.isEmpty) return phone;

    String formatted = formatPhoneForDB(phone);
    if (formatted.isEmpty) return phone;

    if (!formatted.startsWith('+')) {
      return '+$formatted';
    }

    return formatted;
  }

  /// 🔧 MODIFIÉ: Valide et suggère des corrections pour un numéro avec support externe
  static Map<String, dynamic> validateAndSuggestPhone(String phone) {
    String originalPhone = phone.trim();
    String formatted = formatPhoneForDB(originalPhone);

    Map<String, dynamic> result = {
      'original': originalPhone,
      'formatted': formatted,
      'isValid': formatted.isNotEmpty,
      'isValidForExternal': false,
      'suggestions': <String>[],
      'errors': <String>[],
      'supportedProviders': <String>[],
    };

    if (formatted.isNotEmpty) {
      // Vérifier si valide pour transfert externe
      result['isValidForExternal'] = isValidExternalNumber(formatted);

      if (result['isValidForExternal']) {
        result['provider'] = _detectMobileProvider(formatted);
        result['country'] = _detectCountryFromPhone(formatted);
        result['displayFormat'] = '+$formatted';
      }
    }

    if (formatted.isEmpty) {
      // Analyser les erreurs possibles et suggérer des corrections
      String cleaned = originalPhone.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');

      if (cleaned.isEmpty) {
        result['errors'].add('Numéro vide');
      } else if (cleaned.length < 8) {
        result['errors'].add('Numéro trop court (minimum 8 chiffres)');

        if (cleaned.length >= 6) {
          result['suggestions'].add('2420$cleaned');
        }
      } else if (cleaned.length > 15) {
        result['errors'].add('Numéro trop long (maximum 15 chiffres)');
      } else {
        result['errors'].add('Format non reconnu');

        if (!cleaned.startsWith('242') && !cleaned.startsWith('0')) {
          result['suggestions'].add('242$cleaned');
          result['suggestions'].add('2420$cleaned');
        }
      }
    } else {
      // Ajouter des informations sur les providers supportés
      if (formatted.startsWith('242')) {
        result['supportedProviders'] = [
          'MTN Mobile Money',
          'Airtel Money',
          'Moov Money'
        ];
      } else if (formatted.startsWith('243')) {
        result['supportedProviders'] = [
          'Vodacom M-Pesa',
          'Orange Money',
          'Airtel Money'
        ];
      }
    }

    return result;
  }

  /// 📊 MODIFIÉ: Statistiques des transferts par type avec détails des providers
  static Future<Map<String, dynamic>?> getTransferStatistics() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/transfers/statistics'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'onyfastTransfers': data['onyfast_transfers'] ?? 0,
            'externalTransfers': data['external_transfers'] ?? 0,
            'totalAmount': data['total_amount'] ?? 0.0,
            'averageFees': data['average_fees'] ?? 0.0,
            'monthlyStats': data['monthly_stats'] ?? {},
            'providerBreakdown': data['provider_breakdown'] ?? {},
            'countryBreakdown': data['country_breakdown'] ?? {},
            'successRate': data['success_rate'] ?? 0.0,
          };
        }
      }
    } catch (e) {
      print('❌ Erreur récupération statistiques: $e');
    }
    return null;
  }

  /// 🔄 Convertit un contact en format unifié
  static Map<String, dynamic> normalizeContactData(
      Map<String, dynamic> contact) {
    return {
      'id': contact['id'],
      'name': contact['name']?.toString().trim() ?? 'Contact',
      'phone': contact['phone']?.toString() ?? '',
      'display_phone':
          formatPhoneForDisplay(contact['phone']?.toString() ?? ''),
      'email': contact['email']?.toString().trim() ?? '',
      'avatar': contact['avatar']?.toString(),
      'has_onyfast': contact['has_onyfast'] == true,
      'is_online': contact['is_online'] == true,
      'last_seen': contact['last_seen'],
      'created_at': contact['created_at'],
      'phone_name': contact['phone_name']?.toString().trim(),
      'onyfast_name': contact['onyfast_name']?.toString().trim(),
      'original_phone': contact['original_phone']?.toString(),
      'transaction_count': contact['transaction_count'] ?? 0,
      'can_receive_external': contact['phone'] != null
          ? isValidExternalNumber(formatPhoneForDB(contact['phone']))
          : false,
      'mobile_provider': contact['phone'] != null
          ? _detectMobileProvider(contact['phone'])
          : null,
    };
  }

  /// 🎯 MODIFIÉ: Recherche unifiée de contacts (OnyFast + externes) avec support provider
  static Future<List<Map<String, dynamic>>> searchAllContacts(
      String query) async {
    List<Map<String, dynamic>> results = [];

    try {
      // Rechercher dans les contacts OnyFast
      final onyfastContacts = await searchContacts(query);
      for (var contact in onyfastContacts) {
        results.add({
          ...normalizeContactData(contact),
          'source': 'onyfast',
          'has_onyfast': true,
        });
      }

      // Rechercher des numéros externes valides
      if (query.length >= 8 && RegExp(r'^[\d\+\s\-\(\)\.]+$').hasMatch(query)) {
        String formatted = formatPhoneForDB(query);
        if (formatted.isNotEmpty && isValidExternalNumber(formatted)) {
          // Vérifier que ce numéro n'existe pas déjà dans les résultats
          bool alreadyExists =
              results.any((contact) => contact['phone'] == formatted);

          if (!alreadyExists) {
            String provider = _detectMobileProvider(formatted);
            String country = _detectCountryFromPhone(formatted);

            results.add({
              'id': null,
              'name': 'Contact externe ($provider)',
              'phone': formatted,
              'display_phone': formatPhoneForDisplay(formatted),
              'email': '',
              'avatar': null,
              'has_onyfast': false,
              'is_online': false,
              'source': 'external',
              'phone_name': query,
              'onyfast_name': null,
              'original_phone': query,
              'transaction_count': 0,
              'can_receive_external': true,
              'mobile_provider': provider,
              'country': country,
            });
          }
        }
      }

      print('🔍 Recherche "$query": ${results.length} résultats trouvés');
      return results;
    } catch (e) {
      print('❌ Erreur recherche unifiée: $e');
      return [];
    }
  }

  /// 💾 Cache des contacts favoris avec statut OnyFast et externe
  static Future<void> cacheFavoriteWithStatus(
      Map<String, dynamic> contact) async {
    try {
      List<Map<String, dynamic>> favorites = await getCachedFavorites() ?? [];

      int existingIndex = favorites.indexWhere((fav) =>
          fav['phone'] == contact['phone'] ||
          (fav['id'] != null && fav['id'] == contact['id']));

      Map<String, dynamic> favoriteData = {
        ...normalizeContactData(contact),
        'added_at': DateTime.now().toIso8601String(),
        'last_used': DateTime.now().toIso8601String(),
        'usage_count': 1,
      };

      if (existingIndex != -1) {
        favoriteData['usage_count'] =
            (favorites[existingIndex]['usage_count'] ?? 0) + 1;
        favoriteData['added_at'] = favorites[existingIndex]['added_at'];
        favorites[existingIndex] = favoriteData;
      } else {
        favorites.add(favoriteData);
      }

      favorites.sort((a, b) {
        DateTime dateA =
            DateTime.tryParse(a['last_used'] ?? '') ?? DateTime.now();
        DateTime dateB =
            DateTime.tryParse(b['last_used'] ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      if (favorites.length > 50) {
        favorites = favorites.take(50).toList();
      }

      _storage.write('cached_favorites', favorites);

      String type = contact['has_onyfast'] == true ? 'OnyFast' : 'externe';
      print('💾 Favori $type mis en cache: ${contact['name']}');
    } catch (e) {
      print('❌ Erreur cache favori: $e');
    }
  }

  /// 📥 Récupération des favoris mis en cache
  static Future<List<Map<String, dynamic>>?> getCachedFavorites() async {
    try {
      final cached = _storage.read('cached_favorites');
      if (cached != null) {
        return List<Map<String, dynamic>>.from(cached);
      }
    } catch (e) {
      print('❌ Erreur récupération favoris: $e');
    }
    return null;
  }

  /// 🗑️ Suppression d'un favori du cache
  static Future<void> removeCachedFavorite(String phone) async {
    try {
      List<Map<String, dynamic>> favorites = await getCachedFavorites() ?? [];
      favorites.removeWhere((fav) => fav['phone'] == phone);
      _storage.write('cached_favorites', favorites);
      print('🗑️ Favori supprimé du cache: $phone');
    } catch (e) {
      print('❌ Erreur suppression favori: $e');
    }
  }

  /// 📱 Récupère les contacts du téléphone avec permissions
  static Future<List<Contact>> getContacts(
      {bool withThumbnails = false}) async {
    if (!await FlutterContacts.requestPermission()) {
      throw Exception('Permission refusée pour lire les contacts.');
    }

    return await FlutterContacts.getContacts(
      withProperties: true,
      withThumbnail: withThumbnails,
    );
  }

  /// 📊 Calcul local des frais selon la logique du backend
  static double calculerFraisLocal(
      double montant, Map<String, dynamic> config) {
    double fraisMontant = 0;

    if (config['montant'] != null && config['montant'] != 0) {
      fraisMontant = double.tryParse(config['montant'].toString()) ?? 0;
    } else if (config['pourcentage'] != null && config['pourcentage'] != 0) {
      fraisMontant = (montant * config['pourcentage']) / 100;

      if (config['min'] != null && config['min'] != 0) {
        final minValue = double.tryParse(config['min'].toString()) ?? 0;
        if (minValue > 0) {
          fraisMontant = fraisMontant < minValue ? minValue : fraisMontant;
        }
      }

      if (config['max'] != null && config['max'] != 0) {
        final maxValue = double.tryParse(config['max'].toString()) ?? 0;
        if (maxValue > 0) {
          fraisMontant = fraisMontant > maxValue ? maxValue : fraisMontant;
        }
      }
    }

    return fraisMontant;
  }

  /// 🗑️ Nettoie le cache des contacts Onyfast
  static void clearContactsCache() {
    _storage.remove('onyfast_contacts');
    _storage.remove('onyfast_contacts_timestamp');
    print('🗑️ Cache contacts nettoyé');
  }

  /// 🧹 Nettoyage complet du cache
  static void clearAllCache() {
    clearContactsCache();
    _storage.remove('cached_favorites');
    _storage.remove('all_contacts_cache');
    _storage.remove('all_contacts_stats');
    _storage.remove('all_contacts_timestamp');
    print('🧹 Cache complet nettoyé');
  }

  /// 📱 Test pour vérifier la connectivité API
  static Future<bool> testApiConnectivity() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/health'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Test connectivité API échoué: $e');
      return false;
    }
  }

  /// 🔧 Validation robuste des données de transaction
  static Map<String, dynamic> validateTransactionData({
    required String phone,
    required double amount,
    required double fees,
    String? recipientId,
    bool isExternal = false,
  }) {
    List<String> errors = [];
    Map<String, dynamic> warnings = {};

    String formattedPhone = formatPhoneForDB(phone);
    if (formattedPhone.isEmpty) {
      errors.add('Numéro de téléphone invalide');
    }

    if (amount <= 0) {
      errors.add('Le montant doit être supérieur à 0');
    } else if (amount > 1000000) {
      warnings['amount'] = 'Montant très élevé, vérifiez la saisie';
    }

    if (fees < 0) {
      errors.add('Les frais ne peuvent pas être négatifs');
    } else if (fees > amount * 0.5) {
      warnings['fees'] = 'Frais très élevés par rapport au montant';
    }

    if (!isExternal && (recipientId == null || recipientId.isEmpty)) {
      errors.add('ID destinataire requis pour transfert OnyFast');
    }

    // NOUVEAU: Validations spécifiques aux transferts externes
    if (isExternal) {
      if (!isValidExternalNumber(formattedPhone)) {
        errors.add('Numéro non supporté pour transferts externes');
      } else {
        String provider = _detectMobileProvider(formattedPhone);
        if (provider.isEmpty || provider == 'Mobile Money') {
          warnings['provider'] = 'Opérateur mobile non identifié';
        }
      }
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'warnings': warnings,
      'formattedPhone': formattedPhone,
      'total': amount + fees,
      'isExternal': isExternal,
      'provider': isExternal ? _detectMobileProvider(formattedPhone) : null,
      'country': _detectCountryFromPhone(formattedPhone),
    };
  }

  /// 🔧 Utilitaires de validation et formatage

  /// Valide qu'un numéro est au format correct pour la BD
  static bool isValidPhoneNumber(String phone) {
    String formatted = formatPhoneForDB(phone);
    return formatted.isNotEmpty && formatted.length >= 10;
  }

  /// Extrait tous les numéros valides d'une liste de contacts
  static List<String> extractValidNumbers(List<String> phoneNumbers) {
    List<String> validNumbers = [];

    for (String phone in phoneNumbers) {
      String formatted = formatPhoneForDB(phone);
      if (formatted.isNotEmpty && !validNumbers.contains(formatted)) {
        validNumbers.add(formatted);
      }
    }

    return validNumbers;
  }

  /// Normalise un numéro pour la comparaison
  static String normalizeForComparison(String phone) {
    return formatPhoneForDB(phone);
  }

  /// 📊 MODIFIÉ: Analyse la répartition des contacts avec support externe
  static Map<String, dynamic> analyzeContacts(
      List<Map<String, dynamic>> contacts) {
    int totalContacts = contacts.length;
    int onyfastContacts = 0;
    int externalContacts = 0;
    int contactsWithPhones = 0;
    int contactsWithEmails = 0;
    int contactsOnline = 0;

    Map<String, int> phoneCountryCodes = {};
    Map<String, int> mobileProviders = {};

    for (var contact in contacts) {
      // Compter les contacts OnyFast
      if (contact['has_onyfast'] == true) {
        onyfastContacts++;
      }

      // Compter les contacts externes
      if (contact['can_receive_external'] == true) {
        externalContacts++;

        // Analyser les providers
        String provider = contact['mobile_provider'] ?? '';
        if (provider.isNotEmpty) {
          mobileProviders[provider] = (mobileProviders[provider] ?? 0) + 1;
        }
      }

      // Compter les contacts avec numéros
      if (contact['phone'] != null && contact['phone'].toString().isNotEmpty) {
        contactsWithPhones++;

        // Analyser les codes pays
        String phone = contact['phone'].toString();
        if (phone.length >= 3) {
          String countryCode = phone.substring(0, 3);
          phoneCountryCodes[countryCode] =
              (phoneCountryCodes[countryCode] ?? 0) + 1;
        }
      }

      // Compter les contacts avec emails
      if (contact['email'] != null && contact['email'].toString().isNotEmpty) {
        contactsWithEmails++;
      }

      // Compter les contacts en ligne
      if (contact['is_online'] == true) {
        contactsOnline++;
      }
    }

    return {
      'total_contacts': totalContacts,
      'onyfast_contacts': onyfastContacts,
      'external_contacts': externalContacts,
      'contacts_with_phones': contactsWithPhones,
      'contacts_with_emails': contactsWithEmails,
      'contacts_online': contactsOnline,
      'contacts_without_phones': totalContacts - contactsWithPhones,
      'onyfast_percentage': totalContacts > 0
          ? ((onyfastContacts / totalContacts) * 100).toStringAsFixed(1)
          : '0',
      'external_percentage': totalContacts > 0
          ? ((externalContacts / totalContacts) * 100).toStringAsFixed(1)
          : '0',
      'phones_percentage': totalContacts > 0
          ? ((contactsWithPhones / totalContacts) * 100).toStringAsFixed(1)
          : '0',
      'country_codes': phoneCountryCodes,
      'mobile_providers': mobileProviders,
      'most_common_country_code': phoneCountryCodes.isNotEmpty
          ? phoneCountryCodes.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key
          : null,
      'most_common_provider': mobileProviders.isNotEmpty
          ? mobileProviders.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key
          : null,
    };
  }

  /// 🔍 MODIFIÉ: Recherche avancée dans les contacts avec filtres externes
  static List<Map<String, dynamic>> advancedSearch(
    List<Map<String, dynamic>> contacts,
    String query, {
    bool onlyOnyfast = false,
    bool onlyExternal = false,
    bool onlyWithPhones = false,
    bool onlyOnline = false,
    String? providerFilter,
    String? countryFilter,
  }) {
    if (query.isEmpty &&
        !onlyOnyfast &&
        !onlyExternal &&
        !onlyWithPhones &&
        !onlyOnline &&
        providerFilter == null &&
        countryFilter == null) {
      return contacts;
    }

    return contacts.where((contact) {
      // Filtres de base
      if (onlyOnyfast && contact['has_onyfast'] != true) return false;
      if (onlyExternal && contact['can_receive_external'] != true) return false;
      if (onlyWithPhones &&
          (contact['phone'] == null || contact['phone'].toString().isEmpty))
        return false;
      if (onlyOnline && contact['is_online'] != true) return false;

      // NOUVEAU: Filtres par provider
      if (providerFilter != null &&
          contact['mobile_provider']?.toString() != providerFilter) {
        return false;
      }

      // NOUVEAU: Filtres par pays
      if (countryFilter != null &&
          contact['country']?.toString() != countryFilter) {
        return false;
      }

      // Recherche textuelle si query n'est pas vide
      if (query.isNotEmpty) {
        final searchQuery = query.toLowerCase();
        final name = contact['name']?.toString().toLowerCase() ?? '';
        final phoneName = contact['phone_name']?.toString().toLowerCase() ?? '';
        final onyfastName =
            contact['onyfast_name']?.toString().toLowerCase() ?? '';
        final phone = contact['phone']?.toString().toLowerCase() ?? '';
        final email = contact['email']?.toString().toLowerCase() ?? '';
        final provider =
            contact['mobile_provider']?.toString().toLowerCase() ?? '';

        return name.contains(searchQuery) ||
            phoneName.contains(searchQuery) ||
            onyfastName.contains(searchQuery) ||
            phone.contains(searchQuery) ||
            email.contains(searchQuery) ||
            provider.contains(searchQuery);
      }

      return true;
    }).toList();
  }

  /// 📋 MODIFIÉ: Trie les contacts selon différents critères avec support externe
  static List<Map<String, dynamic>> sortContacts(
    List<Map<String, dynamic>> contacts, {
    String sortBy =
        'name', // 'name', 'onyfast_first', 'external_first', 'phone', 'recent', 'provider'
    bool ascending = true,
  }) {
    List<Map<String, dynamic>> sortedContacts = List.from(contacts);

    switch (sortBy) {
      case 'onyfast_first':
        sortedContacts.sort((a, b) {
          // OnyFast en premier
          if (a['has_onyfast'] == true && b['has_onyfast'] != true) return -1;
          if (a['has_onyfast'] != true && b['has_onyfast'] == true) return 1;
          // Puis par nom
          return (a['name'] ?? '').compareTo(b['name'] ?? '');
        });
        break;

      case 'external_first':
        sortedContacts.sort((a, b) {
          // Externes en premier
          if (a['can_receive_external'] == true &&
              b['can_receive_external'] != true) return -1;
          if (a['can_receive_external'] != true &&
              b['can_receive_external'] == true) return 1;
          // Puis par nom
          return (a['name'] ?? '').compareTo(b['name'] ?? '');
        });
        break;

      case 'provider':
        sortedContacts.sort((a, b) {
          final providerA = a['mobile_provider']?.toString() ?? '';
          final providerB = b['mobile_provider']?.toString() ?? '';
          int providerComparison = ascending
              ? providerA.compareTo(providerB)
              : providerB.compareTo(providerA);

          // Si même provider, trier par nom
          if (providerComparison == 0) {
            return (a['name'] ?? '').compareTo(b['name'] ?? '');
          }
          return providerComparison;
        });
        break;

      case 'phone':
        sortedContacts.sort((a, b) {
          final phoneA = a['phone']?.toString() ?? '';
          final phoneB = b['phone']?.toString() ?? '';
          return ascending
              ? phoneA.compareTo(phoneB)
              : phoneB.compareTo(phoneA);
        });
        break;

      case 'recent':
        sortedContacts.sort((a, b) {
          final dateA = DateTime.tryParse(a['created_at']?.toString() ?? '');
          final dateB = DateTime.tryParse(b['created_at']?.toString() ?? '');
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        });
        break;

      case 'name':
      default:
        sortedContacts.sort((a, b) {
          final nameA = a['name']?.toString() ?? '';
          final nameB = b['name']?.toString() ?? '';
          return ascending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
        });
        break;
    }

    return sortedContacts;
  }

  /// 📱 MODIFIÉ: Valide et nettoie les données de contact avec support externe
  static Map<String, dynamic> sanitizeContact(Map<String, dynamic> contact) {
    String phone = contact['phone']?.toString() ?? '';
    String formattedPhone = formatPhoneForDB(phone);

    return {
      'id': contact['id'],
      'name': (contact['name']?.toString() ?? '').trim(),
      'phone': phone,
      'phone_display': formatPhoneForDisplay(phone),
      'original_phone': contact['original_phone']?.toString() ?? '',
      'email': (contact['email']?.toString() ?? '').trim().toLowerCase(),
      'avatar': contact['avatar']?.toString(),
      'has_onyfast': contact['has_onyfast'] == true,
      'is_online': contact['is_online'] == true,
      'last_seen': contact['last_seen'],
      'created_at': contact['created_at'],
      'phone_name': (contact['phone_name']?.toString() ?? '').trim(),
      'onyfast_name': (contact['onyfast_name']?.toString() ?? '').trim(),
      'can_receive_external': formattedPhone.isNotEmpty
          ? isValidExternalNumber(formattedPhone)
          : false,
      'mobile_provider': formattedPhone.isNotEmpty
          ? _detectMobileProvider(formattedPhone)
          : null,
      'country': formattedPhone.isNotEmpty
          ? _detectCountryFromPhone(formattedPhone)
          : null,
    };
  }

  /// NOUVELLE MÉTHODE: Obtient les providers mobile money supportés
  static Map<String, List<String>> getSupportedProviders() {
    return {
      'Congo-Brazzaville': ['MTN Mobile Money', 'Airtel Money', 'Moov Money'],
      'République Démocratique du Congo': [
        'Vodacom M-Pesa',
        'Orange Money',
        'Airtel Money'
      ],
      'Cameroun': ['MTN Mobile Money', 'Orange Money'],
      'Gabon': ['Airtel Money', 'Moov Money'],
      'International': ['Mobile Money']
    };
  }

  /// NOUVELLE MÉTHODE: Obtient les limites de transfert par provider
  static Map<String, dynamic> getTransferLimits(String provider) {
    Map<String, Map<String, dynamic>> limits = {
      'MTN Mobile Money': {
        'min_amount': 500,
        'max_amount': 1000000,
        'daily_limit': 5000000,
        'monthly_limit': 20000000,
        'currency': 'XAF'
      },
      'Airtel Money': {
        'min_amount': 100,
        'max_amount': 500000,
        'daily_limit': 2000000,
        'monthly_limit': 10000000,
        'currency': 'XAF'
      },
      'Moov Money': {
        'min_amount': 250,
        'max_amount': 750000,
        'daily_limit': 3000000,
        'monthly_limit': 15000000,
        'currency': 'XAF'
      },
      'Vodacom M-Pesa': {
        'min_amount': 1000,
        'max_amount': 2000000,
        'daily_limit': 10000000,
        'monthly_limit': 50000000,
        'currency': 'CDF'
      },
      'Orange Money': {
        'min_amount': 500,
        'max_amount': 1500000,
        'daily_limit': 8000000,
        'monthly_limit': 40000000,
        'currency': 'CDF'
      },
    };

    return limits[provider] ??
        {
          'min_amount': 100,
          'max_amount': 100000,
          'daily_limit': 500000,
          'monthly_limit': 2000000,
          'currency': 'XAF'
        };
  }

  /// NOUVELLE MÉTHODE: Vérifie si un montant respecte les limites
  static Map<String, dynamic> checkTransferLimits(
      String provider, double amount) {
    Map<String, dynamic> limits = getTransferLimits(provider);

    return {
      'isValid':
          amount >= limits['min_amount'] && amount <= limits['max_amount'],
      'min_amount': limits['min_amount'],
      'max_amount': limits['max_amount'],
      'currency': limits['currency'],
      'message': amount < limits['min_amount']
          ? 'Montant minimum: ${limits['min_amount']} ${limits['currency']}'
          : amount > limits['max_amount']
              ? 'Montant maximum: ${limits['max_amount']} ${limits['currency']}'
              : 'Montant valide',
    };
  }

  /// NOUVELLE MÉTHODE: Obtient le temps de livraison estimé
  static String getEstimatedDeliveryTime(String provider, String country) {
    if (country == 'Congo-Brazzaville') {
      if (provider.contains('MTN')) return '1-3 minutes';
      if (provider.contains('Airtel')) return '2-5 minutes';
      if (provider.contains('Moov')) return '2-4 minutes';
    }

    if (country == 'République Démocratique du Congo') {
      return '3-10 minutes';
    }

    return '5-15 minutes';
  }

  /// NOUVELLE MÉTHODE: Valide un transfert externe avant envoi
  static Future<Map<String, dynamic>> validateExternalTransfer({
    required String phone,
    required double amount,
  }) async {
    try {
      String formattedPhone = formatPhoneForDB(phone);

      if (!isValidExternalNumber(formattedPhone)) {
        return {
          'isValid': false,
          'error': 'Numéro non supporté pour transferts externes',
          'suggestions': _getNumberSuggestions(phone),
        };
      }

      String provider = _detectMobileProvider(formattedPhone);
      String country = _detectCountryFromPhone(formattedPhone);

      // Vérifier les limites de montant
      Map<String, dynamic> limitsCheck = checkTransferLimits(provider, amount);

      if (!limitsCheck['isValid']) {
        return {
          'isValid': false,
          'error': limitsCheck['message'],
          'limits': limitsCheck,
          'provider': provider,
        };
      }

      return {
        'isValid': true,
        'provider': provider,
        'country': country,
        'formatted_phone': formattedPhone,
        'display_phone': formatPhoneForDisplay(formattedPhone),
        'estimated_delivery': getEstimatedDeliveryTime(provider, country),
        'limits': limitsCheck,
      };
    } catch (e) {
      print('❌ Erreur validation transfert externe: $e');
      return {
        'isValid': false,
        'error': 'Erreur de validation',
      };
    }
  }

  /// NOUVELLE MÉTHODE: Obtient l'historique des transferts externes
  static Future<List<Map<String, dynamic>>> getExternalTransferHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
                '${ApiEnvironmentController.to.baseUrl}/transfers/external/history?limit=$limit&offset=$offset'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['transfers'] != null) {
          return List<Map<String, dynamic>>.from(data['transfers']);
        }
      }
    } catch (e) {
      print('❌ Erreur récupération historique: $e');
    }
    return [];
  }

  /// NOUVELLE MÉTHODE: Vérifie le statut d'un transfert externe
  static Future<Map<String, dynamic>?> checkExternalTransferStatus(
      String transactionId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/transfers/external/status/$transactionId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'status': data['status'],
            'message': data['message'],
            'updated_at': data['updated_at'],
            'provider_reference': data['provider_reference'],
          };
        }
      }
    } catch (e) {
      print('❌ Erreur vérification statut: $e');
    }
    return null;
  }
}
