import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

IconData getIconForType(String type) {
  switch (type) {
    case 'Cashback':
      return Icons.check_circle;
    case 'Offre':
      return Icons.lightbulb;
    case 'Rappel':
      return Icons.warning;
    case 'Transaction':
      return Icons.send;
    case 'Feature':
      return Icons.new_releases;
    case 'Onypay':
      return Icons.payment;
    default:
      return CupertinoIcons.bell;
  }
}

Color getColorForType(String type) {
  
  switch (type) {
    case 'Cashback':
      return Colors.green;
    case 'Offre':
      return Colors.orange;
    case 'Rappel':
      return Colors.red;
    case 'Transaction':
      return Colors.blue;
    case 'Feature':
      return Colors.pink;
    case 'Onypay':
      return const Color(0xFF6C3FE8);
    default:
      return Colors.grey;
  }
}
