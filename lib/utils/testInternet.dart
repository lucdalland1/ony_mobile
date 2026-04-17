import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Vérifie si l'utilisateur a une connexion Internet
/// Retourne true si connecté, false sinon
Future<bool> hasInternetConnection() async {
  try {
    // Vérifier d'abord le type de connectivité
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    
    // Vérifier si la connexion est réellement fonctionnelle
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (e) {
    return false;
  }
}

/// Version plus rapide - vérifie juste le type de connexion
Future<bool> hasNetworkConnection() async {
  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  } catch (e) {
    return false;
  }
}

/// Version avec timeout personnalisé
Future<bool> hasInternetWithTimeout({Duration timeout = const Duration(seconds: 5)}) async {
  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    
    final result = await InternetAddress.lookup('google.com')
        .timeout(timeout);
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (e) {
    return false;
  }
}

// // Exemple d'utilisation
// void main() async {
//   bool isConnected = await hasInternetConnection();
  
//   if (isConnected) {
//     print('Connexion Internet disponible');
//   } else {
//     print('Pas de connexion Internet');
//   }
// }