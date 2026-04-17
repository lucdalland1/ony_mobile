// controllers/date_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DateController extends GetxController {
  var selectedDate = DateTime.now().obs;
  var dateText = ''.obs;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      dateText.value = DateFormat('dd/MM/yyyy').format(picked);
    }
  }
}