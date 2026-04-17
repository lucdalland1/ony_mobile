import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/Register_User_APi/Model/user_register.dart';
import 'package:onyfast/Api/Register_User_APi/codeparaind_api.dart';
import 'package:onyfast/Api/addresseNetwork/addresseNetworkApi.dart';
import 'package:onyfast/Api/piecesjustificatif_Api/pieces_justificatif_api.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/RecenteTransaction/recenttransactcontroller.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Controller/features/features_controller.dart';
import 'package:onyfast/Controller/otpcontroller.dart';
import 'package:onyfast/Controller/verifier_identite/voir_justificatifresidencecontroller.dart';
import 'package:onyfast/View/InscriptionSuplementaire/InscritInfoSuplementaire.dart';
import 'package:onyfast/View/ResetPassword/resetpassword.dart';
import 'package:onyfast/View/ResetPassword/resetpassword2.dart';
import 'package:onyfast/View/home.dart';
import 'package:onyfast/View/hometoken.dart';
import 'package:onyfast/View/menuscreen.dart';
import 'package:onyfast/View/otp.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Widget/dialog.dart';
import 'package:onyfast/Widget/redirectionAppPro.dart';
import 'package:onyfast/otplogin.dart';
import 'package:onyfast/utils/device.dart';
import 'package:onyfast/utils/telephoneValidator.dart';
import '../model/transactionmodel.dart';
import '../model/user_model.dart';
import '../model/wallet_model.dart';
import 'package:flutter/material.dart';

import 'const.dart';
import 'package:onyfast/Api/const.dart';

class AuthController extends GetxController {
  var transactionTypes = <TransactionTypeModel>[].obs;
  var isLoading = false.obs;
  var token = ''.obs;
  var userInfo = {}.obs;
  var walletInfo = {}.obs;

  var phoneNumber = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var otp = ''.obs;

  final User _user = User.empty();

  var SoldewalletInfo = {}.obs;
  var transactionInfo = [].obs;
  User? user;
  var isOtpVerified = false.obs;
  var errorMessage = ''.obs;

  final Dio _dio = Dio();

  final GetStorage storage = GetStorage();

  // TextEditingControllers pour C2C pour les transactions carte à carte
  final fromAccountId = TextEditingController();
  final toAccountId = TextEditingController();
  final last4Digits = TextEditingController();
  final amount = TextEditingController();

//Methode pour s'enregistrer
//    Future<void> register(String telephone, String pin, String confirmPassword) async {
//     // String pinConfirm = pin;
// // Validation des entrées

//     isLoading.value = true;
//     print('Début de la fonction register avec téléphone: $telephone');

//     try {
//       final response = await http.post(
//         Uri.parse('${baseUrl}/register'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(<String, String>{
//           'telephone': telephone.replaceAll("+", ""),
//           'password': pin,
//           'password_confirmation': confirmPassword,
//         }),
//       );

//       print('Réponse reçue: ${response.statusCode}');
//       print('Corps de la réponse: ${response.body}');

//       if (response.statusCode == 201) {
//         await storage.write('register_phone', phoneNumber.value);

//         // Demande d'OTP automatique
//         await requestOtp();
//  print('Token reçu: ${token.value}');
//         print('Informations utilisateur: ${userInfo.value}');
//         print('Informations du wallet: ${walletInfo.value}');
//         print('Types de transactions: ${transactionInfo.value}');
//         Map<String, dynamic> responseData = json.decode(response.body);
//         List<dynamic> transactionTypesJson = responseData['transaction_types'];
//         token.value = responseData['token'];
//         userInfo.value = responseData['user'];
//         walletInfo.value = responseData['wallet'];
//         if (transactionTypesJson != null && transactionTypesJson is List) {
//           transactionInfo.value = responseData['transaction_types'];
//         } else {
//           transactionInfo.value = [];
//         }
//         // Stocker les informations dans GetStorage
//         storage.write('token', token.value);
//         storage.write('userInfo', userInfo.value);
//         storage.write('walletInfo', walletInfo.value);
//         storage.write('transactionInfo', transactionInfo.value);

//         print('Token reçu: ${token.value}');
//         print('Informations utilisateur: ${userInfo.value}');
//         print('Informations du wallet: ${walletInfo.value}');
//         print('Types de transactions: ${transactionInfo.value}');

//         Get.offAll(() => Otp());
//         Get.snackbar('Succès', 'Inscription réussie', backgroundColor: Colors.orange);

//       } else if (response.statusCode == 302) {
//         print("L'utilisateur existe déjà passez par un autre numéro.");
//         Get.snackbar('Erreur', 'Redirection détectée. Vérifiez l\'URL de l\'API.', backgroundColor: Colors.orange);
//       } else {
//         print('Échec de l\'inscription avec le code: ${response.statusCode}');
//         Get.snackbar('Erreur', 'Échec de l\'inscription: ${response.body}', backgroundColor: Colors.orange);
//       }
//     } catch (e) {
//       print('Exception capturée: $e');
//       Get.snackbar('Erreur', 'Une erreur s\'est produite: $e', backgroundColor: Colors.orange);
//     } finally {
//       isLoading.value = false;
//       print('Fin de la fonction register');
//     }
//   }

