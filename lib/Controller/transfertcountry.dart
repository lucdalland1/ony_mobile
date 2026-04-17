// controllers/country_controller.dart
// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:onyfast/Controller/transfert/pays_controller.dart';
import 'package:onyfast/View/Transfert/model/configuration_pays/contry.dart';

class Country {
  final String name;
  final String flag;
  final String code;
  final int idContries;
  final String indicatif;  

  Country(this.idContries, {required this.name, required this.flag, required this.code, required this.indicatif});

  @override
  String toString() => '$flag $name';
}

class TransfertCountryController extends GetxController {

  final PaysController _paysController = Get.find();

  var countries = <Country>[].obs;
  var selectedCountry = Rx<Country?>(null);
  var filteredCountries = <Country>[].obs;
  var searchQuery = ''.obs;

  String _getCountryFlag(String code) {
    return getFlagByCode(code);
  }

  @override
  void onInit() {
    super.onInit();
    print('Fetching pays data...');
    _paysController.fetchPays().then((_) {
      
      print('Voila son indicatif luc: ${_paysController.countries[0].indicatif}');
      countries.assignAll(_paysController.countries.map((e) {
  print('Pays: ${e.nom}, indicatif: ${e.indicatif}');
  return Country(
    e.aggregateurs.first.pivot.paysId,
    name: e.nom ?? "",
    flag: _getCountryFlag(e.code) ?? "🌍",
    code: e.code,
    indicatif: e.indicatif,
  );
}));

      filteredCountries.assignAll(countries);
      print('Countries mapped: ${countries.length}');
    }).catchError((error) {
      print('Error fetching countries: $error');
    });
  }

  void filterCountries(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredCountries.assignAll(countries);
    } else {
      filteredCountries.assignAll(countries
          .where((country) =>
              country.name.toLowerCase().contains(query.toLowerCase()))
          .toList());
    }
  }

  void selectCountry(Country country) {
    print('Selecting country: ${country.name} (ID: ${country.idContries})');
    selectedCountry.value = country;
  }

  void clearSelection() {
    print('Clearing country selection');
    selectedCountry.value = null;
  }
}
