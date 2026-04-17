// // controllers/auth_controller.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:onyfast/View/inscrit.dart';
// import 'package:onyfast/View/menuscreen.dart';
// import 'package:onyfast/model/user_model.dart';
// import 'package:onyfast/model/wallet_model.dart';
// import '../Model/user_register.dart';

// class InscriptionController extends GetxController {
//   final String registerUrl = 'http://192.168.100.30:8000/api/register';
//   final String otpGenerateUrl = 'https://api.dev.onyfastbank.com/bulk_sms/otp_generate.php';
//   final String otpVerifyUrl = 'https://api.dev.onyfastbank.com/bulk_sms/otp_verify.php';

//    final User _user = User.empty();
//   final storage = GetStorage();
//   final String baseUrl = 'http://192.168.100.30:8000';

//   var isLoading = false.obs;
//   var isOtpSent = false.obs;
//   var isOtpVerified = false.obs;
//   var errorMessage = ''.obs;


//   Future<void> registerUser(String telephone, String password, String confirmPassword) async {
//     try {
//       isLoading(true);
//       errorMessage('');

//       // Stocker les données utilisateur temporairement
//       _user = User(
//         telephone: telephone,
//         password: password,
//         confirmPassword: confirmPassword,
//       );

//       // Demander l'OTP
//       await requestOtp(telephone);
//     } catch (e) {
//       errorMessage('Erreur lors de l\'enregistrement: ${e.toString()}');
//     } finally {
//       isLoading(false);
//     }
//   }

//   Future<void> requestOtp(String phoneNumber) async {
//     try {
//       isLoading(true);
//       errorMessage('');

//       final cleanedPhone = phoneNumber.replaceAll("+", "");
      
//       final response = await http.post(
//         Uri.parse(otpGenerateUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'phone_number': cleanedPhone}),
//       );

//       if (response.statusCode == 200) {
//         print("voici les data: $response");
//         Get.offAll(() => Inscrit());
//         isOtpSent(true);
//       } else {
//         throw Exception('Échec de l\'envoi de l\'OTP');
//       }
//     } catch (e) {
//       errorMessage('Erreur lors de la demande OTP: ${e.toString()}');
//     } finally {
//       isLoading(false);
//     }
//   }
//  Future<void> verifyAndRegister() async {
//     try {
//       isLoading(true);
//       errorMessage('');

//       // 1. Vérification OTP
//       final otpResponse = await http.post(
//         Uri.parse('https://api.dev.onyfastbank.com/bulk_sms/otp_verify.php'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'phone_number': _user.telephone.replaceAll("+", ""),
//           'otp': _user.otp.trim(),
//         }),
//       );

//       final otpData = json.decode(otpResponse.body);
      
//       if (otpResponse.statusCode != 200 || otpData['status'] != 'success') {
//         throw Exception(otpData['message'] ?? 'OTP invalide');
//       }

//       // 2. Enregistrement de l'utilisateur
//       final registerResponse = await http.post(
//         Uri.parse('$baseUrl/api/register'),
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//         body: jsonEncode({
//           'telephone': _user.telephone.replaceAll("+", ""),
//           'password': _user.password,
//           'password_confirmation': _user.confirmPassword,
//         }),
//       );

//       final registerData = json.decode(registerResponse.body);

//       if (registerResponse.statusCode == 200 || registerResponse.statusCode == 201) {
//         // 3. Stockage des données
//         await _storeUserData(registerData);
//         Get.offAll(() => MenuScreen());
//       } else {
//         throw Exception(registerData['message'] ?? 'Échec de l\'enregistrement');
//       }
//     } catch (e) {
//       errorMessage('Erreur: ${e.toString()}');
//       Get.snackbar('Erreur', e.toString(), backgroundColor: Colors.orange);
//     } finally {
//       isLoading(false);
//     }
//   }

//   Future<void> _storeUserData(Map<String, dynamic> responseData) async {
//     if (responseData['user'] == null || 
//         responseData['wallet'] == null || 
//         responseData['token'] == null) {
//       throw Exception('Données manquantes dans la réponse API');
//     }

//     final userModel = UserModel.fromJson(responseData['user']);
//     final walletModel = WalletModel.fromJson(responseData['wallet']);
//     final authToken = responseData['token'].toString();

//     await Future.wait([
//       storage.write('userInfo', userModel.toMap()),
//       storage.write('walletInfo', walletModel.toMap()),
//       storage.write('token', authToken),
//       storage.write('telephone', userModel.telephone),
//       storage.write('register_phone', _user.telephone),
//     ]);

//     await fetchSolde();
//   }
//   Future<void> verifyOtp() async {
//     try {
//       isLoading(true);
//       errorMessage('');

//       // Vérification que l'OTP est valide (6 chiffres)
//       if (_user.otp.isEmpty || _user.otp.length != 6) {
//         throw Exception('Veuillez entrer un code OTP valide');
//       }

