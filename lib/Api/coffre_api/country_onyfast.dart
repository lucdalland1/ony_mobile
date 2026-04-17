
 import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

class CountryOnyfast {


void fetchCountries() async {
  var headers = {'Accept': 'application/json'};

  var dio = Dio();
  try {
    var response = await dio.request(
      '${ApiEnvironmentController.to.baseUrl}/contry_onyfast',
      options: Options(
        method: 'GET',
        headers: headers,
      ),
    );

    if (response.statusCode == 200) {
      // Affiche le JSON brut
      print(jsonEncode(response.data));
    } else {
      print('Erreur HTTP: ${response.statusCode} - ${response.statusMessage}');
    }
  } catch (e) {
    print('Erreur: $e');
  }
}
 
}