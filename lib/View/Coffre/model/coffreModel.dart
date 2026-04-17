import 'package:intl/intl.dart';

class CoffreModel {
  final int userId;
  final int id;
  final String nom;
  final double totalAmount;
  final DateTime createdAt;
  final List<ObjectifModel> objectifs;
  final Totals totals;

  CoffreModel({
    required this.userId,
    required this.id,
    required this.nom,
    required this.totalAmount,
    required this.createdAt,
    required this.objectifs,
    required this.totals,
  });

  factory CoffreModel.fromJson(Map<String, dynamic> json) {
    var objectifsJson = json['objectifs'] as List<dynamic>? ?? [];

    return CoffreModel(
      userId: json['user_id'] ?? 0,
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      objectifs: objectifsJson.map((e) => ObjectifModel.fromJson(e)).toList(),
      totals: json['totals'] != null
          ? Totals.fromJson(json['totals'])
          : Totals(totalDisponible: 0, totalIndisponible: 0, totalGeneral: 0),
    );
  }

  String get totalAmountFormatted =>
      NumberFormat("#,##0.00", "fr_FR").format(totalAmount ??0.0);
}

class ObjectifModel {
  final int id;
  final int coffreId;
  final String nom;
  final double montantCible;
  final double montantActuel;
  final String? dateLimite;
  final String delai;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  ObjectifModel({
    required this.id,
    required this.coffreId,
    required this.nom,
    required this.montantCible,
    required this.montantActuel,
    this.dateLimite,
    required this.delai,
    this.startDate,
    this.endDate,
    required this.isActive,
  });

  factory ObjectifModel.fromJson(Map<String, dynamic> json) {
    return ObjectifModel(
      id: json['id'] ?? 0,
      coffreId: json['coffre_id'] ?? 0,
      nom: json['nom'] ?? '',
      montantCible: (json['montant_cible'] ?? 0).toDouble(),
      montantActuel: (json['montant_actuel'] ?? 0).toDouble(),
      dateLimite: json['date_limite']?.toString(),
      delai: (json['delai'] ??""),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      isActive: (json['is_active'] ?? false) == true || json['is_active'] == 1,
    );
  }

  String get montantCibleFormatted =>
      NumberFormat("#,##0.00", "fr_FR").format(montantCible??0.0);

  String get montantActuelFormatted =>
      NumberFormat("#,##0.00", "fr_FR").format(montantActuel??0.0);

  String get delaiFormatted => delai;

  String get dateLimiteFormatted =>
      dateLimite != null ? dateLimite.toString() : "Aucune date";
}

class Totals {
  final double totalDisponible;
  final double totalIndisponible;
  final double totalGeneral;

  Totals({
    required this.totalDisponible,
    required this.totalIndisponible,
    required this.totalGeneral,
  });

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
      totalDisponible: (json['totalDisponible'] ?? 0).toDouble(),
      totalIndisponible: (json['totalIndisponible'] ?? 0).toDouble(),
      totalGeneral: (json['totalGeneral'] ?? 0).toDouble(),
    );
  }

  String get totalDisponibleFormatted =>
      NumberFormat("#,##0.00", "fr_FR").format(totalDisponible??0.0);

  String get totalIndisponibleFormatted =>
      NumberFormat("#,##0.00", "fr_FR").format(totalIndisponible??0.0);

  String get totalGeneralFormatted =>
      NumberFormat("#,##0.00", "fr_FR").format(totalGeneral??0.0);
}
