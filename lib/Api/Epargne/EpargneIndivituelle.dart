import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData;
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/EpargneIndividuelController.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/View/Epargne/Eparne%20individuel/eparne_individuelle.dart';
import 'package:onyfast/View/Epargne/model/EpargneIndividuelleModel.dart';

class EpargneIndividuelleService {
  final Dio dio = Dio();
  final GetStorage storage = GetStorage();

  Map<String, String> _buildHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  Future<EpargneIndividuelleModel?> fetchEpargneIndividuelleUser() async {
    final token = storage.read('token');
    print('Token: $token');

    if (token == null || token.isEmpty) {
      print('Token non disponible');
      Get.snackbar("Erreur", "Token non disponible");
      return null;
    }

    try {
      print('Effectuant la requête à: ${ApiEnvironmentController.to.baseUrl}/epargnes/individuelle/user');
      final response = await dio.get(
        '${ApiEnvironmentController.to.baseUrl}/epargnes/individuelle/user',
        options: Options(headers: _buildHeaders(token)),
      );
      print('Status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        // Vérifier si la réponse est vide
        if (response.data.isEmpty) {
          print('Réponse vide du serveur');
          return null;
        }
        
        // Vérifier si les champs obligatoires sont présents
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (!data.containsKey('id') || !data.containsKey('montant_total')) {
            print('Réponse incomplète: ${data.keys}');
            return null;
          }
          return EpargneIndividuelleModel.fromJson(data);
        }
        
        print('Format de réponse invalide');
        return null;
      } else {
        print('Erreur HTTP: ${response.statusCode} - ${response.statusMessage}');
        Get.snackbar("Erreur", "Erreur HTTP: ${response.statusCode} - ${response.statusMessage}");
        return null;
      }
    } catch (e, stackTrace) {
      print('Erreur complète: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar("Erreur", "Erreur de requête : $e");
      return null;
    }
  }

  Future<dynamic> createObjectif({
  required String nom,
  required String montantCible,
  required String endDate,
}) async {
  final token = storage.read('token');

  if (token == null || token.isEmpty) {
    
    Get.snackbar("Erreur", "Token non disponible");
    return null;
  }

  var headers = {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };
 var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
  var data = FormData.fromMap({
    'nom': nom,
    'montant_cible': montantCible,
    'endDate': endDate,
    'device':deviceskey
  });

  try {
    final response = await dio.post(
      '${ApiEnvironmentController.to.baseUrl}/epargnes/individuelle/objets',
      data: data,
      options: Options(headers: headers),
    );
    print("je suis dans la creation");
    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.close(2);
      Get.to(EpargneIndividuellePage());
      Get.snackbar("Succès", "Objectif créé avec succès!");
          print("c'est passé");

      // Create and return EpargneIndividuelleModel from the response data
      return EpargneIndividuelleModel.fromJson(response.data);
    } else {
      Get.snackbar("Erreur", "Erreur HTTP : ${response.statusCode} - ${response.statusMessage}");
      return null;
    }
  } catch (e) {
   Get.snackbar("Erreur", "Erreur : $e");
   print("c'est pas passé $e" );
    return null;
  }
}

}