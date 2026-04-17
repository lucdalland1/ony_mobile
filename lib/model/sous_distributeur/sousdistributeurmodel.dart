class HierarchyModel {
  final bool success;
  final Data? data;
  final Statistiques? statistiques;
  final InformationsJour? informationsJour;
  final String? message;

  HierarchyModel({
    required this.success,
    this.data,
    this.statistiques,
    this.informationsJour,
    this.message,
  });

  factory HierarchyModel.fromJson(Map<String, dynamic> json) {
    return HierarchyModel(
      success: json['success'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      statistiques: json['statistiques'] != null
          ? Statistiques.fromJson(json['statistiques'])
          : null,
      informationsJour: json['informations_jour'] != null
          ? InformationsJour.fromJson(json['informations_jour'])
          : null,
      message: json['message'],
    );
  }
}

class Data {
  final Pays? pays;
  final List<Ville>? villes;

  Data({this.pays, this.villes});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      pays: json['pays'] != null ? Pays.fromJson(json['pays']) : null,
      villes: json['villes'] != null
          ? List<Ville>.from(json['villes'].map((x) => Ville.fromJson(x)))
          : null,
    );
  }
}

class Pays {
  final int? id;
  final String? designation;
  final String? code;
  final String? indicatif;

  Pays({this.id, this.designation, this.code, this.indicatif});

  factory Pays.fromJson(Map<String, dynamic> json) {
    return Pays(
      id: json['id'],
      designation: json['designation'],
      code: json['code'],
      indicatif: json['indicatif'],
    );
  }
}

class Ville {
  final int? id;
  final String? designation;
  final int? nombreSousDistrib;
  final List<District>? districts;

  Ville({this.id, this.designation, this.nombreSousDistrib, this.districts});

  factory Ville.fromJson(Map<String, dynamic> json) {
    return Ville(
      id: json['id'],
      designation: json['designation'],
      nombreSousDistrib: json['nombre_sous_distributeurs'],
      districts: json['districts'] != null
          ? List<District>.from(
              json['districts'].map((x) => District.fromJson(x)))
          : null,
    );
  }
}

class District {
  final int? id;
  final String? designation;
  final int? nombreSousDistrib;
  final List<Quartier>? quartiers;

  District({this.id, this.designation, this.nombreSousDistrib, this.quartiers});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      designation: json['designation'],
      nombreSousDistrib: json['nombre_sous_distributeurs'],
      quartiers: json['quartiers'] != null
          ? List<Quartier>.from(
              json['quartiers'].map((x) => Quartier.fromJson(x)))
          : null,
    );
  }
}

class Quartier {
  final int? id;
  final String? designation;
  final int? nombreSousDistrib;
  final List<SousDistributeur>? sousDistr;

  Quartier({this.id, this.designation, this.nombreSousDistrib, this.sousDistr});

  factory Quartier.fromJson(Map<String, dynamic> json) {
    return Quartier(
      id: json['id'],
      designation: json['designation'],
      nombreSousDistrib: json['nombre_sous_distributeurs'],
      sousDistr: json['sous_distributeurs'] != null
          ? List<SousDistributeur>.from(json['sous_distributeurs']
              .map((x) => SousDistributeur.fromJson(x)))
          : null,
    );
  }
}

class SousDistributeur {
  final int? id;
  final String? nomComplet;
  final String? nom;
  final String? prenom;
  final String? email;
  final String? telephone;
  final String? adresse;
  final Entreprise? entreprise;
  final LocalisationGPS? localisationGps;
  final HorairesOuverture? horairesOuverture;
  final String? dateInscription;

  SousDistributeur({
    this.id,
    this.nomComplet,
    this.nom,
    this.prenom,
    this.email,
    this.telephone,
    this.adresse,
    this.entreprise,
    this.localisationGps,
    this.horairesOuverture,
    this.dateInscription,
  });

