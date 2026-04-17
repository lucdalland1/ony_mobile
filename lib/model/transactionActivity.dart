class TransactionActivity {
  final int transactionId;
  final String transactionDate;
  final String transactionTime;
  final String transactionTimeHH24;
  final double baseAmount;
  final double fee;
  final double totalAmount;
  final double runningBalance;
  final String transactionDesc;
  final String? referenceInformation;
  final String? merchantCountry;
  final String? extendedInformation;

  TransactionActivity({
    required this.transactionId,
    required this.transactionDate,
    required this.transactionTime,
    required this.transactionTimeHH24,
    required this.baseAmount,
    required this.fee,
    required this.totalAmount,
    required this.runningBalance,
    required this.transactionDesc,
    this.referenceInformation,
    this.merchantCountry,
    this.extendedInformation,
  });

  factory TransactionActivity.fromJson(Map<String, dynamic> json) {
    return TransactionActivity(
      transactionId: json['transactionId'],
      transactionDate: json['transactionDate'],
      transactionTime: json['transactionTime'],
      transactionTimeHH24: json['transactionTimeHH24'],
      baseAmount: (json['baseAmount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      runningBalance: (json['runningBalance'] as num).toDouble(),
      transactionDesc: json['transactionDesc'],
      referenceInformation: json['referenceInformation'],
      merchantCountry: json['merchantCountry'],
      extendedInformation: json['extendedInformation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'transactionDate': transactionDate,
      'transactionTime': transactionTime,
      'transactionTimeHH24': transactionTimeHH24,
      'baseAmount': baseAmount,
      'fee': fee,
      'totalAmount': totalAmount,
      'runningBalance': runningBalance,
      'transactionDesc': transactionDesc,
      'referenceInformation': referenceInformation,
      'merchantCountry': merchantCountry,
      'extendedInformation': extendedInformation,
    };
  }
}
