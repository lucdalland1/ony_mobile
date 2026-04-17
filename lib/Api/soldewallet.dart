// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';

// import 'user_inscription.dart';

// class WalletService {
//   static const String _baseUrl = "http://192.168.100.30:8000/api";
//   final AuthController connexion = Get.find();
//     var wallet = connexion.getWallet();
//     var token = connexion.getToken();
  
//   Future<Map<String, dynamic>> fetchWalletData({
//     required String telephone,
//     required String token,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/get_solde'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'telephone': telephone,
//           'token': token,
//         }),
//       );

//       if (response.statusCode == 200) {

//         Get.snackbar('Succès', 'Solde chargé avec succès');
//         return jsonDecode(response.body);
//       } else {
//         throw Exception('Échec du chargement: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Erreur API: $e');
//       Get.snackbar('Erreur', 'Une erreur s\'est produite: $e');
//       }
//       rethrow;
//     }
//   }
// }