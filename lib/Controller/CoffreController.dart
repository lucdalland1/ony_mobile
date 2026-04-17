import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/coffre_api/coffre_api.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/View/Coffre/model/coffreModel.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Widget/container.dart';

class CoffreController extends GetxController {

  static CoffreController get to => Get.find();

  // Controllers
  final TextEditingController rechercheController = TextEditingController();
  var totalActif=0.obs;
  
  // Reactive variables
  final RxString _selectedDateAjouter = "Appuyez pour choisir le délai".obs;
  DateTime _selectedDate = DateTime.now();
  // Getters and Setters
  String get selectedDateAjouter => _selectedDateAjouter.value;
  set selectedDateAjouter(String value) => _selectedDateAjouter.value = value;
  // Lifecycle
  @override
  void onClose() {  
    rechercheController.dispose();
    super.onClose();
  }

  // Methods
  void showMyCupertinoModalPopup() {
    DateTime selectedDate = DateTime.now();
    final now = DateTime.now();

    showCupertinoModalPopup(
      context: Get.context!,
      builder: (_) => SafeArea(
        bottom: true,
        child: Container(
        height: 300,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 250,
                child: CupertinoDatePicker(
                  minimumDate: DateTime(now.year, now.month, now.day),
                  minimumYear: DateTime.now().year,
                  maximumYear: DateTime.now().year + 10,
                  initialDateTime: DateTime.now(),
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (DateTime newDate) {
                    selectedDate = newDate;
                  },
                ),
              ),
              CupertinoButton(
                child: Text('Valider'),
               onPressed: () {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final picked = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

  if (picked.isAfter(today)) {
    Get.back();
    _selectedDate = selectedDate;
    selectedDateAjouter = selectedDate.toString();
  } else {
    SnackBarService.warning(
      "Veuillez sélectionner une date future",
    );
  }
}
              )
            ],
          ),
        ),
      ),
    ));
  }

////////partie api 
 var coffre = Rxn<CoffreModel>();
  var isLoading = false.obs;

  final CoffreService _service = CoffreService();

  @override
  void onInit() {
    super.onInit();
    fetchCoffre();
  }

  void fetchCoffre() async {
    isLoading.value = true;
    final data = await _service.fetchCoffre();
    if (data != null) {
      coffre.value = data;
    }
    isLoading.value = false;
    print('voila le data ${data?.nom}');
  }
  

  /// Partie Controller Ajouter Coffre
  /// 
    final TextEditingController objectifController = TextEditingController();
  final TextEditingController montantController = TextEditingController();

    var isLoading1 = false.obs;

  String? validateObjectif(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom de l\'objectif est requis';
    }
    if (value.length < 3) {
      return 'Le nom doit contenir au moins 3 caractères';
    }
    return null;
  }

  String? validateMontant(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le montant est requis';
    }
    final numValue = num.tryParse(value.replaceAll(' ', ''));
    if (numValue == null) {
      return 'Veuillez entrer un montant valide';
    }
    if (numValue <= 0) {
      return 'Le montant doit être supérieur à 0';
    }
    if(selectedDateAjouter=="Appuyez pour choisir le délai"){
      return 'Veuillez choisir un délai';
    }
    return null;
  }

  bool validateForm() {
    final objectifError = validateObjectif(objectifController.text);
    final montantError = validateMontant(montantController.text);
    
    if (objectifError != null) {
      SnackBarService.warning( objectifError,
        );
      return false;
    }
    
    if (montantError != null) {
      SnackBarService.warning( montantError,
        );
      return false;
    }
    
    return true;
  }
  clearForm() {
    objectifController.clear();
    montantController.clear();
    selectedDateAjouter = "Appuyez pour choisir le délai";
  }
 

  Future<void> ajouterCoffre() async {
    isLoading1.value = true;
    try {
      if (!validateForm()) return;
    
    final objectif = objectifController.text.trim();
    final montant = num.parse(montantController.text.replaceAll(' ', ''));
    
    print('Objectif: $objectif');
    print('Montant: $selectedDateAjouter');
    print('Date: ${selectedDateAjouter.isDateTime}');
    print('voila $_selectedDate');
    
    await _service.ajouterObjectif(coffreId: coffre.value!.id, nom: objectif, montantCible: montant.toString(), dateLimite:  _selectedDate.toString());
    // Refresh the coffre data after adding
    fetchCoffre();
    } catch (e) {
      SnackBarService.warning( "Ajout objectif échoué \n Si le problème persiste Contacter le support");
    } finally {
      isLoading1.value = false;
    }
  }
  
  Future<void> modifierCoffre(var id) async {
    isLoading1.value = true;
    try {
      if (!validateForm()) return;
    
    final objectif = objectifController.text.trim();
    final montant = num.parse(montantController.text.replaceAll(' ', ''));
    
    print('Objectif: $objectif');
    print('Montant: $selectedDateAjouter');
    print('Date: ${selectedDateAjouter.isDateTime}');
    print('voila $_selectedDate');
    
    await _service.modifierObjectif(objectifId: id, nom: objectif, montantCible: int.parse(montant.toString()), dateLimite:  _selectedDate.toString());
    // Refresh the coffre data after adding
    fetchCoffre();
    } catch (e) {
      SnackBarService.warning( e.toString());
    } finally {
      isLoading1.value = false;
    }
  }
  
  
  Future<void> supprimerObjectif(int id) async {
    await _service.supprimerObjectif(objectifId: id);
    // Refresh the coffre data after deletion
    fetchCoffre();
  }
  ajouterMontantObjectif(int id, int montant) async {
    await _service.ajouterMontantObjectif(objectifId: id, montant: montant.toString());
    fetchCoffre(); 
     }

  void retraitC2W({required int montant}) async {
    await _service.retraitC2W(montant: montant);
    
  }

}