  Future<void> register(
      String telephone,
      String password,
      String confirmPassword,
      String code,
      String indicatif,
      String CodeParrain) async {
    print('📤📤📤📤📤📤📤 voila son indicatif $indicatif et le code $code ');
    try {
      isLoading(true);
      errorMessage('');

      // Validation des champs
      if (telephone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        SnackBarService.info('Tous les champs doivent être remplis.');
        return;
      }

      if (password != confirmPassword) {
        print('les mots de passe sont differents 📤📤📤📤📤📤📤');
        SnackBarService.info('Les mots de passe ne correspondent pas.');
        return;
      }

      // Nettoyer le numéro de téléphone
      String cleanedTelephone = telephone.replaceAll("+", "").trim();
      if (cleanedTelephone.isEmpty) {
        errorMessage('Numéro de téléphone invalide.');
        return;
      }
      if (CodeParrain.isNotEmpty) {
        if (CodeParrain.length > 12) {
          SnackBarService.warning(
              'Le code parrain doit contenir 12 caractères');
          return;
        }
        var result =
            await ParrainageService().getUserByParrainCode(CodeParrain);
        if (result == null) {
          //  SnackBarService.warning('Impossible de vérifier le code parrain. Veuillez réessayer plus tard.');
          return;
        }

        print('result parainage $result');
        if (result == false) {
          SnackBarService.warning(
              'Code parrain invalide. Veuillez vérifier et réessayer.');
          return;
        }
      }
      try {
        final headers = {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        };

        telephone = telephone
            .replaceFirst(RegExp(r'^\+'), '') // enlève + en début
            .replaceAll(RegExp(r'\s+'), ''); // enlève espaces
        print("voila le numero $telephone");
        if (!commenceParIndicatif(telephone.replaceAll(' ', ""))) {
          isLoading.value = false;
          return;
        }
        print("📤 GET /api/check-phone");
        print("➡️ URL: ${ApiEnvironmentController.to.baseUrl}/check-phone");
        print("➡️ Query: { telephone: $telephone }");
        print("➡️ Headers: $headers");

        final dio = Dio();
        final res = await dio.get(
          '${ApiEnvironmentController.to.baseUrl}/check-phone',
          queryParameters: {'telephone': telephone}, // GET => queryParameters
          options: Options(headers: headers),
        );

        print("✅ Réponse reçue: ${res.data}");

        if (res.statusCode == 200) {
          SnackBarService.error('Ce Numéro est déjà associé à un compte',
              title: "Erreur");
          return;
        }
      } catch (e) {}

      // Stocker les données utilisateur dans GetStorage
      // await storage.write('register_phone', cleanedTelephone);
      // await storage.write('temp_password', password);
      // await storage.write('temp_confirm_password', confirmPassword);

      bool success = await requestOtp(telephone);

      if (success) {
        // Continuer le processus
        Get.offAll(Otp(), arguments: {
          'telephone': telephone,
          'password': password,
          'code': indicatif,
          'indicatif': code.replaceAll("+", ""),
          "codeParrain": CodeParrain ?? ""
        });
      } else {
        // Afficher une erreur ou rester sur place
      }
      // Initialiser le modèle User
      // user = User.empty()
      //   ..telephone = cleanedTelephone
      //   ..password = password
      //   ..confirmPassword = confirmPassword;
      // Rediriger vers l'écran OTP
      // Get.offAll(Otp());
    } catch (e) {
      print('Exception capturée: $e');
      errorMessage('Erreur lors de l\'enregistrement: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> login1(String telephone, String password) async {
    isLoading.value = true;

    // Validation des champs requis
    if (telephone.isEmpty || password.isEmpty) {
      SnackBarService.error('Veuillez remplir tous les champs',
          title: "Erreur");
      isLoading.value = false;
      return;
    }
    var deviceskey = await getDeviceIMEI();
    var ip = await ValidationTokenController.to.getPublicIP();
    final networkInfo = await IpInfoService.getNetworkInfo();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/login'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'telephone': telephone.replaceAll("+", ""),
              'password': password.trim(),
              'device': deviceskey,
              'ip': ip,
              "device_type": "mobile",
              "os": Platform.isIOS ? 'Iphone' : 'Android',
              "browser": "Application native",
              "ip_address": networkInfo?.ipAddress,
              "country": networkInfo?.isp,
              "country_code": networkInfo?.countryCode,
              "city": networkInfo?.city,
              "region": networkInfo?.region,
              "latitude": networkInfo?.latitude,
              "longitude": networkInfo?.longitude,
              "isp": networkInfo?.isp
            }),
          )
          .timeout(const Duration(seconds: 20));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        var typeUser = responseData['type_user'];
        if (typeUser == "partenaire") {
          redirection();

          return;
        }

        // Récupération de l'utilisateur et du token
        final userModel = UserModel.fromMap(responseData['user']); // ✅ CORRIGÉ
        final authToken = responseData['token'].toString();

        // Sauvegarde dans le stockage sécurisé
        await Future.wait([
          storage.write('userInfo', userModel.toMap()),
          storage.write('id', userModel.id),
          storage.write('token', authToken),
          storage.write('telephone', userModel.telephone),
          storage.write('register_phone', phoneNumber.value),
        ]);

        final securetoken = SecureTokenController.to.saveToken(authToken);
        SecureTokenController.to.saveTelephone(userModel.telephone);

        // Appel d'autres données (ex : solde)
        await fetchSolde();

