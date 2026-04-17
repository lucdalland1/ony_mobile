// ============================================
// 1. MODELS - lib/models/rejection_response.dart
// ============================================
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/apiUrlController.dart';

class RejectionResponse {
  final bool success;
  final bool hasRejections;
  final List<Rejection> rejections;
  final int count;

  RejectionResponse({
    required this.success,
    required this.hasRejections,
    required this.rejections,
    required this.count,
  });

  factory RejectionResponse.fromJson(Map<String, dynamic> json) {
    return RejectionResponse(
      success: json['success'] ?? false,
      hasRejections: json['has_rejections'] ?? false,
      rejections: (json['rejections'] as List?)
              ?.map((e) => Rejection.fromJson(e))
              .toList() ??
          [],
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'has_rejections': hasRejections,
      'rejections': rejections.map((e) => e.toJson()).toList(),
      'count': count,
    };
  }
}

class Rejection {
  final int id;
  final String documentType;
  final String documentTypeFormatted;
  final String rejectionReason;
  final String adminName;
  final String rejectedAt;
  final String timeSinceRejection;
  final bool isResolved;

  Rejection({
    required this.id,
    required this.documentType,
    required this.documentTypeFormatted,
    required this.rejectionReason,
    required this.adminName,
    required this.rejectedAt,
    required this.timeSinceRejection,
    required this.isResolved,
  });

  factory Rejection.fromJson(Map<String, dynamic> json) {
    return Rejection(
      id: json['id'] ?? 0,
      documentType: json['document_type'] ?? '',
      documentTypeFormatted: json['document_type_formatted'] ?? '',
      rejectionReason: json['rejection_reason'] ?? '',
      adminName: json['admin_name'] ?? '',
      rejectedAt: json['rejected_at'] ?? '',
      timeSinceRejection: json['time_since_rejection'] ?? '',
      isResolved: json['is_resolved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_type': documentType,
      'document_type_formatted': documentTypeFormatted,
      'rejection_reason': rejectionReason,
      'admin_name': adminName,
      'rejected_at': rejectedAt,
      'time_since_rejection': timeSinceRejection,
      'is_resolved': isResolved,
    };
  }
}


// ============================================
// 2. SERVICE - lib/services/rejection_service.dart
// ============================================

// Import le model ci-dessus
// import '../models/rejection_response.dart';

class RejectionService {
  final Dio _dio = Dio();
      final GetStorage _storage = GetStorage();

  RejectionService() {
    _dio.options.baseUrl = ApiEnvironmentController.to.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<RejectionResponse> getRejectionReasons() async {


final token = _storage.read('token');
    try {
      final response = await _dio.get(
        '/user/rejection-reasons',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return RejectionResponse.fromJson(response.data);
      } else {
        throw Exception('Erreur: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Erreur serveur: ${e.response?.statusMessage}');
      } else {
        throw Exception('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }
}


// ============================================
// 3. CONTROLLER - lib/controllers/rejection_controller.dart
// ============================================

// Import le model et service ci-dessus
// import '../models/rejection_response.dart';
// import '../services/rejection_service.dart';

class RejectionController extends GetxController {
  final RejectionService _rejectionService = RejectionService();

  // Observables
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var rejectionResponse = Rxn<RejectionResponse>();
  var rejections = <Rejection>[].obs;

  // Getters
  bool get hasRejections => rejectionResponse.value?.hasRejections ?? false;
  int get rejectionCount => rejectionResponse.value?.count ?? 0;

  // Méthode pour récupérer les rejets
  Future<void> fetchRejectionReasons() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _rejectionService.getRejectionReasons();

      rejectionResponse.value = response;
      rejections.value = response.rejections;

      isLoading.value = false;

    } catch (e) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = e.toString();
      
      // Get.snackbar(
      //   'Erreur',
      //   e.toString(),
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    }
  }

  // Filtrer les rejets non résolus
  List<Rejection> get unresolvedRejections {
    return rejections.where((r) => !r.isResolved).toList();
  }

  // Filtrer par type de document
  List<Rejection> getRejectionsByType(String type) {
    return rejections.where((r) => r.documentType == type).toList();
  }

  // Rafraîchir les données
  // ignore: annotate_overrides
  Future<void> refresh() async {
    await fetchRejectionReasons();
  }

  // Nettoyer les données
  void clearData() {
    rejectionResponse.value = null;
    rejections.clear();
    hasError.value = false;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    clearData();
    super.onClose();
  }
}


// ============================================
// 4. UTILISATION - lib/pages/rejection_page.dart
// ============================================

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// // Import le controller ci-dessus
// // import '../controllers/rejection_controller.dart';

// class RejectionPage extends StatelessWidget {
//   RejectionPage({Key? key}) : super(key: key);

//   final RejectionController controller = Get.put(RejectionController());
//   final String token = '63810|pEfoVw1D8UUbDG6twDrvczbBWViifQx9yVza79Gk416ee427';

//   @override
//   Widget build(BuildContext context) {
//     // Charger les données au démarrage
//     controller.fetchRejectionReasons(token);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Mes Documents Rejetés'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => controller.refresh(token),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         // Afficher le loader
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // Afficher l'erreur
//         if (controller.hasError.value) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error_outline, size: 60, color: Colors.red),
//                 const SizedBox(height: 16),
//                 Text(
//                   controller.errorMessage.value,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () => controller.fetchRejectionReasons(token),
//                   child: const Text('Réessayer'),
//                 ),
//               ],
//             ),
//           );
//         }

//         // Afficher le message si pas de rejets
//         if (!controller.hasRejections) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.check_circle, size: 60, color: Colors.green),
//                 SizedBox(height: 16),
//                 Text('Aucun document rejeté', style: TextStyle(fontSize: 18)),
//               ],
//             ),
//           );
//         }

//         // Afficher la liste des rejets
//         return RefreshIndicator(
//           onRefresh: () => controller.refresh(token),
//           child: ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: controller.rejections.length,
//             itemBuilder: (context, index) {
//               final rejection = controller.rejections[index];
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: rejection.isResolved ? Colors.green : Colors.red,
//                     child: Icon(
//                       rejection.isResolved ? Icons.check : Icons.close,
//                       color: Colors.white,
//                     ),
//                   ),
//                   title: Text(
//                     rejection.documentTypeFormatted,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 4),
//                       Text('Raison: ${rejection.rejectionReason}', 
//                            style: const TextStyle(color: Colors.red)),
//                       const SizedBox(height: 4),
//                       Text('Rejeté par: ${rejection.adminName}', 
//                            style: const TextStyle(fontSize: 12)),
//                       Text(rejection.timeSinceRejection, 
//                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                     ],
//                   ),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.upload_file),
//                     onPressed: () {
//                       Get.snackbar('Action', 'Re-soumettre le document #${rejection.id}');
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       }),
//       bottomNavigationBar: Obx(() {
//         if (!controller.hasRejections) return const SizedBox.shrink();
        
//         return Container(
//           padding: const EdgeInsets.all(16),
//           color: Colors.red.shade50,
//           child: Text(
//             '${controller.rejectionCount} document(s) rejeté(s)',
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//         );
//       }),
//     );
//   }
// }