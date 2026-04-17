// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'package:onyfast/model/app_notification.dart';
// import 'package:timeago/timeago.dart' as timeago;
// // import 'package:timeago/timeago.dart' as timeago_fr show fr;

// class NotificationController extends GetxController {
//   var notifications = <AppNotification>[].obs;
//   var groupedNotifications = <String, List<AppNotification>>{}.obs;
//   final GetStorage storage = GetStorage();
//   var isLoading = false.obs;
//   var hasError = false.obs;
//   var errorMessage = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     timeago.setLocaleMessages('fr', timeago.FrMessages());

//     // Données de test avec types corrects
//     notifications.value = [
//       AppNotification(
//         id: 1,
//         title: 'Test Notification',
//         body: 'Ceci est une notification de test.',
//         type: 'transaction',
//         date: DateTime.now(),
//         isRead: false,
//       ),
//       AppNotification(
//         id: 2,
//         title: 'Offre spéciale',
//         body: 'Profitez de -20% cette semaine.',
//         type: 'offre',
//         date: DateTime.now().subtract(const Duration(days: 1)),
//         isRead: true,
//       ),
//     ];

//     // Grouper les données de test d'abord
//     groupByDay();

//     // Puis récupérer les vraies données (avec un délai pour voir les données de test)
//     Future.delayed(const Duration(milliseconds: 500), () {
//       fetchNotifications();
//     });
//   }

//   // Configuration des URLs
//   static const String baseUrl =
//       'http://192.168.100.5:8001'; // Changez cette IP
//   // static const String baseUrl = 'http://10.0.2.2:8001'; // Pour émulateur
//   // static const String baseUrl = 'https://votre-domaine.com'; // Pour production

//   void fetchNotifications() async {
//     try {
//       isLoading.value = true;
//       hasError.value = false;
//       errorMessage.value = '';

//       final bearerToken = storage.read('token');

//       print('Bearer token: $bearerToken');

//       if (bearerToken == null || bearerToken.isEmpty) {
//         throw Exception('Session expirée, veuillez vous reconnecter');
//       }

//       // Timeout pour éviter l'attente infinie
//       final response = await http.get(
//         Uri.parse('$baseUrl/get-notifications'),
//         headers: {
//           'Authorization': 'Bearer $bearerToken',
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//       ).timeout(
//         Duration(seconds: 10),
//         onTimeout: () {
//           throw Exception(
//               'Délai d\'attente dépassé. Vérifiez votre connexion.');
//         },
//       );

//       print('Status code: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         try {
//           final responseData = json.decode(response.body);
//           print('Données reçues: $responseData');

//           List<AppNotification> newNotifications = [];

//           // Vérifier si la réponse contient des données
//           if (responseData is List) {
//             for (var item in responseData) {
//               if (item != null) {
//                 newNotifications.add(AppNotification.fromJson(item));
//               }
//             }
//           } else if (responseData is Map && responseData.containsKey('data')) {
//             final List data = responseData['data'] ?? [];
//             for (var item in data) {
//               if (item != null) {
//                 newNotifications.add(AppNotification.fromJson(item));
//               }
//             }
//           } else if (responseData is Map &&
//               responseData.containsKey('notifications')) {
//             final List data = responseData['notifications'] ?? [];
//             for (var item in data) {
//               if (item != null) {
//                 newNotifications.add(AppNotification.fromJson(item));
//               }
//             }
//           }

//           notifications.value = newNotifications;
//           print('Notifications chargées: ${notifications.length}');
//         } catch (parseError) {
//           print('Erreur de parsing JSON: $parseError');
//           print('Réponse brute: ${response.body}');
//           throw Exception('Erreur de format des données reçues');
//         }

//         groupByDay();
//       } else if (response.statusCode == 401) {
//         throw Exception('Session expirée, veuillez vous reconnecter');
//       } else {
//         throw Exception(
//             'Erreur lors du chargement des notifications: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Erreur fetchNotifications: $e');
//       hasError.value = true;

//       // Messages d'erreur plus spécifiques
//       if (e.toString().contains('No route to host') ||
//           e.toString().contains('SocketException')) {
//         errorMessage.value =
//             'Impossible de se connecter au serveur.\nVérifiez votre connexion internet et l\'adresse du serveur.';
//       } else if (e.toString().contains('TimeoutException') ||
//           e.toString().contains('Délai d\'attente')) {
//         errorMessage.value =
//             'La connexion a pris trop de temps.\nVérifiez votre connexion internet.';
//       } else if (e.toString().contains('Session expirée')) {
//         errorMessage.value = 'Session expirée, veuillez vous reconnecter.';
//       } else {
//         errorMessage.value = 'Une erreur est survenue:\n${e.toString()}';
//       }

