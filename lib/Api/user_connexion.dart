// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:onyfast/Api/const.dart';
// import 'package:onyfast/View/home.dart';
// import 'package:onyfast/View/menuscreen.dart';
// import 'dart:convert';
// import '../model/user_model.dart';
// import '../model/wallet_model.dart';

// class ConnexionController extends GetxController {
//   var isLoading = false.obs;
//   var userInfo = {}.obs; // Pour stocker les informations de l'utilisateur
//   var walletInfo = {}.obs; // Pour stocker les informations du wallet
//   final GetStorage storage = GetStorage();

//   Future<void> login(String telephone, String password) async {
//     isLoading.value = true;

//     if (telephone.isEmpty || password.isEmpty) {
//       Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
//       isLoading.value = false;
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/login'),
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//         body: jsonEncode({'telephone': telephone, 'password': password}),
//       );

//       if (response.statusCode == 200) {
//         Map<String, dynamic> responseData = json.decode(response.body);
//         UserModel userModel = UserModel.fromJson(responseData['user']);
//         WalletModel walletModel = WalletModel.fromJson(responseData['wallet']);
//         String authToken = responseData['token'];

//         // Stockage des informations
//         storage.write('user',
//             userModel.toJson()); // Assurez-vous que `toJson()` retourne un Map
//         storage.write(
//             'wallet',
//             walletModel
//                 .toJson()); // Assurez-vous que `toJson()` retourne un Map
//         storage.write('token', authToken); // Auth token est un String
//         print(userModel);
//         print(authToken);

//         Get.offAll(() => MenuScreen());
//         Get.snackbar('Succès', 'Connexion réussie');
//       } else {
//         Get.snackbar('Erreur', 'Numéro de téléphone ou mot de passe incorrect');
//       }
//     } catch (e) {
//       Get.snackbar('Erreur', 'Une erreur s\'est produite: $e');
//     } finally {
//       isLoading.value = false;
//     }
//     // }

//     UserModel? getUser() {
//       final userJson = storage.read('user');
//       if (userJson is String) {
//         return UserModel.fromJson(
//             json.decode(userJson)); // Décodez si c'est une chaîne
//       }
//       return null;
//     }

//     WalletModel? getWallet() {
//       final walletJson = storage.read('wallet');
//       if (walletJson is String) {
//         return WalletModel.fromJson(
//             json.decode(walletJson)); // Décodez si c'est une chaîne
//       }
//       return null;
//     }

//     String? getToken() {
//       return storage.read('token'); // Le token devrait déjà être une chaîne
//     }

//     // Méthode pour se déconnecter
//     void logout() {
//       storage.remove('user');
//       storage.remove('wallet');
//       storage.remove('token');
//       Get.offAll(() => Home()); // Rediriger vers l'écran de connexion
//       Get.snackbar('Déconnexion', 'Vous avez été déconnecté avec succès');
//     }
//   }
// }
