import 'package:get/get.dart';
import 'package:dio/dio.dart';

// Classe pour représenter la structure de la réponse de l'API
class AppUpdateResponse {
  bool success;
  AppUpdateData? data;

  AppUpdateResponse({
    required this.success,
    this.data,
  });

  factory AppUpdateResponse.fromJson(Map<String, dynamic> json) {
    return AppUpdateResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? AppUpdateData.fromJson(json['data']) : null,
    );
  }
}

class AppUpdateData {
  int id;
  String buildVersion;
  int versionCode;
  String updateNotes;
  String updateDate;
  int status;
  String createdAt;
  String updatedAt;
  String? deletedAt;

  AppUpdateData({
    required this.id,
    required this.buildVersion,
    required this.versionCode,
    required this.updateNotes,
    required this.updateDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory AppUpdateData.fromJson(Map<String, dynamic> json) {
    return AppUpdateData(
      id: json['id'],
      buildVersion: json['build_version'],
      versionCode: json['version_code'],
      updateNotes: json['update_notes'],
      updateDate: json['update_date'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }
}

// Controller avec GetX pour gérer l'état de l'application
class AppUpdateController extends GetxController {
  // Les variables d'état que nous allons observer avec GetX
  var isLoading = false.obs;
  var appUpdateResponse = Rx<AppUpdateResponse>(AppUpdateResponse(success: false, data: null));
  var errorMessage = ''.obs;

  // Fonction pour récupérer les mises à jour de l'application
  Future<void> fetchAppUpdate() async {
    isLoading.value = true;

    try {
      final dio = Dio();
      final response = await dio.get("http://192.168.100.166:8000/api/buildname");

      print('🔥🔥🔥   🔥🔥🔥 🔥🔥🔥   $response');

      if (response.statusCode == 200) {
        appUpdateResponse.value = AppUpdateResponse.fromJson(response.data);
      } else {
        appUpdateResponse.value = AppUpdateResponse(success: false, data: null);
        errorMessage.value = "Erreur: Code de statut non valide.";
      }
    } catch (e) {
      errorMessage.value = "Erreur de réseau ou de parsing: $e";
      appUpdateResponse.value = AppUpdateResponse(success: false, data: null);
    } finally {
      isLoading.value = false;
    }
  }
}
