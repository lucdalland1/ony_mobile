// ignore: file_names

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

class JustificatifDomicileService {
  static Future<Map<String, dynamic>?> fetchAll() async {
    final Dio dio = Dio();
    final token = GetStorage().read('token');

    try {
      final response = await dio.get(
        '${ApiEnvironmentController.to.baseUrl}/justificatif-domicile',
        options: Options(headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
       

        print("nous y sommes ");
        return response.data['data'];
      } else {
        return  null;
      }
    } catch (e) {
      return null;
    }
  }
}





class DocumentJustificatif {
  final int id;
  final int userId;
  final int typeDocumentJustificatifId;
  final String numeroDocument;
  final int status;
  final int verificationAdmin;
  final String startDate;
  final String? endDate;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;
  final String documentPath;

  DocumentJustificatif({
    required this.id,
    required this.userId,
    required this.typeDocumentJustificatifId,
    required this.numeroDocument,
    required this.status,
    required this.verificationAdmin,
    required this.startDate,
    required this.endDate,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.documentPath,
  });

  factory DocumentJustificatif.fromJson(Map<String, dynamic> json) {
    return DocumentJustificatif(
      id: json['id'],
      userId: json['user_id'],
      typeDocumentJustificatifId: json['type_document_justificatif_id'],
      numeroDocument: json['numero_document'],
      status: json['status'],
      verificationAdmin: json['verification_admin'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      documentPath: json['document_path'],
    );
  }
}