        // Notification et redirection
        Get.offAll(() => HomeToken());
      } else {
        // Gestion des erreurs de l’API
        final errorMessage =
            responseData['message'] ?? "Mot de passe ou numéro incorrect";
        SnackBarService.error(title: 'Erreur', errorMessage);
      }
    } on SocketException {
      SnackBarService.error(
        title: 'Erreur',
        'Problème de connexion internet',
      );
    } on TimeoutException {
      SnackBarService.error(
        title: 'Erreur',
        'vérifier votre connexion internet',
      );
    } catch (e) {
      print('Exception: $e');
      SnackBarService.error(
        title: 'Erreur',
        'Échec de la connexion',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String telephone, String password) async {
    isLoading.value = true;

    // Validation des champs requis
    if (telephone.isEmpty || password.isEmpty) {
      SnackBarService.error(
        title: 'Erreur',
        'Veuillez remplir tous les champs',
      );
      isLoading.value = false;
      return;
    }

    if (!commenceParIndicatif(telephone.replaceAll(' ', ""))) {
      isLoading.value = false;
      return;
    }

    var deviceskey = await getDeviceIMEI();
    print(
        '✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅voila tel: ${telephone.replaceAll("+", "").replaceAll(" ", "")} \n pass: $deviceskey');

    try {
      var ip = await ValidationTokenController.to.getPublicIP();
      final networkInfo = await IpInfoService.getNetworkInfo();
      final response = await http
          .post(
            Uri.parse('${ApiEnvironmentController.to.baseUrl}/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: jsonEncode({
              'telephone': telephone.replaceAll("+", "").replaceAll(" ", ""),
              'password': password.trim().replaceAll(" ", ""),
              'device': deviceskey,
              'ip': ip,
              "device_type": "mobile",
              "os": Platform.isIOS ? 'Iphone' : 'Android',
              "browser": "Application native",
              "ip_address": networkInfo?.ipAddress,
              "country": networkInfo?.isp,
              "country_code": networkInfo?.countryCode,
              "city": networkInfo?.city,
              "region": networkInfo?.region,
              "latitude": networkInfo?.latitude,
              "longitude": networkInfo?.longitude,
              "isp": networkInfo?.isp
            }),
          )
          .timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);

      print(
          '✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅voila la reponse $responseData devices: $deviceskey  ${response.statusCode}');

      if (response.statusCode == 200) {
        var typeUser = responseData['type_user'];
        print('voila le type user $typeUser');
        // return ;
        if (typeUser == "merchant") {
          redirection();
          return;
        }
        if (typeUser == "partenaire") {
          redirection();
          return;
        }
        final authToken = responseData['token'].toString();

        print('voila le nouveau token $authToken');
        // Sauvegarde dans le stockage sécurisé
        await Future.wait([
          storage.write('tokenss', authToken),
        ]);

        bool success = await requestOtp(telephone);

        final service = FeaturesService();

        final isActive = await service.isFeatureActive(AppFeature.otpTelephone);
        final isActive2 = await service.isFeatureActive(AppFeature.otpWhatssap);

        if (isActive || isActive2) {
          print('✅ Ajout de la Piece Identité');
          Get.offAll(Otplogin(iswhatssap: isActive2, isTelephone: isActive),
              arguments: {
                'telephone': telephone,
                'password': password,
                "verif": false
              });
        } else {
          SnackBarService.info(
              '❌ Ce service est actuellement indisponible. Veuillez réessayer plus tard.');

          return;
        }

        return;

        // // Récupération de l'utilisateur et du token
        // final userModel = UserModel.fromMap(responseData['user']); // ✅ CORRIGÉ
        // final authToken = responseData['token'].toString();

        // // Sauvegarde dans le stockage sécurisé
        // await Future.wait([
        //   storage.write('token', authToken),
        // ]);

        // // Appel d'autres données (ex : solde)
        // await fetchSolde();

        // // Notification et redirection
        // Get.snackbar('Succès', 'OTP envoyé au ${phoneNumber.value}');
        // Get.offAll(() => MenuScreen());
      } else {
        // Gestion des erreurs de l’API
        final errorMessage = responseData['ko'] ?? responseData['message'];
        if (errorMessage != null)
          SnackBarService.error(title: 'Erreur', errorMessage);
      }
    } on SocketException {
      // SnackBarService.error(
      //   title: 'Erreur',
      //   'Problème de connexion internet',
      // );
    } on TimeoutException {
      SnackBarService.error(
        title: 'Erreur',
        'vérifier votre connexion internet',
      );
    } on FormatException {
      // SnackBarService.error(
      //   title: 'Erreur',
      //   'Compte introuvable',
      // );
    } catch (e) {
      // print('Exception: $e');
      // SnackBarService.error(
      //   title: 'Erreur',
      //   'Échec de la connexion',
      // );
    } finally {
      isLoading.value = false;
    }
  }

  // Demande d'OTP
// Future<bool> requestOtp() async {
//   try {
//     isLoading.value = true;
//     errorMessage('');

//     // 1. Récupération et validation du numéro
//     final phone = await storage.read('register_phone') ?? '';
//     if (phone.isEmpty) {
//       throw FormatException('Aucun numéro enregistré. Veuillez recommencer l\'inscription.');
//     }

//     // 2. Nettoyage et validation stricte
//     final cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
//     if (!RegExp(r'^\+?\d{8,15}$').hasMatch(cleanedPhone)) {
//       throw FormatException('Format de numéro invalide');
//     }

//     // 3. Envoi sécurisé avec timeout
//     final response = await http.post(
//       Uri.parse('https://api.dev.onyfastbank.com/bulk_sms/otp_generate.php'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//       body: jsonEncode({
//         'phone_number': phone.replaceAll('+', ''),
//       }),
//     ).timeout(const Duration(seconds: 30));

//     // 4. Gestion de la réponse
//     if (response.statusCode != 200) {
//       throw HttpException('Erreur serveur',);
//     }

//     final data = jsonDecode(utf8.decode(response.bodyBytes));
//     if (data['success'] != true) {
//       throw Exception(data['message'] ?? 'Échec de génération OTP');
//     }

//     // 5. Stockage sécurisé de l'OTP (optionnel selon besoin)
//     otp.value = data['otp']?.toString() ?? '';

//     // 6. Feedback utilisateur
//     Get.snackbar(
//       'Code de vérification envoyé',
//       'Un code à 6 chiffres a été envoyé au ${obfuscatePhone(phone)}',
//       duration: const Duration(seconds: 5),
//       backgroundColor: Colors.green[800],
//       colorText: Colors.white,
//     );

//     // Journalisation debug
//     debugPrint('OTP requested for $cleanedPhone');

