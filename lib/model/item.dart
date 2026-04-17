import 'package:flutter/material.dart';

class Item {
  final String title;
  final String subtitle;
  final String date;
  final String icon;
  final Color color;
  final double progress;

  Item({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
    required this.progress,
  });
}