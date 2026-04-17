// lib/Api/user_service.dart
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

class UserService {
  static final Dio _dio = Dio();

  /// Récupère le profil via /user/me
  static Future<UserMeResponse> fetchMe() async {
    final box = GetStorage();

    final newToken = SecureTokenController.to.token.value;
    final storedToken = box.read('token');

    final authToken =
        (newToken != null && newToken.toString().isNotEmpty)
            ? newToken
            : storedToken;

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await _dio.get(
        '${ApiEnvironmentController.to.baseUrl}/user',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return UserMeResponse(
          success: true,
          message: "Profil utilisateur",
          data: UserProfile.fromJson(
            Map<String, dynamic>.from(response.data),
          ),
        );
      } else {
        return UserMeResponse(
          success: false,
          message:
              response.statusMessage ?? 'Erreur HTTP ${response.statusCode}',
          data: null,
        );
      }
    } on DioException catch (e) {
      String msg = 'Erreur réseau';

      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;

        if (data is Map && data['message'] != null) {
          msg = data['message'].toString();
        } else if (data is String) {
          msg = data;
        }
      } else {
        msg = e.message ?? msg;
      }

      return UserMeResponse(success: false, message: msg, data: null);
    } catch (e) {
      return UserMeResponse(
        success: false,
        message: e.toString(),
        data: null,
      );
    }
  }
}

class UserProfile {
  final int id;
  final String name;
  final String prenom;
  final String email;
  final String profilePhotoPath;
  final String telephone;
  final String adresse;

  final int? genreId;
  final String? dateNaissance;

  final String? parrainageCode;
  final String? statut;
  final int? organisationId;
  final int? abonnementActuelId;
  final String? profilePhotoUrl;
  final int? isPrimaryDistributor;
  final int? isRechargeFiger;

  UserProfile({
    required this.id,
    required this.name,
    required this.prenom,
    required this.email,
    required this.profilePhotoPath,
    required this.telephone,
    required this.adresse,
    this.genreId,
    this.dateNaissance,
    this.parrainageCode,
    this.statut,
    this.organisationId,
    this.abonnementActuelId,
    this.profilePhotoUrl,
    this.isPrimaryDistributor,
    this.isRechargeFiger,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profilePhotoPath: json['profile_photo_path']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      adresse: json['adresse']?.toString() ?? '',
      genreId: json['genre_id'] is int
          ? json['genre_id']
          : int.tryParse('${json['genre_id']}'),
      dateNaissance: json['date_naissance']?.toString(),
      parrainageCode: json['parrainage_code']?.toString(),
      statut: json['statut']?.toString(),
      organisationId: json['organisation_id'] is int
          ? json['organisation_id']
          : int.tryParse('${json['organisation_id']}'),
      abonnementActuelId: json['abonnement_actuel_id'] is int
          ? json['abonnement_actuel_id']
          : int.tryParse('${json['abonnement_actuel_id']}'),
      profilePhotoUrl: json['profile_photo_url']?.toString(),
      isPrimaryDistributor: json['is_primary_distributor'] is int
          ? json['is_primary_distributor']
          : int.tryParse('${json['is_primary_distributor']}'),
      isRechargeFiger: json['is_recharge_figer'] is int
          ? json['is_recharge_figer']
          : int.tryParse('${json['is_recharge_figer']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'prenom': prenom,
      'email': email,
      'profile_photo_path': profilePhotoPath,
      'telephone': telephone,
      'adresse': adresse,
      'genre_id': genreId,
      'date_naissance': dateNaissance,
      'parrainage_code': parrainageCode,
      'statut': statut,
      'organisation_id': organisationId,
      'abonnement_actuel_id': abonnementActuelId,
      'profile_photo_url': profilePhotoUrl,
      'is_primary_distributor': isPrimaryDistributor,
      'is_recharge_figer': isRechargeFiger,
    };
  }
}

class UserMeResponse {
  final bool success;
  final String message;
  final UserProfile? data;

  UserMeResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory UserMeResponse.fromJson(Map<String, dynamic> json) {
    return UserMeResponse(
      success: true,
      message: "Profil utilisateur",
      data: UserProfile.fromJson(json),
    );
  }
}