//   } on FormatException catch (e) {
//     errorMessage(e.message);
//     Get.snackbar('Erreur de format', e.message,
//         backgroundColor: Colors.orange);
//   } on TimeoutException {
//     errorMessage('Délai dépassé. Veuillez réessayer.');
//     Get.snackbar('Problème de connexion', 'Le serveur a mis trop de temps à répondre',
//         backgroundColor: Colors.orange);
//   } on http.ClientException {
//     errorMessage('Erreur réseau. Vérifiez votre connexion.');
//     Get.snackbar('Problème réseau', 'Impossible de contacter le serveur',
//         backgroundColor: Colors.orange);
//   } on HttpException catch (e) {
//     errorMessage('Erreur serveur (${e})');
//     Get.snackbar('Erreur technique', 'Code ${e} - Veuillez réessayer plus tard',
//         backgroundColor: Colors.orange);
//   } catch (e) {
//     errorMessage('Erreur inattendue');
//     debugPrint('OTP Request Error: $e');
//     Get.snackbar('Erreur technique', 'Une erreur inattendue est survenue',
//         backgroundColor: Colors.orange);
//   } finally {
//     isLoading.value = false;
//   }
// }

  Future<bool> requestOtp(phone) async {
    Otpcontroller otpcontroller = Get.find();
    otpcontroller.error.value = '';
    otpcontroller.number.value = 0;

    try {
      isLoading.value = true;
      errorMessage('');

      // 1. Récupération et validation du numéro
      // final phone = await storage.read('register_phone') ?? '';
      if (phone.isEmpty) {
        throw FormatException(
            'Aucun numéro enregistré. Veuillez recommencer l\'inscription.');
      }

      // 2. Nettoyage et validation stricte
      final cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
      if (!RegExp(r'^\+?\d{8,15}$').hasMatch(cleanedPhone)) {
        throw FormatException('Format de numéro invalide');
      }

      // 3. Préparation du numéro pour l'API (utilise le même numéro partout)
      final phoneForApi = cleanedPhone.startsWith('+')
          ? cleanedPhone.substring(1)
          : cleanedPhone;

      // 4. Envoi sécurisé avec timeout
      final response = await http
          .post(
            Uri.parse(
                "https://api.dev.onyfastbank.com/bulk_sms/otp_generate_v2.php"),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-API-Key':
                  '965fc5d7360d21f0a4d6a460774c0256b1ae16ce6753a4154eba8ec90a4271a6'
            },
            body: jsonEncode({
              'phone_number': phoneForApi, // Utilise le numéro unifié
            }),
          )
          .timeout(const Duration(seconds: 30));

      // 5. Gestion de la réponse
      if (response.statusCode != 200) {
        throw HttpException('Erreur serveur');
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data['success'] != true) {
        // Get.snackbar('voila le data', 'voila le data ${data["message"]}');
        otpcontroller.error.value = data["message"];
        throw Exception(data['message'] ?? 'Échec de génération OTP');
      }
      if (data['success'] == true) {
        otpcontroller.error.value = '';
        otpcontroller.number.value = data["attempts"] ?? 0;

        // Get.snackbar('voila le data', 'voila le data ${data["attempts"]}');
      }
      // 6. Stockage sécurisé de l'OTP (optionnel selon besoin)
      otp.value = data['otp']?.toString() ?? '';

      // 7. Feedback utilisateur
      SnackBarService.success(
        title: 'Code de vérification envoyé',
        'Un code à 6 chiffres a été envoyé au ${obfuscatePhone(cleanedPhone)}',
      );

      debugPrint('OTP requested for $phoneForApi');
      return true; // Succès
    } on FormatException catch (e) {
      errorMessage(e.message);
      SnackBarService.error(
        title: 'Erreur de format',
        e.message,
      );
    } on TimeoutException {
      errorMessage('Délai dépassé. Veuillez réessayer.');
      SnackBarService.error(
        'Problème de connexion',
      );
    } on http.ClientException {
      errorMessage('Erreur réseau. Vérifiez votre connexion.');
      SnackBarService.networkError();
      // SnackBarService.error(
      //   title: 'Problème réseau',
      //   'Impossible de contacter le serveur',
      // );
    } on HttpException catch (e) {
      errorMessage('Erreur serveur ($e)');
      // Get.snackbar('Erreur technique', 'Code $e - Veuillez réessayer plus tard',
      //     backgroundColor: Colors.orange);
    } catch (e) {
      errorMessage('Erreur inattendue');
      debugPrint('OTP Request Error: $e');
      // Get.snackbar('Erreur technique', 'Une erreur inattendue est survenue',
      //     backgroundColor: Colors.orange);
    } finally {
      isLoading.value = false;
    }

    return false; // En cas d'échec
  }

// Helper pour masquer une partie du numéro
  String obfuscatePhone(String phone) {
    if (phone.length < 4) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 2)}';
  }
//   Future<void> requestOtp() async {
//   isLoading.value = true;

//   try {
//     // Priorité 1: phoneNumber.value
//     // Priorité 2: register_phone dans le stockage
//     // Priorité 3: telephone dans le stockage
//     String phone = phoneNumber.value;

//     if (phone.isEmpty) {
//       phone = await storage.read('register_phone') ?? '';
//     }

//     if (phone.isEmpty) {
//       phone = await storage.read('telephone') ?? '';
//     }

//     if (phone.isEmpty) {
//       Get.snackbar('Erreur', 'Veuillez fournir un numéro de téléphone',
//           backgroundColor: Colors.orange);
//       return;
//     }

//     // Nettoyage du numéro
//     final cleanedPhone = phone.replaceAll("+", "").trim();

//     final response = await http.post(
//       Uri.parse('https://api.dev.onyfastbank.com/bulk_sms/otp_generate.php'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'phone_number': cleanedPhone}),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['success'] == true) {
//         otp.value = data['otp'] ?? '';
//         Get.snackbar('Succès', 'OTP envoyé au $cleanedPhone',
//             backgroundColor: Colors.green);
//       } else {
//         throw Exception(data['message'] ?? 'Échec de l\'envoi OTP');
//       }
//     } else {
//       throw Exception('Statut HTTP ${response.statusCode}');
//     }
//   } catch (e) {
//     Get.snackbar('Erreur OTP', e.toString().split(':')[0],
//         backgroundColor: Colors.orange);
//   } finally {
//     isLoading.value = false;
//   }
// }
//Verification de l'OTP
//  Future<void> verifyAndRegister(String phone, String password) async {
//   isLoading.value = true;
//   print(phone);
//   print(password);
//   print(otp.value.trim());

//   try {
//     // Validation des entrées
//     if (phone.isEmpty) {
//       Get.snackbar('Erreur', 'Aucun numéro de téléphone disponible', backgroundColor: Colors.orange);
//       return;
//     }

//     if (otp.value.isEmpty || otp.value.length != 6) {
//       Get.snackbar('Erreur', 'Veuillez entrer un code OTP valide (6 chiffres)', backgroundColor: Colors.orange);
//       return;
//     }

//     // Nettoyage du numéro
//     final cleanedPhone = phone.replaceAll("+", "").trim();

//     // Vérification OTP
//     final response = await http.post(
//       Uri.parse('https://api.dev.onyfastbank.com/bulk_sms/otp_verify.php'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'phone_number': cleanedPhone,
//         'otp': otp.value.trim(),
//       }),
//     ).timeout(const Duration(seconds: 10));

//     // Log de la réponse
//     debugPrint('Réponse de vérification OTP: ${response.body}');

//     if (response.statusCode != 200) {
//       throw Exception('Erreur de vérification OTP (Statut: ${response.statusCode})');
//     }

//     final result = jsonDecode(response.body);
//     if (result['success'] != true) {
//       throw Exception(result['message'] ?? 'Échec de la vérification OTP');
//     }

