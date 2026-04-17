import 'package:onyfast/model/Carte/cartePhysique.dart';

class ApiStatus {
  final bool success;
  final int code;
  final String message;

  ApiStatus({
    required this.success,
    required this.code,
    required this.message,
  });

  factory ApiStatus.fromJson(Map<String, dynamic> json) => ApiStatus(
        success: json['success'] == true,
        code: json['code'] ?? 0,
        message: json['message'] ?? '',
      );
}

class EmmettreCartePhysiqueResponse {
  final ApiStatus status;
  final EmmettreCartePhysique? data;

  EmmettreCartePhysiqueResponse({required this.status, this.data});

  factory EmmettreCartePhysiqueResponse.fromJson(Map<String, dynamic> json) {
    return EmmettreCartePhysiqueResponse(
      status: ApiStatus.fromJson(json['status']),
      data: json['data'] != null
          ? EmmettreCartePhysique.fromJson(json['data'])
          : null,
    );
  }
}
