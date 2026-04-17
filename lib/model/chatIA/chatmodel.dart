// lib/models/chat_message.dart
enum MessageStatus {
  sending,    // En cours d'envoi
  sent,       // Envoyé avec succès
  delivered,  // Livré
  read,       // Lu
  failed,     // Échec de l'envoi
}

// Extension pour convertir en String
extension MessageStatusExtension on MessageStatus {
  String get name {
    switch (this) {
      case MessageStatus.sending:
        return 'sending';
      case MessageStatus.sent:
        return 'sent';
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.read:
        return 'read';
      case MessageStatus.failed:
        return 'failed';
    }
  }

  static MessageStatus fromString(String name) {
    switch (name) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool? isRead;
  final String? senderId;
  final MessageStatus status;
  final int? retryCount;
  final String? errorMessage;

  ChatMessage({
    String? id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isRead = true,
    this.senderId,
    this.status = MessageStatus.sent,
    this.retryCount = 0,
    this.errorMessage,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Convertir en Map pour le stockage (CORRIGÉ)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead ?? true,
      'senderId': senderId,
      'status': status.name, // Utiliser le nom de l'enum
      'retryCount': retryCount ?? 0,
      'errorMessage': errorMessage,
    };
  }

  // Créer à partir d'un Map (CORRIGÉ)
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String? ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] as bool? ?? true,
      senderId: json['senderId'] as String?,
      status: MessageStatusExtension.fromString(json['status'] as String? ?? 'sent'), // Convertir depuis string
      retryCount: json['retryCount'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  // Copier avec modifications
  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isRead,
    String? senderId,
    MessageStatus? status,
    int? retryCount,
    String? errorMessage,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      senderId: senderId ?? this.senderId,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Méthodes utilitaires
  bool get isSending => status == MessageStatus.sending;
  bool get isSent => status == MessageStatus.sent;
  bool get isDelivered => status == MessageStatus.delivered;
  bool get isReadStatus => status == MessageStatus.read;
  bool get isFailed => status == MessageStatus.failed;

  // Icône selon le statut
  String get statusIcon {
    switch (status) {
      case MessageStatus.sending:
        return '⏳';
      case MessageStatus.sent:
        return '✓';
      case MessageStatus.delivered:
        return '✓✓';
      case MessageStatus.read:
        return '👁️';
      case MessageStatus.failed:
        return '✗';
    }
  }

  // Texte du statut
  String get statusText {
    switch (status) {
      case MessageStatus.sending:
        return 'Envoi en cours...';
      case MessageStatus.sent:
        return 'Envoyé';
      case MessageStatus.delivered:
        return 'Livré';
      case MessageStatus.read:
        return 'Lu';
      case MessageStatus.failed:
        return errorMessage ?? 'Échec de l\'envoi';
    }
  }

  // Couleur selon le statut
  int get statusColor {
    switch (status) {
      case MessageStatus.sending:
        return 0xFFF39C12; // Orange
      case MessageStatus.sent:
        return 0xFF3498DB; // Bleu
      case MessageStatus.delivered:
        return 0xFF2ECC71; // Vert clair
      case MessageStatus.read:
        return 0xFF27AE60; // Vert foncé
      case MessageStatus.failed:
        return 0xFFE74C3C; // Rouge
    }
  }
}