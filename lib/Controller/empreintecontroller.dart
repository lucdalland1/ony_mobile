// import 'dart:async';
// import 'package:get/get.dart';
// import 'package:local_auth/local_auth.dart';
// /*
// enum AuthMethod { biometric, pin, none }

// class EmpreinteController extends GetxController {
//   final LocalAuthentication _localAuth = LocalAuthentication();

//   // États observables
//   var isAuthenticated = false.obs;
//   var isLocked = true.obs; // L'app démarre verrouillée par défaut
//   var showUnlockButton = false.obs;
//   var authMethod = AuthMethod.none.obs;
//   var tempPin = ''.obs;
//   var pinError = ''.obs;
//   var showPinPad = false.obs;
//   var remainingAttempts = 3.obs;

//   // Timers
//   Timer? _inactivityTimer;

//   // Configuration
//   final int lockDelay = 10; // Verrouillage après 10 secondes d'inactivité
//   final int maxPinAttempts = 3;
//   final String correctPin = '1234'; // À stocker de manière sécurisée en production

//   @override/*  */
//   void onInit() {
//     super.onInit();
//     _initializeAuth();
//     startInactivityTimer();
//   }

//   void startInactivityTimer() {
//     _inactivityTimer?.cancel(); // Annuler le timer précédent
//     _inactivityTimer = Timer(Duration(seconds: lockDelay), () {
//       lockApp(); // Verrouiller l'application après inactivité
//     });
//   }

//   void resetInactivityTimer() {
//     if (!isLocked.value) {
//       startInactivityTimer(); // Redémarrer le timer si l'application n'est pas verrouillée
//     }
//   }

//   Future<void> _initializeAuth() async {
//     try {
//       final canAuth = await _localAuth.canCheckBiometrics;
//       final availableBiometrics = await _localAuth.getAvailableBiometrics();

//       if (canAuth && availableBiometrics.isNotEmpty) {
//         authMethod.value = AuthMethod.biometric;
//         await authenticateWithBiometrics();
//       } else {
//         authMethod.value = AuthMethod.pin;
//         showPinInput();
//       }
//     } catch (e) {
//       authMethod.value = AuthMethod.pin;
//       showPinInput();
//     }
//   }

//   Future<void> authenticateWithBiometrics() async {
//     try {
//       final authenticated = await _localAuth.authenticate(
//         localizedReason: 'Authentification requise pour accéder à l\'application',
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           useErrorDialogs: true,
//           stickyAuth: true,
//         ),
//       );

//       if (authenticated) {
//         unlockApp();
//       } else {
//         showAlternativeAuth();
//       }
//     } catch (e) {
//       showAlternativeAuth();
//     }
//   }

//   void showAlternativeAuth() {
//     authMethod.value = AuthMethod.pin;
//     showPinInput();
//   }

//   void showPinInput() {
//     showUnlockButton.value = false;
//     showPinPad.value = true;
//     tempPin.value = '';
//     pinError.value = '';
//   }

//   void onPinEntered(String digit) {
//     resetInactivityTimer(); // Réinitialiser le timer d'inactivité
//     if (tempPin.value.length < 4) {
//       tempPin.value += digit;
//       if (tempPin.value.length == 4) verifyPin();
//     }
//   }

//   void onPinDeleted() {
//     resetInactivityTimer(); // Réinitialiser le timer d'inactivité
//     if (tempPin.value.isNotEmpty) {
//       tempPin.value = tempPin.value.substring(0, tempPin.value.length - 1);
//     }
//   }

//   void verifyPin() {
//     if (tempPin.value == correctPin) {
//       unlockApp();
//     } else {
//       remainingAttempts.value--;
//       pinError.value = 'Code incorrect. Essais restants: ${remainingAttempts.value}';
//       tempPin.value = '';

//       if (remainingAttempts.value <= 0) {
//         lockApp();
//       }
//     }
//   }

//   void unlockApp() {
//     isAuthenticated.value = true;
//     isLocked.value = false;
//     showUnlockButton.value = false;
//     showPinPad.value = false;
//     remainingAttempts.value = maxPinAttempts; // Réinitialiser les tentatives
//     resetInactivityTimer(); // Redémarrer le timer d'inactivité après déverrouillage
//   }

//   void lockApp() {
//     isLocked.value = true;
//     isAuthenticated.value = false;
//     showUnlockButton.value = true;
//     showPinPad.value = false;
//     remainingAttempts.value = maxPinAttempts; // Réinitialiser les tentatives
//     _inactivityTimer?.cancel(); // Annuler le timer d'inactivité
//   }

//   void onUnlockPressed() {
//     resetInactivityTimer(); // Réinitialiser le timer d'inactivité
//     if (authMethod.value == AuthMethod.biometric) {
//       authenticateWithBiometrics();
//     } else {
//       showPinInput();
//     }
//   }

//   @override
//   void onClose() {
//     _inactivityTimer?.cancel(); // Annuler le timer lors de la fermeture
//     super.onClose();
//   }

//   derivePinFromPassword(String password) {}
// }*/
