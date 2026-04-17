import 'package:flutter/material.dart';
import 'package:onyfast/Color/app_color_model.dart';

enum MerchantType {
  store,
  pastry,
  hotel,
  bar,
}

enum StoreSubType {
  grocery,
  clothing,
  electronics,
  convenience,
}

extension MerchantTypeExtension on MerchantType {
  String get displayName {
    switch (this) {
      case MerchantType.store: return 'Magasin';
      case MerchantType.pastry: return 'Pâtisserie';
      case MerchantType.hotel: return 'Hôtel';
      case MerchantType.bar: return 'Bar';
    }
  }

  Color get color {
    switch (this) {
      case MerchantType.store: return AppColorModel.BlueColor;
      case MerchantType.pastry: return AppColorModel.BlueColor;
      case MerchantType.hotel: return AppColorModel.BlueColor;
      case MerchantType.bar: return AppColorModel.BlueColor;
    }
  }

  IconData get icon {
    switch (this) {
      case MerchantType.store: return Icons.store;
      case MerchantType.pastry: return Icons.cake;
      case MerchantType.hotel: return Icons.hotel;
      case MerchantType.bar: return Icons.local_bar;
    }
  }

  List<String>? get subTypes {
    switch (this) {
      case MerchantType.store:
        return StoreSubType.values.map((e) => e.displayName).toList();
      case MerchantType.pastry:
        return ['Pâtisserie Josephine', ' Pâtisserie de la Paix',"La Mandarine"," La Citronnelle", 'Pâtisserie VALDAISE '];
      case MerchantType.hotel:
        return ["Pefaco Hotel Maya Maya","Radisson Blu M'Bamou Palace Hotel","Résidence Elys", "class hotel","Mikhael's Hotel","RESIDENCE HOTEL Moungali","Résidence l'amitié","Hilton Brazzaville Les Tours Jumelles Hotel"];
      case MerchantType.bar:
        return ['LA CAVE DE KAB '," MAKUSA ","SOUS LE PALMIER","LE RENOUVEAU"," LE LAMPADAIRE ","LA CAVE DE KAB ","LE COMPTOIR ", "LE FAIGNOND ","Mavula Hôtel",'LA SANZA ', 'Cocktail'];
      default:
        return null;
    }
  }
}

extension StoreSubTypeExtension on StoreSubType {
  String get displayName {
    switch (this) {
      case StoreSubType.grocery: return 'Épicerie';
      case StoreSubType.clothing: return 'Vêtements';
      case StoreSubType.electronics: return 'Électronique';
      case StoreSubType.convenience: return 'Supérette';
    }
  }
}

class Merchant {
  final String id;
  final String name;
  final MerchantType type;

  Merchant({
    required this.id,
    required this.name,
    required this.type,
  });
}

class Transaction {
  final String id;
  final MerchantType merchantType;
  final String subType;
  final double amount;
  final DateTime date;

  Transaction({
    required this.id,
    required this.merchantType,
    required this.subType,
    required this.amount,
    required this.date,
  });
}