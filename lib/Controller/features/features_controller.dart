// features_enum.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

/// Enum des features disponibles sur l'API
enum AppFeature {
  rechargeMomo('recharge_momo', 'Recharge MTN MoMo'),
  rechargeAirtelMoney('recharge_aitel_money', 'Recharge Airtel Money'),
  depotWalletCarte('depot_wallet_carte', 'Dépôt Wallet vers Carte'),
  depotCarteWallet('depot_carte_wallet', 'Dépôt Carte vers Wallet'),
  retraitWalletCarte('retrait_wallet_carte', 'Retrait Wallet vers Carte'),
  retraitCarteWallet('retrait_carte_wallet', 'Retrait Carte vers Wallet'),
  ajoutCartePhysique('ajout_carte_physique', 'Ajout de la carte physique'),
  emissionCarteVirtuelle('emission_carte_virtuelle', 'Émission de la carte virtuelle'),
  transfertWalletWalletLocal('transfert_wallet_wallet_local', 'Transfert Wallet vers Wallet Local'),
  transfertWalletWalletInternational('transfert_wallet_wallet_international', 'Transfert Wallet vers Wallet International'),
  transfertWalletNumeroLocal('transfert_wallet_numero_local', 'Transfert Wallet vers Numéro Local'),
  uploadPieceIdentite('upload_piece_identite', 'Upload Pièce d\'identité'),
  uploadJustificatifDomicile('upload_justificatif_domicile', 'Upload Justificatif de domicile'),
  payementFactureCongoTelecom('payement_facture_congo_telecom', 'Payement Facture CongoTelecom'),
  ///
  otpWhatssap('otp_whatssap','Message otp Whatssap'),
  otpTelephone('otp_telephone','message otp telephone'),
  connexionAppClient('connexion_app_client','Connexion Wallet App Client'),
  inscriptionAppClient('inscription_app_client','Inscription Wallet App client'),
  payementMarchands('payement_marchands',"Payement Marchands Wallet"),
  payementAbonnement('payement_abonnement','Prendre Abonnement Depuis App Client'),
  modificationMdpClient('modification_mdp_client',"Modification Mot de Passe Depuis App Client"),
  chatIA('chat_ia','Chat IA'),
  
  ;

  final String key;
  final String displayName;

  const AppFeature(this.key, this.displayName);

  /// Récupère une feature depuis sa clé
  static AppFeature? fromKey(String key) {
    try {
      return AppFeature.values.firstWhere((f) => f.key == key);
    } catch (_) {
      return null;
    }
  }

  /// URL de l'endpoint pour cette feature
  String get endpoint => '${ApiEnvironmentController.to.baseUrl}/features/$key';
}

/// Modèle de réponse d'une feature
class FeatureData {
  final int id;
  final String key;
  final String name;
  final String description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FeatureData({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory FeatureData.fromJson(Map<String, dynamic> json) {
    return FeatureData(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Service pour gérer les features
class FeaturesService {
  final Dio _dio;
  final GetStorage _storage;
  static final String _baseUrl = ApiEnvironmentController.to.baseUrl;

  FeaturesService({Dio? dio, GetStorage? storage})
      : _dio = dio ?? Dio(),
        _storage = storage ?? GetStorage();

  /// Headers pour les requêtes authentifiées
  Map<String, String> get _headers {
    final token = _storage.read('token');
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// Récupère toutes les features
  Future<FeaturesResult> getAllFeatures() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/features',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<FeatureData> features = (data['data'] as List)
              .map((json) => FeatureData.fromJson(json))
              .toList();
          return FeaturesResult.success(features);
        }
      }
      return FeaturesResult.error('Échec de récupération des features');
    } catch (e) {
      return FeaturesResult.error('Erreur: $e');
    }
  }

  /// Récupère une feature spécifique par son enum
  Future<FeatureResult> getFeature(AppFeature feature) async {
    try {
      final response = await _dio.get(
        feature.endpoint,
        options: Options(headers: _headers),
      );


      print('✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅voila la reponse $response');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final featureData = FeatureData.fromJson(data['data']);
          return FeatureResult.success(featureData);
        }
      }
      return FeatureResult.error('Échec de récupération de la feature');
    }on SocketException {
  // Cas de non-connexion Internet
  return FeatureResult.error("Pas de connexion Internet. Vérifiez votre réseau.");
} 
    
    
    catch (e) {
      
      return FeatureResult.error('Erreur: $e');
    }
  }

  /// Vérifie si une feature est active
  Future<bool> isFeatureActive(AppFeature feature) async {
    final result = await getFeature(feature);
    return result.when(
      success: (data) => data.isActive,
      error: (_) => false,
      
    );
  }

