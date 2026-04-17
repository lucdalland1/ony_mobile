import 'dart:convert';
import 'package:equatable/equatable.dart';

class TransactionTypeModel extends Equatable {
  final int id;
  final String designation;
  final String? description;
  final String? codeExterne;
  final int userId;
  final String startDate;
  final String? endDate;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

const  TransactionTypeModel({
    required this.id,
    required this.designation,
    this.description,
    this.codeExterne,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionTypeModel.fromJson(Map<String, dynamic> json) {
    return TransactionTypeModel(
      id: json['id'] ?? 0,
      designation: json['designation'] ?? '',
      description: json['description'],
      codeExterne: json['codeExterne'],
      userId: json['user_id'] ?? 0,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'designation': designation,
      'description': description,
      'codeExterne': codeExterne,
      'user_id': userId,
      'startDate': startDate,
      'endDate': endDate,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  List<Object?> get props => [
        id,
        designation,
        description,
        codeExterne,
        userId,
        startDate,
        endDate,
        deletedAt,
        createdAt,
        updatedAt,
      ];

  @override
  bool get stringify => true;
}
