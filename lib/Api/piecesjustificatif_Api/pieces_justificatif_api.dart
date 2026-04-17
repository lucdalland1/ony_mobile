import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

class PiecesResponse {
  final List<PieceIdentiteModel> data;
  final int total;

  PiecesResponse({required this.data, required this.total});

  factory PiecesResponse.fromJson(Map<String, dynamic> json) {
    return PiecesResponse(
      data: (json['data'] as List)
          .map((item) => PieceIdentiteModel.fromJson(item))
          .toList(),
      total: json['total'] ?? 0,
    );
  }
}

class PieceIdentiteModel {
  final int id;
  final int userId;
  final int typePieceId;
  final String numeroPiece;
  final String? typePiecePath;
  final bool verificationAdmin;
  final int status;
  final DateTime startDate;
  final DateTime? endDate;
  final TypePiece typePiece;

  PieceIdentiteModel({
    required this.id,
    required this.userId,
    required this.typePieceId,
    required this.numeroPiece,
    required this.typePiecePath,
    required this.verificationAdmin,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.typePiece,
  });

  factory PieceIdentiteModel.fromJson(Map<String, dynamic> json) {
    return PieceIdentiteModel(
      id: json['id'],
      userId: json['user_id'],
      typePieceId: json['type_piece_id'],
      numeroPiece: json['NumeroPiece'],
      typePiecePath: json['type_piece_path'],
      verificationAdmin: json['verification_admin'] ?? false,
      status: json['status'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      typePiece: TypePiece.fromJson(json['type_piece']),
    );
  }
}

class TypePiece {
  final int id;
  final String designation;
  final String? description;
  final int userId;
  final DateTime startDate;
  final DateTime? endDate;

  TypePiece({
    required this.id,
    required this.designation,
    this.description,
    required this.userId,
    required this.startDate,
    this.endDate,
  });

  factory TypePiece.fromJson(Map<String, dynamic> json) {
    return TypePiece(
      id: json['id'],
      designation: json['designation'],
      description: json['description'],
      userId: json['user_id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
    );
  }
}


class PiecesController extends GetxController {
  var pieces = <PieceIdentiteModel>[].obs;
  var totalPieces = 0.obs;
  var isLoading = false.obs;
  var Error = false.obs;

  Future<void> fetchPieces() async {
    isLoading.value = true;

    try {
      final token = GetStorage().read('token');
      final dio = Dio();

      final response = await dio.get(
        '${ApiEnvironmentController.to.baseUrl}/pieces/mes-pieces',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final dataParsed = PiecesResponse.fromJson(response.data);
        pieces.value = dataParsed.data;
        totalPieces.value = dataParsed.total;
        print('tout est passé');
        Error.value = false;
      } else {
        // Get.snackbar('Erreur', response.data['message'] ?? 'Erreur de récupération');
        Error.value = true;
        print('Erreur de récupération ${response.data['message']}');
      }
    } catch (e) {
      // Get.snackbar('Erreur', 'Erreur réseau : $e');
      Error.value = true;
      print('Erreur de récupération $e');
    } finally {
      isLoading.value = false;
    }
  }
}