//       // En cas d'erreur, garder les données de test visibles
//       if (notifications.isEmpty) {
//         // Ne pas effacer les données de test, juste re-grouper
//         groupByDay();
//       }
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // void groupByDay() {
//   //   try {
//   //     final now = DateTime.now();
//   //     final Map<String, List<AppNotification>> result = {
//   //       "Aujourd'hui": [],
//   //       "Hier": [],
//   //       "Plus ancien": [],
//   //     };

//   //     for (var n in notifications) {
//   //       if (n != null) {
//   //         if (isSameDay(n.date, now)) {
//   //           result["Aujourd'hui"]!.add(n);
//   //         } else if (isSameDay(n.date, now.subtract(const Duration(days: 1)))) {
//   //           result["Hier"]!.add(n);
//   //         } else {
//   //           result["Plus ancien"]!.add(n);
//   //         }
//   //       }
//   //     }

//   //     // Supprimer les sections vides
//   //     result.removeWhere((key, value) => value.isEmpty);

//   //     groupedNotifications.value = result;
//   //     print('Notifications groupées: ${groupedNotifications.length} sections');
//   //   } catch (e) {
//   //     print('Erreur lors du groupement: $e');
//   //     groupedNotifications.value = {};
//   //   }
//   // }

//   void groupByDay() {
//     try {
//       final now = DateTime.now();

//       // 🟡 Trier par date décroissante avant de grouper
//       final sortedNotifications = List<AppNotification>.from(notifications)
//         ..sort((a, b) => b.date.compareTo(a.date)); // plus récent d'abord

//       final Map<String, List<AppNotification>> result = {
//         "Aujourd'hui": [],
//         "Hier": [],
//         "Plus ancien": [],
//       };

//       for (var n in sortedNotifications) {
//         if (isSameDay(n.date, now)) {
//           result["Aujourd'hui"]!.add(n);
//         } else if (isSameDay(n.date, now.subtract(const Duration(days: 1)))) {
//           result["Hier"]!.add(n);
//         } else {
//           result["Plus ancien"]!.add(n);
//         }
//       }

//       // Supprimer les sections vides
//       result.removeWhere((key, value) => value.isEmpty);

//       groupedNotifications.value = result;
//       print('Notifications groupées: ${groupedNotifications.length} sections');
//     } catch (e) {
//       print('Erreur lors du groupement: $e');
//       groupedNotifications.value = {};
//     }
//   }

//   bool isSameDay(DateTime a, DateTime b) {
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }

//   // void markAsRead(AppNotification notif) {
//   //   notif.isRead = true;
//   //   notifications.refresh();
//   //   groupByDay(); // Re-grouper après modification
//   // }

//   // void markAllAsRead() {
//   //   for (var notif in notifications) {
//   //     notif.isRead = true;
//   //   }
//   //   notifications.refresh();
//   //   groupByDay();
//   // }

//   void markAsRead(AppNotification notif) async {
//     try {
//       final bearerToken = storage.read('token');
//       final response = await http.post(
//         Uri.parse('$baseUrl/notifications/${notif.id}/read'),
//         headers: {
//           'Authorization': 'Bearer ${bearerToken}', // selon ton système
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         notif.isRead = true;
//         notifications.refresh();
//         groupByDay();
//       } else {
//         print('❌ Erreur lors de la mise à jour (1 notif) : ${response.body}');
//       }
//     } catch (e) {
//       print('❌ Exception markAsRead : $e');
//     }
//   }

//   void markAllAsRead() async {
//     try {
//       final bearerToken = storage.read('token');
//       final ids = notifications.map((n) => n.id).toList();

//       final response = await http.post(
//         Uri.parse('$baseUrl/notifications/mark-all-read'),
//         headers: {
//           'Authorization': 'Bearer $bearerToken',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'ids': ids}),
//       );

//       if (response.statusCode == 200) {
//         for (var notif in notifications) {
//           notif.isRead = true;
//         }
//         notifications.refresh();
//         groupByDay();
//       } else {
//         print('❌ Erreur lors de markAllAsRead : ${response.body}');
//       }
//     } catch (e) {
//       print('❌ Exception markAllAsRead : $e');
//     }
//   }

//   void refreshNotifications() {
//     fetchNotifications();
//   }

//   // Méthode pour tester la connectivité
//   Future<bool> testConnection() async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//             '$baseUrl/health-check'), // ou n'importe quelle route simple
//         headers: {'Accept': 'application/json'},
//       ).timeout(Duration(seconds: 5));

