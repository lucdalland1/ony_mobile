// lib/Api/transfert_execute_service.dart

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

class TransfertExecuteService {
  final Dio dio = Dio();
  final GetStorage storage = GetStorage();

  Future<Response?> executeTransfert({
    required String operatorId,
    required String countryId,
    required String montant,
    required String fromTelephone,
    required String toTelephone,
    required String beneficiaryName,
  }) async {
    try {
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${storage.read('token')}',
      };
       var ip=await ValidationTokenController.to.getPublicIP();
 var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
      final data = FormData.fromMap({
        'operator_id': operatorId,
        'country_id': countryId,
        'montant': montant,
        'from_telephone': fromTelephone,
        'to_telephone': '242$toTelephone',
        'beneficiary_name': beneficiaryName,
        'device':deviceskey,
        'ip':ip
      }); 

      final response = await dio.post(
        '${ApiEnvironmentController.to.baseUrl}/transfer/execute',
        data: data,
        options: Options(headers: headers),
      );

      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception("Temps de connexion dépassé");
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("Erreur de connexion réseau");
      } else if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "Erreur serveur");
      } else {
        throw Exception("Erreur inconnue : ${e.message}");
      }
    } catch (e) {
      throw Exception("Échec de la requête : $e");
    }
  }
}
