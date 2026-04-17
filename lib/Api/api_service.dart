import 'dart:async';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/model/user_model.dart';

class ApiService {
  // static const String baseUrl = 'http://192.168.100.5:8001';
  static final GetStorage _storage = GetStorage();

  /// Headers par défaut avec authentification
  static Map<String, String> get _headers {
    final token = _storage.read('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Recherche un utilisateur par numéro de téléphone
  static Future<UserModel?> searchUserByPhone(String phone) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/users/search?phone=$phone'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          return UserModel.fromJson(data['user']);
        }
      } else if (response.statusCode == 404) {
        // Utilisateur non trouvé - retourner null sans erreur
        return null;
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur recherche utilisateur: $e');
      rethrow;
    }
    return null;
  }

  /// Vérifie quels numéros ont un compte OnyFast
  static Future<List<String>> checkOnyfastUsers(
      List<String> phoneNumbers) async {
    try {

      var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
      var ip=await ValidationTokenController.to.getPublicIP();
      final response = await http
          .post(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/users/check-onyfast'),
            headers: _headers,
            body: jsonEncode({
              'phones': phoneNumbers,
              'device': deviceskey,
              'ip':ip
              }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<String>.from(data['onyfast_phones'] ?? []);
        }
      }
    } catch (e) {
      print('❌ Erreur vérification contacts OnyFast: $e');
    }
    return [];
  }

  /// Calcule les frais pour un montant et un type de transaction
  static Future<Map<String, dynamic>?> calculerFrais({
    required double montant,
    required String type,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/frais/calculer?montant=$montant&type=$type'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['frais'] != null) {
          return {
            'frais': double.tryParse(data['frais'].toString()) ?? 0.0,
            'type': type,
            'montant': montant,
          };
        }
      } else if (response.statusCode == 404) {
        // Pas de configuration de frais trouvée
        return null;
      }
    } catch (e) {
      print('❌ Erreur calcul frais: $e');
    }
    return null;
  }

  /// Récupère la configuration des frais généraux
  static Future<Map<String, dynamic>?> getFraisConfig(String type) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/frais/config?type=$type'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['config'] != null) {
          return Map<String, dynamic>.from(data['config']);
        }
      } else if (response.statusCode == 404) {
        // Pas de configuration trouvée
        return null;
      }
    } catch (e) {
      print('❌ Erreur récupération config frais: $e');
    }
    return null;
  }

  /// Récupère la configuration des frais pour un utilisateur spécifique
  static Future<Map<String, dynamic>?> getUserFraisConfig({
    required int userId,
    required String type,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/frais/user/$userId?type=$type'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['config'] != null) {
          return Map<String, dynamic>.from(data['config']);
        }
      } else if (response.statusCode == 404) {
        // Pas de configuration spécifique trouvée
        return null;
      }
    } catch (e) {
      print('❌ Erreur récupération frais utilisateur: $e');
    }
    return null;
  }

  /// Traite une transaction C2C
  static Future<Map<String, dynamic>> processC2CTransaction({
    required String recipientId,
    required double amount,
    required double fees,
  }) async {
    try {
            var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
            var ip=ValidationTokenController.to.getPublicIP();

      final response = await http
          .post(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/transactions/c2c'),
            headers: _headers,
            body: jsonEncode({
              'recipient_id': recipientId,
              'amount': amount,
              'fees': fees,
              'total': amount + fees,
              'type': 'c2c',
              'device':deviceskey,
              'ip':ip
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'transactionId': data['transaction_id'] ?? data['id'],
          'message': data['message'] ?? 'Transaction réussie',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la transaction',
          'error_code': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Erreur transaction: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion lors de la transaction',
      };
    }
  }

  /// Récupère les contacts OnyFast
  static Future<List<Map<String, dynamic>>> getOnyfastContacts() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/contacts/onyfast'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['contacts'] != null) {
          final contacts = List<Map<String, dynamic>>.from(data['contacts']);

          // Transformer les données pour correspondre au format attendu
          return contacts
              .map((contact) => {
                    'id': contact['user_id'] ?? contact['id'],
                    'name': contact['name'] ?? 'Nom inconnu',
                    'phone': contact['telephone'] ?? contact['phone'] ?? '',
                    'email': contact['email'] ?? '',
                    'avatar': contact['avatar'] ?? contact['profile_picture'],
                    'is_online': contact['is_online'] ?? false,
                    'last_seen': contact['last_seen'],
                    'created_at': contact['created_at'],
                  })
              .toList();
        }
      } else if (response.statusCode == 404) {
        // Pas de contacts trouvés
        return [];
      }
    } catch (e) {
      print('❌ Erreur récupération contacts OnyFast: $e');
      rethrow;
    }
    return [];
  }

  /// Recherche dans les contacts OnyFast
  static Future<List<Map<String, dynamic>>> searchOnyfastContacts(
      String query) async {
    try {
      final response = await http
          .get(
            Uri.parse(
                '${ApiEnvironmentController.to.baseUrl}/contacts/onyfast/search?q=${Uri.encodeQueryComponent(query)}'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['contacts'] != null) {
          final contacts = List<Map<String, dynamic>>.from(data['contacts']);

          return contacts
              .map((contact) => {
                    'id': contact['user_id'] ?? contact['id'],
                    'name': contact['name'] ?? 'Nom inconnu',
                    'phone': contact['telephone'] ?? contact['phone'] ?? '',
                    'email': contact['email'] ?? '',
                    'avatar': contact['avatar'] ?? contact['profile_picture'],
                    'is_online': contact['is_online'] ?? false,
                    'last_seen': contact['last_seen'],
                    'created_at': contact['created_at'],
                  })
              .toList();
        }
      }
    } catch (e) {
      print('❌ Erreur recherche contacts: $e');
      rethrow;
    }
    return [];
  }
}
