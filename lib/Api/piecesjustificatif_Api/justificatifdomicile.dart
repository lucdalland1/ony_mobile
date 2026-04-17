import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

class JustificatifDomicileService {
  static Future<Map<String, dynamic>> envoyerJustificatif({
    required File fichier,
    required int typeId,
    // required String numeroDocument,
  }) async {
    final Dio dio = Dio();
    final token = GetStorage().read('token');

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
     var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
      var ip=await ValidationTokenController.to.getPublicIP();
    final data = FormData.fromMap({
      'type_document_justificatif_id': typeId.toString(),
      // 'numero_document': numeroDocument,
      'document_path': await MultipartFile.fromFile(
        fichier.path,
        filename: fichier.path.split('/').last,
      ),
      'device':deviceskey,
      'ip':ip
    });

    try {
      final response = await dio.post(
        '${ApiEnvironmentController.to.baseUrl}/justificatif/create',
        options: Options(headers: headers),
        data: data,
      );

      print('[✅ Réponse] ${response.data}');
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('[❌ Erreur 422] ${e.response?.data}');

        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Erreur de validation',
          'errors': e.response?.data['errors'] ?? {},
        };
      } else {
        print('[❌ Erreur Inattendue] $e');
        return {
          'success': false,
          'message': 'Erreur inattendue. Veuillez réessayer.',
        };
      }
    }
  }
}