//     // OTP vérifié avec succès, procéder à l'enregistrement
//     // Enregistrement de l'utilisateur
//     final registerResponse = await http.post(
//       Uri.parse('$baseUrl/api/register'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept' : 'application/json'

//         },
//       body: jsonEncode({
//         'telephone': cleanedPhone,
//         'password': password,
//         'password_confirmation': password,
//       }),
//     );

//     // Log de la réponse d'enregistrement
//     print(registerResponse.body);

//     if (registerResponse.statusCode != 200 && registerResponse.statusCode != 201) {
//       final registerData = jsonDecode(registerResponse.body);
//       throw Exception(registerData['message'] ?? 'Échec de l\'enregistrement (Statut: ${registerResponse.statusCode})');
//     }

//     final registerData = jsonDecode(registerResponse.body);
//     await _storeUserData(registerData);
//     await storage.write('is_verified', true);

//     // Stockage des informations utilisateur
//     token.value = registerData['token'];
//     userInfo.value = registerData['user'];
//     walletInfo.value = registerData['wallet'];
//     transactionInfo.value = registerData['transaction_types'] ?? [];

//     // Stocker les informations dans GetStorage
//     await storage.write('token', token.value);
//     await storage.write('userInfo', userInfo.value);
//     await storage.write('walletInfo', walletInfo.value);
//     await storage.write('transactionInfo', transactionInfo.value);

//     Get.snackbar('Succès', 'Vérification OTP et inscription réussies', backgroundColor: Colors.green);
//     Get.offAll(() => MenuScreen());

//   } on SocketException {
//     Get.snackbar('Erreur', 'Problème de connexion internet', backgroundColor: Colors.orange);
//   } on TimeoutException {
//     Get.snackbar('Erreur', 'Le serveur a mis trop de temps à répondre', backgroundColor: Colors.orange);
//   } on FormatException {
//     Get.snackbar('Erreur', 'Erreur de format des données reçues', backgroundColor: Colors.orange);
//   } catch (e) {
//     Get.snackbar('Erreur', e.toString().split(':').first, backgroundColor: Colors.orange);
//   } finally {
//     isLoading.value = false;
//   }
// }

// Future<void> verifyAndRegister(String phone, String password) async {
//   isLoading.value = true;
//   print('Téléphone : $phone');
//   print('Mot de passe : $password');
//   print('OTP : ${otp.value.trim()}');

//   try {
//     // Validation des entrées
//     if (phone.isEmpty) {
//       Get.snackbar('Erreur', 'Aucun numéro de téléphone disponible', backgroundColor: Colors.orange);
//       return;
//     }

//     if (otp.value.isEmpty || otp.value.length != 6) {
//       Get.snackbar('Erreur', 'Veuillez entrer un code OTP valide (6 chiffres)', backgroundColor: Colors.orange);
//       return;
//     }

//     // Nettoyage du numéro
//     final cleanedPhone = phone.replaceAll("+", "").trim();

//     // Vérification OTP
//     final response = await http.post(
//       Uri.parse('https://api.dev.onyfastbank.com/bulk_sms/otp_verify.php'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'phone_number': cleanedPhone,
//         'otp': otp.value.trim(),
//       }),
//     ).timeout(const Duration(seconds: 10));

//     debugPrint('Réponse de vérification OTP: ${response.body}');

//     if (response.statusCode != 200) {
//       throw Exception('Erreur de vérification OTP (Statut: ${response.statusCode})');
//     }

//     final result = jsonDecode(response.body);
//     if (result['success'] != true) {
//       throw Exception(result['message'] ?? 'Échec de la vérification OTP');
//     }

//     // OTP vérifié avec succès, procéder à l'enregistrement
//     print('>>> Envoi des données d\'enregistrement...');
//     print({
//       'telephone': cleanedPhone,
//       'password': password,
//       'password_confirmation': password,
//     });

//     final registerResponse = await http.post(
//       Uri.parse('$baseUrl/api/register'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//       body: jsonEncode({
//         'telephone': cleanedPhone,
//         'password': password,
//         'password_confirmation': password,
//       }),
//     );

//     print('>>> Statut Enregistrement: ${registerResponse.statusCode}');
//     print('>>> Réponse Enregistrement: ${registerResponse.body}');

//     if (registerResponse.statusCode != 200 && registerResponse.statusCode != 201) {
//       final registerData = jsonDecode(registerResponse.body);

//       if (registerData is Map && registerData.containsKey('errors')) {
//         print('>>> Erreurs de validation: ${registerData['errors']}');
//       }

//       throw Exception(registerData['message'] ?? 'Échec de l\'enregistrement (Statut: ${registerResponse.statusCode})');
//     }

//     final registerData = jsonDecode(registerResponse.body);

//     await _storeUserData(registerData);
//     await storage.write('is_verified', true);

//     // Stockage des informations utilisateur
//     token.value = registerData['token'];
//     userInfo.value = registerData['user'];
//     walletInfo.value = registerData['wallet'];
//     transactionInfo.value = registerData['transaction_types'] ?? [];

//     // Stocker dans GetStorage
//     await storage.write('token', token.value);
//     await storage.write('userInfo', userInfo.value);
//     await storage.write('walletInfo', walletInfo.value);
//     await storage.write('transactionInfo', transactionInfo.value);

//     Get.snackbar('Succès', 'Vérification OTP et inscription réussies', backgroundColor: Colors.green);
//     Get.offAll(() => MenuScreen());

