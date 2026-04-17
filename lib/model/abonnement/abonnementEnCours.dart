class AbonnementEnCoursResponse {
  final bool success;
  final AbonnementEnCours data;

  AbonnementEnCoursResponse({required this.success, required this.data});

  factory AbonnementEnCoursResponse.fromJson(Map<String, dynamic> json) {
    return AbonnementEnCoursResponse(
      success: json['success'] as bool,
      data: AbonnementEnCours.fromJson(json['data']['abonnement']), // accès direct à l'abonnement
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class AbonnementEnCours {
  final int id;
  final String type;
  final String dateDebut;
  final String dateFin;
  final String statut;
  final String? modePaiement;
  final String prixMensuel;
  final bool autoRenew;

  AbonnementEnCours({
    required this.id,
    required this.type,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    this.modePaiement,
    required this.prixMensuel,
    required this.autoRenew,
  });

  factory AbonnementEnCours.fromJson(Map<String, dynamic> json) {
    return AbonnementEnCours(
      id: json['id'] as int,
      type: json['type'] as String,
      dateDebut: json['date_debut'] as String,
      dateFin: json['date_fin'] as String,
      statut: json['statut'] as String,
      modePaiement: json['mode_paiement'],
      prixMensuel: json['prix_mensuel'] as String,
      autoRenew: json['auto_renew'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'date_debut': dateDebut,
      'date_fin': dateFin,
      'statut': statut,
      'mode_paiement': modePaiement,
      'prix_mensuel': prixMensuel,
      'auto_renew': autoRenew,
    };
  }
}
