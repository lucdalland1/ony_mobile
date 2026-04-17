import 'dart:convert';
import 'package:equatable/equatable.dart';

class WalletModel extends Equatable {
  final int? id;
  final double solde;
  final int? assignedUserId;
  final int? userId;
  final String startDate;
  final String? endDate;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

 const WalletModel({
    this.id,
    required this.solde,
    this.assignedUserId,
    this.userId,
    required this.startDate,
    this.endDate,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: _parseInt(json['id']),
      solde: _parseDouble(json['solde']),
      assignedUserId: _parseInt(json['assigned_user_id']),
      userId: _parseInt(json['user_id']),
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
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

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}