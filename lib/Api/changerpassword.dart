import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

class PasswordService {
  final Dio _dio = Dio();
 final storage = GetStorage();
  // Remplacez par votre URL d'API

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
         final token =await    storage.read('token');

      // Récupérer le token d'authentification
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Token d\'authentification introuvable. Veuillez vous reconnecter.',
        };
      }

      // Configuration des headers
      final options = Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
    var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
     var ip=await ValidationTokenController.to.getPublicIP();
      // Envoi de la requête
      final response = await _dio.post(
        '${ApiEnvironmentController.to.baseUrl}/user/changepassword',
        data: {
          'ancien': oldPassword,
          'nouveau': newPassword,
          'confirmation': confirmPassword,
          'device':deviceskey,
          'ip':ip
        },
        options: options,
      );

      // Réponse réussie
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Mot de passe modifié avec succès.',
        };
      }

      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue.',
      };
      
    } on DioException catch (e) {
      // Gestion des erreurs HTTP
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final data = e.response!.data;

        if (statusCode == 422) {
          // Erreur de validation
          if (data['errors'] != null) {
            // Extraire le premier message d'erreur
            final errors = data['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            final errorMessage = firstError is List ? firstError.first : firstError;
            
            return {
              'success': false,
              'message': errorMessage,
            };
          } else if (data['message'] != null) {
            return {
              'success': false,
              'message': data['message'],
            };
          }
        } else if (statusCode == 401) {
          return {
            'success': false,
            'message': 'Session expirée. Veuillez vous reconnecter.',
          };
        }
      }

      // Erreur de connexion
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {
          'success': false,
          'message': 'Délai de connexion dépassé. Vérifiez votre connexion internet.',
        };
      }

      if (e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message': 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
        };
      }

      return {
        'success': false,
        'message': 'Une erreur est survenue. Veuillez réessayer.',
      };
      
    } catch (e) {
      // Erreur générique
      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue: ${e.toString()}',
      };
    }
  }
}