//       final response = await http.post(
//         Uri.parse(otpVerifyUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'phone_number': _user.telephone.replaceAll("+", ""),
//           'otp': _user.otp.trim(),
//         }),
//       );

//       final responseData = json.decode(response.body);
      
//       if (response.statusCode == 200 && responseData['status'] == 'success') {
//         await completeRegistration();
//       } else {
//         throw Exception(responseData['message'] ?? 'OTP invalide');
//       }
//     } catch (e) {
//       errorMessage('Erreur de vérification: ${e.toString()}');
//       Get.offAll(() => Inscrit());
//     } finally {
//       isLoading(false);
//     }
//   }

//   ///Solde
//   Future<WalletModel?> fetchSolde() async {
//   try {
//     // Vérification des données nécessaires
//     final telephone = storage.read('telephone');
//     final token = storage.read('token');

//     if (telephone == null) {
//       throw Exception('Numéro de téléphone non trouvé');
//     }
    
//     if (token == null) {
//       throw Exception('Session expirée, veuillez vous reconnecter');
//     }

//     isLoading.value = true;
    
//     // Envoi de la requête avec timeout
//     final response = await http.post(
//       Uri.parse('${baseUrl}/api/get_solde'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode({
//         'telephone': telephone,
//         'token': token,
//       })
//     ).timeout(const Duration(seconds: 5));

//     // Journalisation pour le débogage
//     debugPrint('Réponse solde - Code: ${response.statusCode}');
//     debugPrint('Réponse solde - Body: ${response.body}');

//     // Traitement de la réponse
//     if (response.statusCode == 200) {
//       final responseData = json.decode(response.body);
      
//       // Validation des données reçues
//       if (responseData['wallet'] == null) {
//         throw FormatException('Structure de données incorrecte');
//       }

//       final wallet = WalletModel.fromJson(responseData['wallet']);
      
//       // Mise à jour des données locales
//       await Future.wait([
//         storage.write('walletInfo', wallet.toMap()),
//         storage.write('solde', wallet.solde),
//       ]);

//       walletInfo.value = wallet.toMap();
//       SoldewalletInfo.value = wallet.toMap();
      
//       // Journalisation du succès
//       debugPrint('Solde mis à jour: ${wallet.solde} FCFA');

//       // Affichage d'un Snackbar pour indiquer que le solde a été mis à jour
//       _showSnackbar('Succès', 'Solde actualisé avec succès: ${wallet.solde} FCFA', Colors.orange);
//       return wallet;
//     } 
//     // Gestion des erreurs HTTP spécifiques
//     else if (response.statusCode == 401) {
//       _showSnackbar('Erreur', 'Session expirée, veuillez vous reconnecter', Colors.orange);
//       throw Exception('Session expirée, veuillez vous reconnecter');
//     } 
//     else if (response.statusCode == 404) {
//       _showSnackbar('Erreur', 'Portefeuille non trouvé', Colors.orange);
//       throw Exception('Portefeuille non trouvé');
//     } 
//     else {
//       _showSnackbar('Erreur', 'Erreur serveur', Colors.orange);
//       throw HttpException('Erreur serveur');
//     }
//   } 
//   // Gestion des exceptions spécifiques
//   on SocketException {
//     _showSnackbar('Erreur', 'Problème de connexion internet', Colors.orange);
//     throw Exception('Problème de connexion internet');
//   } 
//   on TimeoutException {
//     _showSnackbar('Erreur', 'Le serveur met trop de temps à répondre', Colors.orange);
//     throw Exception('Le serveur met trop de temps à répondre');
//   } 
//   on FormatException catch (e) {
//     _showSnackbar('Erreur', 'Données reçues invalides: ${e.message}', Colors.orange);
//     throw Exception('Données reçues invalides: ${e.message}');
//   } 
//   on HttpException catch (e) {
//     _showSnackbar('Erreur', 'Erreur HTTP: ${e.message}', Colors.orange);
//     throw Exception('Erreur HTTP: ${e.message}');
//   } 
//   catch (e) {
//     _showSnackbar('Erreur', 'Erreur inattendue: ${e.toString().split(':')[0]}', Colors.orange);
//     throw Exception('Erreur inattendue: ${e.toString().split(':')[0]}');
//   } 
//   finally {
//     isLoading.value = false;
//   }
// }
//   Future<void> completeRegistration() async {
//     try {
//       isLoading(true);
      
//       final response = await http.post(
//         Uri.parse(registerUrl),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(_user.toJson()),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         Get.offAll(() => MenuScreen()); // Page de succès
//       } else {
//         throw Exception('Échec de l\'enregistrement final');
//       }
//     } catch (e) {
//       errorMessage('Erreur finale: ${e.toString()}');
//       Get.offAll(() => Inscrit()); // Retour à la page d'inscription
//     } finally {
//       isLoading(false);
//     }
//   }
// }