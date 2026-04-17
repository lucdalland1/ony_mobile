// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Api/piecesjustificatif_Api/pieces_justificatif_api.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Widget/alerte.dart';

class JustificatifIdentiteController extends GetxController {
  var numero = ''.obs;
  var typePieceId = ''.obs;
  var fichier = Rx<File?>(null);
  var isLoading = false.obs;
  var photoIdentite = Rx<File?>(null);
  
  
  void pickFile() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      fichier.value = File(result.files.single.path!);
    } else {
       SnackBarService.error( "Aucun fichier sélectionné.");
    }
  }

  void reset() {
    numero.value = '';
    typePieceId.value = '';
    fichier.value = null;
    photoIdentite.value = null;

  }

  Future<void> soumettre() async {
  isLoading.value = true;

  final token = GetStorage().read('token');
  print('📦 Token utilisé: $token');
  print('📦 type_piece_id: ${typePieceId.value}');
  print('📦 NumeroPiece: ${numero.value}');
  print('📦 Fichier: ${fichier.value?.path}');

  try {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(minutes: 2); // connexion lente
    dio.options.receiveTimeout = const Duration(minutes: 2); // réponse lente
    
    
    dio.options.headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
     var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
      var ip=await ValidationTokenController.to.getPublicIP();
    final formData = FormData.fromMap({
      'NumeroPiece': numero.value,
      if (photoIdentite.value != null)
  'photo_path': await MultipartFile.fromFile(
    photoIdentite.value!.path,
    filename: photoIdentite.value!.path.split('/').last,
  ),
      'type_piece_id': typePieceId.value,
      'type_piece_path': [
        await MultipartFile.fromFile(
          fichier.value!.path,
          filename: fichier.value!.path.split('/').last,
        ),
      ],
      "device":deviceskey,
      'ip':ip
    });

    final response = await dio.post(
      '${ApiEnvironmentController.to.baseUrl}/pieces/soumettre',
      data: formData,
    );

    print('✅ Réponse reçue: ${response.data}');
    Get.back();
      PiecesController controllerTest =Get.find() ;
        controllerTest.fetchPieces();
         SnackBarService.success( "Pièce d'identité soumise avec succès");


  } on DioError catch (e) {
  print('❌ Erreur Dio: ${e.response?.statusCode}');
  print('❌ Données erreur: ${e.response?.data}');

  SnackBarService.error(e.response?.data['message']??' Une erreur est survenue ');

  if (e.type == DioErrorType.connectionTimeout ||
      e.type == DioErrorType.receiveTimeout) {
    SnackBarService.error('Connexion trop lente, veuillez réessayer.');
  } else if (e.type == DioErrorType.unknown &&
             e.error is SocketException) {
    SnackBarService.error('Pas de connexion internet.');
  } else {
    
  }

  } catch (e) {
    print('❌ Erreur inconnue: $e');
    // 
  } finally {
    isLoading.value = false;
  }
}

}
