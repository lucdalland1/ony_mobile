// lib/data/models/otp_response.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData;
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/View/otp_mail.dart';
import 'package:onyfast/Widget/alerte.dart';

class OtpResource {
  
  
  
  /// Envoie l’OTP via /api/senotp avec telephone (FormData)
  Future<OtpResponse> sendOtp() async {


                          final storage = GetStorage();
                          final userInfo = storage.read('userInfo');
                          print(" voila les users $userInfo");
                          String telephone = userInfo['telephone'];
    final dio = Dio();
    final url = '${ApiEnvironmentController.to.baseUrl}/send-otp';
     var ip=await ValidationTokenController.to.getPublicIP();
     var token=await SecureTokenController.to.token.value;
    try {
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };
      print('✅✅✅ Voilà le header $headers');
       var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
      final form = FormData.fromMap({
        'telephone': telephone,
        "device":deviceskey,
        'ip':ip
      });
      print('✅✅✅ Voila url : $url');
      final resp = await dio.request(
        url,
        data: form,
        options: Options(method: 'POST', headers: headers),
      );
      print("✅✅✅  voila la reponse $resp");

      // Statuts 200 ou 429 (quota) -> on parse le body JSON
      if (resp.data is Map<String, dynamic>) {
        print("envoie de l'otp succes 1$resp");
        print("envoie de l'otp succes 2${resp.data}");
        SnackBarService.warning(resp.data['message']
          );
          if (Get.isDialogOpen ?? false) {
        Get.until((route) => !Get.isDialogOpen!);
      }
       Get.to(
        OtpMail(),
        // Resetpassword(),
  transition: Transition.cupertino, // 👈 transition iOS
);

        return OtpResponse.fromJson(resp.data as Map<String, dynamic>);
      } else if (resp.data is String) {
        print("envoie de l'otp succes3 $resp");
        print("envoie de l'otp succes 4${resp.data}");
        return OtpResponse.fromRaw(resp.data as String);
      } else {

        // cas non JSON
        return OtpResponse(
          success: false,
          message: 'Réponse inattendue du serveur.',
        );
      }
    } on DioError catch (e) {
      if (Get.isDialogOpen ?? false) {
              Get.until((route) => !Get.isDialogOpen!);
      }
      print('✅✅✅✅✅✅ erreur ${e.toString()} ');
   // Si le serveur renvoie un JSON d’erreur on tente de parser
      if (e.response?.data is Map<String, dynamic>) {

        SnackBarService.info(
          "${e.response?.data['message']}\nRéessayer à : ${e.response?.data['retry_after']}",
        
        );
        return OtpResponse.fromJson(e.response!.data as Map<String, dynamic>);
      }
     SnackBarService.networkError();
      final status = e.response?.statusCode;
      return OtpResponse(
        success: false,
        message: 'Erreur réseau (${status ?? 'N/A'})',
      );
      
    } catch (e) {
      print('erreur $e');
      return OtpResponse(
        success: false,
        message: 'Erreur: $e',
      );
    }
  }

  Future<OtpResponse> sendOtpNumber(String telephone ) async {


                         
                          
    final dio = Dio();
    final url = '${ApiEnvironmentController.to.baseUrl}/senotp';
   var ip=await ValidationTokenController.to.getPublicIP();
    try {
      final headers = {
        'Accept': 'application/json',
      };
       var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
      final form = FormData.fromMap({
        'telephone': telephone,
        "device":deviceskey,
        'ip':ip
      });

      final resp = await dio.request(
        url,
        data: form,
        options: Options(method: 'POST', headers: headers),
      );
      print("envoie de l'otp");

      // Statuts 200 ou 429 (quota) -> on parse le body JSON
      if (resp.data is Map<String, dynamic>) {
        print("envoie de l'otp succes 1$resp");
        print("envoie de l'otp succes 2${resp.data}");
        SnackBarService.warning( title:  resp.data['message'],
        'Vérifier votre boite Mail'
        );

       Get.to(
        OtpMail(),
        // Resetpassword(),
  transition: Transition.cupertino, // 👈 transition iOS
);

        return OtpResponse.fromJson(resp.data as Map<String, dynamic>);
      } else if (resp.data is String) {
        print("envoie de l'otp succes3 $resp");
        print("envoie de l'otp succes 4${resp.data}");
        return OtpResponse.fromRaw(resp.data as String);
      } else {

        // cas non JSON
        return OtpResponse(
          success: false,
          message: 'Réponse inattendue du serveur.',
        );
      }
    } on DioError catch (e) {


   // Si le serveur renvoie un JSON d’erreur on tente de parser
      if (e.response?.data is Map<String, dynamic>) {

        SnackBarService.warning(
          "${e.response?.data['message']}\nRéessayer à : ${e.response?.data['retry_after']}",
          
        );
        return OtpResponse.fromJson(e.response!.data as Map<String, dynamic>);
      }
      SnackBarService.networkError();
      final status = e.response?.statusCode;
      return OtpResponse(
        success: false,
        message: 'Erreur réseau (${status ?? 'N/A'})',
      );
      
    } catch (e) {
      print('erreur $e');
      return OtpResponse(
        success: false,
        message: 'Erreur: $e',
      );
    }
  }



}

class OtpResponse {
  final bool success;
  final String message;

  /// présent si success=true
  final DateTime? expiresAt;
  final int? sentToday;

  /// présent si success=false (quota atteint)
  final String? retryAfter; // ex: "2H 30M"

  OtpResponse({
    required this.success,
    required this.message,
    this.expiresAt,
    this.sentToday,
    this.retryAfter,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
      sentToday: json['sent_today'] != null
          ? int.tryParse(json['sent_today'].toString())
          : null,
      retryAfter: json['retry_after']?.toString(),
    );
  }

  static OtpResponse fromRaw(String source) =>
      OtpResponse.fromJson(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
        if (sentToday != null) 'sent_today': sentToday,
        if (retryAfter != null) 'retry_after': retryAfter,
      };
}
