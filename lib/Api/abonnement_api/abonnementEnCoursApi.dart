import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/model/abonnement/abonnementEnCours.dart';

class AbonnementEncoursService {
  final Dio _dio = Dio();
  final String _baseUrl = '${ApiEnvironmentController.to.baseUrl}/abonnements/current';

  /// Récupère l'abonnement en cours depuis l'API
  Future<AbonnementEnCours?> getAbonnementEnCours() async {
  final box = GetStorage();
    final tokenValue = box.read('token');
    try {
      // print('🔐🔐🔐🔐🔐🔐 voila le token :  $tokenValue');
      // print('🔐🔐🔐🔐🔐🔐 $_baseUrl');
      
      final response = await _dio.get(
        _baseUrl,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $tokenValue',
          },
        ),
      );
    // print('🔐🔐🔐🔐🔐🔐 $response');
      if (response.statusCode == 200) {


        // Conversion JSON -> modèle Dart
        return AbonnementEnCoursResponse.fromJson(response.data).data;
      } else {
        print('Erreur API: ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('Erreur Dio: $e');
      return null;
    }
  }
}
