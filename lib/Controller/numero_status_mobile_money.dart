import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

class RechargeStatusController extends GetxController {
  final GetStorage storage = GetStorage();
  final Dio dio = Dio();

  /// valeur observable
  final RxInt isRechargeFiger = 0.obs;

  static const String storageKey = 'is_recharge_figer';

  @override
  void onInit() {
    super.onInit();
    _loadFromLocal();
    fetchRechargeStatus();
    _loadFromLocal();
  }

  /// 🔹 Charger depuis le stockage local
  void _loadFromLocal() {
    final localValue = storage.read(storageKey);
    if (localValue != null) {
      isRechargeFiger.value = localValue;
    }
  }

  /// 🔹 Appel API
  Future<void> fetchRechargeStatus() async {
    try {
      final token = storage.read('token'); // ou récupère depuis ton auth

      final response = await dio.get(
        '${ApiEnvironmentController.to.baseUrl}/user',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('🔄 Récupération is_recharge_figer depuis API...');
      print('🔄 Token utilisé: $response');
      var parrainageCode = response.data['parrainage_code'];
      var code_parrainage = response.data['code_parrain'];
      

      print('✅ parrainage_code: $parrainageCode');
      print('✅ code_parrainage: $code_parrainage');

      if (response.statusCode == 200) {
        final data = response.data;
        print('✅ Réponse API is_recharge_figer: $data');

        final int value = data['is_recharge_figer'] ?? 1;
        await SecureTokenController.to.saveParrainageCode(parrainageCode);
        await SecureTokenController.to.saveCodeParrain(code_parrainage);
        isRechargeFiger.value = value;

        
          
        // print('✅ is_recharge_figer mis à jour: $value');
        
        /// sauvegarde locale
        await storage.write(storageKey, value);
      }
    } catch (e) {
      print('❌ Erreur récupération is_recharge_figer: $e');
    }
  }

  /// 🔹 Helper pratique
  bool get rechargeBloquee => isRechargeFiger.value == 1;
}
