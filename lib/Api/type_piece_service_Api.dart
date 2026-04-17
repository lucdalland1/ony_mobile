import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

class TypePieceService {
 

  Future<List<Map<String, dynamic>>> getAllRaw() async {


    final storage = GetStorage();
    final token = storage.read('token');

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final dio = Dio();

    final response = await dio.get(
      '${ApiEnvironmentController.to.baseUrl}/type_pieces',
      options: Options(headers: headers),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return List<Map<String, dynamic>>.from(response.data['data']);
    } else {
      throw Exception('Erreur lors de la récupération des types de pièces');
    }
  }
   

  

  
}
