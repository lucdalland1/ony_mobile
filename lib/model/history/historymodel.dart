class TransactionResponse {
  final bool success;
  final List<TransactionData> data;
  final int count;
  final int limit;
  final String? soldeActuel;

  TransactionResponse({
    required this.success,
    required this.data,
    required this.count,
    required this.limit,
    this.soldeActuel,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      success: json['success'],
      data: (json['data'] as List)
          .map((item) => TransactionData.fromJson(item))
          .toList(),
      count: json['count'],
      limit: json['limit'],
      soldeActuel: json['solde_actuel']?.toString(),
    );
  }
}

class TransactionData {
  final int id;
  final String reference;
  final String date;
  final String montant;
  final String montantNumerique;
  final String frais;
  final String? signe;
  final Destinataire destinataire;
  final Emetteur emetteur;
  final String? operateur;
  final String? pays;
  final String statut;
  final int typeTransaction;
  final Soldes soldes;
  final List<Operation> operations;
  final String? avatar;

  TransactionData({
    required this.id,
    required this.reference,
    required this.date,
    required this.montant,
    required this.montantNumerique,
    required this.frais,
    this.signe,
    required this.destinataire,
    required this.emetteur,
    this.operateur,
    this.pays,
    required this.statut,
    required this.typeTransaction,
    required this.soldes,
    required this.operations,
    this.avatar,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      id: json['id'],
      reference: json['reference']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      montant: json['montant']?.toString() ?? '0',
      montantNumerique: json['montant_numerique']?.toString() ?? '0',
      frais: json['frais']?.toString() ?? '0.00',
      signe: json['sens_utilisateur']?.toString(),
      destinataire: json['destinataire'] != null
          ? Destinataire.fromJson(json['destinataire'])
          : Destinataire.empty(),
      emetteur: json['emetteur'] != null
          ? Emetteur.fromJson(json['emetteur'])
          : Emetteur.empty(),
      operateur: json['operateur']?.toString(),
      pays: json['pays']?.toString(),
      statut: json['statut']?.toString() ?? '',
      typeTransaction: json['type_transaction'] is int
          ? json['type_transaction']
          : int.tryParse(json['type_transaction'].toString()) ?? 0,
      soldes: json['soldes'] != null
          ? Soldes.fromJson(json['soldes'])
          : Soldes.empty(),
      operations: json['operations'] != null
          ? (json['operations'] as List)
              .map((item) => Operation.fromJson(item))
              .toList()
          : [],
      avatar: json['avatar']?.toString(),
    );
  }
}

class Destinataire {
  final String? nomComplet;
  final String? to;
  final dynamic compte;
  final dynamic wallet;

  Destinataire({
    this.nomComplet,
    this.to,
    this.compte,
    this.wallet,
  });

  factory Destinataire.fromJson(Map<String, dynamic> json) {
    return Destinataire(
      nomComplet: json['nom_complet']?.toString(),
      to: json['to']?.toString(),
      compte: json['compte'],
      wallet: json['wallet'],
    );
  }

  factory Destinataire.empty() => Destinataire();
}

class Emetteur {
  final int userId;
  final dynamic compte;
  final dynamic wallet;
  final String? from;

  Emetteur({
    required this.userId,
    this.compte,
    this.wallet,
    this.from,
  });

  factory Emetteur.fromJson(Map<String, dynamic> json) {
    return Emetteur(
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      compte: json['compte'],
      wallet: json['wallet'],
      from: json['from']?.toString(),
    );
  }

  factory Emetteur.empty() => Emetteur(userId: 0);
}

class Soldes {
  final String avant;
  final String apres;

  Soldes({
    required this.avant,
    required this.apres,
  });

  factory Soldes.fromJson(Map<String, dynamic> json) {
    return Soldes(
      avant: json['avant']?.toString() ?? '0.00',
      apres: json['apres']?.toString() ?? '0.00',
    );
  }

  factory Soldes.empty() => Soldes(avant: "0.00", apres: "0.00");
}

class Operation {
  final int id;
  final String montant;
  final double montantNumerique;
  final String sensOperation;
  final String signe;
  final String precision;
  final OperationDates dates;

  Operation({
    required this.id,
    required this.montant,
    required this.montantNumerique,
    required this.sensOperation,
    required this.signe,
    required this.precision,
    required this.dates,
  });

  factory Operation.fromJson(Map<String, dynamic> json) {
    return Operation(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      montant: json['montant']?.toString() ?? '0',
      montantNumerique:
          double.tryParse(json['montant_numerique'].toString()) ?? 0.0,
      sensOperation: json['sens_operation']?.toString() ?? '',
      signe: json['signe']?.toString() ?? '',
      precision: json['precision']?.toString() ?? '',
      dates: OperationDates.fromJson(json['dates']),
    );
  }
}

class OperationDates {
  final String debut;
  final String? fin;

  OperationDates({
    required this.debut,
    this.fin,
  });

  factory OperationDates.fromJson(Map<String, dynamic> json) {
    return OperationDates(
      debut: json['debut']?.toString() ?? '',
      fin: json['fin']?.toString(),
    );
  }
}