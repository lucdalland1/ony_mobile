import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/View/InscriptionSuplementaire/model/userInscriptionModel.dart';
import '../const.dart';
class UserService {

  Future<UserInscriptionModel?> updateUserInfo({
    required int id,
    required String token,
    required String name,
    required String email,
    required String prenom,
    required String adresse,
    required String telephone,
    String? profilePhotoPath,
    required  sexe,
    required  dateNaissance,

  }) async {
    final url = Uri.parse('${ApiEnvironmentController.to.baseUrl}/userinfosup/$id');
try {
   var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
    var ip=await ValidationTokenController.to.getPublicIP();
   final body = {
    'ip':ip,
      'device':deviceskey,
      'token': token,
      'name': name,
      'email': email,
      'prenom': prenom,
      'adresse': adresse,
      'telephone': telephone,
      'genre_id': sexe.toString(),
      'date_naissance': dateNaissance.toString(),
      if (profilePhotoPath != null) 'profile_photo_path': profilePhotoPath,
    };

    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return UserInscriptionModel.fromJson(data);
    } else {
      print("Erreur : ${response.body}");
      return null;
    }
} catch (e) {
  print("Erreur : $e");
  return null;
}
   
  }
}
