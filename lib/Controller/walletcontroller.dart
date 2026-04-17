// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import '../Api/user_inscription.dart';

// class WalletController extends GetxController {
//   final AuthController _authController = Get.find();
//   final GetStorage _storage = GetStorage();
  
//   // États observables
//   final RxString balance = '0'.obs;
//   final RxBool isLoading = false.obs;
//   final RxString lastUpdate = 'Jamais mis à jour'.obs;
//   final RxInt refreshCount = 0.obs;
//   final RxDouble previousBalance = 0.0.obs;

//   // Timer pour le rafraîchissement périodique
//   Duration refreshInterval = const Duration(seconds: 30);
  
//   @override
//   void onInit() {
//     super.onInit();
//     _loadCachedBalance();
//     _initializeAutoRefresh();
//   }

//   // Charger le solde depuis le cache au démarrage
//   void _loadCachedBalance() {
//     final cachedBalance = _storage.read('cachedBalance');
//     if (cachedBalance != null) {
//       balance.value = cachedBalance;
//       previousBalance.value = double.tryParse(cachedBalance) ?? 0.0;
//     }
//     fetchBalance();
//   }

//   // Initialiser le rafraîchissement automatique
//   void _initializeAutoRefresh() {
//     refreshBalancePeriodically();
//   }

//   // Rafraîchissement périodique
//   void refreshBalancePeriodically() async {
//     await Future.delayed(refreshInterval);
//     if (!isLoading.value) {
//       await fetchBalance();
//     }
//     refreshBalancePeriodically();
//   }

//   // Récupérer le solde
//   Future<void> fetchBalance() async {
//     // try {
//       isLoading(true);
//       await _authController.getWallet();
      
//      final wallet= await _authController.fetchSolde();
//       final newBalance = wallet?.solde ?? 0.0;
//       // final newBalance = double.tryParse(_storage.read('solde')) ?? 0.0;
//       print(wallet.toString());
//       // Mise à jour seulement si le solde a changé
//       if (newBalance != previousBalance.value) {
//         balance.value = newBalance.toStringAsFixed(2);
//         previousBalance.value = newBalance;
//         _storage.write('cachedBalance', balance.value);
//         refreshCount.refresh();
        
//         // Notification de mise à jour
//         if (refreshCount.value > 0) {
//           _showBalanceUpdateNotification(newBalance);
//         }
//       }
//       lastUpdate.value = _getCurrentTime();
//     // } catch (e) {
//     //   Get.snackbar(
//     //     'Erreur', 
//     //     'Impossible de mettre à jour le solde: ${e.toString()}',
//     //     snackPosition: SnackPosition.BOTTOM,
//     //   );
//     // } finally {
//     //   isLoading(false);
//     // }
//   }

//   // Notification visuelle lorsque le solde change
//   void _showBalanceUpdateNotification(double newBalance) {
//     final difference = newBalance - previousBalance.value;
//     final message = difference > 0
//         ? '+${difference.toStringAsFixed(2)} FCFA'
//         : '${difference.toStringAsFixed(2)} FCFA';

//     Get.snackbar(
//       'Solde mis à jour',
//       message,
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: difference > 0 ? Colors.green : Colors.red,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 2),
//     );
//   }

//   // Formater l'heure actuelle
//   String _getCurrentTime() {
//     return 'Mis à jour à ${DateTime.now().hour}h${DateTime.now().minute}';
//   }

//   // Forcer une actualisation manuelle
//   Future<void> forceRefresh() async {
//     refreshCount.value++;
//     await fetchBalance();
//   }

//   // Getter pour le solde formaté
//   String get formattedBalance => '${balance.value} FCFA';
// }