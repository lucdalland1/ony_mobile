import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

class CountryService {
  Future<void> getCountry() async {
    final storage = GetStorage();
    final token = storage.read('token');

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final dio = Dio();
    final response = await dio.get(
      '${ApiEnvironmentController.to.baseUrl}/pays',
      options: Options(headers: headers),
    );

    if (response.statusCode == 200) {
      print(json.encode(response.data));
    } else {
      print(response.statusMessage);
    }
  }
}
