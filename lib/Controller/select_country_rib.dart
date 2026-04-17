import 'package:get/get.dart';

class CountryRIBController extends GetxController {
  var selectedCountry = ''.obs;
  var selectedCountryCode = ''.obs;

  final List<Map<String, String>> countries = [
    {'name': 'République du Congo', 'code': 'CG'},
    {'name': 'Gabon', 'code': 'GA'},
    {'name': 'Tchad', 'code': 'TD'},
    {'name': 'République centrafricaine', 'code': 'CF'},
    {'name': 'Guinée Équatoriale', 'code': 'GQ'},
  ];

  void setCountry(String name, String code) {
    selectedCountry.value = name;
    selectedCountryCode.value = code;
  }
}