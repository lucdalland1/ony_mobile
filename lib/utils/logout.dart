import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/utils/testInternet.dart';

Future<bool> logout() async {

  bool isConnected = await hasInternetConnection();
  if (!isConnected) {
      SnackBarService.networkError();
    return false;
  }
  final storage = GetStorage();
  final token = storage.read<String>('token');

  var headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  };

  try {
    var dio = Dio();
  var response = await dio.request(
    '${ApiEnvironmentController.to.baseUrl}/logout/',
    options: Options(
      method: 'POST',
      headers: headers,
    ),
  );
  print('✅✅✅✅Logout response: ${response.data}');
  if (response.statusCode == 200) {
    return true;
  }
  if (response.statusCode == 401) {
    return true;
  } 
  } catch (e) {
    
  }
 
  // §§/SnackBarService.error('Erreur lors de la déconnexion.');
  return false;
}
