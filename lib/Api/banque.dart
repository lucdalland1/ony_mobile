import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/model/banque.dart';
import 'dart:convert';

class BankController extends GetxController {
  var banks = <Bank>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchBanks();
    super.onInit();
  }

  Future<void> fetchBanks() async {
    final response = await http.get(Uri.parse("${ApiEnvironmentController.to.baseUrl}/banques"));

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      for (var bank in jsonData['data']) {
        banks.add(Bank.fromJson(bank));
      }
      isLoading.value = false;
    } else {
      // Gérer les erreurs ici
      isLoading.value = false;
    }
  }
}