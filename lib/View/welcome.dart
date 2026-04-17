import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../Color/app_color_model.dart';
import '../Controller/numbercontroller.dart';
import '../Widget/container.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final NumberController phoneController = Get.put(NumberController());
    
    return Material(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.15,
              left: screenWidth * 0.20,
              right: screenWidth * 0.1,
              bottom: 10,
            ),
            child: Container(
              width: screenWidth * 0.4,
              height: screenWidth * 0.4,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "asset/onylogo.png",
                    height: screenWidth * 0.7,
                    width: screenWidth * 0.25,
                  ),
                ),
              ),
            ),
          ),
          Gap(15),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.1), // Responsive padding
            child: InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                if (number.dialCode != null && number.dialCode!.startsWith('+')) {
                  final cleanNumber = number;
                  phoneController.onPhoneNumberChange(cleanNumber);
                } else {
                  phoneController.onPhoneNumberChange(number);
                }
              },
              selectorConfig: SelectorConfig(
                selectorType: PhoneInputSelectorType.DIALOG,
                leadingPadding: 0,
                trailingSpace: false,
              ),
              ignoreBlank: false,
              selectorTextStyle: TextStyle(color: Colors.black),
              initialValue: phoneController.phoneNumber.value,
              formatInput: false,
              keyboardType: TextInputType.phone,
              inputDecoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Numéro de téléphone',
              ),
              spaceBetweenSelectorAndTextField: 0,
              onSaved: (PhoneNumber number) {
                print('Numéro enregistré: ${number.phoneNumber}');
              },
            ),
          ),
          Gap(5),
          InkWell(
            onTap: () => Get.to(Welcome()),
            child: ContainerWidget(
              height: 50,
              width: screenWidth * 0.78, // Responsive width
              color: AppColorModel.BlueColor,
              borderRadius: BorderRadius.circular(10),
              child: Center(
                child: Text(
                  "Vérifier",
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    color: AppColorModel.WhiteColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}