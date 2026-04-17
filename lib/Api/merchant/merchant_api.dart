// services/merchant_service.dart
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/model/merchant/merchant.dart';
import 'dart:convert';

class MerchantService {
  static final Dio _dio = Dio();

  static Future<MerchantResponse?> fetchMerchants() async {
    try {

    final storage = GetStorage();
    final token = storage.read('token');
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await _dio.request(
        '${ApiEnvironmentController.to.baseUrl}/merchant/liste',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Réponse API: ${json.encode(response.data)}');
        return MerchantResponse.fromJson(response.data);
      } else {
        print('❌ Erreur HTTP: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('❌ Erreur Dio: ${e.message}');
      if (e.response != null) {
        print('❌ Réponse d\'erreur: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('❌ Erreur générale: $e');
      return null;
    }
  }

  // Méthode pour configurer les intercepteurs Dio si nécessaire
  static void setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🚀 Requête: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Réponse: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ Erreur: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }
}