import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/model/Onypay/payementEnAttente.dart';
import 'package:onyfast/utils/device.dart';

class PaiementOnyPayService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.onyfastbank.com/api/v1/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  String? _token;

  /// 🔐 Injecter le token (venant de AuthOnyPayService)
  void setToken(String token) {
    _token = token;
  }

  /// 📲 OTP en attente (pending)
  Future<PendingPaymentsResponse> payementOtpEnAttente({
    required String device,
  }) async {
    try {
      final token = SecureTokenController.to.onyPayToken.value;
      if (token == null) {
        print("❌ Token OnyPay null");
        return PendingPaymentsResponse(success: false, data: [], count: 0);
      }

      final response = await _dio.get(
        'client/otp/pending',
        queryParameters: {"device": device},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print("✅ OTP en attente récupéré");
        return PendingPaymentsResponse.fromJson(response.data);
        print("✅ OTP en attente récupéré");
      } else {
        print("❌ Erreur OTP: ${response.statusMessage}");
        return PendingPaymentsResponse(success: false, data: [], count: 0);
      }
    } on DioException catch (e) {
      print("🔥 Erreur Dio OTP: ${e.response?.data ?? e.message}");
      if (e.response?.data != null) {
        try {
          return PendingPaymentsResponse.fromJson(e.response!.data);
        } catch (_) {
          return PendingPaymentsResponse(success: false, data: [], count: 0);
        }
      }
      return PendingPaymentsResponse(success: false, data: [], count: 0);
    } catch (e) {
      print("⚠️ Erreur inconnue OTP: $e");
      return PendingPaymentsResponse(success: false, data: [], count: 0);
    }
  }

  Future<Map<String, dynamic>?> validateOtp({
    required String paymentId,
    required String code,
  }) async {
    try {
      final token = SecureTokenController.to.onyPayToken.value;
      final device = await getDeviceIMEI();
      final response = await _dio.post(
        'client/payments/$paymentId/otp/validate',
        data: jsonEncode({
          "code": code,
          "device": device,
        }),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("✅ OTP validé avec succès");
        return response.data;
      } else {
        print("❌ Erreur validation OTP: ${response.statusMessage}");
        return null;
      }
    }on DioException catch (e) {
    // ✅ Récupérer la réponse même en cas d'erreur HTTP (400, 422...)
    if (e.response?.data != null) {
      print("⚠️ OTP échoué: ${e.response?.data}");
      return e.response!.data is Map<String, dynamic>
          ? e.response!.data
          : null;
    }
    print("🔥 Erreur Dio validation OTP: ${e.message}");
    return null;
  } catch (e) {
    print("⚠️ Erreur inconnue validation OTP: $e");
    return null;
  }
  }

  /// 🔁 RENVOYER OTP
  Future<Map<String, dynamic>?> renvoyerOtp({
    required String paymentId,
    required String device,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        'client/payments/$paymentId/otp/resend',
        data: jsonEncode({
          "device": device,
        }),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("✅ OTP renvoyé avec succès");
        return response.data;
      } else {
        print("❌ Erreur renvoi OTP: ${response.statusMessage}");
        return null;
      }
    } on DioException catch (e) {
    // ✅ Récupérer la réponse même en cas d'erreur HTTP (400, 422...)
    if (e.response?.data != null) {
      print("⚠️ Resend OTP échoué: ${e.response?.data}");
      return e.response!.data is Map<String, dynamic>
          ? e.response!.data
          : null;
    }
    print("🔥 Erreur Dio renvoi OTP: ${e.message}");
    return null;
  } catch (e) {
    print("⚠️ Erreur inconnue renvoi OTP: $e");
    return null;
  }
  }
}
