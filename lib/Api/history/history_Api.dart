import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/%20manage_cards_controller_v2.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/model/history/historymodel.dart';

class TransactionApiService {
  static Future<TransactionResponse?> fetchTransactionHistory({
    int page = 1,
    int limit = 20,
    String period = '',
  }) async {
    try {
      final storage = GetStorage();
      final token = storage.read('token');

      final dio = Dio();

      // Construire les paramètres de requête
      Map<String, dynamic> queryParams = {};

      // Ajouter les paramètres de pagination si l'API les supporte
      if (page > 1) queryParams['page'] = page;
      if (limit != 20) queryParams['limit'] = limit;
      if (period.isNotEmpty) queryParams['period'] = period;
      var cardId = ManageCardsController.to.currentCard?.cardID ?? '';

      final response = await dio.request(
        '${ApiEnvironmentController.to.baseUrl}/transactions/user/history?card_id=$cardId',
        options: Options(
          method: 'GET',
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return TransactionResponse.fromJson(response.data);
      } else {
        print('Erreur API: ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('Erreur lors du fetch des transactions : $e');
      return null;
    }
  }
}
