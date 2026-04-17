// lib/controllers/otp_controller.dart
import 'package:get/get.dart';
import 'package:onyfast/Api/otp_renitialisation_key/send.dart';

class OtpRenitPasswordController extends GetxController {
  OtpResource resource = OtpResource();

  // états observables
  final isLoading = false.obs;
  final lastResponse = Rxn<OtpResponse>();
  final errorText = RxnString();

  /// Envoie un OTP pour [telephone]
  Future<void> sendOtp() async {
    errorText.value = null;
    isLoading.value = true;

    try {
      final res = await resource.sendOtp();
      lastResponse.value = res;

      if (!res.success) {
        
        // échec (ex: quota) -> message dans errorText pour UI
        errorText.value = res.message +
            (res.retryAfter != null ? ' (Réessayer dans ${res.retryAfter})' : '');
      } else {
        // succès -> tu peux déclencher un toast/snackbar ici si tu veux
        errorText.value = null;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Helpers pour l’UI
  String get expiresAtLabel {
    final dt = lastResponse.value?.expiresAt;
    if (dt == null) return '';
    // Affichage local simple HH:mm (à adapter si besoin)
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  int get sentTodayCount => lastResponse.value?.sentToday ?? 0;
}
