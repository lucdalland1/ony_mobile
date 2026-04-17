class EpargneIndividuelleModel {
  final int id;
  final String montantTotal;
  final String montantProgramme;
  final int userId;
  final int frequenceId;
  final int verrouillageId;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final Frequence frequence;
  final List<Objet> objets;
  final List<dynamic> depots;
  final List<dynamic> retraits;

  EpargneIndividuelleModel({
    required this.id,
    required this.montantTotal,
    required this.montantProgramme,
    required this.userId,
    required this.frequenceId,
    required this.verrouillageId,
    required this.startDate,
    required this.endDate,
    required this.scheduledAt,
    required this.createdAt,
    required this.frequence,
    required this.objets,
    required this.depots,
    required this.retraits,
  });

  factory EpargneIndividuelleModel.fromJson(Map<String, dynamic> json) {
    return EpargneIndividuelleModel(
      id: json['id'],
      montantTotal: json['montant_total'],
      montantProgramme: json['montant_programme'],
      userId: json['user_id'],
      frequenceId: json['frequence_id'],
      verrouillageId: json['verrouillage_id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      scheduledAt: DateTime.parse(json['scheduled_at']),
      createdAt: DateTime.parse(json['created_at']),
      frequence: Frequence.fromJson(json['frequence']),
      objets: (json['objets'] as List).map((e) => Objet.fromJson(e)).toList(),
      depots: json['depots'] ?? [],
      retraits: json['retraits'] ?? [],
    );
  }
}

class Frequence {
  final int id;
  final String nom;
  final int? userId;
  final String? startDate;
  final String? endDate;
  final DateTime createdAt;

  Frequence({
    required this.id,
    required this.nom,
    this.userId,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  factory Frequence.fromJson(Map<String, dynamic> json) {
    return Frequence(
      id: json['id'],
      nom: json['nom'],
      userId: json['user_id'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Objet {
  final int id;
  final int epargneIndividuelleId;
  final int? etatId;
  final String nom;
  final String montantCible;
  final String montantActuel;
  final DateTime? nextDepositDate;
  final DateTime? nextRetraitDate;
  final bool autoMode;
  final bool objectifAtteint;
  final int userId;
  final String startDate;
  final String endDate;
  final DateTime createdAt;
  final DateTime? archivedAt;

  Objet({
    required this.id,
    required this.epargneIndividuelleId,
    this.etatId,
    required this.nom,
    required this.montantCible,
    required this.montantActuel,
    this.nextDepositDate,
    this.nextRetraitDate,
    required this.autoMode,
    required this.objectifAtteint,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.archivedAt,
  });

  factory Objet.fromJson(Map<String, dynamic> json) {
    return Objet(
      id: json['id'],
      epargneIndividuelleId: json['epargne_individuelle_id'],
      etatId: json['etat_id'],
      nom: json['nom'],
      montantCible: json['montant_cible'],
      montantActuel: json['montant_actuel'],
      nextDepositDate: json['next_deposit_date'] != null
          ? DateTime.tryParse(json['next_deposit_date'])
          : null,
      nextRetraitDate: json['next_retrait_date'] != null
          ? DateTime.tryParse(json['next_retrait_date'])
          : null,
      autoMode: json['auto_mode'] == 1,
      objectifAtteint: json['objectif_atteint'] == 1,
      userId: json['user_id'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      createdAt: DateTime.parse(json['created_at']),
      archivedAt: json['archived_at'] != null ? DateTime.tryParse(json['archived_at']) : null,
    );
  }
}
