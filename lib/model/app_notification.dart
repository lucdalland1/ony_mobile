class AppNotification {
  final int id;
  final String notificationId; // 👈 champ manquant (UUID)
  final String title;
  final String body;
  final String type;
  final DateTime date;
  bool isRead;

  AppNotification({
    required this.id,
    required this.notificationId, // 👈
    required this.title,
    required this.body,
    required this.type,
    required this.date,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    try {
      return AppNotification(
        id: json['id']?.toInt() ?? 0,
        notificationId: json['notificationId']?.toString() ?? '', // 👈
        title: json['title']?.toString() ?? 'Notification',
        body: json['body']?.toString() ?? 'Aucun contenu',
        type: json['type']?.toString() ?? 'general',
        date: json['date'] != null
            ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
            : DateTime.now(),
        isRead: json['is_read'] == true || json['isRead'] == true,
      );
    } catch (e) {
      print('Erreur lors de la désérialisation: $e');
      return AppNotification(
        id: 0,
        notificationId: '', // 👈
        title: 'Erreur de données',
        body: 'Impossible de charger cette notification',
        type: 'error',
        date: DateTime.now(),
        isRead: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId, // 👈
      'title': title,
      'body': body,
      'type': type,
      'date': date.toIso8601String(),
      'is_read': isRead,
    };
  }

  @override
  String toString() {
    return 'AppNotification(id: $id, notificationId: $notificationId, title: $title, type: $type, isRead: $isRead)';
  }
}