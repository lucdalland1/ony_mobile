import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Services/deconnexionUser.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/utils/device.dart';

class AuthOnyPayService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.onyfastbank.com/api/v1/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  /// 🔐 Connexion utilisateur OnyPay
  Future<Map<String, dynamic>?> login({
    required String phone,
    required String password,
    required String device,
  }) async {
    try {
      final response = await _dio.post(
        'client/auth/login',
        data: jsonEncode({
          "phone": phone,
          "password": password,
          "device": device,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Connexion OnyPay réussie");
        print('Data: ${response.data}');
        var aa = response.data['data'] ?? '';
        var token = aa['token'];
        print('luc voila son token $token');
         await SecureTokenController.to.saveOnyPayToken(token);

        print(
            'voila le token stocké ${SecureTokenController.to.onyPayToken.value}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response?.statusCode;

        if (statusCode == 403 || statusCode == 422) {
          await logoutUser();
          ValidationTokenController.to.validateToken();
          print("🚫 Accès refusé (403)");
          print("Message serveur: ${e.response?.data}");
          return {"error": true, "message": "Accès refusé"};
        } else {
          print("❌ Erreur HTTP: $statusCode");
          print("Message: ${e.response?.data}");
        }
      } else {
        print("🌐 Erreur réseau: ${e.message}");
      }

      return null;
    } catch (e) {
      print("⚠️ Erreur inconnue OnyPay: ${e.toString()}");
      return null;
    }
    return null;
  }

  Future<Map<String, dynamic>?> me() async {
    var device = (await getDeviceIMEI())!;
    try {
      final response = await _dio.get(
        'client/auth/me',
        queryParameters: {
          "device": device,
        },
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${SecureTokenController.to.onyPayToken.value}',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("✅ Infos utilisateur récupérées");
        return response.data;
      } else {
        print("❌ Erreur me(): ${response.statusMessage}");
        return null;
      }
    } on DioException catch (e) {
      print("🔥 Erreur Dio me(): ${e.response?.data ?? e.message}");
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      var device = (await getDeviceIMEI())!;
      var token = SecureTokenController.to.onyPayToken.value;
      print('new token $token');
      final response = await _dio.post(
        'client/auth/logout',
        data: jsonEncode({
          "device": device,
        }),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // 🔥 important
          },
        ),
      );

      if (response.statusCode == 200) {
        print("✅ Déconnexion réussie");

        return true;
      } else {
        print("❌ Erreur logout: ${response.statusMessage}");
        return false;
      }
    } on DioException catch (e) {
      print("🔥 Erreur Dio logout: ${e.response?.data ?? e.message}");
      return false;
    }
  }
}