  /// Vérifie plusieurs features en une seule requête
  Future<Map<AppFeature, bool>> checkMultipleFeatures(
    List<AppFeature> features,
  ) async {
    final result = await getAllFeatures();
    return result.when(
      success: (allFeatures) {
        final Map<AppFeature, bool> statusMap = {};
        for (final feature in features) {
          final featureData = allFeatures.firstWhere(
            (f) => f.key == feature.key,
            orElse: () => FeatureData(
              id: 0,
              key: feature.key,
              name: feature.displayName,
              description: '',
              isActive: false,
            ),
          );
          statusMap[feature] = featureData.isActive;
        }
        return statusMap;
      },
      error: (_) {
        return {for (final f in features) f: false};
      },
    );
  }
}

/// Résultat pour une seule feature
class FeatureResult {
  final FeatureData? data;
  final String? error;

  FeatureResult.success(this.data) : error = null;
  FeatureResult.error(this.error) : data = null;

  bool get isSuccess => data != null;
  bool get isError => error != null;

  T when<T>({
    required T Function(FeatureData data) success,
    required T Function(String error) error,
  }) {
    if (isSuccess) return success(data!);
    return error(this.error!);
  }
}

/// Résultat pour plusieurs features
class FeaturesResult {
  final List<FeatureData>? data;
  final String? error;

  FeaturesResult.success(this.data) : error = null;
  FeaturesResult.error(this.error) : data = null;

  bool get isSuccess => data != null;
  bool get isError => error != null;

  T when<T>({
    required T Function(List<FeatureData> data) success,
    required T Function(String error) error,
  }) {
    if (isSuccess) return success(data!);
    return error(this.error!);
  }
}

// ==================== EXEMPLES D'UTILISATION ====================

/// Exemple 1: Vérifier une feature spécifique
Future<void> exempleVerifierFeature() async {
  final service = FeaturesService();
  
  final result = await service.getFeature(AppFeature.emissionCarteVirtuelle);
  
  result.when(
    success: (feature) {
      print('✅ Feature: ${feature.name}');
      print('📊 Active: ${feature.isActive}');
      print('🔑 Key: ${feature.key}');
    },
    error: (err) {
      print('❌ Erreur: $err');
    },
  );
}

/// Exemple 2: Vérifier si une feature est active (simple)
Future<void> exempleVerifierSiActive() async {
  final service = FeaturesService();
  
  final isActive = await service.isFeatureActive(AppFeature.rechargeMomo);
  
  if (isActive) {
    print('✅ La recharge MoMo est disponible');
  } else {
    print('❌ La recharge MoMo est désactivée');
  }
}

/// Exemple 3: Vérifier plusieurs features
Future<void> exempleVerifierPlusieurs() async {
  final service = FeaturesService();
  
  final features = [
    AppFeature.rechargeMomo,
    AppFeature.emissionCarteVirtuelle,
    AppFeature.transfertWalletWalletLocal,
  ];
  
  final statusMap = await service.checkMultipleFeatures(features);
  
  statusMap.forEach((feature, isActive) {
    print('${isActive ? "✅" : "❌"} ${feature.displayName}');
  });
}

/// Exemple 4: Récupérer toutes les features
Future<void> exempleRecupererToutes() async {
  final service = FeaturesService();
  
  final result = await service.getAllFeatures();
  
  result.when(
    success: (features) {
      print('📋 ${features.length} features disponibles:');
      for (final f in features) {
        print('  ${f.isActive ? "✅" : "❌"} ${f.name}');
      }
    },
    error: (err) {
      print('❌ Erreur: $err');
    },
  );
}

/// Exemple 5: Utilisation dans un controller GetX
/*
class MonController extends GetxController {
  final service = FeaturesService();
  final canEmitCard = false.obs;
  final canRecharge = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    checkFeatures();
  }
  
  Future<void> checkFeatures() async {
    // Méthode 1: Vérification simple
    canEmitCard.value = await service.isFeatureActive(
      AppFeature.emissionCarteVirtuelle
    );
    
    // Méthode 2: Vérification détaillée
    final result = await service.getFeature(AppFeature.rechargeMomo);
    result.when(
      success: (feature) {
        canRecharge.value = feature.isActive;
      },
      error: (_) {
        canRecharge.value = false;
      },
    );
  }
  
  Future<void> tentativeRecharge() async {
    if (!canRecharge.value) {
      Get.snackbar(
        '❌ Service indisponible',
        'La recharge MoMo est temporairement désactivée',
      );
      return;
    }
    
    // Continuer avec la recharge...
  }
}
*/