import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

import '../Api/Userapi.dart';

class AuthService extends GetxController {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final RxBool isLoggedIn = false.obs;
  final Rx<User?> currentUser = Rx<User?>(null);

  Future<void> login(String telephone, String password) async {
    try {
       var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
        var ip=await ValidationTokenController.to.getPublicIP();
      final response = await _dio.post(
        '${ApiEnvironmentController.to.baseUrl}/login',
        data: {'telephone': telephone, 'password': password,
        "device":deviceskey,
        'ip':ip
        },
      );
      print(response);
      if (response.statusCode == 200) {
        // final token = response.data['token'];
        // final userJson = response.data['user'];
        // final user = User.fromJson(userJson);
        // user.token = token; // Ajouter le token à l'objet User
        // print(response.data);
        // print(user);
        // print(userJson);

        // // Stocker le token et les informations de l'utilisateur
        // await _storage.write(key: 'token', value: token);
        // await _storage.write(key: 'user', value: user.toJson().toString());

        // currentUser.value = user;
        // isLoggedIn.value = true;

        // // Rediriger vers l'écran principal
        // Get.offAllNamed('/menu');
      } else {
        print('Erreur de connexion: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur de connexion: $e');
    }
  }

  // Future<void> autoLogin() async {
  //   final storedToken = await _storage.read(key: 'token');
  //   final storedUser = await _storage.read(key: 'user');

  //   if (storedToken != null && storedUser != null) {
  //     final user = User.fromJson(jsonDecode(storedUser));
  //     user.token = storedToken;
  //     currentUser.value = user;
  //     isLoggedIn.value = true;
  //   }
  // }

  // Future<void> logout() async {
  //   await _storage.delete(key: 'token');
  //   await _storage.delete(key: 'user');
  //   currentUser.value = null;
  //   isLoggedIn.value = false;
  //   Get.offAllNamed('/login');
  // }

  // Future<User?> getProfile() async {
  //   try {
  //     final storedToken = await _storage.read(key: 'token');
  //     if (storedToken != null) {
  //       final response = await _dio.get(
  //         '${ApiEnvironmentController.to.baseUrl}/user',
  //         options: Options(headers: {'Authorization': 'Bearer $storedToken'}),
  //       );

  //       if (response.statusCode == 200) {
  //         final user = User.fromJson(response.data);
  //         user.token = storedToken;
  //         await _storage.write(key: 'user', value: user.toJson().toString());
  //         currentUser.value = user;
  //         return user;
  //       } else {
  //         print("Erreur lors de la récupération du profil : ${response.statusCode}");
  //         return null;
  //       }
  //     } else {
  //       print("Aucun token trouvé.");
  //       return null;
  //     }
  //   } catch (e) {
  //     print("Erreur lors de la récupération du profil : $e");
  //     return null;
  //   }
  // }
}