  factory SousDistributeur.fromJson(Map<String, dynamic> json) {
    return SousDistributeur(
      id: json['id'],
      nomComplet: json['nom_complet'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'],
      adresse: json['adresse'],
      entreprise:
          json['entreprise'] != null ? Entreprise.fromJson(json['entreprise']) : null,
      localisationGps: json['localisation_gps'] != null
          ? LocalisationGPS.fromJson(json['localisation_gps'])
          : null,
      horairesOuverture: json['horaires_ouverture'] != null
          ? HorairesOuverture.fromJson(json['horaires_ouverture'])
          : null,
      dateInscription: json['date_inscription'],
    );
  }
}

class Entreprise {
  final String? nom;
  final String? email;
  final String? telephone;
  final String? localisation;
  final String? activite;

  Entreprise({this.nom, this.email, this.telephone, this.localisation, this.activite});

  factory Entreprise.fromJson(Map<String, dynamic> json) {
    return Entreprise(
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'],
      localisation: json['localisation'],
      activite: json['activite'],
    );
  }
}

class LocalisationGPS {
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? timezone;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final String? source;
  final bool? isCurrent;
  final String? lastUpdated;

  LocalisationGPS({
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.timezone,
    this.accuracy,
    this.altitude,
    this.speed,
    this.source,
    this.isCurrent,
    this.lastUpdated,
  });

  factory LocalisationGPS.fromJson(Map<String, dynamic> json) {
    return LocalisationGPS(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'],
      city: json['city'],
      country: json['country'],
      postalCode: json['postal_code'],
      timezone: json['timezone'],
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      source: json['source'],
      isCurrent: json['is_current'],
      lastUpdated: json['last_updated'],
    );
  }
}

class HorairesOuverture {
  final String? jourActuel;
  final Aujourdhui? aujourdhui;
  final List<Semaine>? semaine;

  HorairesOuverture({this.jourActuel, this.aujourdhui, this.semaine});

  factory HorairesOuverture.fromJson(Map<String, dynamic> json) {
    return HorairesOuverture(
      jourActuel: json['jour_actuel'],
      aujourdhui: json['aujourdhui'] != null
          ? Aujourdhui.fromJson(json['aujourdhui'])
          : null,
      semaine: json['semaine'] != null
          ? List<Semaine>.from(json['semaine'].map((x) => Semaine.fromJson(x)))
          : null,
    );
  }
}

class Aujourdhui {
  final bool? estOuvert;
  final String? heureOuverture;
  final String? heureFermeture;

  Aujourdhui({this.estOuvert, this.heureOuverture, this.heureFermeture});

  factory Aujourdhui.fromJson(Map<String, dynamic> json) {
    return Aujourdhui(
      estOuvert: json['est_ouvert'],
      heureOuverture: json['heure_ouverture'],
      heureFermeture: json['heure_fermeture'],
    );
  }
}

class Semaine {
  final String? jour;
  final bool? estOuvert;
  final String? heureOuverture;
  final String? heureFermeture;

  Semaine({this.jour, this.estOuvert, this.heureOuverture, this.heureFermeture});

  factory Semaine.fromJson(Map<String, dynamic> json) {
    return Semaine(
      jour: json['jour'],
      estOuvert: json['est_ouvert'],
      heureOuverture: json['heure_ouverture'],
      heureFermeture: json['heure_fermeture'],
    );
  }
}

class Statistiques {
  final int? totalVilles;
  final int? totalDistricts;
  final int? totalQuartiers;
  final int? totalSousDistributeurs;

  Statistiques({
    this.totalVilles,
    this.totalDistricts,
    this.totalQuartiers,
    this.totalSousDistributeurs,
  });

  factory Statistiques.fromJson(Map<String, dynamic> json) {
    return Statistiques(
      totalVilles: json['total_villes'],
      totalDistricts: json['total_districts'],
      totalQuartiers: json['total_quartiers'],
      totalSousDistributeurs: json['total_sous_distributeurs'],
    );
  }
}

class InformationsJour {
  final String? jourActuel;
  final String? dateRequete;

  InformationsJour({this.jourActuel, this.dateRequete});

  factory InformationsJour.fromJson(Map<String, dynamic> json) {
    return InformationsJour(
      jourActuel: json['jour_actuel'],
      dateRequete: json['date_requete'],
    );
  }
}
