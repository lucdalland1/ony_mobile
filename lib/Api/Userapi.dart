class User {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? twoFactorConfirmedAt;
  final int? currentTeamId;
  final String? profilePhotoPath;
  final String createdAt;
  final String updatedAt;
  final int organisationId;
  final String? prenom;
  final String telephone;
  final String? adresse;
  final int typeUserId;
  final String profilePhotoUrl;
  String? token; // Ajout du token

  User({
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
    required this.typeUserId,
    required this.profilePhotoUrl,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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
      profilePhotoUrl: json['profile_photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'two_factor_confirmed_at': twoFactorConfirmedAt,
      'current_team_id': currentTeamId,
      'profile_photo_path': profilePhotoPath,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'organisation_id': organisationId,
      'prenom': prenom,
      'telephone': telephone,
      'adresse': adresse,
      'type_user_id': typeUserId,
      'profile_photo_url': profilePhotoUrl,
      'token': token,
    };
  }
}