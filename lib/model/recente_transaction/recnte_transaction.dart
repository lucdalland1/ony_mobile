class TransactionResponse {
  final bool success;
  final int count;
  final int limit;
  final String? soldeActuel;
  final List<Transaction> data;

  TransactionResponse(
      {
      required this.success,
      required this.count,
      required this.limit,
      required this.soldeActuel,
      required this.data,
    }
  );

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      success: json['success'],
      count: json['count'],
      limit: json['limit'],
      soldeActuel: json['solde_actuel'],
      data: List<Transaction>.from(json['data'].map((e) => Transaction.fromJson(e))),
    );
  }
}

class Transaction {
  final int id;
  final String reference;
  final String date;
  final String montant;
  final String montantNumerique;
  final String frais;
  final String signe;
  final Destinataire destinataire;
  final Emetteur emetteur;
  final String? operateur;
  final dynamic pays;
  final String statut;
  final int typeTransaction;
  final Soldes soldes;
  final List<Operation> operations;

  Transaction({
    required this.id,
    required this.reference,
    required this.date,
    required this.montant,
    required this.montantNumerique,
    required this.frais,
    required this.signe,
    required this.destinataire,
    required this.emetteur,
    this.operateur,
    this.pays,
    required this.statut,
    required this.typeTransaction,
    required this.soldes,
    required this.operations,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      reference: json['reference'],
      date: json['date'],
      montant: json['montant'],
      montantNumerique: json['montant_numerique'],
      frais: json['frais'],
      signe: json['signe'],
      destinataire: Destinataire.fromJson(json['destinataire']),
      emetteur: Emetteur.fromJson(json['emetteur']),
      operateur: json['operateur'],
      pays: json['pays'],
      statut: json['statut'],
      typeTransaction: json['type_transaction'],
      soldes: Soldes.fromJson(json['soldes']),
      operations: List<Operation>.from(json['operations'].map((e) => Operation.fromJson(e))),
    );
  }
}

class Destinataire {
  final String nomComplet;
  final String telephone;

  Destinataire({
    required this.nomComplet,
    required this.telephone,
  });

  factory Destinataire.fromJson(Map<String, dynamic> json) {
    return Destinataire(
      nomComplet: json['nom_complet'],
      telephone: json['telephone'],
    );
  }
}

class Emetteur {
  final int userId;
  final int? wallet;
  final String telephone;

  Emetteur({
    required this.userId,
    this.wallet,
    required this.telephone,
  });

  factory Emetteur.fromJson(Map<String, dynamic> json) {
    return Emetteur(
      userId: json['user_id'],
      wallet: json['wallet'],
      telephone: json['telephone'],
    );
  }
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
      avant: json['avant'],
      apres: json['apres'],
    );
  }
}

class Operation {
  final int id;
  final String montant;
  final int montantNumerique;
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
      id: json['id'],
      montant: json['montant'],
      montantNumerique: json['montant_numerique'],
      sensOperation: json['sens_operation'],
      signe: json['signe'],
      precision: json['precision'],
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
      debut: json['debut'],
      fin: json['fin'],
    );
  }
}
