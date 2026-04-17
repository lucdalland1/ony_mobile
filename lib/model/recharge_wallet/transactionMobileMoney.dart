class TransactionMobileMoney {
  final String message;
  final Transaction transaction;

  TransactionMobileMoney({required this.message, required this.transaction});

  factory TransactionMobileMoney.fromJson(Map<String, dynamic> json) {
    return TransactionMobileMoney(
      message: json['message'],
      transaction: Transaction.fromJson(json['transaction']),
    );
  }
}

class Transaction {
  final int typeTransactionId;
  final int fromWallet;
  final String montant;
  final String from;
  final String to;
  final String codeInterne;
  final String status;
  final int userId;
  final int operatorId;
  final String startDate;
  final String idExterne;
  final String updatedAt;
  final String createdAt;
  final int id;

  Transaction({
    required this.typeTransactionId,
    required this.fromWallet,
    required this.montant,
    required this.from,
    required this.to,
    required this.codeInterne,
    required this.status,
    required this.userId,
    required this.operatorId,
    required this.startDate,
    required this.idExterne,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      typeTransactionId: json['type_transaction_id'],
      fromWallet: json['from_wallet'],
      montant: json['montant'],
      from: json['from'],
      to: json['to'],
      codeInterne: json['codeInterne'],
      status: json['status'],
      userId: json['user_id'],
      operatorId: json['operator_id'],
      startDate: json['startDate'],
      idExterne: json['idExterne'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      id: json['id'],
    );
  }
}
