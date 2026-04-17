class Pays {
  final String code;
  final String? nom;
  final String indicatif;
  final List<Aggregateur> aggregateurs;

  Pays({
    required this.code,
    this.nom,
    required this.indicatif,
    required this.aggregateurs,
  });

  factory Pays.fromJson(Map<String, dynamic> json) {
    return Pays(
      code: json['code']?.toString() ?? '',
      nom: json['name']?.toString(),
      indicatif: json['indicatif']?.toString() ?? '',
      aggregateurs: (json['aggregators'] as List<dynamic>? ?? [])
          .map((e) => Aggregateur.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': nom,
      'indicatif': indicatif,
      'aggregators': aggregateurs.map((e) => e.toJson()).toList(),
    };
  }
}

class Aggregateur {
  final int id;
  final String nom;
  final String code;
  final String? logo;
  final String? description;
  final int estActif;
  final DateTime creeLe;
  final DateTime modifieLe;
  final Pivot pivot;

  Aggregateur({
    required this.id,
    required this.nom,
    required this.code,
    this.logo,
    this.description,
    required this.estActif,
    required this.creeLe,
    required this.modifieLe,
    required this.pivot,
  });

  factory Aggregateur.fromJson(Map<String, dynamic> json) {
    return Aggregateur(
      id: json['id'] ?? 0,
      nom: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      logo: json['logo']?.toString(),
      description: json['description']?.toString(),
      estActif: json['is_active'] ?? 0,
      creeLe: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      modifieLe: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      pivot: Pivot.fromJson(json['pivot'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nom,
      'code': code,
      'logo': logo,
      'description': description,
      'is_active': estActif,
      'created_at': creeLe.toIso8601String(),
      'updated_at': modifieLe.toIso8601String(),
      'pivot': pivot.toJson(),
    };
  }
}

class Pivot {
  final int paysId;
  final int aggregateurId;
  final String fraisFixes;
  final String fraisPourcentage;
  final int estActif;
  final DateTime creeLe;
  final DateTime modifieLe;

  Pivot({
    required this.paysId,
    required this.aggregateurId,
    required this.fraisFixes,
    required this.fraisPourcentage,
    required this.estActif,
    required this.creeLe,
    required this.modifieLe,
  });

  factory Pivot.fromJson(Map<String, dynamic> json) {
    return Pivot(
      paysId: json['country_id'] ?? 0,
      aggregateurId: json['aggregateur_id'] ?? 0,
      fraisFixes: json['fees_fixed']?.toString() ?? '0',
      fraisPourcentage: json['fees_percentage']?.toString() ?? '0',
      estActif: json['is_active'] ?? 0,
      creeLe: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      modifieLe: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country_id': paysId,
      'aggregateur_id': aggregateurId,
      'fees_fixed': fraisFixes,
      'fees_percentage': fraisPourcentage,
      'is_active': estActif,
      'created_at': creeLe.toIso8601String(),
      'updated_at': modifieLe.toIso8601String(),
    };
  }
}
