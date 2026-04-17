import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/model/Epargne/epargnegroupe.dart';

class EpargneService {
  final Dio _dio;

  EpargneService([Dio? dio]) : _dio = dio ?? Dio();

  Future<void> creerGroupeEpargne(
      {required String nom,
      required String typeGroupeId,
      required String frequence}) async {
    final storage = GetStorage();
    final token = storage.read<String>('token');

    if (token == null) {
      throw Exception('Token non trouvé');
    }

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final formData = FormData.fromMap({
      'nom': nom,
      'type_groupe_id': typeGroupeId,
      "frequence_id": frequence
    });

    try {
      final response = await _dio.post(
        '${ApiEnvironmentController.to.baseUrl}/epargnes/groupes/',
        options: Options(headers: headers),
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Erreur serveur : ${response.statusCode} - ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Échec création groupe : $e');
    }
  }

  Future<List<Groupe>> fetchMesGroupes() async {
    final storage = GetStorage();
    final token = storage.read<String>('token');

    if (token == null) {
      throw Exception('Token non trouvé');
    }

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await _dio.get(
        '${ApiEnvironmentController.to.baseUrl}/epargnes/groupes',
        options: Options(headers: headers),
      );
      print('fetching epargne Grouế ');

      if (response.statusCode == 200) {
        List data = response.data['groupes'] ?? [];
        print("voila la taille ${data.length}");
        return data.map((json) => Groupe.fromJson(json)).toList();
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }
}
