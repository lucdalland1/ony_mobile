// import 'dart:async'; // Pour utiliser Timer
// import 'package:get/get.dart';
// import 'package:local_auth/local_auth.dart';

// class FaceIdController extends GetxController {
//   final LocalAuthentication _localAuth = LocalAuthentication();
//   var isAuthenticated = false.obs; // État observable pour l'authentification
//   var isLocked = false.obs; // État observable pour le verrouillage
//   Timer? _lockTimer; // Timer pour gérer le verrouillage automatique

//   // Vérifier si l'appareil supporte l'authentification biométrique
//   Future<void> checkBiometricSupport() async {
//     bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
//     List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();

//     if (!canCheckBiometrics || availableBiometrics.isEmpty) {
//       Get.snackbar(
//         'Erreur',
//         'Authentification biométrique non supportée',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }

//   // Authentifier l'utilisateur avec Face ID ou Touch ID
//   Future<void> authenticate() async {
//     try {
//       bool authenticated = await _localAuth.authenticate(
//         localizedReason: 'Veuillez vous authentifier pour accéder à l\'application',
//         options: const AuthenticationOptions(
//           biometricOnly: true, // Forcer l'utilisation de la biométrie
//           useErrorDialogs: true, // Afficher les dialogues d'erreur natifs
//           stickyAuth: true, // Maintenir l'authentification active
//         ),
//       );

//       isAuthenticated.value = authenticated;

//       if (authenticated) {
//         isLocked.value = false; // Déverrouiller l'application
//         Get.snackbar(
//           'Succès',
//           'Authentification réussie !',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         resetLockTimer(); // Réinitialiser le timer après une authentification réussie
//       } else {
//         Get.snackbar(
//           'Erreur',
//           'Authentification échouée',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Erreur',
//         'Erreur lors de l\'authentification : $e',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }

//   // Démarrer le timer de verrouillage
//   void startLockTimer() {
//     _lockTimer = Timer(Duration(seconds: 30), () {
//       isLocked.value = true; // Verrouiller l'application après 30 secondes
//       isAuthenticated.value = false; // Réinitialiser l'état d'authentification
//       Get.snackbar(
//         'Verrouillé',
//         'L\'application a été verrouillée après 30 secondes d\'inactivité.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     });
//   }

//   // Réinitialiser le timer de verrouillage
//   void resetLockTimer() {
//     _lockTimer?.cancel(); // Annuler le timer actuel
//     startLockTimer(); // Redémarrer le timer
//   }

//   // Annuler le timer lors de la destruction du contrôleur
//   @override
//   void onClose() {
//     _lockTimer?.cancel();
//     super.onClose();
//   }
// }