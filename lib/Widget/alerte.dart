// Créez ce fichier : lib/services/snackbar_service.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AlertType {
  success, // Succès
  error, // Erreur/Échec
  warning, // Alerte/Avertissement
  info // Information (bonus)
}

class SnackBarService {
  // Configuration des couleurs et icônes par type
  static final Map<AlertType, AlertConfig> _configs = {
    AlertType.success: AlertConfig(
      backgroundColor: Colors.green.shade700,
      icon: Icons.check_circle_outline,
      title: 'Succès ✅',
      defaultMessage: 'Opération effectuée avec succès',
    ),
    AlertType.error: AlertConfig(
      backgroundColor: Colors.red.shade700,
      icon: Icons.error_outline,
      title: 'Erreur 😕',
      defaultMessage: 'Une erreur est survenue',
    ),
    AlertType.warning: AlertConfig(
      backgroundColor: Colors.orange.shade700,
      icon: Icons.warning_amber_rounded,
      title: 'Attention ⚠️',
      defaultMessage: 'Veuillez vérifier les informations',
    ),
    AlertType.info: AlertConfig(
      backgroundColor: Colors.red.shade700,
      icon: Icons.info_outline,
      title: 'Information ℹ️',
      defaultMessage: 'Information importante',
    ),
  };

  /// Affiche une alerte de succès
  static void success(String message, {String? title}) {
    _showAlert(AlertType.success, message, customTitle: title);
  }

  /// Affiche une alerte d'erreur
  static void error(String message, {String? title}) {
    _showAlert(AlertType.error, message, customTitle: title);
  }

  /// Affiche une alerte d'avertissement
  static void warning(String message, {String? title}) {
    _showAlert(AlertType.warning, message, customTitle: title);
  }

  /// Affiche une alerte d'information
  static void info(String message, {String? title}) {
    _showAlert(AlertType.info, message, customTitle: title);
  }

  /// Méthode générique pour afficher une alerte
  static void show({
    required AlertType type,
    required String message,
    String? title,
    Duration? duration,
    SnackPosition? position,
  }) {
    _showAlert(
      type,
      message,
      customTitle: title,
      customDuration: duration,
      customPosition: position,
    );
  }

  // Méthode privée qui gère l'affichage
  static void _showAlert(
    AlertType type,
    String message, {
    String? customTitle,
    Duration? customDuration,
    SnackPosition? customPosition,
  }) {
    final config = _configs[type]!;

    Get.snackbar(
      customTitle ?? config.title,
      message.isNotEmpty ? message : config.defaultMessage,
      snackPosition: customPosition ?? (!Platform.isIOS ? SnackPosition.TOP : SnackPosition.BOTTOM),
      snackStyle: SnackStyle.FLOATING,
      backgroundColor: config.backgroundColor,
      colorText: Colors.white,
      icon: Icon(config.icon, color: Colors.white),
      margin: EdgeInsets.only(
        top: Platform.isIOS ? 50 : 12,
        left: 12,
        right: 12,
        bottom: 12,
      ),
      borderRadius: Platform.isIOS ? 16 : 12,
      duration: customDuration ?? const Duration(seconds: 6),
      isDismissible: true,
      // Animation améliorée
      animationDuration: const Duration(milliseconds: 400),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
    );
  }

  /// Alerte de succès avec message par défaut
  static void defaultSuccess() => success('');

  /// Alerte d'erreur avec message par défaut
  static void defaultError() => error('');

  /// Alerte d'avertissement avec message par défaut
  static void defaultWarning() => warning('');

  /// Alerte personnalisée pour les erreurs HTTP
  static void httpError(int statusCode, [String? message]) {
    final errorMessage = message?.isNotEmpty == true
        ? message!
        : 'Erreur serveur (code: $statusCode)';
    error(errorMessage);
  }

  /// Alerte pour carte déjà utilisée (cas spécifique de votre app)
  static void cardAlreadyUsed([String? message]) {
    warning(
      message?.isNotEmpty == true
          ? message!
          : "Cette carte d'identité est déjà associée à une demande",
      title: 'Déjà utilisé',
    );
  }

  /// Alerte pour validation de formulaire
  static void validationError(String field) {
    warning('Veuillez vérifier le champ: $field');
  }

  /// Alerte pour connexion réseau
  static void networkError() {
    error('Vérifiez votre connexion internet');
  }

  /// Alerte pour action réussie avec délai court
  static void quickSuccess(String message) {
    show(
      type: AlertType.success,
      message: message,
      duration: const Duration(seconds: 2),
    );
  }
}

// Configuration interne pour chaque type d'alerte
class AlertConfig {
  final Color backgroundColor;
  final IconData icon;
  final String title;
  final String defaultMessage;

  const AlertConfig({
    required this.backgroundColor,
    required this.icon,
    required this.title,
    required this.defaultMessage,
  });
}

// ========== EXEMPLES D'UTILISATION ==========

/*
// Dans n'importe quelle partie de votre app :

// 1. Alertes simples
SnackBarService.success("Inscription réussie !");
SnackBarService.error("Erreur lors de l'envoi");
SnackBarService.warning("Champs obligatoires manquants");
SnackBarService.info("Nouvelle mise à jour disponible");

// 2. Avec titre personnalisé
SnackBarService.success("Profil mis à jour", title: "Parfait ! 🎉");

// 3. Messages par défaut
SnackBarService.defaultSuccess();
SnackBarService.defaultError();

// 4. Cas spécifiques
SnackBarService.httpError(404, "Ressource introuvable");
SnackBarService.cardAlreadyUsed();
SnackBarService.validationError("Email");
SnackBarService.networkError();

// 5. Alerte personnalisée complète
SnackBarService.show(
  type: AlertType.warning,
  message: "Action non autorisée",
  title: "Accès refusé",
  duration: const Duration(seconds: 6),
  position: SnackPosition.BOTTOM,
);

// 6. Succès rapide (2 secondes)
SnackBarService.quickSuccess("Sauvegardé !");
*/
