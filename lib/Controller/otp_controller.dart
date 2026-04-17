// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:onyfast/model/userapi.dart';
// import 'package:pinput/pinput.dart';
// import '../services/auth_service.dart';

// class OtpController extends GetxController {
//   final AuthService _authService = Get.find();
  
//   var otp = ''.obs;
//   var otpError = ''.obs;
//   var isLoading = false.obs;
//   var remainingTime = 60.obs;
//   var canResendOtp = false.obs;
//   var autoFilled = false.obs;
  
//   late Timer _timer;
//   final otpController = TextEditingController();
//   final otpFocusNode = FocusNode();

//   @override
//   void onInit() {
//     super.onInit();
//     startTimer();
//     _tryAutoFillOtp();
//   }

//   @override
//   void onClose() {
//     _timer.cancel();
//     otpController.dispose();
//     otpFocusNode.dispose();
//     super.onClose();
//   }

//   String getMaskedPhone() {
//     final phone = _authService.getRegisteredPhone();
//     if (phone.length > 4) {
//       return '******${phone.substring(phone.length - 2)}';
//     }
//     return phone;
//   }

//   void _tryAutoFillOtp() async {
//     await Future.delayed(const Duration(seconds: 2));
    
//     // Simuler la récupération automatique de l'OTP
//     final receivedOtp = _authService.getStoredOtp();
//     if (receivedOtp.isNotEmpty) {
//       otpController.text = receivedOtp;
//       otp.value = receivedOtp;
//       autoFilled.value = true;
//       verifyOtp();
//     }
//   }

//   void startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (remainingTime.value > 0) {
//         remainingTime.value--;
//       } else {
//         canResendOtp.value = true;
//         timer.cancel();
//       }
//     });
//   }

//   Future<void> verifyOtp() async {
//     try {
//       isLoading(true);
//       otpError.value = '';

//       if (otp.value.isEmpty || otp.value.length != 6) {
//         throw 'Veuillez entrer un code OTP valide à 6 chiffres';
//       }

//       final isValid = await _authService.verifyOtp(
//         phoneNumber: _authService.getRegisteredPhone(),
//         otp: otp.value,
//       );

//       if (isValid) {
//         Get.offAllNamed('/home');
//       } else {
//         throw 'Code OTP incorrect';
//       }
//     } catch (e) {
//       otpError.value = e.toString();
//       HapticFeedback.vibrate();
//     } finally {
//       isLoading(false);
//     }
//   }

//   Future<void> resendOtp() async {
//     try {
//       isLoading(true);
//       otpError.value = '';
//       await _authService.requestOtp(_authService.getRegisteredPhone());
      
//       // Réinitialiser le timer
//       remainingTime.value = 60;
//       canResendOtp.value = false;
//       startTimer();
      
//       // Effacer l'ancien OTP
//       otpController.clear();
//       otp.value = '';
//       autoFilled.value = false;
      
//       Get.snackbar('Succès', 'Un nouveau code OTP a été envoyé');
//     } catch (e) {
//       otpError.value = e.toString();
//     } finally {
//       isLoading(false);
//     }
//   }
// }