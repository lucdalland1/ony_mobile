import 'package:flutter/material.dart';

class TextfielWidget extends StatelessWidget {
  final TextInputType? keyboardType;
  final String? labelText;
  final TextEditingController? controller;
  final InputBorder? border;
  const TextfielWidget({
    required this.keyboardType,
    required this.controller,
    required this.labelText,
    required this.border,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: border,
        ),
        keyboardType:keyboardType,
      ),
    );
  }
}