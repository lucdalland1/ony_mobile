import 'package:dio/dio.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

import '../../Controller/ manage_cards_controller_v2.dart';

class RecentTransactionsApi {
  static Future<Map<String, dynamic>> getRecentTransactions({
    required String token,
  }) async {
    final Dio dio = Dio();

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final cardId = ManageCardsController.to.currentCard?.cardID ?? '';
    print('📡 CARD ID: $cardId');

    try {
      final response = await dio.request(
        '${ApiEnvironmentController.to.baseUrl}/transactions/user/recent?card_id=$cardId',
        options: Options(method: 'GET', headers: headers),
      );

      print('✅ Réponse recent transactions: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Erreur DioException: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Erreur réseau ou serveur',
      };
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      return {
        'success': false,
        'message': 'Erreur inattendue: $e',
      };
    }
  }
}