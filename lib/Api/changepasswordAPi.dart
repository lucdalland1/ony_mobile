// ignore: file_names
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/View/menuscreen.dart';
import 'package:onyfast/Widget/alerte.dart';

class ResetPasswordService {
  final Dio dio = Dio();

  Future<void> resetPassword({
    required BuildContext context,
    // required String telephone,
    required String password,
    required String confirmPassword,
  }) async {
    final storage = GetStorage();
    final token = storage.read('token');

    print('voila le token $token');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      // ignore: unnecessary_brace_in_string_interps
      'Authorization': 'Bearer ${token}',
    };
    var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
 var ip=await ValidationTokenController.to.getPublicIP();
    final data = jsonEncode({
      // "telephone": telephone,
      "password": password,
      "password_confirmation": confirmPassword,
      "device":deviceskey,
      'ip':ip
    });

    try {
      
      final response = await dio.request(
        '${ApiEnvironmentController.to.baseUrl}/pro/reset-password',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {

        storage.write('code_temporaire', false);
        Get.back();
        _showCupertinoDialog(
          context,
          title: "Succès",
          content: "Mot de passe réinitialisé avec succès !",
        );
        print("✅ ${response.data}");
        Get.offAll(() => MenuScreen());
      } else {
        print("Erreur status code: ${response.statusCode}");
        _showCupertinoDialog(
          context,
          title: "Erreur",
          content: "Échec : ${response.statusMessage ?? 'Erreur inconnue'}",
        );
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.data}");
      _showCupertinoDialog(
        context,
        title: "Erreur",
        content: e.response?.data['message'] ?? 'Erreur inconnue',
      );
    } catch (e) {
      print("Erreur inconnue: $e");
      _showCupertinoDialog(
        context,
        title: "Erreur",
        content: "Connexion impossible au serveur",
      );
    }
  }


Future<Map<String, dynamic>> resetPasswordSansToken({
  required String telephone,
  required String password,
}) async {




  try {
    var headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'x-api-key':
          'x6Af3nCWzUxxwvvw3aDosNQJw67/Nam6MCT9/uXNFguuRO0l53lGjpZhvdwpe0mXClhmdShMbtqiuaI7aSOMyg==',
    };
var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
 var ip=await ValidationTokenController.to.getPublicIP();
    var data = json.encode({
      "telephone": telephone,
      "password": password,
      "password_confirmation": password, // confirmation = même valeur
      "device":deviceskey,
      "ip":ip
    });

    var dio = Dio();
    var response = await dio.request(
      '${ApiEnvironmentController.to.baseUrl}/reset-password-sans-token',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print("✅ Succès : ${json.encode(response.data)}");
      SnackBarService.success("Mot de passe réinitialisé avec succès ");

      return response.data;
    } else {
      SnackBarService.error("Echec de modification du mot de passe");

      print("❌ Erreur serveur : ${response.statusMessage}");
      return {
        "success": false,
        "message": response.statusMessage,
      };
    }
  } on DioException catch (e) {
    // gestion erreur réseau / API
    print("⚠️ Erreur API : ${e.response?.data ?? e.message}");
    return {
      "success": false,
      "message": e.response?.data ?? e.message,
    };
  } catch (e) {
    print("⚠️ Erreur inattendue : $e");
    return {
      "success": false,
      "message": e.toString(),
    };
  }
}
  void _showCupertinoDialog(BuildContext context,
      {required String title, required String content}) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }
}
