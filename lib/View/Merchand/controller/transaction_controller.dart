import 'package:get/get.dart';

import '../model/merchand.dart';

class TransactionController extends GetxController {
  final transactions = <Transaction>[].obs;

  void addTransaction(MerchantType type, String subType, double amount) {
    transactions.add(Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchantType: type,
      subType: subType,
      amount: amount,
      date: DateTime.now(),
    ));
  }
}