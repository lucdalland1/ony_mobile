// lib/Controller/chatIa/chatIAController.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/model/chatIA/chatmodel.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class ChatController extends GetxController {
  static const String storageKey = 'chat_messages';
  static const String sessionKey = 'chat_session_id';
  static const String userPhoneKey = 'user_phone';
  
  final GetStorage _box = GetStorage();
  final Dio _dio = Dio();

  /// Liste réactive des messages
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  
  /// État du chargement
  final RxBool isLoading = false.obs;
  
  /// Session ID
  late String sessionId;
  
  /// Téléphone de l'utilisateur
  String userPhone = '242066367034'; // Valeur par défaut

  // Configuration API
  static const String apiUrl = 'https://ai.onyfastbank.com/webhook/mobile-webhook';
  static const Duration timeout = Duration(seconds: 100);

  @override
  void onInit() {
    super.onInit();
    _configureDio();
    _initializeSession();
    _loadMessages();
    _loadUserInfo();
  }

  /* =========================
     Configuration Dio
     ========================= */
  
  void _configureDio() {
    _dio.options = BaseOptions(
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  /* =========================
     Initialisation
     ========================= */
  
  void _initializeSession() {
    // Récupérer ou créer un session_id unique
    sessionId = _box.read(sessionKey) ?? _generateSessionId();
    _box.write(sessionKey, sessionId);
    print('📱 Session ID: $sessionId');
  }

  String _generateSessionId() {
    return 'mobile-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _loadUserInfo() {
    final storedPhone = _box.read(userPhoneKey);
    if (storedPhone != null) {
      userPhone = storedPhone;
    }
  }

  void setUserPhone(String phone) {
    userPhone = phone;
    _box.write(userPhoneKey, phone);
  }

  /* =========================
     Stockage local
     ========================= */
  
  void _loadMessages() {
    try {
      final List<dynamic>? stored = _box.read(storageKey);
      if (stored != null) {
        messages.value = stored
            .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        print('💾 ${messages.length} messages chargés depuis le stockage');
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des messages: $e');
    }
  }

  void _saveMessages() {
    try {
      _box.write(
        storageKey,
        messages.map((m) => m.toJson()).toList(),
      );
      print('💾 Messages sauvegardés');
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde: $e');
    }
  }

  /* =========================
     Appel API
     ========================= */
  
  Future<Map<String, dynamic>?> _callApi(String messageText) async {
    try {
        final GetStorage storage = GetStorage();

          var user = storage.read('userInfo') ?? {};

      final data = {
        "message": messageText,
        "user_phone": user['telephone']??"",
        "client_telephone": user['telephone']??"",
        "session_id": "${user['telephone']}",
      };

      print('📤 Envoi du message: $messageText');
      print('📡 Session: $sessionId');
      print('📞 Phone: $userPhone');
      
      final response = await _dio.post(
        apiUrl,
        data: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('✅ Réponse reçue: ${response.data}');
        return response.data;
      } else {
        print('❌ Erreur HTTP: ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Erreur serveur: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ Erreur Dio: ${e.type} - ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      return null;
    }
  }

  Map<String, dynamic>? _handleDioError(DioException e) {
    String errorMessage;
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Délai d\'attente dépassé. Vérifiez votre connexion.';
        break;
      
      case DioExceptionType.connectionError:
        errorMessage = 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
        break;
      
      case DioExceptionType.badResponse:
        errorMessage = 'Réponse invalide du serveur.';
        break;
      
      default:
        errorMessage = 'Une erreur est survenue. Réessayez plus tard.';
    }
    
    return {'error': true, 'message': errorMessage};
  }

  /* =========================
     Envoi de messages avec API
     ========================= */
  
  /// Envoyer un message utilisateur et récupérer la réponse
  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;

    // 1. Créer le message utilisateur avec statut "sending"
    final userMessage = ChatMessage(
      text: messageText.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    // 2. Ajouter le message à la liste
    messages.add(userMessage);
    _saveMessages();

    // 3. Activer le chargement
    isLoading.value = true;

    try {
      // 4. Envoyer la requête à l'API
      print('📡 Envoi à l\'API...');
      final response = await _callApi(messageText.trim());

      // 5. Vérifier si la réponse contient une erreur
      if (response == null || response['error'] == true) {
        throw Exception(response?['message'] ?? 'Erreur de connexion');
      }

      // 6. Mise à jour du statut du message utilisateur
      updateStatus(userMessage.id, MessageStatus.sent);

      // 7. Attendre un peu pour simuler le "typing"
      await Future.delayed(Duration(milliseconds: 500));

      // 8. Extraire le message de la réponse
      String botMessageText = response['message'] ?? 'Désolé, je n\'ai pas pu traiter votre demande.';
      
      // 9. Ajouter la réponse du bot
      final botMessage = ChatMessage(
        text: botMessageText,
        isUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.read,
      );

      messages.add(botMessage);
      _saveMessages();

      // 10. Marquer le message utilisateur comme lu
      updateStatus(userMessage.id, MessageStatus.read);
      
      print('✅ Message envoyé et réponse reçue');

    } catch (e) {
      // 11. Gestion des erreurs
      print('❌ Erreur: $e');
      
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('connexion')) {
        errorMessage = 'Pas de connexion internet';
      } else if (e.toString().contains('serveur')) {
        errorMessage = 'Erreur serveur. Réessayez plus tard.';
      } else if (e.toString().contains('Délai')) {
        errorMessage = 'Le serveur met trop de temps à répondre';
      }
      
      updateStatus(
        userMessage.id,
        MessageStatus.failed,
        errorMessage: errorMessage,
      );

      // Afficher un message d'erreur
      SnackBarService.error(
        
        errorMessage,
       
      );

    } finally {
      // 12. Désactiver le chargement
      isLoading.value = false;
    }
  }

  /// Réessayer l'envoi d'un message échoué
  Future<void> retryMessage(String messageId) async {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final message = messages[index];
    if (!message.isFailed) return;

    // Supprimer l'ancien message
    messages.removeAt(index);
    _saveMessages();

    // Renvoyer le message
    await sendMessage(message.text);
  }

  /* =========================
     Gestion des messages
     ========================= */
  
  void addMessage(ChatMessage message) {
    messages.add(message);
    _saveMessages();
  }

  void updateMessage(ChatMessage updatedMessage) {
    final index = messages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      messages[index] = updatedMessage;
      _saveMessages();
    }
  }

  void updateStatus(
    String messageId,
    MessageStatus status, {
    String? errorMessage,
  }) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      messages[index] = messages[index].copyWith(
        status: status,
        errorMessage: errorMessage,
      );
      _saveMessages();
    }
  }

  void markAsRead(String messageId) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      messages[index] = messages[index].copyWith(
        status: MessageStatus.read,
        isRead: true,
      );
      _saveMessages();
    }
  }

  void removeMessage(String messageId) {
    messages.removeWhere((m) => m.id == messageId);
    _saveMessages();
  }

  void clearChat() {
    messages.clear();
    _box.remove(storageKey);
    
    // Regénérer une nouvelle session
    sessionId = _generateSessionId();
    _box.write(sessionKey, sessionId);
    
    print('🗑️ Chat effacé et nouvelle session créée');
  }

  /* =========================
     Getters utiles
     ========================= */
  
  List<ChatMessage> get userMessages =>
      messages.where((m) => m.isUser).toList();

  List<ChatMessage> get botMessages =>
      messages.where((m) => !m.isUser).toList();

  bool get hasFailedMessages =>
      messages.any((m) => m.isFailed);

  int get failedMessagesCount =>
      messages.where((m) => m.isFailed).length;
}