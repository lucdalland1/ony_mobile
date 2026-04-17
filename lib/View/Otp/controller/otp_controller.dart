import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:onyfast/View/Otp/model/otp.dart';

class OtpController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString otpCode = ''.obs;
  final RxString smsStatus = ''.obs;
  final RxString errorMessage = ''.obs;
  final Rx<OtpResponse?> otpResponse = Rx<OtpResponse?>(null);

  Future<void> generateOtp(String phoneNumber) async {
    try {
      isLoading(true);
      errorMessage('');
      otpResponse.value = null;

      final response = await http.post(
        Uri.parse('https://api.dev.onyfastbank.com/bulk_sms/otp_generate.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone_number': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final otpResponseData = OtpResponse.fromJson(responseData);
        otpResponse.value = otpResponseData;
        
        otpCode.value = otpResponseData.otp;
        
        // Parse the nested SMS data
        final smsData = json.decode(otpResponseData.smsResponse.data);
        smsStatus.value = '${smsData['resultat']} (Statut: ${smsData['statut']})';
        
      } else {
        errorMessage.value = 'Erreur serveur: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Erreur de connexion: ${e.toString()}';
    } finally {
      isLoading(false);
    }
  }
}