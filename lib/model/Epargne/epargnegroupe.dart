class Groupe {
  int id;
  String nom;
  int typeGroupeId;
  int? frequenceId;
  int? verrouillageId;
  String montantTotal;
  int estSonTour;
  int userId;
  int? userIdTour;
  String startDate;
  String? endDate;
  DateTime? nextDepositDate;
  DateTime? nextWithdrawDate;
  DateTime? deletedAt;
  DateTime createdAt;
  DateTime updatedAt;
  List<GroupeObject> groupeObjects;

  Groupe({
    required this.id,
    required this.nom,
    required this.typeGroupeId,
    this.frequenceId,
    this.verrouillageId,
    required this.montantTotal,
    required this.estSonTour,
    required this.userId,
    this.userIdTour,
    required this.startDate,
    this.endDate,
    this.nextDepositDate,
    this.nextWithdrawDate,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.groupeObjects,
  });

  factory Groupe.fromJson(Map<String, dynamic> json) {
    var list = json['groupe_objects'] as List? ?? [];
    List<GroupeObject> groupeObjectsList = list.map((e) => GroupeObject.fromJson(e)).toList();

    return Groupe(
      id: json['id'],
      nom: json['nom'],
      typeGroupeId: json['type_groupe_id'],
      frequenceId: json['frequence_id'],
      verrouillageId: json['verrouillage_id'],
      montantTotal: json['montant_total'],
      estSonTour: json['est_son_tour'],
      userId: json['user_id'],
      userIdTour: json['user_id_tour'] == null ? null : int.tryParse(json['user_id_tour'].toString()),
      startDate: json['startDate'],
      endDate: json['endDate'],
      nextDepositDate: json['next_deposit_date'] == null ? null : DateTime.parse(json['next_deposit_date']),
      nextWithdrawDate: json['next_withdraw_date'] == null ? null : DateTime.parse(json['next_withdraw_date']),
      deletedAt: json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      groupeObjects: groupeObjectsList,
    );
  }
}



class GroupeObject {
  int id;
  int epargneGroupeId;
  String nom;
  String montantCible;
  String montantFixe;
  String montantActuel;
  int nombreMembre;
  int objectifAtteint;
  int retire;
  String startDate;
  String endDate;
  List<Membre> membres;

  GroupeObject({
    required this.id,
    required this.epargneGroupeId,
    required this.nom,
    required this.montantCible,
    required this.montantFixe,
    required this.montantActuel,
    required this.nombreMembre,
    required this.objectifAtteint,
    required this.retire,
    required this.startDate,
    required this.endDate,
    required this.membres,
  });

  factory GroupeObject.fromJson(Map<String, dynamic> json) {
    var list = json['membres'] as List? ?? [];
    List<Membre> membresList = list.map((e) => Membre.fromJson(e)).toList();

    return GroupeObject(
      id: json['id'],
      epargneGroupeId: json['epargne_groupe_id'],
      nom: json['nom'],
      montantCible: json['montant_cible'],
      montantFixe: json['montant_fixe'],
      montantActuel: json['montant_actuel'],
      nombreMembre: json['nombre_membre'],
      objectifAtteint: json['objectif_atteint'],
      retire: json['retire'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      membres: membresList,
    );
  }
}

class Membre {
  int id;
  String name;
  String email;
  String? emailVerifiedAt;
  String? twoFactorConfirmedAt;
  String? currentTeamId;
  String? profilePhotoPath;
  String createdAt;
  String updatedAt;
  int organisationId;
  String? prenom;
  String telephone;
  String? adresse;
  String? typeUserId;
  String? oldId;
  String profilePhotoUrl;

  Membre({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.twoFactorConfirmedAt,
    this.currentTeamId,
    this.profilePhotoPath,
    required this.createdAt,
    required this.updatedAt,
    required this.organisationId,
    this.prenom,
    required this.telephone,
    this.adresse,
    this.typeUserId,
    this.oldId,
    required this.profilePhotoUrl,
  });

  factory Membre.fromJson(Map<String, dynamic> json) {
    return Membre(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      twoFactorConfirmedAt: json['two_factor_confirmed_at'],
      currentTeamId: json['current_team_id'],
      profilePhotoPath: json['profile_photo_path'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      organisationId: json['organisation_id'],
      prenom: json['prenom'],
      telephone: json['telephone'],
      adresse: json['adresse'],
      typeUserId: json['type_user_id'],
      oldId: json['old_id'],
      profilePhotoUrl: json['profile_photo_url'],
    );
  }
}
