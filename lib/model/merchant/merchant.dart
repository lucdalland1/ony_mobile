// models/merchant_model.dart
class Merchant {
  final int id;
  final String nom;
  final String telephone;
  final String categorie;
  final String lettre;

  Merchant({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.categorie,
    required this.lettre,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      telephone: json['telephone'] ?? '',
      categorie: json['categorie'] ?? 'Non défini',
      lettre: json['lettre'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'telephone': telephone,
      'categorie': categorie,
      'lettre': lettre,
    };
  }
}

class MerchantResponse {
  final bool success;
  final Map<String, List<Merchant>> data;

  MerchantResponse({
    required this.success,
    required this.data,
  });

  factory MerchantResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, List<Merchant>> merchantData = {};
    
    if (json['data'] != null) {
      json['data'].forEach((letter, merchantList) {
        merchantData[letter] = List<Merchant>.from(
          merchantList.map((merchant) => Merchant.fromJson(merchant)),
        );
      });
    }

    return MerchantResponse(
      success: json['success'] ?? false,
      data: merchantData,
    );
  }
}