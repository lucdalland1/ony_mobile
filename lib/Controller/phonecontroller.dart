import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneNumberController extends GetxController {
  var number = PhoneNumber(isoCode: 'NG').obs;
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  void updatePhoneNumber(PhoneNumber newNumber) {
    number.value = newNumber;
  }

  void getPhoneNumber(String phoneNumber) async {
    PhoneNumber newNumber =
        await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, 'US');
    updatePhoneNumber(newNumber);
  }

  @override
  void onClose() {
    controller.dispose();
    focusNode.dispose();
    super.onClose();
  }
}