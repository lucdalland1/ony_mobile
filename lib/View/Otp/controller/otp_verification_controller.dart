import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:onyfast/Widget/alerte.dart';

class OtpController extends GetxController {
  final String verifyOtpUrl = "https://api.dev.onyfastbank.com/bulk_sms/otp_verify.php";
  
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxBool isOtpVerified = false.obs;

  // Fonction pour vérifier automatiquement l'OTP quand il est reçu
  Future<void> verifyOtpAutomatically(String phoneNumber, String receivedOtp) async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await http.post(
        Uri.parse(verifyOtpUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone_number': phoneNumber,
          'otp': receivedOtp,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['phone_number'] == phoneNumber && 
            responseData['otp'] == receivedOtp) {
          isOtpVerified(true);
           SnackBarService.warning( 'OTP vérifié avec succès');
          // Vous pouvez naviguer vers l'écran suivant ici
          // Get.to(() => NextScreen());
        } else {
          errorMessage('La vérification OTP a échoué');
           SnackBarService.warning('La vérification OTP a échoué');
        }
      } else {
        errorMessage('Erreur serveur: ${response.statusCode}');
        SnackBarService.networkError();
      }
    } catch (e) {
      errorMessage('Erreur: ${e.toString()}');
      SnackBarService.networkError();
    } finally {
      isLoading(false);
    }
  }

  // Appeler cette fonction quand l'OTP est reçu (depuis SMS par exemple)
  void onOtpReceived(String phoneNumber, String otp) {
    verifyOtpAutomatically(phoneNumber, otp);
  }
}