// lib/Controller/transfert_execute_con.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:onyfast/Api/transfert/sendConfirme.dart';
import 'package:onyfast/Controller/RecenteTransaction/recenttransactcontroller.dart';
import 'package:onyfast/View/BottomView/service.dart';
import 'package:onyfast/View/Transfert/transfert.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/verificationcode.dart';

class TransfertExecuteCon extends GetxController {

  
  final TransfertExecuteService _service = TransfertExecuteService();

  var isLoading = false.obs;

  Future<void> executeTransfert({
    required String operatorId,
    required String countryId,
    required String montant,
    required String fromTelephone,
    required String toTelephone,
    required String beneficiaryName,
    required BuildContext context,
  }) async {
    isLoading.value = true;
    bool trouve = false;

  // ignore: await_only_futures
     CodeVerification().show(context, () async { // (_) car on n'utilise pas le param
 
   try {
      final response = await _service.executeTransfert(
        operatorId: operatorId,
        countryId: countryId,
        montant: montant,
        fromTelephone: fromTelephone,
        toTelephone: toTelephone,
        beneficiaryName: beneficiaryName,
      );

      isLoading.value = false;

      if (response != null && response.statusCode == 200) {
        Get.back();
        Get.back();
 SnackBarService.success(          
          'Transfert en Attente de Validation',
         
        );
        int count = 0;
        // Get.until((route) => count++ >= 1);
        // Get.off(ServicesPage()); // remplace la page restante par la nouvelle

        print(response.data);
      } else {
        //  SnackBarService.warning(
        //   'Erreur inconnue lors du transfert',

        // );
      }
    } catch (e) {
      isLoading.value = false;
      SnackBarService.warning(
        e.toString().replaceFirst('Exception: ', ''),
      
      );
    }
});
   isLoading.value = false;
  }
}
