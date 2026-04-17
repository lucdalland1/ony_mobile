import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:get_storage/get_storage.dart';

class NiveauController extends GetxController {
  final Dio _dio = Dio();

  var isLoading = false.obs;
  var niveau = 0.obs; 
  var errorMessage = ''.obs;
  var idValue="".obs;

    fetchNiveau() async {
    niveau.value=0;
    isLoading.value = true;
    errorMessage.value = '';

    final box = GetStorage();
    final user = box.read('userInfo');

    
    try {
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      var response = await _dio.request(
        'https://api.dev.onyfastbank.com/niveau.php?phone=${user['telephone'] ?? ''}',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {

        var data=(response.data);


        int niveauValue = data['data']['niveau']; // <- récupère 3 dans ton exemple
        print("✅✅✅✅✅✅✅    ${json.encode(response.data)} voila son niveau ✅✅✅✅✅✅✅ $niveauValue");

        niveau.value=niveauValue;
        idValue.value='${data['data']['idValue'] ?? ''}';


print("✅✅✅✅✅✅✅    voila son niveau ✅✅✅✅✅✅✅ $idValue");

      } else {
        
      errorMessage.value = 'Impossible de récupérer le niveau \nsi le problème persiste, contacter le support';
        print(response.statusMessage);
      }
    } catch (e) {
      errorMessage.value = 'Impossible de récupérer le niveau \nsi le problème persiste, contacter le support';
      print('Exception: $e');
      
    } finally {
      isLoading.value = false;
    }
  }
}
