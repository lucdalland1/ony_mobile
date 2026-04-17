class Abonnement {
  final int id;
  final String identifiant;
  final String nom;
  final Prix prix;
  final String description;
  final Caracteristiques? caracteristiques;
  final Avantages? avantages;
  final String? bestFor;
  final Popularite? popularite;
  final Cta? cta;

  Abonnement({
    required this.id,
    required this.identifiant,
    required this.nom,
    required this.prix,
    required this.description,
    this.caracteristiques,
    this.avantages,
    this.bestFor,
    this.popularite,
    this.cta,
  });

  factory Abonnement.fromJson(Map<String, dynamic> json) {
    return Abonnement(
      id: json['id'] ?? 0,
      identifiant: json['identifiant'] ?? '',
      nom: json['nom'] ?? '',
      prix: Prix.fromJson(json['prix'] ?? {}),
      description: json['description'] ?? '',
      caracteristiques: json['caracteristiques'] != null 
          ? Caracteristiques.fromJson(json['caracteristiques']) 
          : null,
      avantages: json['avantages'] != null 
          ? Avantages.fromJson(json['avantages']) 
          : null,
      bestFor: json['best_for'],
      popularite: json['popularite'] != null 
          ? Popularite.fromJson(json['popularite']) 
          : null,
      cta: json['cta'] != null 
          ? Cta.fromJson(json['cta']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'identifiant': identifiant,
      'nom': nom,
      'prix': prix.toJson(),
      'description': description,
      'caracteristiques': caracteristiques?.toJson(),
      'avantages': avantages?.toJson(),
      'best_for': bestFor,
      'popularite': popularite?.toJson(),
      'cta': cta?.toJson(),
    };
  }
}

class Prix {
  final String mensuel;
  final String annuel;
  final String economieAnnuelle;

  Prix({
    required this.mensuel,
    required this.annuel,
    required this.economieAnnuelle,
  });

  factory Prix.fromJson(Map<String, dynamic> json) {
    return Prix(
      mensuel: json['mensuel'] ?? '0 FCFA',
      annuel: json['annuel'] ?? '0 FCFA',
      economieAnnuelle: json['economie_annuelle'] ?? '0 FCFA',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mensuel': mensuel,
      'annuel': annuel,
      'economie_annuelle': economieAnnuelle,
    };
  }
}

class Caracteristiques {
  final Plafonds? plafonds;
  final dynamic objectifs; // peut être int ou String

  Caracteristiques({
    this.plafonds,
    this.objectifs,
  });

  factory Caracteristiques.fromJson(Map<String, dynamic> json) {
    return Caracteristiques(
      plafonds: json['plafonds'] != null 
          ? Plafonds.fromJson(json['plafonds']) 
          : null,
      objectifs: json['objectifs'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plafonds': plafonds?.toJson(),
      'objectifs': objectifs,
    };
  }
}

class Plafonds {
  final String mensuel;
  final String? prets; // peut être null

  Plafonds({
    required this.mensuel,
    this.prets,
  });

  factory Plafonds.fromJson(Map<String, dynamic> json) {
    return Plafonds(
      mensuel: json['mensuel'] ?? '0 FCFA',
      prets: json['prets'] ?? json['0'], // gérer la clé "0" du JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mensuel': mensuel,
      'prets': prets,
    };
  }
}

class Avantages {
  final Services? services;
  final Map<String, dynamic>? autres; // pour stocker d'autres avantages dynamiquement

  Avantages({
    this.services,
    this.autres,
  });

  factory Avantages.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? autres;
    if (json.isNotEmpty) {
      autres = Map<String, dynamic>.from(json);
      autres.remove('services'); // enlever services des autres
    }

    return Avantages(
      services: json['services'] != null 
          ? Services.fromJson(json['services']) 
          : null,
      autres: autres,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    if (services != null) {
      result['services'] = services!.toJson();
    }
    if (autres != null) {
      result.addAll(autres!);
    }
    return result;
  }
}

class Services {
  final String? support;
  final dynamic conseillerDedie; // peut être 0, 1 ou bool

  Services({
    this.support,
    this.conseillerDedie,
  });

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      support: json['support'],
      conseillerDedie: json['conseiller_dedie'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'support': support,
      'conseiller_dedie': conseillerDedie,
    };
  }
}

class Popularite {
  final double etoiles;
  final String clients;

  Popularite({
    required this.etoiles,
    required this.clients,
  });

  factory Popularite.fromJson(Map<String, dynamic> json) {
    return Popularite(
      etoiles: (json['etoiles'] ?? 0).toDouble(),
      clients: json['clients'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'etoiles': etoiles,
      'clients': clients,
    };
  }
}

class Cta {
  final String souscrire;
  final String details;

  Cta({
    required this.souscrire,
    required this.details,
  });

  factory Cta.fromJson(Map<String, dynamic> json) {
    return Cta(
      souscrire: json['souscrire'] ?? '',
      details: json['details'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'souscrire': souscrire,
      'details': details,
    };
  }
}