import 'dart:convert';
import 'package:equatable/equatable.dart';

// ── CardFromApi ──
class CardFromApi extends Equatable {
  final String type; // "principal", "physical", "virtual"
  final String cardId;
  final String last4;
  final String label;
  final String display;

  const CardFromApi({
    required this.type,
    required this.cardId,
    required this.last4,
    required this.label,
    required this.display,
  });

  factory CardFromApi.fromMap(Map<String, dynamic> map) {
    return CardFromApi(
      type: map['type']?.toString() ?? '',
      cardId: map['card_id']?.toString() ?? '',
      last4: map['last4']?.toString() ?? '****',
      label: map['label']?.toString() ?? '',
      display: map['display']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'card_id': cardId,
        'last4': last4,
        'label': label,
        'display': display,
      };

  @override
  List<Object?> get props => [type, cardId, last4, label, display];
}

// ── TypeUserModel ──
class TypeUserModel extends Equatable {
  final int id;
  final String designation;
  final String description;
  final int userId;
  final String startDate;
  final String endDate;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  const TypeUserModel({
    required this.id,
    required this.designation,
    required this.description,
    required this.userId,
    required this.startDate,
    required this.endDate,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TypeUserModel.fromMap(Map<String, dynamic> map) {
    return TypeUserModel(
      id: map['id'] ?? 0,
      designation: map['designation'] ?? '',
      description: map['description'] ?? '',
      userId: map['user_id'] ?? 0,
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      deletedAt: map['deleted_at'],
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'designation': designation,
      'description': description,
      'user_id': userId,
      'startDate': startDate,
      'endDate': endDate,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        designation,
        description,
        userId,
        startDate,
        endDate,
        deletedAt,
        createdAt,
        updatedAt,
      ];
}

// ── UserModel ──
class UserModel extends Equatable {
  final int? id;
  final String name;
  final String email;
  final String token;
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
  final String? oldId;
  final String profilePhotoUrl;
  final String? avatar;
  final bool? isOnline;
  final String? lastSeen;
  final bool? codeTemporaire;
  final int? abonnementActuelId;
  final TypeUserModel? typeUser;

  // NOUVEAU
  final String walletBalance;
  final List<CardFromApi> cards;

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    this.token = '',
    this.emailVerifiedAt,
    this.twoFactorConfirmedAt,
    this.currentTeamId,
    this.profilePhotoPath,
    required this.createdAt,
    required this.updatedAt,
    this.organisationId = 0,
    this.prenom,
    required this.telephone,
    this.adresse,
    this.typeUserId = 0,
    this.oldId,
    required this.profilePhotoUrl,
    this.avatar,
    this.isOnline,
    this.lastSeen,
    this.codeTemporaire,
    this.abonnementActuelId,
    this.typeUser,
    this.walletBalance = '0',
    this.cards = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Gère les deux formats : réponse directe ou imbriquée dans "user"
    final data = map.containsKey('user') && map['user'] is Map<String, dynamic>
        ? map['user'] as Map<String, dynamic>
        : map;

    // Parser les cartes
    List<CardFromApi> cardsList = [];
    if (data['cards'] != null && data['cards'] is List) {
      cardsList = (data['cards'] as List)
    .whereType<Map<String, dynamic>>()
    .where((c) => c['type'] != 'principal') // ✅ filtre ici
    .map((c) => CardFromApi.fromMap(c))
    .toList();
    }

    // type_user peut être une String ("Client") ou un Map (ancien format)
    TypeUserModel? typeUserParsed;
    if (data['type_user'] != null &&
        data['type_user'] is Map<String, dynamic>) {
      typeUserParsed =
          TypeUserModel.fromMap(data['type_user'] as Map<String, dynamic>);
    }

    return UserModel(
      id: data['id'] != null ? int.tryParse(data['id'].toString()) : null,
      name: data['name']?.toString() ?? 'Utilisateur',
      email: data['emails']?.toString() ?? '',
      prenom: data['prenom']?.toString(),
      token: data['token']?.toString() ?? '',
      emailVerifiedAt: data['email_verified_at']?.toString(),
      twoFactorConfirmedAt: data['two_factor_confirmed_at']?.toString(),
      currentTeamId: data['current_team_id'] != null
          ? int.tryParse(data['current_team_id'].toString())
          : null,
      profilePhotoPath: data['profile_photo_path']?.toString(),
      createdAt: data['created_at']?.toString() ?? '',
      updatedAt: data['updated_at']?.toString() ?? '',
      organisationId: data['organisation_id'] != null
          ? int.tryParse(data['organisation_id'].toString()) ?? 0
          : 0,
      telephone: data['telephone']?.toString() ?? '',
      adresse: data['adresse']?.toString(),
      typeUserId: data['type_user_id'] != null
          ? int.tryParse(data['type_user_id'].toString()) ?? 0
          : 0,
      oldId: data['old_id']?.toString(),
      abonnementActuelId: data['abonnement_actuel_id'] != null
          ? int.tryParse(data['abonnement_actuel_id'].toString())
          : null,
      profilePhotoUrl: data['profile_photo_url']?.toString() ?? '',
      avatar:
          data['avatar']?.toString() ?? data['profile_picture']?.toString(),
      isOnline: data['is_online'] is bool
          ? data['is_online']
          : data['is_online']?.toString().toLowerCase() == 'true',
      lastSeen: data['last_seen']?.toString(),
      codeTemporaire: data['code_temporaire'] is bool
          ? data['code_temporaire']
          : data['code_temporaire']?.toString().toLowerCase() == 'true',
      typeUser: typeUserParsed,
      walletBalance: data['wallet_balance']?.toString() ?? '0',
      cards: cardsList,
    );
  }

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'prenom': prenom,
      'token': token,
      'email_verified_at': emailVerifiedAt,
      'two_factor_confirmed_at': twoFactorConfirmedAt,
      'current_team_id': currentTeamId,
      'profile_photo_path': profilePhotoPath,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'organisation_id': organisationId,
      'telephone': telephone,
      'adresse': adresse,
      'type_user_id': typeUserId,
      'old_id': oldId,
      'abonnement_actuel_id': abonnementActuelId,
      'profile_photo_url': profilePhotoUrl,
      'avatar': avatar,
      'is_online': isOnline,
      'last_seen': lastSeen,
      'code_temporaire': codeTemporaire,
      'type_user': typeUser?.toMap(),
      'wallet_balance': walletBalance,
      'cards': cards.map((c) => c.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());

  // Helpers pratiques
  String get fullName => '${name} ${prenom ?? ''}'.trim();

  CardFromApi? get physicalCard =>
      cards.where((c) => c.type == 'physical').isNotEmpty
          ? cards.firstWhere((c) => c.type == 'physical')
          : null;

  CardFromApi? get virtualCard =>
      cards.where((c) => c.type == 'virtual').isNotEmpty
          ? cards.firstWhere((c) => c.type == 'virtual')
          : null;

  CardFromApi? get principalCard =>
      cards.where((c) => c.type == 'principal').isNotEmpty
          ? cards.firstWhere((c) => c.type == 'principal')
          : null;

  bool get hasPhysicalCard => physicalCard != null;
  bool get hasVirtualCard => virtualCard != null;
  bool get hasPrincipalCard => principalCard != null;
  bool get hasAnyCard => cards.isNotEmpty;

  double get walletBalanceDouble =>
      double.tryParse(walletBalance) ?? 0.0;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        token,
        emailVerifiedAt,
        twoFactorConfirmedAt,
        currentTeamId,
        profilePhotoPath,
        createdAt,
        updatedAt,
        organisationId,
        prenom,
        telephone,
        adresse,
        typeUserId,
        oldId,
        abonnementActuelId,
        profilePhotoUrl,
        avatar,
        isOnline,
        lastSeen,
        codeTemporaire,
        typeUser,
        walletBalance,
        cards,
      ];

  @override
  bool get stringify => true;
}