import 'dart:math';

import 'package:get/get.dart';
import 'package:onyfast/Api/voircode.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/OnypayController/onypayController.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Route/route.dart';
import 'package:onyfast/Services/deconnexionUser.dart';
import 'package:onyfast/View/inscrit.dart';

class VoirPasswController extends GetxController {
  final VoirPasswService _service = VoirPasswService();

  var isLoading = false.obs;
  var result = {}.obs;
  var errorMessage = ''.obs;
  var success = false.obs;
  var error = ''.obs;

  Future<void> verifyPassword({
    required String telephone,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    result.value = {};

    final response = await _service.verify(
      telephone: telephone,
      password: password,
    );
    
    

    if (response['success']) {

         await OnyPayController.to.loginAndLogoutAutomatique( telephone,  password);
        
    

      result.value = response['data'];
      print('result ${response['data']}');
      success.value = true;

       
      // Redirection vers l'écran d'accueil
      // Get.offAllNamed(AppRoutes.hometoken);
    } else {
      errorMessage.value = response['message'];
      print('error ${response['message']}');
      error.value = 'Code Incorrect';
    }
    isLoading.value = false;
  }

   Future<bool> verifyPin({
    required String telephone,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    result.value = {};

    final response = await _service.verify(
      telephone: telephone,
      password: password,
    );


    

    

    if (response['success']) {
      await OnyPayController.to.loginAndLogoutAutomatique( telephone,  password);
      result.value = response['data'];
      print('result ${response['data']}');
      success.value = true;
      // Redirection vers l'écran d'accueil
      isLoading.value = false;
      return true;
    } else {
      isLoading.value = false;
      errorMessage.value = response['message'];
      print('error ${response['message']}');
      error.value = 'Code Incorrect';
      return false;
    }
  }


}