//       return response.statusCode == 200;
//     } catch (e) {
//       print('Test de connexion échoué: $e');
//       return false;
//     }
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/model/app_notification.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();
  var loading2=false.obs;
  RxInt get unreadCount => notifications.where((n) => !n.isRead).length.obs;
  
  final GetStorage storage = GetStorage();

  // Observables
  var notifications = <AppNotification>[].obs;
  var groupedNotifications = <String, List<AppNotification>>{}.obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // StreamController pour les flux (facultatif mais utile avec StreamBuilder)
  final _streamController = StreamController<List<AppNotification>>.broadcast();
  Stream<List<AppNotification>> get notificationStream =>
      _streamController.stream;

  Timer? _refreshTimer;

  // static const String baseUrl = 'http://192.168.100.5:8001';

  @override
  void onInit() {
    super.onInit();
    timeago.setLocaleMessages('fr', timeago.FrMessages());

    // Données de test affichées immédiatement
    notifications.value = [
     
    ];
    groupByDay();

    // Chargement réel après petit délai
    Future.delayed(const Duration(milliseconds: 100), () {
      fetchNotifications();
    });

    // Rafraîchissement automatique toutes les 30 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchNotifications();
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    _streamController.close();
    super.onClose();
  }

  void fetchNotifications() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final bearerToken = storage.read('token');
      if (bearerToken == null || bearerToken.isEmpty) {
        throw Exception('Session expirée, veuillez vous reconnecter');
      }

      final response = await http.get(
        Uri.parse('${ApiEnvironmentController.to.baseUrl}/get-notifications'),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<AppNotification> newNotifications = [];

        if (responseData is List) {
          for (var item in responseData) {
            if (item != null) {
              newNotifications.add(AppNotification.fromJson(item));
            }
          }
        } else if (responseData is Map && responseData.containsKey('data')) {
          final List data = responseData['data'] ?? [];
          for (var item in data) {
            if (item != null) {
              newNotifications.add(AppNotification.fromJson(item));
            }
          }
        } else if (responseData is Map &&
            responseData.containsKey('notifications')) {
          final List data = responseData['notifications'] ?? [];
          for (var item in data) {
            if (item != null) {
              newNotifications.add(AppNotification.fromJson(item));
            }
          }
        }

        notifications.value = newNotifications;
        _streamController.add(newNotifications); // Pour StreamBuilder
        groupByDay();
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée, veuillez vous reconnecter');
      } else {
        throw Exception('Erreur lors du chargement: ${response.statusCode}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = _handleError(e);
      if (notifications.isEmpty) groupByDay(); // Afficher les données de test
    } finally {
      isLoading.value = false;
    }
  }

  String _handleError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('No route to host') || msg.contains('SocketException')) {
      return 'Connexion impossible au serveur.\nVérifiez votre réseau ou l\'adresse IP.';
    } else if (msg.contains('TimeoutException') ||
        msg.contains('Délai d\'attente')) {
      return 'Connexion trop longue.\nVérifiez votre connexion internet.';
    } else if (msg.contains('Session expirée')) {
      return 'Session expirée, veuillez vous reconnecter.';
    } else {
      return 'Erreur inconnue :\n$msg';
    }
  }

  void groupByDay() {
    try {
      final now = DateTime.now();
      final sorted = List<AppNotification>.from(notifications)
        ..sort((a, b) => b.date.compareTo(a.date));

      final Map<String, List<AppNotification>> result = {
        "Aujourd'hui": [],
        "Hier": [],
        "Plus ancien": [],
      };

      for (var n in sorted) {
        if (isSameDay(n.date, now)) {
          result["Aujourd'hui"]!.add(n);
        } else if (isSameDay(n.date, now.subtract(const Duration(days: 1)))) {
          result["Hier"]!.add(n);
        } else {
          result["Plus ancien"]!.add(n);
        }
      }

      result.removeWhere((key, value) => value.isEmpty);
      groupedNotifications.value = result;
    } catch (e) {
      print('Erreur groupByDay: $e');
      groupedNotifications.value = {};
    }
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void markAsRead(AppNotification notif) async {
    print('🤯🤯🤯🤯🤯 Voila ${notif.notificationId}');
    try {
      final token = storage.read('token');
      final response = await http.post(
        Uri.parse('${ApiEnvironmentController.to.baseUrl}/notifications/${notif.notificationId}/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        notif.isRead = true;
        notifications.refresh();
        groupByDay();
      } else {
        print('Erreur markAsRead : ${response.body}');
      }
    } catch (e) {
      print('Exception markAsRead : $e');
    }
  }

  void markAllAsRead() async {
    try {
      final token = storage.read('token');
      final ids = notifications.map((n) => n.id).toList();
 var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
  var ip=await ValidationTokenController.to.getPublicIP();
      final response = await http.post(
        Uri.parse('${ApiEnvironmentController.to.baseUrl}/notifications/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'ids': ids,
          'device':deviceskey,
          "ip":ip
        }),
      );

      if (response.statusCode == 200) {
        for (var notif in notifications) {
          notif.isRead = true;
        }
        notifications.refresh();
        groupByDay();
      } else {
        print('Erreur markAllAsRead : ${response.body}');
      }
    } catch (e) {
      print('Exception markAllAsRead : $e');
    }
  }

  void refreshNotifications() => fetchNotifications();

  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEnvironmentController.to.baseUrl}/health-check'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('Test connexion échoué: $e');
      return false;
    }
  }
}
