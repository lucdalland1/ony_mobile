import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneController extends GetxController {
  
  var controller = TextEditingController();
  var initialCountry = 'CG';
  var phoneNumber = PhoneNumber(isoCode: 'CG').obs;

  // Concatenate the country code and phone number
  String get fullPhoneNumber => '${phoneNumber.value.dialCode}${controller.text}';
}