//   } on SocketException {
//     Get.snackbar('Erreur', 'Problème de connexion internet', backgroundColor: Colors.orange);
//   } on TimeoutException {
//     Get.snackbar('Erreur', 'Le serveur a mis trop de temps à répondre', backgroundColor: Colors.orange);
//   } on FormatException {
//     Get.snackbar('Erreur', 'Erreur de format des données reçues', backgroundColor: Colors.orange);
//   } catch (e) {
//     print('>>> Exception attrapée: $e');
//     Get.snackbar('Erreur', e.toString().split(':').last.trim(), backgroundColor: Colors.orange);
//   } finally {
//     isLoading.value = false;
//   }
// }

  Future<void> verifyAndLogin(String phone, String password, bool verif) async {
    bool voir = verif;

    // testConnection();

    // return;

    // Get.snackbar('voila le code ${password} , indicatif $phone', 'voila le co');
    // isLoading.value = true;
    // print("Verifiy and Register");
    // print('📞 Téléphone saisi : $phone');
    // print('🔐 Mot de passe saisi : $password');
    // print('🔢 OTP saisi : ${otp.value.trim()}');

    try {
      // 1. Validation des entrées
      if (phone.isEmpty) {
        SnackBarService.error(
          title: 'Erreur',
          'Aucun numéro de téléphone disponible',
        );
        return;
      }

      if (otp.value.isEmpty || otp.value.length != 6) {
        SnackBarService.error(
          title: 'Erreur',
          'Veuillez entrer un code OTP valide (6 chiffres)',
        );
        return;
      }

      // 2. Nettoyage du numéro
      final cleanedPhone = phone.replaceAll("+", "").trim();
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "X-API-Key":
            "965fc5d7360d21f0a4d6a460774c0256b1ae16ce6753a4154eba8ec90a4271a6"
      };
      try {
        final request = http.Request(
          'POST',
          Uri.parse(
              "https://api.dev.onyfastbank.com/bulk_sms/otp_verify_v2.php"),
        );

        request.body = json.encode({
          "phone_number": cleanedPhone,
          "otp": otp.value.trim(),
        });

        request.headers.addAll(headers);

        final response = await request.send();

        if (response.statusCode == 200) {
          final result = await response.stream.bytesToString();
          print("✅ Réponse API aa : $result  ");

          final data = jsonDecode(result);

          if (data['success'] == true) {
            if (verif == false) {
              await login1(phone, password);
              return;
            }

// ✅ Nettoyage du numéro : supprime "+" et espaces
            final telephone = phone
                .replaceFirst(RegExp(r'^\+'), '') // enlève le + au début
                .replaceAll(RegExp(r'\s+'), ''); // enlève les espaces

            if (verif == true)
              Get.offAll(
                () => ResetpasswordSansToken(),
                arguments: {
                  "telephone": telephone,
                },
              );

            SnackBarService.success(
              title: 'Succès',
              'Vérification OTP réussie',
            );
          } else {
            SnackBarService.error(
              title: 'Erreur',
              data['message'] ?? 'Vérification OTP échouée',
            );
          }
        } else {
          final result = await response.stream.bytesToString();

          final data = jsonDecode(result);

          print(
              "❌ Erreur serveur (${response.statusCode}) : ${response.reasonPhrase}");
          if (data['message'] != null)
            SnackBarService.info(
              '${data['message']}',
            );
        }
      } catch (e) {
        print("⚠️ Exception attrapée : $e");
        SnackBarService.error(
          title: 'Erreur',
          'Une erreur est survenue. $e',
        );
      }
    } on SocketException {
      SnackBarService.warning(
        'Problème de connexion internet',
      );
    } on TimeoutException {
      // SnackBarService.warning(
      //   '',
      // );
    } on FormatException {
      // SnackBarService.error(
      //   title: 'Erreur',
      //   'Erreur de format des données reçues',
      // );
    } catch (e) {
      SnackBarService.error(
        title: 'Erreur',
        e.toString().split(':').first,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyAndRegister(String phone, String password, indicatif, code,
      String codeParrain) async {
    // testConnection();
    // return;
    isLoading.value = true;
    print("Verifiy and Register");
    print('📞 Téléphone saisi : $phone');
    print('🔐 Mot de passe saisi : $password');
    print('🔢 OTP saisi : ${otp.value.trim()}');

    print('voila le code $code , indicatif $indicatif');

    try {
      // 1. Validation des entrées
      if (phone.isEmpty) {
        SnackBarService.info(
          'Aucun numéro de téléphone disponible',
        );
        return;
      }

      if (otp.value.isEmpty || otp.value.length != 6) {
        SnackBarService.warning(
          'Veuillez entrer un code OTP valide (6 chiffres)',
        );
        return;
      }

      // 2. Nettoyage du numéro
      final cleanedPhone = phone.replaceAll("+", "").trim();

      // 3. Vérification OTP
      final otpResponse = await http
          .post(
            Uri.parse(
                'https://api.dev.onyfastbank.com/bulk_sms/otp_verify.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phone_number': cleanedPhone,
              'otp': otp.value.trim(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Réponse de vérification OTP: ${otpResponse.body}');

      // SnackBarService.info(jsonDecode(otpResponse.body)['message']);

      // if (otpResponse.statusCode != 200 ||
      //     (jsonDecode(otpResponse.body)['status'] != true ||
      //         otpResponse.statusCode == 200)) {
      //   SnackBarService.info(jsonDecode(otpResponse.body)['message']);
      //   throw Exception(
      //       'Erreur de vérification OTP (Statut: ${jsonDecode(otpResponse.body)['message']})');
      // }

      final responseBody = jsonDecode(otpResponse.body);

      print(responseBody);

// Force la conversion en booléen en toute sécurité
      final bool isSuccess = responseBody['success'] == true;

      if (isSuccess) {
        SnackBarService.success(responseBody['message']);
      } else {
        print('Nous sommes dans l\'erreur');
        SnackBarService.error(responseBody['message']);
        return;
      }

      // final otpResult = jsonDecode(otpResponse.body);
      // if (otpResult['success'] != true) {
      //   throw Exception(otpResult['message'] ?? 'Échec de la vérification OTP');
      // }

      // 4. Enregistrement de l'utilisateur
      var deviceskey = await getDeviceIMEI();
      print('>>> Envoi des données d\'enregistrement...');
      print({
        '\ntelephone': cleanedPhone,
        '\npassword': password,
        '\npassword_confirmation': password,
        '\ncode': code,
        '\nindicatif': indicatif,
        "\ndevice": deviceskey
      });

      print(
          '>>> baseUrl utilisé : ${ApiEnvironmentController.to.baseUrl}\n code parrain: $codeParrain');

      try {
        var ip = await ValidationTokenController.to.getPublicIP();
        final networkInfo = await IpInfoService.getNetworkInfo();

        final registerResponse = await http
            .post(
              Uri.parse('${ApiEnvironmentController.to.baseUrl}/register'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'telephone': cleanedPhone,
                'password': password,
                'password_confirmation': password,
                'code': code,
                'indicatif': indicatif,
                'device': deviceskey ?? '',
                'code_parrain': codeParrain,
                'ip': ip,
                "device_type": "mobile",
                "os": Platform.isIOS ? 'Iphone' : 'Android',
                "browser": "Application native",
                "ip_address": networkInfo?.ipAddress,
                "country": networkInfo?.isp,
                "country_code": networkInfo?.countryCode,
                "city": networkInfo?.city,
                "region": networkInfo?.region,
                "latitude": networkInfo?.latitude,
                "longitude": networkInfo?.longitude,
                "isp": networkInfo?.isp
              }),
            )
            .timeout(const Duration(seconds: 10));

        print('✅ Statut Enregistrement: ${registerResponse.statusCode}');
        print('📦 Réponse Enregistrement: ${registerResponse.body}');
        print('📦 test entré');
        print(
            '📦 test entré ${jsonDecode(registerResponse.body)["message"]}\n codeparrain: $codeParrain');

        if (registerResponse.statusCode != 200 &&
            registerResponse.statusCode != 201) {
          final errorData = jsonDecode(registerResponse.body);

          SnackBarService.error(errorData['message'] ?? errorData["error"]);
          return;
          throw Exception(errorData['message'] ??
              errorData['error'] ??
              'Échec de l\'enregistrement');
        }

        final registerData = jsonDecode(registerResponse.body);
        await _storeUserData(registerData);
        await storage.write('is_verified', true);

        // Stockage des données dans les variables
        token.value = registerData['token'];
        userInfo.value = registerData['user'];
        walletInfo.value = registerData['wallet'];
        transactionInfo.value = registerData['transaction_types'] ?? [];

        // Stockage persistant
        await storage.write('token', token.value);
        await storage.write('telephone', cleanedPhone);
        await storage.write('userInfo', userInfo.value);
        await storage.write('walletInfo', walletInfo.value);
        await storage.write('transactionInfo', transactionInfo.value);
        await SecureTokenController.to.saveToken(token.value);

        await SecureTokenController.to.saveTelephone(cleanedPhone);
        await fetchSolde();

        Get.offAll(() => MenuScreen());
        SnackBarService.success(
          'Vérification OTP et inscription réussies',
        );
        //Partie Supplementaire storage User fait par Luc

        await storage.write('nom', null);
        await storage.write('prenom', null);
        await storage.write('adresse', null);
        await storage.write('email', null);
        await storage.write('profilePhotoUrl', null);

        await fetchSolde();

        //  Get.offAll(() => MenuScreen());
        Get.offAll(() => InscritInfoSuplementaire());
      } on SocketException catch (e) {
        print('❌ SocketException: $e');
        // SnackBarService.error(
        //   'Impossible de se connecter',
        // );
      } on TimeoutException {
        print('❌ Timeout détecté');
        // SnackBarService.error(
        //   'Impossible de se connecter',
        // );
      } on FormatException catch (e) {
        print('❌ FormatException: $e');
        // Get.snackbar('Erreur', 'Réponse du serveur mal formatée.',
        //     backgroundColor: Colors.orange);
      } catch (e) {
        print('❌ Autre erreur lors de l\'enregistrement : ${e.toString()}');
        // Get.snackbar('Erreur', 'Erreur inattendue : ${e.toString()}',
        //     backgroundColor: Colors.orange);
      }
    } on SocketException {
      SnackBarService.warning(
        'Problème de connexion internet',
      );
    } on TimeoutException {
      SnackBarService.warning(
        'Connexion Trop Lente',
      );
    } on FormatException {
      print('❌ FormatException: Erreur de format des données reçues');
      // SnackBarService.warning('Erreur de format des données reçues',
      //    );
    } catch (e) {
      // Get.snackbar('Erreur', e.toString(),
      //     backgroundColor: Colors.orange);
    } finally {
      isLoading.value = false;
    }
  }

  void testConnection() async {
    try {
      final response =
          await http.get(Uri.parse(baseUrl)).timeout(Duration(seconds: 10));
      print("✅ Réponse du serveur : ${response.body}");
    } catch (e) {
      print("❌ Erreur de connexion : $e");
    }
  }

  Future<void> _storeUserData(Map<String, dynamic> responseData) async {
    try {
      if (responseData['user'] == null ||
          responseData['wallet'] == null ||
          responseData['token'] == null) {
        throw Exception(
            'Réponse API incomplète. Veuillez contacter le support.');
      }

      // await fetchSolde();
    } catch (e) {
      debugPrint('Storage error: $e');
      rethrow;
    }
  }

  void setUserCredentials(String phone, String pwd, String confirmPwd) {
    _user.telephone = phone;
    _user.password = pwd;
    _user.confirmPassword = confirmPwd;
  }

  void setOtp(String otp) {
    _user.otp = otp;
  }

  ///Vérification de l'OTP
  ///   // Vérification OTP
  // Future<void> verifyOtp(String enteredOtp) async {
  //   isLoading.value = true;

  //   final phone = storage.read('register_phone') ?? phoneNumber.value;
  //   if (phone.isEmpty) {
  //     Get.snackbar('Erreur', 'Numéro de téléphone manquant');
  //     return;
  //   }

  //   try {
  //     final response = await http.post(
  //       Uri.parse('https://api.dev.onyfastbank.com/bulk_sms/otp_verify.php'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'phone_number': phone,
  //         'otp': enteredOtp,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (data['success'] == true) {
  //         // Activation du compte après vérification réussie
  //         // await activateAccount(phone);
  //         Get.offAll(() => MenuScreen());
  //       } else {
  //         throw Exception(data['message'] ?? 'OTP incorrect');
  //       }
  //     } else {
  //       throw Exception('Statut HTTP ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     Get.snackbar('Erreur', 'Échec de vérification: ${e.toString()}');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
//Methode pour C2C
  // Future<void> c2c() async {
  //   if (fromAccountId.text.isEmpty || toAccountId.text.isEmpty ||
  //       last4Digits.text.isEmpty || amount.text.isEmpty) {
  //     Get.snackbar('Error', 'Please fill in all fields');
  //     return;
  //   }

  //   isLoading.value = true;
  //   // Show loading dialog
  //   final loading = Get.dialog(Center(child: CircularProgressIndicator()));

  //   final url = "https://api.dev.onyfastbank.com/v1/gtp-c2c.php?fromAccountId=${fromAccountId.text}&toAccountId=${toAccountId.text}&last4digits=${last4Digits.text}&amount=${amount.text}";
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     if (response.statusCode != 200) {
  //       throw Exception('Response status: ${response.statusCode}');
  //     }

  //     final json = jsonDecode(response.body);
  //     print(json);

  //     if (json['status']?['code'] == 200) {
  //       Get.snackbar('Transfert C2C', 'Transfert effectué',
  //           messageText: Text('ID Transaction: ${json['data']['newBalance']}\nNouveau solde: ${json['data']['newBalance']}'));
  //     } else {
  //       Get.snackbar('Transfert C2C', 'Erreur dans la requête',
  //           messageText: Text(json['data']?['detail']?.toString() ?? 'Details not available'));
  //     }
  //   } catch (error) {
  //     print(error.toString());
  //     Get.snackbar('Transfert C2C', 'Erreur', messageText: Text(error.toString()));
  //   } finally {
  //     isLoading.value = false;
  //     Get.back(); // Dismiss loading dialog
  //   }
  // }

//Fonction pour le solde
// Fonction pour le solde
  Future<WalletModel?> fetchSolde() async {
    try {
      // Vérification des données nécessaires
      final telephone = storage.read('telephone');
      final token = storage.read('token');

      if (telephone == null) {
        throw Exception('Numéro de téléphone non trouvé');
      }

      if (token == null) {
        throw Exception('Session expirée, veuillez vous reconnecter');
      }

      isLoading.value = true;
      var deviceskey = await ValidationTokenController.to.getDeviceIMEI();
      var ip = await ValidationTokenController.to.getPublicIP();
      // Envoi de la requête avec timeout
      final response = await http
          .post(Uri.parse('${ApiEnvironmentController.to.baseUrl}/get_solde'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'telephone': telephone,
                'token': token,
                'device': deviceskey,
                "ip": ip
              }))
          .timeout(const Duration(seconds: 5));

      // Journalisation pour le débogage
      debugPrint('Réponse solde - Code: ${response.statusCode}');
      debugPrint('Réponse solde - Body: ${response.body}');

      // Traitement de la réponse
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Validation des données reçues
        if (responseData['wallet'] == null) {
          throw FormatException('Structure de données incorrecte');
        }

        final wallet = WalletModel.fromJson(responseData['wallet']);

        // Mise à jour des données locales
        await Future.wait([
          storage.write('walletInfo', wallet.toMap()),
          storage.write('solde', wallet.solde),
        ]);

        walletInfo.value = wallet.toMap();
        SoldewalletInfo.value = wallet.toMap();

        // Journalisation du succès
        debugPrint('Solde mis à jour: ${wallet.solde} FCFA');

        // Affichage d'un Snackbar pour indiquer que le solde a été mis à jour
        // _showSnackbar('Succès',
        //     'Solde actualisé avec succès: ${wallet.solde} FCFA', Colors.orange);
        return wallet;
      }
      // Gestion des erreurs HTTP spécifiques
      else if (response.statusCode == 401) {
        SnackBarService.error('Session expirée, veuillez vous reconnecter',
            title: "Erreur");
        throw Exception('Session expirée, veuillez vous reconnecter');
      } else if (response.statusCode == 404) {
        //  SnackBarService.error('Portefeuille non trouvé', title: "Erreur");
        throw Exception('Portefeuille non trouvé');
      } else {
        // SnackBarService.error('Erreur serveur', title: "Erreur");
        throw HttpException('Erreur serveur');
      }
    }
    // Gestion des exceptions spécifiques
    on SocketException {
      // SnackBarService.error('Problème de connexion internet', title: "Erreur");
      throw Exception('Problème de connexion internet');
    } on TimeoutException {
      // SnackBarService.error('',
      //     title: "Erreur");
      throw Exception('Le serveur met trop de temps à répondre');
    } on FormatException catch (e) {
      // SnackBarService.error(
      //     title: 'Erreur', 'Données reçues invalides: ${e.message}');
      throw Exception('Données reçues invalides: ${e.message}');
    } on HttpException catch (e) {
      // SnackBarService.error('Erreur HTTP: ${e.message}', title: "Erreur");
      throw Exception('Erreur HTTP: ${e.message}');
    } catch (e) {
      // SnackBarService.error('Erreur inattendue: ${e.toString().split(':')[0]}',
      //     title: "Erreur");
      throw Exception('Erreur inattendue: ${e.toString().split(':')[0]}');
    } finally {
      isLoading.value = false;
    }
  }

// Méthode pour afficher le Snackbar
// Conserver la fonction _showSnackbar de l'ancien code
// void _showSnackbar(BuildContext context, String message, Color color) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text(message),
//       backgroundColor: color,
//       duration: Duration(seconds: 3),
//     ),
//   );
// }

  // Méthode pour charger les informations de l'utilisateur au démarrage de l'application
  void loadUserInfo() {
    token.value = storage.read('token') ?? '';
    userInfo.value = storage.read('userInfo') ?? {};
    walletInfo.value = storage.read('walletInfo') ?? {};
    transactionInfo.value = storage.read('transactionInfo') ?? [];
  }

  UserModel? getUser() {
    final userJson = storage.read('userInfo');
    if (userJson is String) {
      return UserModel.fromJson(
          json.decode(userJson)); // Décodez si c'est une chaîne
    }
    return null;
  }

  WalletModel? getWallet() {
    final walletJson = storage.read('walletInfo');
    if (walletJson is String) {
      return WalletModel.fromJson(
          json.decode(walletJson)); // Décodez si c'est une chaîne
    }
    return null;
  }

  String? getToken() {
    return storage.read('token'); // Le token devrait déjà être une chaîne
  }

  // Méthode pour déconnecter l'utilisateur
  void logout() {
    // final recup=Get.find<RecentTransactionsController>();
    // recup.fetchTransactions();

    storage.remove('token');
    storage.remove('userInfo');
    storage.remove('walletInfo');
    storage.remove('transactionInfo');
    token.value = '';
    userInfo.value = {};
    walletInfo.value = {};
    transactionInfo.value = [];

    Get.offAll(() => Home());
  }

  Future<void> showSuccessDialog(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Succès'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showErrorDialog(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
