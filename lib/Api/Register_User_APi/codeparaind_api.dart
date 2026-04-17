import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/utils/testInternet.dart';

class ParrainageService extends GetxService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiEnvironmentController.to.baseUrl, // <-- remplace par ton URL
    connectTimeout: Duration(minutes: 2),
    receiveTimeout: Duration(minutes: 2),
  ));

  // Récupérer un utilisateur par code parrain
  Future getUserByParrainCode(String codeparrain) async {
  try {
    bool isConnected = await hasInternetConnection();

                      if (isConnected) {
                        print('Connexion Internet disponible');
                      } else {
                     
                        // SnackBarService.error('Pas de connexion Internet');
                        return Null;}

    debugPrint('🌐 baseUrl: ${_dio.options.baseUrl}');
    final response = await _dio.get('/parrain/$codeparrain');

    print('📤 response parrainage: ${response.data}');
    print('📤 statusCode: ${response.statusCode}');
    final data = response.data as Map<String, dynamic>;
    var status = data['status'];
    print('📤 status: ${status}');
    // ✅ Cas VALIDE
    if ((response.statusCode == 200 && data['status'] == true)||data['status'] == true) {
      print('✅ Code parrain valide');
      return true;
    }

  
  
    return false;

  } on DioException catch (e) {

    return false;

  } catch (e) {
    print('Erreur inattendue: $e');
   // SnackBarService.warning('Erreur inattendue');
    return false;
  }
}

}
