import 'dart:convert';
import 'package:equatable/equatable.dart';

class SoldeWallet extends Equatable {
  final int id;
  final double solde;
  final int assignedUserId;
  final int userId;
  final String startDate;
  final String? endDate;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

 const SoldeWallet({
    required this.id,
    required this.solde,
    required this.assignedUserId,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SoldeWallet.fromJson(Map<String, dynamic> json) {
    return SoldeWallet(
      id: json['id'] ?? 0,
      solde: _parseDouble(json['solde']),
      assignedUserId: json['assigned_user_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'solde': solde,
      'assigned_user_id': assignedUserId,
      'user_id': userId,
      'start_date': startDate,
      'end_date': endDate,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  List<Object?> get props => [
        id,
        solde,
        assignedUserId,
        userId,
        startDate,
        endDate,
        deletedAt,
        createdAt,
        updatedAt,
      ];

  @override
  bool get stringify => true;

  // Méthode pour convertir une valeur en double de manière sécurisée
  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
