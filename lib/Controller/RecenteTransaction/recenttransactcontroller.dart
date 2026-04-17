import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/recent_transact/recente_transact_Api.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';

class RecentTransactionsController extends GetxController {
    static RecentTransactionsController get to => Get.find();

  var isLoading = false.obs;
  var transactions = [].obs;
  var message = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    isLoading.value = true;

    final token = GetStorage().read('token');
    print('🔑 TOKEN: $token');

    if (token == null || token.toString().isEmpty) {
      print('❌ Token manquant');
      isLoading.value = false;
      return;
    }

    if (!Get.isRegistered<ManageCardsController>()) {
      print('⚠️ ManageCardsController pas encore enregistré');
      isLoading.value = false;
      return;
    }

    final cardId = ManageCardsController.to.currentCard?.cardID ?? '';
    print('💳 CARD ID: $cardId');

    final response = await RecentTransactionsApi.getRecentTransactions(
      token: token.toString(),
    );

    print('📦 RESPONSE: $response');

    isLoading.value = false;

    if (response['success'] == true) {
      transactions.value = response['data'] ?? [];
      message.value = response['message']?.toString() ?? '';
      print('✅ ${transactions.length} transaction(s) chargée(s)');
    } else {
      print('❌ Erreur API: ${response['message']}');
      transactions.value = [];
    }
  }

  Future<void> refresh() => fetchTransactions();

  void supprimerData() {
    transactions.value = [];
    message.value = '';
  }
}