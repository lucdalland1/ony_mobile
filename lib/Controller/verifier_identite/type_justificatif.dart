import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Widget/alerte.dart';

class TypeJustificatif {
  final int id;
  final String designation;
  final int userId;
  final String? startDate;
  final String? endDate;

  TypeJustificatif({
    required this.id,
    required this.designation,
    required this.userId,
    this.startDate,
    this.endDate,
  });

  factory TypeJustificatif.fromJson(Map<String, dynamic> json) {
    return TypeJustificatif(
      id: json['id'],
      designation: json['designation'],
      userId: json['user_id'],
      startDate: json['startDate'],
      endDate: json['endDate'],
    );
  }
}

class JustificatifDomicileController extends GetxController {
  var justificatifs = <TypeJustificatif>[].obs;
  var isLoading = false.obs;

  Future<void> fetchJustificatifs() async {
    try {
      isLoading.value = true;

      final token = GetStorage().read('token');
      final response = await Dio().get(
        '${ApiEnvironmentController.to.baseUrl}/justificatif-domicile/type',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        var data = response.data['data'] as List;
        justificatifs.value =
            data.map((e) => TypeJustificatif.fromJson(e)).toList();

            print('tout passe bien ');
      } else {
      }
    } catch (e) {
      print(e);
      SnackBarService.networkError();
    } finally {
      isLoading.value = false;
    }
  }
}
