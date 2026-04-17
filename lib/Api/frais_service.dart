import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

class FraisService {
  static final GetStorage _storage = GetStorage();

  // Durée de validité du cache (en millisecondes)
  static const int CACHE_DURATION = 24 * 60 * 60 * 1000; // 24 heures
  static const int QUICK_CACHE_DURATION =
      60 * 60 * 1000; // 1 heure pour les échecs
  static const int DESTINATAIRE_CACHE_DURATION =
      30 * 60 * 1000; // 30 minutes pour les frais destinataire

  /// Récupère les informations de frais avec stratégie de cache intelligente
  static Future<Map<String, dynamic>?> getFraisConfig(String type,
      {String? destinataire}) async {
    // Si un destinataire est spécifié, utiliser une clé de cache spécifique
    final String cacheKey = destinataire != null
        ? 'frais_config_${type}_$destinataire'
        : 'frais_config_$type';
    final String timestampKey = destinataire != null
        ? 'frais_config_${type}_${destinataire}_timestamp'
        : 'frais_config_${type}_timestamp';
    final String failureKey = destinataire != null
        ? 'frais_config_${type}_${destinataire}_last_failure'
        : 'frais_config_${type}_last_failure';

    // Durée de cache adaptée selon le type
    final cacheDuration =
        destinataire != null ? DESTINATAIRE_CACHE_DURATION : CACHE_DURATION;

    // Vérifier d'abord le cache local
    final cachedConfig = _storage.read(cacheKey);
    final cachedTimestamp = _storage.read(timestampKey) ?? 0;
    final lastFailure = _storage.read(failureKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Si on a un cache valide, l'utiliser
    final isValidCache =
        cachedConfig != null && (now - cachedTimestamp) < cacheDuration;

    // Si échec récent (moins d'1h), utiliser cache même expiré
    final recentFailure = (now - lastFailure) < QUICK_CACHE_DURATION;

    if (isValidCache) {
      print(
          '✅ Configuration des frais depuis le cache (valide) - ${destinataire ?? type}');
      return Map<String, dynamic>.from(cachedConfig);
    }

    if (cachedConfig != null && recentFailure) {
      print(
          '⚠️ Utilisation du cache expiré (échec récent) - ${destinataire ?? type}');
      return Map<String, dynamic>.from(cachedConfig);
    }

    // Essayer de récupérer depuis l'API
    try {
      final config = await _fetchFromAPI(type, destinataire: destinataire);

      if (config != null) {
        // Sauvegarder en cache
        _storage.write(cacheKey, config);
        _storage.write(timestampKey, now);
        _storage.remove(failureKey); // Supprimer le marqueur d'échec

        print(
            '✅ Configuration des frais depuis l\'API et mise en cache - ${destinataire ?? type}');
        return config;
      }
    } catch (e) {
      print('❌ Erreur API: $e');
      // Marquer l'échec pour éviter les tentatives répétées
      _storage.write(failureKey, now);
    }

    // En dernier recours, utiliser le cache expiré s'il existe
    if (cachedConfig != null) {
      print(
          '⚠️ Utilisation du cache expiré en dernier recours - ${destinataire ?? type}');
      return Map<String, dynamic>.from(cachedConfig);
    }

    print('❌ Aucune configuration disponible - ${destinataire ?? type}');
    return null;
  }

  /// Appel API isolé avec support du destinataire
  // static Future<Map<String, dynamic>?> _fetchFromAPI(String type,
  //     {String? destinataire}) async {
  //   final String? bearerToken = _storage.read('token');

  //   // Construire l'URL avec le destinataire si fourni
  //   String url = '$baseUrl/frais/config?type=$type';
  //   if (destinataire != null && destinataire.isNotEmpty) {
  //     url += '&destinataire=${Uri.encodeComponent(destinataire)}';
  //   }

  //   print('🌐 Appel API: $url');

  //   final response = await http.get(
  //     Uri.parse(url),
  //     headers: {
  //       'Accept': 'application/json',
  //       'Authorization': 'Bearer $bearerToken',
  //     },
  //   ).timeout(
  //     const Duration(seconds: 8), // Timeout réduit
  //     onTimeout: () {
  //       throw TimeoutException(
  //           'Timeout de connexion', const Duration(seconds: 8));
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     print('📥 Réponse API reçue: ${data['config']}');
  //     return data['config'];
  //   } else {
  //     throw Exception('HTTP ${response.statusCode}: ${response.body}');
  //   }
  // }

  static Future<Map<String, dynamic>?> _fetchFromAPI(String type,
      {String? destinataire}) async {
    final String? bearerToken = _storage.read('token');

    // Construire l'URL avec les paramètres dans le chemin
    String url = '${ApiEnvironmentController.to.baseUrl}/frais/user/config/$type/$destinataire';

    print('🌐 Appel API: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      },
    ).timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        throw TimeoutException(
            'Timeout de connexion', const Duration(seconds: 8));
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('📥 Réponse API reçue: ${data['config']}');
      return data['config'];
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  /// Récupère les frais spécifiques pour un destinataire
  static Future<Map<String, dynamic>?> getFraisForDestinataire(
      String destinataire) async {
    print('🎯 Récupération des frais pour le destinataire: $destinataire');

    // Nettoyer le numéro de téléphone (supprimer espaces, tirets, etc.)
    final cleanDestinataire = _cleanPhoneNumber(destinataire);

    return await getFraisConfig('TRANSFERT', destinataire: cleanDestinataire);
  }

  /// Nettoie un numéro de téléphone
  static String _cleanPhoneNumber(String phoneNumber) {
    // Supprimer tous les caractères non numériques sauf le +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Normaliser le format (+237 -> +237)
    if (cleaned.startsWith('00242')) {
      cleaned = '+242${cleaned.substring(5)}';
    } else if (cleaned.startsWith('242') && !cleaned.startsWith('+242')) {
      cleaned = '+$cleaned';
    }

    return cleaned;
  }

  /// Calcule les frais localement basé sur la configuration
  static double calculerFraisLocal(
      double montant, Map<String, dynamic> config) {
    try {
      final double? montantFixe = config['montant']?.toDouble();
      final double? pourcentage = config['pourcentage']?.toDouble();
      final double? min = config['min']?.toDouble();
      final double? max = config['max']?.toDouble();

      double frais = 0.0;

      // Calcul selon le type de frais
      if (montantFixe != null && montantFixe > 0) {
        // Frais fixe
        frais = montantFixe;
        print('💰 Frais fixe appliqué: $frais FCFA');
      } else if (pourcentage != null && pourcentage > 0) {
        // Frais en pourcentage
        frais = (montant * pourcentage) / 100;
        print('💰 Frais en pourcentage ($pourcentage%): $frais FCFA');
      }

      // Application des limites min/max
      if (min != null && frais < min) {
        print('⬆️ Application du minimum: $min FCFA (était $frais)');
        frais = min;
      }
      if (max != null && frais > max) {
        print('⬇️ Application du maximum: $max FCFA (était $frais)');
        frais = max;
      }

      print('✅ Frais final calculé: $frais FCFA pour $montant FCFA');
      return frais;
    } catch (e) {
      print('❌ Erreur lors du calcul des frais: $e');
      return 0.0;
    }
  }

  /// Force le rechargement de la configuration depuis l'API
  static Future<Map<String, dynamic>?> forceReloadConfig(String type,
      {String? destinataire}) async {
    final String cacheKey = destinataire != null
        ? 'frais_config_${type}_$destinataire'
        : 'frais_config_$type';
    final String timestampKey = destinataire != null
        ? 'frais_config_${type}_${destinataire}_timestamp'
        : 'frais_config_${type}_timestamp';
    final String failureKey = destinataire != null
        ? 'frais_config_${type}_${destinataire}_last_failure'
        : 'frais_config_${type}_last_failure';

    // Supprimer tout le cache pour ce type/destinataire
    _storage.remove(cacheKey);
    _storage.remove(timestampKey);
    _storage.remove(failureKey);

    print('🔄 Rechargement forcé depuis l\'API... ${destinataire ?? type}');

    try {
      final config = await _fetchFromAPI(type, destinataire: destinataire);

      if (config != null) {
        // Sauvegarder immédiatement en cache
        final now = DateTime.now().millisecondsSinceEpoch;
        _storage.write(cacheKey, config);
        _storage.write(timestampKey, now);

        print(
            '✅ Rechargement réussi et mis en cache - ${destinataire ?? type}');
        return config;
      }
    } catch (e) {
      print('❌ Échec du rechargement forcé: $e');
      // Marquer l'échec
      _storage.write(failureKey, DateTime.now().millisecondsSinceEpoch);
    }

    return null;
  }

  /// Vérifie si la configuration est en cache et récente
  static bool isConfigCached(String type, {String? destinataire}) {
    final cacheKey = destinataire != null
        ? 'frais_config_${type}_$destinataire'
        : 'frais_config_$type';
    final timestampKey = destinataire != null
        ? 'frais_config_${type}_${destinataire}_timestamp'
        : 'frais_config_${type}_timestamp';

    final cachedConfig = _storage.read(cacheKey);
    if (cachedConfig == null) return false;

    final timestamp = _storage.read(timestampKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheDuration =
        destinataire != null ? DESTINATAIRE_CACHE_DURATION : CACHE_DURATION;

    return (now - timestamp) < cacheDuration;
  }

  /// Nettoie le cache pour un type spécifique
  static void clearCache(String type, {String? destinataire}) {
    if (destinataire != null) {
      _storage.remove('frais_config_${type}_$destinataire');
      _storage.remove('frais_config_${type}_${destinataire}_timestamp');
      _storage.remove('frais_config_${type}_${destinataire}_last_failure');
      print('🗑️ Cache nettoyé pour $type - $destinataire');
    } else {
      _storage.remove('frais_config_$type');
      _storage.remove('frais_config_${type}_timestamp');
      _storage.remove('frais_config_${type}_last_failure');
      print('🗑️ Cache nettoyé pour $type');
    }
  }

  /// Nettoie tout le cache des frais
  static void clearAllCache() {
    final keys = _storage.getKeys().toList(); // ✅ Créer une copie
    final keysToRemove = <String>[];

    for (String key in keys) {
      if (key.startsWith('frais_config_')) {
        keysToRemove.add(key);
      }
    }

    for (String key in keysToRemove) {
      _storage.remove(key);
    }
    print('🗑️ Tout le cache des frais nettoyé');
  }

  /// Nettoie le cache des frais destinataire expiré
  static void cleanExpiredDestinataireCache() {
    final keys = _storage
        .getKeys()
        .toList(); // ✅ Créer une copie pour éviter concurrent modification
    final now = DateTime.now().millisecondsSinceEpoch;
    final keysToRemove = <String>[];

    // 1. Identifier les clés à supprimer (sans modification)
    for (String key in keys) {
      if (key.startsWith('frais_config_TRANSFERT_') &&
          key.contains('_timestamp')) {
        final timestamp = _storage.read(key) ?? 0;
        if ((now - timestamp) > DESTINATAIRE_CACHE_DURATION) {
          final baseKey = key.replaceAll('_timestamp', '');
          keysToRemove.addAll([baseKey, key, '${baseKey}_last_failure']);
        }
      }
    }

    // 2. Supprimer les clés après l'itération
    for (String keyToRemove in keysToRemove) {
      _storage.remove(keyToRemove);
      print('🗑️ Cache destinataire expiré supprimé: $keyToRemove');
    }
  }

  /// Informations de debug sur le cache
  static Map<String, dynamic> getCacheInfo(String type,
      {String? destinataire}) {
    final cacheKey = destinataire != null
        ? 'frais_config_${type}_$destinataire'
        : 'frais_config_$type';
    final timestampKey = destinataire != null
        ? 'frais_config_${type}_${destinataire}_timestamp'
        : 'frais_config_${type}_timestamp';
    final failureKey = destinataire != null
        ? 'frais_config_${type}_${destinataire}_last_failure'
        : 'frais_config_${type}_last_failure';

    final cachedConfig = _storage.read(cacheKey);
    final timestamp = _storage.read(timestampKey) ?? 0;
    final lastFailure = _storage.read(failureKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheDuration =
        destinataire != null ? DESTINATAIRE_CACHE_DURATION : CACHE_DURATION;

    return {
      'hasCache': cachedConfig != null,
      'isValid': cachedConfig != null && (now - timestamp) < cacheDuration,
      'ageMinutes':
          timestamp > 0 ? ((now - timestamp) / (60 * 1000)).round() : 0,
      'lastFailureMinutes':
          lastFailure > 0 ? ((now - lastFailure) / (60 * 1000)).round() : 0,
      'config': cachedConfig,
      'destinataire': destinataire,
      'cacheType': destinataire != null ? 'destinataire' : 'general',
    };
  }

  /// Obtient tous les frais en cache pour debug
  static List<Map<String, dynamic>> getAllCachedFrais() {
    final keys = _storage.getKeys().toList(); // ✅ Créer une copie
    final List<Map<String, dynamic>> cachedFrais = [];

    for (String key in keys) {
      if (key.startsWith('frais_config_') &&
          !key.contains('_timestamp') &&
          !key.contains('_last_failure')) {
        final config = _storage.read(key);
        final timestamp = _storage.read('${key}_timestamp') ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;

        cachedFrais.add({
          'key': key,
          'config': config,
          'ageMinutes':
              timestamp > 0 ? ((now - timestamp) / (60 * 1000)).round() : 0,
          'isExpired':
              timestamp > 0 ? (now - timestamp) > CACHE_DURATION : true,
        });
      }
    }

    return cachedFrais;
  }
}
