import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/frais_service.dart';
import 'package:onyfast/Controller/rechargewalletcontroller.dart';

class FraisController extends GetxController {
  var frais = 0.0.obs;
  var total = 0.0.obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var currentDestinataire = ''.obs;

  // Configuration des frais stockée localement
  Map<String, dynamic>? _fraisConfig;
  String? _configDestinataire;

  @override
  void onInit() {
    super.onInit();
    // Charger la configuration des frais générale au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFraisConfig();

      // Nettoyer les caches expirés de manière sécurisée
      try {
        FraisService.cleanExpiredDestinataireCache();
      } catch (e) {
        print('Erreur lors du nettoyage du cache: $e');
      }
    });
  }

  /// Charge la configuration des frais avec cache intelligent
  Future<void> _loadFraisConfig({String? destinataire}) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      print(
          '🔄 Chargement config frais - Destinataire: ${destinataire ?? "général"}');

      _fraisConfig = await FraisService.getFraisConfig('TRANSFERT',
          destinataire: destinataire);
      _configDestinataire = destinataire;

      if (_fraisConfig != null) {
        print('✅ Configuration des frais disponible: $_fraisConfig');
        hasError.value = false;
        errorMessage.value = '';

        // Afficher les infos de cache pour debug
        final cacheInfo =
            FraisService.getCacheInfo('TRANSFERT', destinataire: destinataire);
        print('📊 Info cache: $cacheInfo');
      } else {
        hasError.value = true;
        errorMessage.value = destinataire != null
            ? 'Frais indisponibles pour ce destinataire'
            : 'Configuration des frais non disponible. Vérifiez votre connexion.';
        print('❌ Aucune configuration des frais disponible');
      }
    } catch (e) {
      print('❌ Erreur lors du chargement de la configuration des frais: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur de chargement des frais.';
      _fraisConfig = null;
      _configDestinataire = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Charge les frais spécifiques pour un destinataire après scan QR
  Future<void> loadFraisForDestinataire(String destinataire) async {
    if (destinataire.isEmpty) {
      print('⚠️ Destinataire vide, chargement des frais généraux');
      await _loadFraisConfig();
      return;
    }

    currentDestinataire.value = destinataire;
    print('🎯 Chargement des frais pour destinataire: $destinataire');

    await _loadFraisConfig(destinataire: destinataire);

    // Si on a un montant en cours, recalculer les frais
    final montantActuel = Get.find<RechargeWalletController>().montant.value;
    if (montantActuel >= 25 && _fraisConfig != null) {
      calculerFrais(montantActuel);
    }
  }

  /// Calcule les frais localement (instantané) - SEULEMENT si config disponible
  void calculerFrais(double montant) {
    if (_fraisConfig == null) {
      print('⚠️ Pas de configuration disponible pour calculer les frais');
      frais.value = 0.0;
      total.value = montant;
      return;
    }

    _performCalculation(montant);
  }

  void _performCalculation(double montant) {
    final fraisCalcules =
        FraisService.calculerFraisLocal(montant, _fraisConfig!);
    frais.value = fraisCalcules;
    total.value = montant + fraisCalcules;

    final destinataireInfo = _configDestinataire != null
        ? ' (destinataire: $_configDestinataire)'
        : '';
    print(
        '💰 Frais calculés: $fraisCalcules FCFA pour $montant FCFA (Total: ${total.value} FCFA)$destinataireInfo');
  }

  /// Recharge la configuration des frais
  Future<void> reloadFraisConfig() async {
    await _loadFraisConfig(destinataire: _configDestinataire);
  }

  /// Force le rechargement depuis l'API (ignore le cache)
  Future<void> forceReloadConfig() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      print('🔄 Rechargement forcé des frais...');
      _fraisConfig = await FraisService.forceReloadConfig('TRANSFERT',
          destinataire: _configDestinataire);

      if (_fraisConfig != null) {
        print('✅ Configuration rechargée: $_fraisConfig');
        clearError();
      } else {
        hasError.value = true;
        errorMessage.value = 'Échec du rechargement. Serveur indisponible.';
      }
    } catch (e) {
      print('❌ Erreur lors du rechargement forcé: $e');
      hasError.value = true;
      errorMessage.value = 'Erreur de connexion lors du rechargement.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Nettoie le cache et recharge
  Future<void> clearCacheAndReload() async {
    FraisService.clearCache('TRANSFERT', destinataire: _configDestinataire);
    await _loadFraisConfig(destinataire: _configDestinataire);
  }

  /// Reset les valeurs et revient aux frais généraux
  void reset() {
    frais.value = 0.0;
    total.value = 0.0;
    currentDestinataire.value = '';

    // Recharger les frais généraux si on avait des frais spécifiques
    if (_configDestinataire != null) {
      _configDestinataire = null;
      _loadFraisConfig();
    }
  }

  /// Reset seulement les montants (garde la config destinataire)
  void resetAmounts() {
    frais.value = 0.0;
    total.value = 0.0;
  }

  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }

  /// Getter pour vérifier si la configuration est chargée
  bool get isConfigLoaded => _fraisConfig != null;

  /// Getter pour vérifier si on peut effectuer des transactions
  bool get canPerformTransaction => _fraisConfig != null && !isLoading.value;

  /// Getter pour obtenir les détails de la configuration
  Map<String, dynamic>? get configDetails => _fraisConfig;

  /// Getter pour savoir si on utilise le cache
  bool get isUsingCache {
    if (!isConfigLoaded) return false;
    return FraisService.isConfigCached('TRANSFERT',
        destinataire: _configDestinataire);
  }

  /// Getter pour obtenir le message d'état avec icônes
  String get statusMessage {
    if (isLoading.value) return '⏳ Chargement des frais...';
    if (hasError.value) return '❌ ${errorMessage.value}';
    if (_fraisConfig != null) {
      String baseMessage =
          isUsingCache ? '📱 Frais (cache)' : '🌐 Frais (serveur)';
      if (_configDestinataire != null) {
        baseMessage += ' - Spécifique';
      }
      return baseMessage;
    }
    return '⚠️ Configuration non disponible';
  }

  /// Getter pour obtenir les informations de debug
  String get debugInfo {
    if (_fraisConfig == null) return 'Aucune config';

    final montant = _fraisConfig!['montant'];
    final pourcentage = _fraisConfig!['pourcentage'];
    final min = _fraisConfig!['min'];
    final max = _fraisConfig!['max'];

    String configInfo = '';
    if (montant != null) {
      configInfo = 'Fixe: $montant FCFA';
    } else if (pourcentage != null) {
      configInfo = '$pourcentage% (min: $min, max: $max)';
    } else {
      configInfo = 'Config invalide';
    }

    // Ajouter info destinataire si applicable
    if (_configDestinataire != null) {
      configInfo +=
          ' [${_configDestinataire!.substring(0, _configDestinataire!.length > 8 ? 8 : _configDestinataire!.length)}...]';
    }

    return configInfo;
  }

  /// Getter pour les informations complètes de cache
  Map<String, dynamic> get cacheInfo =>
      FraisService.getCacheInfo('TRANSFERT', destinataire: _configDestinataire);

  /// Getter pour l'âge du cache en minutes
  int get cacheAgeMinutes => cacheInfo['ageMinutes'] ?? 0;

  /// Getter pour vérifier si le cache est valide
  bool get isCacheValid => cacheInfo['isValid'] ?? false;

  /// Getter pour savoir si on a des frais spécifiques au destinataire
  bool get hasDestinataireSpecificFrais =>
      _configDestinataire != null && _configDestinataire!.isNotEmpty;

  /// Getter pour obtenir le destinataire actuel
  String get currentDestinataireNumber => _configDestinataire ?? '';

  /// Méthode pour obtenir des infos de debug étendues
  Map<String, dynamic> get extendedDebugInfo => {
        'configLoaded': isConfigLoaded,
        'hasDestinataire': hasDestinataireSpecificFrais,
        'destinataire': _configDestinataire,
        'config': _fraisConfig,
        'cacheInfo': cacheInfo,
        'allCachedFrais': FraisService.getAllCachedFrais(),
      };
}
