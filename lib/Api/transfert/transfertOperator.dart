import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/View/Transfert/model/transferepreviewmodel.dart';

class TransferService {
  final Dio dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 40),
    receiveTimeout: Duration(seconds: 40),
  ));
String removePlus(String input) {
  if (input.startsWith('+')) {
    return input.substring(1);
  }
  return input;
}
  Future<TransferPreviewResponse?> previewTransfer({
    required int operatorId,
    required int countryId,
    required double amount,
    required String phoneNumber,
    required String beneficiary_name,
  }) async {
    final token = GetStorage().read("token");
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

       var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
        var ip=await ValidationTokenController.to.getPublicIP();
    final data = FormData.fromMap({
      'operator_id': operatorId.toString(),
      'country_id': countryId.toString(),
      'amount': amount.toString(),
      'phone_number': removePlus(phoneNumber),
      'beneficiary_name': beneficiary_name,
      "device":deviceskey,
      'ip':ip
    });
      print("voila le operator_id $operatorId");
      print("voila le country_id $countryId");
      print("voila le amount $amount");
      print("voila le phoneNumber $phoneNumber");
      print("voila le beneficiary_name $beneficiary_name");
    try {
      final response = await dio.post(
        '${ApiEnvironmentController.to.baseUrl}/transfer/preview/tranfert',
        options: Options(headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        return TransferPreviewResponse.fromJson(response.data);
      } else {
        return TransferPreviewResponse(
          status: false,
          message: "Impossible de traiter la requête veuillez Contacter le support",
        );
      }
    } catch (e) {
      print('voila la nuvelle erreur $e');
      return TransferPreviewResponse(status: false, message: "Impossible de traiter la requête veuillez Contacter le support");
    }
  }
}
