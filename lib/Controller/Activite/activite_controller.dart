import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

// Models
import 'package:flutter/cupertino.dart';

class Transaction {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final IconData icon;
  final Color color;

  Transaction({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.icon,
    required this.color,
  });
}


class ActivityController extends GetxController {
  RxList<Transaction> todayTransactions = <Transaction>[].obs;
  RxList<Transaction> yesterdayTransactions = <Transaction>[].obs;
  RxString selectedPeriod = 'Cette semaine'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  void loadTransactions() {
    todayTransactions.value = [
      Transaction(
        id: '1',
        type: 'facture',
        title: 'Canal +',
        subtitle: 'Facture payée',
        amount: -25000,
        date: DateTime.now(),
        icon: CupertinoIcons.tv,
        color: CupertinoColors.black,
      ),
      Transaction(
        id: '2',
        type: 'recharge',
        title: 'Airtel',
        subtitle: 'Recharge Mobile',
        amount: -5000,
        date: DateTime.now(),
        icon: CupertinoIcons.phone,
        color: CupertinoColors.systemRed,
      ),
      Transaction(
        id: '3',
        type: 'reception',
        title: 'Nail',
        subtitle: 'Argent reçu',
        amount: 50000,
        date: DateTime.now(),
        icon: CupertinoIcons.arrow_down_circle,
        color: CupertinoColors.systemBlue,
      ),
    ];

    yesterdayTransactions.value = [
      Transaction(
        id: '4',
        type: 'retrait',
        title: 'Retrait',
        subtitle: 'Retrait d\'espèces',
        amount: -30000,
        date: DateTime.now().subtract(Duration(days: 1)),
        icon: CupertinoIcons.money_dollar_circle,
        color: CupertinoColors.systemBlue,
      ),
      Transaction(
        id: '5',
        type: 'achat',
        title: 'Supermarché',
        subtitle: 'Achat',
        amount: -12000,
        date: DateTime.now().subtract(Duration(days: 1)),
        icon: CupertinoIcons.shopping_cart,
        color: CupertinoColors.systemOrange,
      ),
      Transaction(
        id: '6',
        type: 'bonus',
        title: 'Bonus',
        subtitle: 'Cashback reçus',
        amount: 2000,
        date: DateTime.now().subtract(Duration(days: 1)),
        icon: CupertinoIcons.gift,
        color: CupertinoColors.systemBlue,
      ),
    ];
  }
}
