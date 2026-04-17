import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/OnypayController/PendingPaymentCacheController.dart';
import 'package:onyfast/Controller/OnypayController/onypayController.dart';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:onyfast/View/Notification/notification.dart';
import 'package:onyfast/View/OnyPay/listedesPayementEnAttentes.dart';
import 'package:onyfast/View/hometoken.dart';
import 'package:onyfast/main.dart';
import 'package:onyfast/model/Onypay/payementEnAttente.dart';
import 'package:onyfast/utils/misaAjourService.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await Firebase.initializeApp();

    // ✅ Configuration iOS AVANT Android
    if (Platform.isIOS) {
      await _configureIOSNotifications();
    }

    // ✅ Configure les notifications locales pour Android ET iOS
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // ✅ Créer le canal de notification pour Android
    if (Platform.isAndroid) {
      await _createAndroidNotificationChannel();
    }

    // Demande de permission avec options spécifiques iOS
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Notifications autorisées');

      // ✅ Configuration spécifique iOS
      if (Platform.isIOS) {
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Gérer les messages en arrière-plan
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

      // Gérer les messages en premier plan
      FirebaseMessaging.onMessage.listen(_onMessageHandler);

      // Gérer les clics sur notifications (app en arrière-plan)
      FirebaseMessaging.onMessageOpenedApp
          .listen(_handleFirebaseNotificationClick);

      // ✅ Gérer les clics quand l'app est fermée
      _checkInitialMessage();

      // ✅ Récupérer et afficher le token FCM (avec gestion d'erreur pour simulateur)
      try {
        await getDeviceToken();
      } catch (e) {
        print(
            '⚠️ Impossible de récupérer le token (normal sur simulateur iOS): $e');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('⚠️ Notifications provisoires accordées');
    } else {
      print('❌ Notifications non autorisées');
    }
  }

  // ✅ Configuration spécifique iOS
  static Future<void> _configureIOSNotifications() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ✅ Créer le canal de notification Android
  static Future<void> _createAndroidNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel', // id
      'Notifications générales', // name
      description: 'Canal de notifications par défaut',
      importance: Importance.max,
      playSound: true,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ✅ Vérifier si l'app a été ouverte via une notification
  static Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('📩 App ouverte via notification : ${initialMessage.data}');
      _handleFirebaseNotificationClick(initialMessage);
    }
  }

  // ✅ Gestionnaire pour les clics sur notifications locales
  static void _onNotificationTapped(NotificationResponse response) {
    print('📱 Notification locale cliquée : ${response.payload}');

    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        Map<String, dynamic> data = json.decode(response.payload!);
        _handleNotificationRedirection(data);
      } catch (e) {
        print('❌ Erreur parsing payload : $e');
        Get.to(NotificationsPage());
      }
    }
  }

  // ✅ Gestionnaire pour les clics sur notifications Firebase
  static void _handleFirebaseNotificationClick(RemoteMessage message) {
    print('📩 Notification Firebase ouverte : ${message.data}');
    _handleNotificationRedirection(message.data);
  }

  static Future<String?> getDeviceToken() async {
    try {
      // ✅ Pour iOS, vérifier d'abord si on a un APNs token (pas disponible sur simulateur)
      if (Platform.isIOS) {
        String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          print('⚠️ APNs Token non disponible (simulateur iOS)');
          print(
              '💡 Les notifications push ne fonctionnent que sur un appareil physique iOS');
          return null;
        }
        print('📱 APNs Token : $apnsToken');
      }

      String? token = await _messaging.getToken();
      print('📱 Token FCM : $token');
      return token;
    } catch (e) {
      print('❌ Erreur lors de la récupération du token: $e');
      if (Platform.isIOS) {
        print(
            '💡 Les simulateurs iOS ne supportent pas les notifications push');
      }
      return null;
    }
  }

  static Future<void> _onMessageHandler(RemoteMessage message) async {
    _showLocalNotification(message);
    await miseAjourView();
    print('📬 Message reçu en premier plan: ${message.notification?.title}');
    print('--------------------------------------------------');

    print('Message data: ${message.data.toString()}');
    var type = message.data['type_notification_id']??'';
    var code = message.data['code']??'';
    if(int.parse(type) == 4){
       await OnyPayController.to.loadPendingOtp();
    }
    if (int.parse(type) == 4 && code != null) {
  try {
    var paymentId = message.data['payment_id'];
    await OnyPayController.to.loadPendingOtp();

    if (OnyPayController.to.pendingPayments.isNotEmpty) {
      // ✅ firstWhereOrNull au lieu de .map()
      final payementCourant = OnyPayController.to.pendingPayments
          .firstWhereOrNull((payment) => payment.paymentId == paymentId);

      print('🔍 payment_id cherché: $paymentId');
      print('🔍 paiement trouvé: $payementCourant');
      bool isLocked = LockController.to.isLocked;
      
      print('App verrouillée : $isLocked');
   
    
      if (payementCourant != null) {

        if(!isLocked){
          showDetailSheetPaiement(payementCourant, OnyPayController.to);
        }else{
          PendingPaymentCacheController.to.savePayment(payementCourant);

        }
      } else {
        print('❌ Aucun paiement trouvé avec id: $paymentId');
      }
      
    }
  } catch (e) {
    print('❌ Erreur: $e');
  }
}

    
    
  }

  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('📬 Message reçu en arrière-plan: ${message.notification?.title}');
    _showLocalNotification(message);
    await miseAjourView();
    print('Message data: ${message.data.toString()}');
    var type = message.data['type_notification_id'];
    var code = message.data['code'];
    if (int.parse(type) == 4 && code != null) {
      try {
        await OnyPayController.to.loadPendingOtp();
        SecureTokenController.to.saveTypeNotificationId(int.parse(type));
        SecureTokenController.to.saveCode(code);
        
      } catch (e) {}

      print('nous sommes sur Onypay');
    }

    
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    // ✅ Configuration Android
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Notifications générales',
      channelDescription: 'Canal de notifications par défaut',
      importance: Importance.max,
      priority: Priority.high,
      autoCancel: true,
      playSound: true,
      enableVibration: true,
    );

    // ✅ Configuration iOS avec plus d'options
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      badgeNumber: 1,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // ✅ Payload encodé en JSON
    String payload = json.encode(message.data);

    await _localNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? '📢 Notification',
      message.notification?.body ?? '',
      notificationDetails,
      payload: payload,
    );
  }

  // ✅ Gestion centralisée de la redirection
  static void _handleNotificationRedirection(Map<String, dynamic> data) async {
    final type = data['type'];
    final id = data['id'];

    print('🔄 Redirection type: $type, id: $id');
    final box = GetStorage();
    final token = await box.read('token');
    if (token == null) {
      print(
          '⚠️ Utilisateur non authentifié, redirection vers la page de connexion');
      Get.offAll(HomeToken());
      return;
    }
    // Attendre que l'interface soit prête
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (type) {
        case 'transaction':
          if (id != null) {
            Get.toNamed('/transaction-details', arguments: {'id': id});
          } else {
            Get.toNamed('/transactions');
          }
          break;
        case 'cashback':
          Get.toNamed('/cashback');
          break;
        case 'offre':
          Get.toNamed('/offres');
          break;
        default:
          Get.to(NotificationsPage());
      }
    });
  }

  // ✅ Méthode pour tester les notifications
  static Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test',
      channelDescription: 'Canal de test',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    Map<String, dynamic> testData = {'type': 'transaction', 'id': '12345'};

    await _localNotificationsPlugin.show(
      999,
      'Test Notification',
      'Cliquez pour tester la redirection',
      notificationDetails,
      payload: json.encode(testData),
    );
  }

  /// 🔴 Supprime toutes les notifications locales affichées
  static Future<void> clearAllNotifications() async {
    try {
      await _localNotificationsPlugin.cancelAll();
      print('🧹 Toutes les notifications locales ont été supprimées');
    } catch (e) {
      print('❌ Erreur suppression notifications : $e');
    }
  }
}
