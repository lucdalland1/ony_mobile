import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/helpers.dart';
import 'package:onyfast/Api/Register_User_APi/codeparaind_api.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Api/piecesjustificatif_Api/pieces_justificatif_api.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Controller/features/features_controller.dart';
import 'package:onyfast/Controller/info_user/usercontroller.dart';
import 'package:onyfast/Controller/niveau/niveau_controller.dart';
import 'package:onyfast/Controller/numero_status_mobile_money.dart';
import 'package:onyfast/View/Activit%C3%A9/recharger_mon_compte.dart';
import 'package:onyfast/View/Notification/notification.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:onyfast/utils/testInternet.dart';

import '../../Color/app_color_model.dart';

import 'package:intl/intl.dart';

import 'formulaireAjoutPopUp.dart';

String? _formatDateForApi(String txt) {
  if (txt.isEmpty) return null;
  try {
    final d = DateFormat('dd/MM/yyyy').parseStrict(txt); // ex: 17/08/2007
    return DateFormat('dd-MM-yyyy').format(d); // -> 17-08-2007
  } catch (_) {
    return null;
  }
}

/// Petit modèle d'option
class SelectOption {
  final String id;
  final String name;
  SelectOption(this.id, this.name);
}

String cleanText(String input) {
  // 1. Supprime les accents (é → e, à → a, ô → o, ñ → n, etc.)
  String withoutAccents = removeDiacritics(input);
  // 2. Supprime tous les caractères spéciaux sauf lettres/chiffres/espaces
  return withoutAccents.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
}

/// ---------- CONTROLLER ----------
class CarteVirtuelleController extends GetxController {
  // Form & état
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final fieldsUpdated = 0.obs;

  // Storage
  final box = GetStorage();
  static const String STORAGE_KEY = 'carte_virtuelle_draft';
  
  // Timer pour la sauvegarde automatique
  Timer? _autoSaveTimer;

  var tabCountry;
  var tabDepartment;
  var tabCity;

  // Dio
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // Champs simples
  final nameCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final genre = ''.obs; // Masculin | Féminin | Autre
  final birthDateCtrl = TextEditingController(); // JJ/MM/AAAA
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final altPhoneCtrl = TextEditingController(); // Autre numéro (optionnel)
  final selectedCountryIndicatif = ''.obs;

  final emailCtrl = TextEditingController();
  final codeParrainCtrl = TextEditingController(); // Code de parrain (optionnel)
  // Focus nodes
  final nameNode = FocusNode();
  final firstNameNode = FocusNode();
  final countryNode = FocusNode();
  final departmentNode = FocusNode();
  final cityNode = FocusNode();
  final genreNode = FocusNode();
  final birthNode = FocusNode();
  final addressNode = FocusNode();
  final phoneNode = FocusNode();
  final altPhoneNode = FocusNode();
  final emailNode = FocusNode();
  final codeParrainNode = FocusNode();
  // --- Selects Pays/Département/Ville ---
  final countries = <SelectOption>[].obs;
  final departments = <SelectOption>[].obs;
  final cities = <SelectOption>[].obs;

  final selectedCountryId = RxnString();
  final selectedCountryName = ''.obs;

  final selectedDepartmentId = RxnString();
  final selectedDepartmentName = ''.obs;

  final selectedCityId = RxnString();
  final selectedCityName = ''.obs;

  // Chargement des listes
  final isCountriesLoading = false.obs;
  final isDepartmentsLoading = false.obs;
  final isCitiesLoading = false.obs;

  // Erreurs de chargement
  final countryLoadError = ''.obs;
  final departmentLoadError = ''.obs;
  final cityLoadError = ''.obs;
  void recupcodeparrain() async{
  await Get.put(RechargeStatusController()).fetchRechargeStatus();

  // Pas besoin d'await ici
  var code_parrain = SecureTokenController.to.codeParrain.value;
  codeParrainCtrl.text = code_parrain ?? codeParrainCtrl.text;
}

  @override
  void onInit() {
    super.onInit();
    fetchCountries();
      Future.delayed(const Duration(milliseconds: 300), () {
      loadDraftFromStorage();
    });
    
    // 3. Configurer l'auto-save après le chargement initial
    _setupAutoSave();
    recupcodeparrain();
  }
/// Configure la sauvegarde automatique toutes les 2 secondes
  /// UNIQUEMENT pour: Genre, Date Naissance, Pays, Département, Ville, Autre numéro
 
  /// Déclenche la sauvegarde avec un délai (debounce)
  void _triggerAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      saveDraftToStorage();
    });
  }

  /// Sauvegarde UNIQUEMENT: Genre, Date Naissance, Pays, Département, Ville, Autre numéro
  void saveDraftToStorage() {
    try {
      final draftData = {
        'genre': genre.value,
        'date_naissance': birthDateCtrl.text.trim(),
        'autre_numero': altPhoneCtrl.text.trim(),
        'code_parrain': codeParrainCtrl.text.trim(),
        'pays_id': selectedCountryId.value,
        'pays_name': selectedCountryName.value,
        'departement_id': selectedDepartmentId.value,
        'departement_name': selectedDepartmentName.value,
        'ville_id': selectedCityId.value,
        'ville_name': selectedCityName.value,
        'timestamp': DateTime.now().toIso8601String(),
      };

      box.write(STORAGE_KEY, draftData);
      print('✅ Brouillon sauvegardé automatiquement (Genre, Date Naissance, Localisation, Autre numéro)');
    } catch (e) {
      print('❌ Erreur sauvegarde: $e');
    }
  }

  /// Charge UNIQUEMENT: Genre, Date Naissance, Pays, Département, Ville, Autre numéro
  void loadDraftFromStorage() {
    try {
      final draftData = box.read(STORAGE_KEY);
      
      if (draftData == null) {
        print('ℹ️ Aucun brouillon trouvé');
        return;
      }

      // Vérifier que le brouillon n'est pas trop ancien (ex: 7 jours)
      final timestamp = draftData['timestamp'];
      if (timestamp != null) {
        final saveDate = DateTime.parse(timestamp);
        final daysDiff = DateTime.now().difference(saveDate).inDays;
        
        if (daysDiff > 7) {
          print('⚠️ Brouillon trop ancien (${daysDiff} jours), suppression');
          clearDraftFromStorage();
          codeParrainCtrl.text =  SecureTokenController.to.codeParrain.value ?? "";
          return;
        }
      }

      print('🔄 Restauration du brouillon...');

      // Restaurer UNIQUEMENT les champs autorisés
      if (draftData['autre_numero'] != null && draftData['autre_numero'].toString().isNotEmpty) {
        altPhoneCtrl.text = draftData['autre_numero'];
        print('  ✓ Autre numéro: ${draftData['autre_numero']}');
      }
      if (draftData['code_parrain'] != null && draftData['code_parrain'].toString().isNotEmpty) {
        if(SecureTokenController.to.codeParrain.value==null||SecureTokenController.to.codeParrain.value==""){
          codeParrainCtrl.text = draftData['code_parrain'];
        }else {codeParrainCtrl.text =  SecureTokenController.to.codeParrain.value ?? draftData['code_parrain'];}
      
  print('  ✓ Code de parrain: ${draftData['code_parrain']}');
}
      if (draftData['date_naissance'] != null && draftData['date_naissance'].toString().isNotEmpty) {
        birthDateCtrl.text = draftData['date_naissance'];
        print('  ✓ Date naissance: ${draftData['date_naissance']}');
      }
      
      // Restaurer le genre
      if (draftData['genre'] != null && draftData['genre'].toString().isNotEmpty) {
        genre.value = draftData['genre'];
        print('  ✓ Genre: ${draftData['genre']}');
      }

      // Restaurer les sélections géographiques avec cascade
      final paysId = draftData['pays_id'];
      final deptId = draftData['departement_id'];
      final villeId = draftData['ville_id'];

      if (paysId != null && paysId.toString().isNotEmpty) {
        print('  🌍 Restauration du pays: $paysId');
        selectedCountryId.value = paysId;
        selectedCountryName.value = draftData['pays_name'] ?? '';
        
        // Attendre que les pays soient chargés
        Future.delayed(const Duration(milliseconds: 800), () async {
          if (deptId != null && deptId.toString().isNotEmpty) {
            print('  📍 Chargement des départements pour pays: $paysId');
            await fetchDepartments(paysId.toString());
            
            // Petit délai pour s'assurer que les départements sont chargés
            await Future.delayed(const Duration(milliseconds: 500));
            
            selectedDepartmentId.value = deptId;
            selectedDepartmentName.value = draftData['departement_name'] ?? '';
            print('  ✓ Département restauré: $deptId');
            
            if (villeId != null && villeId.toString().isNotEmpty) {
              print('  🏙️ Chargement des villes pour département: $deptId');
              await fetchCities(paysId.toString(), deptId.toString());
              
              // Petit délai pour s'assurer que les villes sont chargées
              await Future.delayed(const Duration(milliseconds: 500));
              
              selectedCityId.value = villeId;
              selectedCityName.value = draftData['ville_name'] ?? '';
              print('  ✓ Ville restaurée: $villeId');
            }
            
            fieldsUpdated.value++;
          }
        });
      }

      fieldsUpdated.value++;
      
      // // Afficher un message à l'utilisateur
      // Future.delayed(const Duration(seconds: 2), () {
      //   Get.snackbar(
      //     'Brouillon restauré',
      //     'Genre, date de naissance, localisation et autre numéro récupérés',
      //     snackPosition: SnackPosition.TOP,
      //     backgroundColor: Colors.green.shade100,
      //     colorText: Colors.green.shade900,
      //     icon: const Icon(Icons.restore, color: Colors.green),
      //     duration: const Duration(seconds: 3),
      //     margin: const EdgeInsets.all(12),
      //     borderRadius: 8,
      //   );
      // });
      
      print('✅ Brouillon chargé avec succès');
    } catch (e) {
      print('❌ Erreur chargement brouillon: $e');
    }
  }

  /// Supprime le brouillon du local storage
  void clearDraftFromStorage() {
    try {
      box.remove(STORAGE_KEY);
      print('🗑️ Brouillon supprimé');
    } catch (e) {
      print('❌ Erreur suppression: $e');
    }
  }

  /// Vérifie s'il existe un brouillon sauvegardé
  bool hasDraft() {
    return box.hasData(STORAGE_KEY);
  }
  @override
  void onClose() {
        _autoSaveTimer?.cancel(); // ← AJOUTEZ CETTE LIGNE

    nameCtrl.dispose();
    firstNameCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    phoneCtrl.dispose();
    altPhoneCtrl.dispose();
    birthDateCtrl.dispose();

    nameNode.dispose();
    firstNameNode.dispose();
    countryNode.dispose();
    departmentNode.dispose();
    cityNode.dispose();
    genreNode.dispose();
    birthNode.dispose();
    addressNode.dispose();
    phoneNode.dispose();
    altPhoneNode.dispose();
    emailNode.dispose();
    codeParrainCtrl.dispose();
    codeParrainNode.dispose();
    super.onClose();
  }

  // Pré-remplissage depuis l'utilisateur
  void hydrateFromUser({
    required String? name,
    required String? firstName,
    required String? email,
    required String? phone,
    required String? address,
    required String? dateNaissance,
    required String? genres
  }) {
    nameCtrl.text = name ?? '';
    firstNameCtrl.text = firstName ?? '';
    emailCtrl.text = email ?? '';
    phoneCtrl.text = phone ?? '';
    addressCtrl.text = address ?? '';
    if(dateNaissance != null) {
  try {
    // Convertir de AAAA-MM-JJ vers JJ/MM/AAAA
    final date = DateTime.parse(dateNaissance);
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    birthDateCtrl.text = "$dd/$mm/$yyyy";
  } catch (e) {
  }
}
    if(genres!=null)genre.value =int.parse(genres.toString())==1? 'F':'M' ;
    fieldsUpdated.value++;
  }

  // Helpers focus + toast
  void _focus(FocusNode node) {
    final ctx = Get.context;
    if (ctx != null) FocusScope.of(ctx).requestFocus(node);
  }

  void _toast(String msg) {
    SnackBarService.warning(msg);
  }

  // Validations
  String? validateNonVide(String? v, {String label = 'Champ'}) {
    if (v == null || v.trim().isEmpty) return '$label est requis';
    return null;
  }

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return "Email est requis";
    if (!GetUtils.isEmail(v.trim())) return "Veuillez entrer un email valide";
    return null;
  }
  String? validateCodeParrain(String? v) {
  // Si vide, c'est OK (champ optionnel)
  if (v == null || v.trim().isEmpty) return null;
  
  final clean = v.trim();
  
  // Si rempli, vérifier exactement 12 caractères
  if (clean.length > 12) {
    return "Le code doit contenir au maximum exactement 12 caractères";
  }
  
  // Vérifier uniquement lettres majuscules et chiffres
  if (!RegExp(r'^[A-Z0-9]{1,12}$').hasMatch(clean)) {
    return "Le code doit contenir uniquement des lettres majuscules et des chiffres";
  }
  
  return null;
}

 String? validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return "Téléphone est requis";
    final clean = v.replaceAll(RegExp(r'[^0-9+]'), '');
  if (!RegExp(r'^\+?\d{9}$|^\+?\d{12}$').hasMatch(clean)) {
  return "Numéro de téléphone invalide ";
  }
  if(clean.length!=12){
      if(!(clean.startsWith("06") ||
         clean.startsWith("04") ||
         clean.startsWith("05") ||
         clean.startsWith("22"))){
        return "Numéro de téléphone invalide (ex: (242) 06 123 456 78)";
      }
      else{
        return null;
      }
  }else {
    if(clean.startsWith("242") ){

      var tel242=clean.replaceFirst('242', "");
      tel242=tel242.replaceAll('+', '');
      if(!(tel242.startsWith("06") ||
         tel242.startsWith("04") ||
         tel242.startsWith("05") ||
         tel242.startsWith("22"))){
        return "Numéro de téléphone invalide (ex: (242) 06 123 456 78)";
      }
      else{
        return null;
      }

    }else {
      return "Indicatif non valide";
    }


  }

 
    return null;
  }


  String? validateAltPhone(String? v) {
  if (v == null || v.trim().isEmpty) return "Autre numéro est requis";
  return validatePhone(v);
}

  DateTime? _parseDdMmYyyy(String v) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(v);
    } catch (_) {
      return null;
    }
  }

  int _ageOn(DateTime dob, DateTime on) {
    var age = on.year - dob.year;
    final hadBirthdayThisYear =
        (on.month > dob.month) || (on.month == dob.month && on.day >= dob.day);
    if (!hadBirthdayThisYear) age--;
    return age;
  }

  String? validateBirth(String? v) {
    if (v == null || v.trim().isEmpty) return "Date de naissance est requise";
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(v.trim())) {
      return "Format requis : JJ/MM/AAAA";
    }

    final dob = _parseDdMmYyyy(v.trim());
    if (dob == null) return "Date invalide (ex: 07/03/1998)";

    final today = DateTime.now();
    if (dob.isAfter(today)) return "La date ne peut pas être dans le futur";

    final age = _ageOn(dob, today);
    if (age < 18) return "Vous devez avoir au moins 18 ans";
    if (age > 120) return "Âge invalide (> 120 ans)";

    return null;
  }
/// Configure la sauvegarde automatique toutes les 2 secondes
  /// UNIQUEMENT pour: Genre, Date Naissance, Pays, Département, Ville, Autre numéro
  void _setupAutoSave() {
    // Écouter UNIQUEMENT "Autre numéro" et "Date de naissance"
    altPhoneCtrl.addListener(_triggerAutoSave);
    birthDateCtrl.addListener(_triggerAutoSave);
    codeParrainCtrl.addListener(_triggerAutoSave);
    // Écouter les changements sur les observables
    ever(genre, (_) => _triggerAutoSave());
    ever(selectedCountryId, (_) => _triggerAutoSave());
    ever(selectedDepartmentId, (_) => _triggerAutoSave());
    ever(selectedCityId, (_) => _triggerAutoSave());
  }

  /// Déclenche la sauvegarde avec un délai (debounce)
 

  /// Sauvegarde UNIQUEMENT: Genre, Date Naissance, Pays, Département, Ville, Autre numéro


  /// Charge UNIQUEMENT: Genre, Date Naissance, Pays, Département, Ville, Autre numéro
  
  /// Supprime le brouillon du local storage
  

  /// Vérifie s'il existe un brouillon sauvegardé
 
  String? validateGenre(String? v) {
    if (v == null || v.trim().isEmpty) return "Genre est requis";
    return null;
  }

  String? validateSelect(String? id, {required String label}) {
    if (id == null || id.isEmpty) return "$label est requis";
    return null;
  }

  // Champs manquants (pour la bannière)
  List<String> getMissingFields() {
    final missing = <String>[];
    if ((selectedCountryId.value ?? '').isEmpty) missing.add("Pays");
    if ((selectedDepartmentId.value ?? '').isEmpty) missing.add("Département");
    if ((selectedCityId.value ?? '').isEmpty) missing.add("Ville");
    if (nameCtrl.text.isEmpty) missing.add("Nom");
    if (firstNameCtrl.text.isEmpty) missing.add("Prénom");
    if (emailCtrl.text.isEmpty) missing.add("Email");
    if (birthDateCtrl.text.isEmpty) missing.add("Date de naissance");
    if ((genre.value).isEmpty) missing.add("Genre");
    if (addressCtrl.text.isEmpty) missing.add("Adresse");
    if (phoneCtrl.text.isEmpty) missing.add("Téléphone");
    return missing;
  }

  bool validateAllAndRedirect() {
    if (validateNonVide(nameCtrl.text, label: "Nom") != null) {
      _focus(nameNode);
      _toast("Veuillez renseigner votre nom");
      return false;
    }
    if (validateNonVide(firstNameCtrl.text, label: "Prénom") != null) {
      _focus(firstNameNode);
      _toast("Veuillez renseigner votre prénom");
      return false;
    }
    if (validateSelect(selectedCountryId.value, label: "Pays") != null) {
      _focus(countryNode);
      _toast("Veuillez sélectionner votre pays");
      return false;
    }
    if (validateSelect(selectedDepartmentId.value, label: "Département") !=
        null) {
      _focus(departmentNode);
      _toast("Veuillez sélectionner votre département");
      return false;
    }
    if (validateSelect(selectedCityId.value, label: "Ville") != null) {
      _focus(cityNode);
      _toast("Veuillez sélectionner votre ville");
      return false;
    }
    if (validateGenre(genre.value) != null) {
      _focus(genreNode);
      _toast("Veuillez sélectionner votre genre");
      return false;
    }
    if (validateBirth(birthDateCtrl.text) != null) {
      _focus(birthNode);
      _toast("Veuillez corriger la date (JJ/MM/AAAA)");
      return false;
    }
    if (validateNonVide(addressCtrl.text, label: "Adresse") != null) {
      _focus(addressNode);
      _toast("Veuillez renseigner votre adresse");
      return false;
    }
    final phoneErr = validatePhone(phoneCtrl.text);
    if (phoneErr != null) {
      _focus(phoneNode);
      _toast(phoneErr);
      return false;
    }
    final altErr = validateAltPhone(altPhoneCtrl.text);
// Ou directement : final altErr = validatePhone(altPhoneCtrl.text);
    if (altErr != null) {
      _focus(altPhoneNode);
      _toast(altErr);
      return false;
    }
// Valider Code Parrain uniquement s'il est rempli
if (codeParrainCtrl.text.trim().isNotEmpty) {
  final codeParrainErr = validateCodeParrain(codeParrainCtrl.text);
  if (codeParrainErr != null) {
    _focus(codeParrainNode);
    _toast(codeParrainErr);
    return false;
  }
}
    final mailErr = validateEmail(emailCtrl.text);
    if (mailErr != null) {
      _focus(emailNode);
      _toast(mailErr);
      return false;
    }
    return true;
  }

  bool hasFieldErrorByLabel(String label) {
    switch (label) {
      case "Nom(s)":
        return validateNonVide(nameCtrl.text, label: "Nom") != null;
      case "Prénom(s)":
        return validateNonVide(firstNameCtrl.text, label: "Prénom") != null;
      case "Pays":
        return validateSelect(selectedCountryId.value, label: "Pays") != null;
      case "Département":
        return validateSelect(selectedDepartmentId.value,
                label: "Département") !=
            null;
      case "Ville":
        return validateSelect(selectedCityId.value, label: "Ville") != null;
      case "Genre":
        return validateGenre(genre.value) != null;
      case "Date de naissance":
        return validateBirth(birthDateCtrl.text) != null;
      case "Adresse":
        return validateNonVide(addressCtrl.text, label: "Adresse") != null;
      case "Téléphone":
        return validatePhone(phoneCtrl.text) != null;
      case "Autre numéro":

           return validateAltPhone(altPhoneCtrl.text) != null;
      case "Email":
        return validateEmail(emailCtrl.text) != null;
      case "Code de Parrain":
        if (codeParrainCtrl.text.trim().isEmpty) return false;
        return validateCodeParrain(codeParrainCtrl.text) != null;
    }
    return false;
  }

  // ---------- API: chargement des selects ----------
  Future<void> fetchCountries() async {
    isCountriesLoading.value = true;
    countryLoadError.value = '';
    try {
      final headers = {'Accept': 'application/json'};
      final response = await dio.request(
        '${ApiEnvironmentController.to.baseUrl}/contry_onyfast',
        options: Options(method: 'GET', headers: headers),
      );

      if (response.statusCode == 200) {
        final list = (response.data['data'] as List?) ?? const [];
        final parsed = list.map((e) {
          final map = (e as Map).cast<String, dynamic>();
          return SelectOption(
            map['id'].toString(),
            map['designation']?.toString() ?? '',
          );
        }).toList();

        countries.assignAll(parsed);
        if (countries.isEmpty) {
          countryLoadError.value = "Aucun pays trouvé.";
        }
        tabCountry = response.data['data'];
      } else {
        countryLoadError.value =
            'HTTP ${response.statusCode}: ${response.statusMessage ?? 'Erreur'}';
      }
    } catch (e) {
      countryLoadError.value = "Impossible de charger la liste des pays.";
      print('fetchCountries error: $e');
    } finally {
      isCountriesLoading.value = false;
    }
  }

  Future<void> fetchDepartments(String countryId) async {
    isDepartmentsLoading.value = true;
    departmentLoadError.value = '';
    try {
      final res = await dio.request(
        '${ApiEnvironmentController.to.baseUrl}/departements_onyfast/$countryId',
        options: Options(
          method: 'GET',
          headers: const {'Accept': 'application/json'},
        ),
      );

      if (res.statusCode == 200) {
        final list = (res.data['data'] as List?) ?? const [];
        final parsed = list.map((e) {
          final m = (e as Map).cast<String, dynamic>();
          return SelectOption(
            m['id'].toString(),
            m['designation']?.toString() ?? '',
          );
        }).toList();

        departments
          ..clear()
          ..addAll(parsed);

        if (departments.isEmpty) {
          departmentLoadError.value = "Aucun département trouvé.";
        }
        tabDepartment = res.data['data'];
      } else {
        departmentLoadError.value =
            'HTTP ${res.statusCode}: ${res.statusMessage ?? 'Erreur'}';
      }
    } catch (e) {
      departmentLoadError.value = "Impossible de charger les départements.";
      print('fetchDepartments error: $e');
    } finally {
      isDepartmentsLoading.value = false;
    }
  }

  Future<void> fetchCities(String countryId, String departmentId) async {
    isCitiesLoading.value = true;
    cityLoadError.value = '';
    try {
      final res = await dio.request(
        '${ApiEnvironmentController.to.baseUrl}/city_onyfast/$countryId/$departmentId',
        options: Options(
          method: 'GET',
          headers: const {'Accept': 'application/json'},
          validateStatus: (_) => true,
        ),
      );

      if (res.statusCode == 200) {
        final list =
            (res.data is Map ? (res.data['data'] as List?) : null) ?? const [];
        final parsed = list.map((e) {
          final m = (e as Map).cast<String, dynamic>();
          return SelectOption(
            m['id'].toString(),
            (m['designation'] ?? m['name'] ?? '').toString(),
          );
        }).toList();

        final seen = <String>{};
        final unique = <SelectOption>[];
        for (final o in parsed) {
          if (o.id.isEmpty) continue;
          if (seen.add(o.id)) unique.add(o);
        }

        cities
          ..clear()
          ..addAll(unique);
        tabCity = res.data['data'];

        if (!cities.any((e) => e.id == (selectedCityId.value ?? ''))) {
          selectedCityId.value = null;
          selectedCityName.value = '';
        }

        if (cities.isEmpty) {
          cityLoadError.value = "Aucune ville trouvée.";
        }
        tabCity = res.data['data'];
      } else if (res.statusCode == 404) {
        cities.clear();
        selectedCityId.value = null;
        selectedCityName.value = '';
        final msg = (res.data is Map) ? res.data['message']?.toString() : null;
        cityLoadError.value =
            msg ?? "Aucune ville trouvée pour ce département.";
      } else {
        cityLoadError.value =
            'HTTP ${res.statusCode}: ${res.statusMessage ?? 'Erreur'}';
      }
    } catch (e) {
      cityLoadError.value = "Impossible de charger les villes.";
      print('fetchCities error: $e');
    } finally {
      isCitiesLoading.value = false;
    }
  }

  // Handlers de sélection (cascade + reset aval)
  void onCountrySelected(SelectOption? opt) {
  selectedCountryId.value = opt?.id;
  selectedCountryName.value = opt?.name ?? '';

  // Récupérer l'indicatif du pays
  if (opt != null && tabCountry != null) {
    try {
      final country = (tabCountry as List).firstWhere(
        (c) => c['id'].toString() == opt.id,
        orElse: () => null,
      );
      if (country != null) {
        selectedCountryIndicatif.value = country['indicatif']?.toString() ?? '';
      }
    } catch (e) {
      selectedCountryIndicatif.value = '';
    }
  } else {
    selectedCountryIndicatif.value = '';
  }

  selectedDepartmentId.value = null;
  selectedDepartmentName.value = '';
  departments.clear();

  selectedCityId.value = null;
  selectedCityName.value = '';
  cities.clear();

  fieldsUpdated.value++;
  if (opt != null) fetchDepartments(opt.id);
}

  void onDepartmentSelected(SelectOption? opt) {
    selectedDepartmentId.value = opt?.id;
    selectedDepartmentName.value = opt?.name ?? '';

    selectedCityId.value = null;
    selectedCityName.value = '';
    cities.clear();

    fieldsUpdated.value++;
    if (opt != null && selectedCountryId.value != null) {
      fetchCities(selectedCountryId.value!, opt.id);
    }
  }

  void onCitySelected(SelectOption? opt) {
    selectedCityId.value = opt?.id;
    selectedCityName.value = opt?.name ?? '';
    fieldsUpdated.value++;
  }

  Future<void> pickBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final latestAdult =
        DateTime(now.year - 18, now.month, now.day); // max autorisé
    final earliest =
        DateTime(now.year - 120, now.month, now.day); // min autorisé

    // Si déjà une valeur, la reprendre comme initiale (sinon 18 ans)
    final current = _parseDdMmYyyy(birthDateCtrl.text);
    DateTime initial = current ?? latestAdult;

    // Clamp l'initiale dans [earliest, latestAdult]
    if (initial.isBefore(earliest) || initial.isAfter(latestAdult)) {
      initial = latestAdult;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: earliest,
      lastDate: latestAdult,
      helpText: "Choisir votre date de naissance",
      cancelText: "Annuler",
      confirmText: "Valider",
    );

    if (picked != null) {
      final dd = picked.day.toString().padLeft(2, '0');
      final mm = picked.month.toString().padLeft(2, '0');
      final yyyy = picked.year.toString();
      birthDateCtrl.text = "$dd/$mm/$yyyy";
      fieldsUpdated.value++;
    }
  }

// ... autres imports et définitions nécessaires ...

  Future<void> submit() async {
    try {
      if (!(formKey.currentState?.validate() ?? false)) {
        if (!validateAllAndRedirect()) return;
      } else {
        if (!validateAllAndRedirect()) return;
      }



      bool isConnected = await hasInternetConnection();

      if (isConnected) {
        print('Connexion Internet disponible');
      } else {
        SnackBarService.error("L'ajout de la carte virtuelle est momentanément indisponible");
        isLoading.value = false;
        return;
      }

      final service = FeaturesService();

        final isActive = await service.isFeatureActive(AppFeature.emissionCarteVirtuelle);

        if (isActive) {
          print('✅ Ajout de la carte actuell ajout ement dispo');
        } else {
          Get.back();
          isLoading.value = false;
          SnackBarService.error('❌ Ce service est momentanément indisponible');

          return;
        }
        if(codeParrainCtrl.text.trim().isNotEmpty){
            var result = await ParrainageService().getUserByParrainCode(codeParrainCtrl.text.trim());
            if(result == null){
            //  SnackBarService.warning('Impossible de vérifier le code parrain. Veuillez réessayer plus tard.');
              return;
            }

            print('result parainage $result');
            if(result == false) {
              isLoading.value = false;
              SnackBarService.warning('Code parrain invalide. Veuillez vérifier et réessayer.');
              return;
            }
        }
        

      NiveauController niveauController=Get.find();
      await niveauController.fetchNiveau();

      if(niveauController.errorMessage.value!=''){
        SnackBarService.warning(
          'Oups 😕'
          "Erreur de récupération des Informations, veuillez recommencer"
        );
        return;
      }
      
    // final result = await showJustificatifPopup();
      
     PiecesController controllerTest = Get.find();
      await controllerTest.fetchPieces();
      

     if(niveauController.niveau.value==0){ if (controllerTest.Error.value) {
        Get.snackbar(
          'Oups 😕',
          'Erreur de récupération des pièces.\nSi le problème persiste, contactez la direction.',
          snackPosition: SnackPosition.TOP,
          snackStyle: SnackStyle.FLOATING,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
          isDismissible: true,
          forwardAnimationCurve: Curves.easeOutBack,
          boxShadows: [
            BoxShadow(
                blurRadius: 8, offset: Offset(0, 4), color: Colors.black12),
          ],
        );
        return;
      }
      }


     bool voirSinull=false;
     var NouvelData ;

     if(niveauController.niveau.value!=0&& niveauController.idValue.value.isEmpty){
          print('il est  la voila son niveau ✅✅✅✅✅✅✅ ');
          if(controllerTest.pieces.isEmpty){
            final result = await showJustificatifPopup();
 
 // Utiliser le résultat
 if (result != null) {
   print('Type de pièce ID: ${result.typePieceId}');
   print('Numéro de pièce: ${result.numeroPiece}');
   voirSinull=true;
   // Exemple: Utiliser dans votre payload
    NouvelData = {
     'type_piece_id': result.typePieceId,
     'numero_piece': result.numeroPiece,
     // ... autres champs
   };
 } else {
   print('Utilisateur a annulé');
   return;
 }

            
          }

     }

      // 2) Validations

      // 3) Récupérer le montant des frais depuis le backend
      final fraisResponse = await _getFraisEmission();
      if (fraisResponse == null) {
        Get.snackbar(
          'Erreur',
          'Impossible de récupérer les frais d\'émission',
          snackPosition: SnackPosition.TOP,
          snackStyle: SnackStyle.FLOATING,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
          isDismissible: true,
        );
        return;
      }

      final montantFrais = fraisResponse['montant'] ?? 3000;

      // 4) Afficher la boîte de dialogue de confirmation (corrigée pour éviter débordement)
      final bool? confirmed = await Get.dialog<bool>(
        Builder(
          builder: (context) {
            final mediaQuery = MediaQuery.of(context);
            final maxWidth = mediaQuery.size.width * 0.9;
            final maxHeight = mediaQuery.size.height * 0.7;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 24),
              titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              title: Row(
                children: [
                  Icon(Icons.payment,
                      color: AppColorModel.Bluecolor242, size: 24),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Confirmation de paiement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColorModel.Bluecolor242,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Frais d\'émission de carte virtuelle',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '$montantFrais FCFA',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Le montant indiqué sera débité de votre compte pour le traitement de votre demande d’émission de carte virtuelle.\n \nSi votre compte n’est pas encore approvisionné, nous vous invitons à effectuer un rechargement depuis l’accueil afin de finaliser l’émission, soit par recharge, soit par transfert.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Voulez-vous continuer ?',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text(
                    'Annuler',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorModel.Bluecolor242,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Confirmer le paiement',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
        barrierDismissible: false,
      );

      if (confirmed != true) return;

      // 5) Traitement avec loader
      isLoading.value = true;
     if(niveauController.niveau.value==0){ if (controllerTest.pieces.isEmpty) {
  Get.snackbar(
    'Pièce manquante',
    'Aucune pièce d\'identité trouvée. Veuillez d\'abord enregistrer une pièce d\'identité.',
    snackPosition: SnackPosition.TOP,
    snackStyle: SnackStyle.FLOATING,
    backgroundColor: Colors.orange.shade700,
    colorText: Colors.white,
    icon: const Icon(Icons.badge_outlined, color: Colors.white),
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
    duration: const Duration(seconds: 4),
    isDismissible: true,
  );
  return;
}}

      // Unfocus les champs
      if (Get.context != null) FocusScope.of(Get.context!).unfocus();
      String formatPhoneWithIndicatif(String phone) {
  if (phone.isEmpty) return '';
  String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
  String indicatif = selectedCountryIndicatif.value.replaceAll('+', '');
  
  if (indicatif.isNotEmpty && !clean.startsWith(indicatif)) {
    return '$indicatif$clean';
  }
  return '$clean';
}

      // 6) Préparer les données pour l'API Laravel
     var deviceskey=await ValidationTokenController.to.getDeviceIMEI();
      var ip=await ValidationTokenController.to.getPublicIP();
        final payload = {
          "nom": cleanText(nameCtrl.text.trim()),
          "prenom": cleanText(firstNameCtrl.text.trim()),
          "genre": genre.value,
          "date_naissance": _formatDateForApi(birthDateCtrl.text.trim()),
          "adresse": cleanText(addressCtrl.text.trim()),
          "telephone": (phoneCtrl.text.trim()),
          "autre_numero": formatPhoneWithIndicatif(altPhoneCtrl.text.trim()),
          "code_parrain": codeParrainCtrl.text.trim(),
          "email": emailCtrl.text.trim().toLowerCase(),
          "pays_id": selectedCountryId.value,
          "departement_id": selectedDepartmentId.value,
          "ville_id": selectedCityId.value,
          "type_piece_id":voirSinull==true?NouvelData['type_piece_id'] :controllerTest.pieces[0].typePieceId,
          "numero_piece": voirSinull==true? NouvelData['numero_piece'] :controllerTest.pieces[0].numeroPiece,
          "device":deviceskey,
          'ip':ip
        };

        

      print( 'voila toute les donnees  $payload');

      // 7) Appeler l'API Laravel pour la demande d'émission avec paiement
      final dio = Dio();
      final box = GetStorage();
      final String? token = box.read('token');

      final response = await dio.post(
        '${ApiEnvironmentController.to.baseUrl}/demande-emission-carte-virtuelle',
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // 8) Traitement de la réponse
      if (response.statusCode == 200 || response.statusCode == 201) {
                clearDraftFromStorage();

        final responseData = response.data;

        Get.dialog(
          AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: 16),
                Text(
                  "Succès !",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  responseData['message'] ??
                      "Paiement effectué avec succès. Votre demande d'émission de carte virtuelle est en cours de traitement.",
                  textAlign: TextAlign.center,
                ),
                if (responseData['transaction'] != null) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Référence: ${responseData['transaction']['codeInterne']}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // ferme le dialog de succès
                    Get.back(); // revient à l'écran précédent
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorModel.Bluecolor242,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        _handleError(response);
      }
      MettreAjourDateSexe();
    } catch (e, stackTrace) {
      debugPrint('🌐🌐🌐🌐🌐Erreur demande émission: ${e.toString()}\n$stackTrace');

      if (e is DioException) {
        if (e.response?.statusCode == 422) {

          print('🌐🌐🌐🌐🌐 Erreur de validation reçue du serveur: ${e.response?.data}');
          final errorData = e.response?.data;
          String errorMessage = 'Erreur de validation';

          if (errorData is Map && errorData['error'] != null) {
            errorMessage = errorData['error'];
          } else if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
          if(errorMessage=="Solde insuffisant"){
              Get.to(() => RechargePage());
                SnackBarService.warning(title:'Erreur de validation','$errorMessage\nPrière de recharger votre compte de 3 000 F, puis de réessayer.');
                
          }else {
            Get.snackbar(
            'Erreur de validation',
            errorMessage,
            snackPosition: SnackPosition.TOP,
            snackStyle: SnackStyle.FLOATING,
            backgroundColor: Colors.orange.shade700,
            colorText: Colors.white,
            icon: Icon(Icons.warning_amber_rounded, color: Colors.white),
            margin: EdgeInsets.all(12),
            borderRadius: 12,
            duration: Duration(seconds: 4),
            isDismissible: true,
          );
          }
          
        } else if (e.response?.statusCode == 401) {
          Get.snackbar(
            'Session expirée',
            'Veuillez vous reconnecter',
            snackPosition: SnackPosition.TOP,
            snackStyle: SnackStyle.FLOATING,
            backgroundColor: Colors.red.shade700,
            colorText: Colors.white,
            icon: Icon(Icons.lock_outline, color: Colors.white),
            margin: EdgeInsets.all(12),
            borderRadius: 12,
            duration: Duration(seconds: 4),
            isDismissible: true,
          );
        } else {
          _handleError(e.response);
        }
      } else {
        Get.snackbar(
          'Erreur',
          'Une erreur s\'est produite. Veuillez réessayer.',
          snackPosition: SnackPosition.TOP,
          snackStyle: SnackStyle.FLOATING,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          icon: Icon(Icons.error_outline, color: Colors.white),
          margin: EdgeInsets.all(12),
          borderRadius: 12,
          duration: Duration(seconds: 4),
          isDismissible: true,
        );
      }

    
    } finally {
      isLoading.value = false;
    }
  }

// Méthode pour récupérer les frais d'émission

 MettreAjourDateSexe()async{
  final userCtrls = Get.find<UserMeController>();
     var deviceskey = await ValidationTokenController.to.getDeviceIMEI();
    var ip = await ValidationTokenController.to.getPublicIP();
      var genreApi=genre.value=='M'?2:1;
      var dateApi=(birthDateCtrl.text.trim());
      if (dateApi.isNotEmpty) {
  final parts = dateApi.split('/');
  if (parts.length == 3) {
    dateApi = "${parts[2]}-${parts[1]}-${parts[0]}"; // "2007-03-11"
  }
}
      print("😶‍🌫️😶‍🌫️ les donnees ne sont pas null   $genreApi   $dateApi");
            final String? token = box.read('token');
        final Map<String, dynamic> payload = {
                    'device': deviceskey,
                     'ip': ip,
                     'genre_id':genreApi.toString()
                     ,'date_naissance':''
                     };
  
      
        

         final url = '${ApiEnvironmentController.to.baseUrl}/user/update-profile';
      print("🌐 URL API : $url");
try {
  final resp = await http.patch(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
} catch (e) {
  
}
      
      
}
  Future<Map<String, dynamic>?> _getFraisEmission() async {
    try {
      final dio = Dio();
      final box = GetStorage();
      final String? token = box.read('auth_token');

      final response = await dio.get(
        '${ApiEnvironmentController.to.baseUrl}/frais-emission-carte-virtuelle',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Erreur récupération frais: $e');
    }
    return null;
  }

// Méthode pour gérer les erreurs
  void _handleError(dynamic response) {
    String errorMessage = 'Une erreur est survenue';

    if (response?.data != null) {
      final data = response.data;
      if (data is Map) {
        errorMessage = data['message'] ?? data['error'] ?? errorMessage;
      }
    }

    Get.snackbar(
      'Erreur',
      errorMessage,
      snackPosition: SnackPosition.TOP,
      snackStyle: SnackStyle.FLOATING,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      icon: Icon(Icons.error_outline, color: Colors.white),
      margin: EdgeInsets.all(12),
      borderRadius: 12,
      duration: Duration(seconds: 4),
      isDismissible: true,
    );
  }
}

/// ---------- WIDGET ----------
class CarteVirtuelle extends StatefulWidget {
  const CarteVirtuelle({super.key});
  @override
  State<CarteVirtuelle> createState() => _CarteVirtuelleState();
}

class _CarteVirtuelleState extends State<CarteVirtuelle> {
  final userCtrl = Get.put(UserMeController());
  final ctrl = Get.put(CarteVirtuelleController());

  @override
  void initState() {
    super.initState();
    Get.put(RechargeStatusController()).fetchRechargeStatus();
    userCtrl.loadMe();
    SecureTokenController.to.onInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        title: Text(
          "Validation de ma carte virtuelle",
          style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          NotificationWidget(),
        ],
      ),
      body: Obx(() {
        if (userCtrl.isLoading.value && userCtrl.user.value == null) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (userCtrl.errorMessage.isNotEmpty && userCtrl.user.value == null) {
          return _errorBox(userCtrl.errorMessage.value,
              onRetry: userCtrl.refreshMe);
        }
        if (userCtrl.user.value == null) {
          return _errorBox(
              "Impossible de récupérer les données. Vérifiez votre connexion.",
              onRetry: userCtrl.refreshMe);
        }

        // Hydrate les champs une seule fois quand user est dispo
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final u = userCtrl.user.value!;
          ctrl.hydrateFromUser(
            name: u.name,
            firstName: u.prenom,
            email: u.email,
            phone: u.telephone,
            address: u.adresse,
            dateNaissance: u.dateNaissance??null,
            genres: u.genreId.toString()??null,
          );
        });

        return _body();
      }),
    );
  }

  Widget _errorBox(String msg, {VoidCallback? onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(msg, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text("Réessayer"),
          ),
        ],
      ),
    );
  }

  Widget _body() => SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: ctrl.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Onyfast",
                    style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                Gap(1.h),
                Text(
                    "Veuillez vérifier soigneusement vos informations ci-dessous.",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                Gap(3.h),

                // Alerte champs manquants
                Obx(() {
                  ctrl.fieldsUpdated.value; // déclenche l’Obx
                  final missing = ctrl.getMissingFields();
                  if (missing.isEmpty) return const SizedBox.shrink();
                  return Container(
                    width: 100.w,
                    margin: EdgeInsets.only(bottom: 3.h),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 5.w),
                        Gap(3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Informations incomplètes",
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red[800])),
                              Text("${missing.length} champ(s) manquant(s)",
                                  style: TextStyle(
                                      fontSize: 11.sp, color: Colors.red[700])),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => _showMissingFieldsDialog(missing),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text("Compléter",
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Lignes d'informations
                Obx(() {
                  ctrl.fieldsUpdated.value;
                  return Column(
                    children: [
                      _infoRow("Nom(s)", ctrl.nameCtrl.text, Icons.person,
                          readOnly: false),
                      _infoRow("Prénom(s)", ctrl.firstNameCtrl.text,
                          Icons.person_outline,
                          readOnly: false),
                      _infoRow("Genre", ctrl.genre.value, Icons.wc,
                          readOnly: false, isDropdownGenre: true),
                      _infoRow("Date de naissance", ctrl.birthDateCtrl.text,
                          Icons.cake,
                          readOnly: true, isBirthPicker: true),
                      _infoRow(
                          "Pays", ctrl.selectedCountryName.value, Icons.public,
                          readOnly: false, isCountry: true),
                      _infoRow("Département", ctrl.selectedDepartmentName.value,
                          Icons.map,
                          readOnly: false, isDepartment: true),
                      _infoRow("Ville", ctrl.selectedCityName.value,
                          Icons.location_city,
                          readOnly: false, isCity: true),
                      _infoRow("Adresse", ctrl.addressCtrl.text, Icons.home,
                          readOnly: false),
                      _infoRow("Téléphone", ctrl.phoneCtrl.text, Icons.phone,
                          readOnly: false, keyboard: TextInputType.phone),
                      _infoRow("Autre numéro", ctrl.altPhoneCtrl.text,
                          Icons.phone_in_talk,
                          readOnly: false, keyboard: TextInputType.phone),
                      _infoRow("Email", ctrl.emailCtrl.text, Icons.email,
                          readOnly: false,
                          keyboard: TextInputType.emailAddress),
                      _infoRow("Code de Parrain", ctrl.codeParrainCtrl.text, Icons.people_outline,
    readOnly: false, keyboard: TextInputType.text),
                    ],
                  );
                }),

                // Gap(3.h),

                // // Info frais
                // Container(
                //   width: 100.w,
                //   padding: EdgeInsets.all(4.w),
                //   decoration: BoxDecoration(
                //     color: Colors.blue[50],
                //     borderRadius: BorderRadius.circular(8),
                //     border: Border.all(color: Colors.blue[200]!),
                //   ),
                //   child: Row(
                //     children: [
                //       Icon(Icons.info_outline, color: Colors.blue, size: 5.w),
                //       Gap(3.w),
                //       Expanded(
                //         child: Text(
                //           "Un montant de 3 000 FCFA sera débité de votre wallet.",
                //           style: TextStyle(fontSize: 11.sp, color: Colors.blue[800]),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Gap(4.h),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        final disabled = ctrl.isLoading.value;
                        return InkWell(
                          onTap: disabled ? null : () {
                            // Sauvegarder avant de quitter
                            ctrl.saveDraftToStorage();
                            Get.back();
                          },
                          child: Container(
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: disabled
                                  ? Colors.grey[300]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text("Retour",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        );
                      }),
                    ),
                    Gap(3.w),
                    Expanded(
                      flex: 2,
                      child: Obx(() {
                        ctrl.fieldsUpdated.value;
                        final canSubmit = ctrl.getMissingFields().isEmpty;
                        final busy = ctrl.isLoading.value;
                        return InkWell(
                          onTap: (canSubmit && !busy)
                              ? () async {
                                  ctrl.isLoading.value = true;
                                  await ctrl
                                      .submit(); // <-- attend la fin correctement
                                }
                              : null,
                          child: Container(
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: (canSubmit && !busy)
                                  ? AppColorModel.Bluecolor242
                                  : Colors.grey[400],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: busy
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 4.w,
                                          height: 4.w,
                                          child:
                                              const CupertinoActivityIndicator(
                                                  color: Colors.white,
                                                  radius: 15),
                                        ),
                                        Gap(2.w),
                                        Text("Traitement...",
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    )
                                  : Text("Créer ma carte",
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                Gap(2.h),
              ],
            ),
          ),
        ),
      );

  Widget _infoRow(
    String label,
    String value,
    IconData icon, {
    bool readOnly = false,
    bool isBirthPicker = false,
    bool isDropdownGenre = false,
    bool isCountry = false,
    bool isDepartment = false,
    bool isCity = false,
    TextInputType? keyboard,
  }) {
    final hasError = ctrl.hasFieldErrorByLabel(label);
    final isEmpty = (value).isEmpty;
    final isSelect = isCountry || isDepartment || isCity || isDropdownGenre;
    final isOptionalField = label == "Autre numéro" || label == "Code de Parrain";
final showEditable = !readOnly &&
    (isEmpty || hasError || isOptionalField) &&
    !isBirthPicker &&
    !isDropdownGenre &&
    !isSelect;


    return Container(
      width: 100.w,
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        // Ligne 1753 - remplacez cette condition
        border: Border.all(
            color: (isEmpty && !isOptionalField) || hasError ? Colors.red[300]! : Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, top: 2.w, right: 4.w),
            child: Text(label=="Code de Parrain" ? "Code de parrainage (facultatif)" : label,
                style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
            child: Row(
              children: [
                Icon(icon,
                    color:
                        (isEmpty || hasError) ? Colors.red : Colors.grey[600],
                    size: 5.w),
                Gap(3.w),
                Expanded(
                  child: isCountry
                      ? _countrySelect()
                      : isDepartment
                          ? _departmentSelect()
                          : isCity
                              ? _citySelect()
                              : isDropdownGenre
                                  ? _genreDropdown()
                                  : isBirthPicker
                                      ? _birthPickerField()
                                      : showEditable
                                          ? _editableField(label,
                                              keyboard: keyboard)
                                          : Text(
                                              isEmpty ? "Non renseigné" : value,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: isEmpty
                                                    ? Colors.red[600]
                                                    : Colors.black87,
                                                fontStyle: isEmpty
                                                    ? FontStyle.italic
                                                    : FontStyle.normal,
                                              ),
                                            ),
                ),
               if (readOnly && !isBirthPicker)
  Icon(Icons.lock_outline, color: Colors.grey[500], size: 4.w)
else if ((isEmpty || hasError) && !isOptionalField)
  const Icon(Icons.edit_outlined, color: Colors.red)
else if (isOptionalField && !readOnly)
  Icon(Icons.edit_outlined, color: Colors.grey[400]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----- Widgets Selects -----
  Widget _countrySelect() {
    return Obx(() {
      if (ctrl.isCountriesLoading.value)
        return const LinearProgressIndicator(minHeight: 2);
      if (ctrl.countryLoadError.isNotEmpty) {
        return Row(
          children: [
            Expanded(
                child: Text(ctrl.countryLoadError.value,
                    style: const TextStyle(color: Colors.red))),
            TextButton(
                onPressed: ctrl.fetchCountries, child: const Text("Réessayer")),
          ],
        );
      }

      final allowed = ctrl.countries.map((o) => o.id).toSet();
      final safeValue = allowed.contains(ctrl.selectedCountryId.value)
          ? ctrl.selectedCountryId.value
          : null;

      return DropdownButtonFormField<String>(
        initialValue: safeValue,
        isExpanded: true,
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Sélectionner le pays",
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        ),
        items: ctrl.countries
            .map((o) =>
                DropdownMenuItem<String>(value: o.id, child: Text(o.name)))
            .toList(),
        onChanged: (id) {
          final opt = ctrl.countries.firstWhereOrNull((e) => e.id == id);
          ctrl.onCountrySelected(opt);
        },
        validator: (_) =>
            ctrl.validateSelect(ctrl.selectedCountryId.value, label: "Pays"),
      );
    });
  }

  Widget _departmentSelect() {
    return Obx(() {
      if (ctrl.selectedCountryId.value == null) {
        return const Text("Sélectionnez d'abord un pays");
      }
      if (ctrl.isDepartmentsLoading.value) {
        return const LinearProgressIndicator(minHeight: 2);
      }
      if (ctrl.departmentLoadError.isNotEmpty) {
        return Row(
          children: [
            Expanded(
                child: Text(ctrl.departmentLoadError.value,
                    style: const TextStyle(color: Colors.red))),
            TextButton(
              onPressed: () =>
                  ctrl.fetchDepartments(ctrl.selectedCountryId.value!),
              child: const Text("Réessayer"),
            ),
          ],
        );
      }

      final allowed = ctrl.departments.map((o) => o.id).toSet();
      final safeValue = allowed.contains(ctrl.selectedDepartmentId.value)
          ? ctrl.selectedDepartmentId.value
          : null;

      return DropdownButtonFormField<String>(
        initialValue: safeValue,
        isExpanded: true,
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Sélectionner le département",
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        ),
        items: ctrl.departments
            .map((o) =>
                DropdownMenuItem<String>(value: o.id, child: Text(o.name)))
            .toList(),
        onChanged: (id) {
          final opt = ctrl.departments.firstWhereOrNull((e) => e.id == id);
          ctrl.onDepartmentSelected(opt);
        },
        validator: (_) => ctrl.validateSelect(ctrl.selectedDepartmentId.value,
            label: "Département"),
      );
    });
  }

  Widget _citySelect() {
    return Obx(() {
      if (ctrl.selectedDepartmentId.value == null) {
        return const Text("Sélectionnez d'abord un département");
      }
      if (ctrl.isCitiesLoading.value)
        return const LinearProgressIndicator(minHeight: 2);
      if (ctrl.cityLoadError.isNotEmpty) {
        return Row(
          children: [
            Expanded(
                child: Text(ctrl.cityLoadError.value,
                    style: const TextStyle(color: Colors.red))),
            TextButton(
              onPressed: () {
                final cid = ctrl.selectedCountryId.value!;
                final did = ctrl.selectedDepartmentId.value!;
                ctrl.fetchCities(cid, did);
              },
              child: const Text("Réessayer"),
            ),
          ],
        );
      }

      final allowed = ctrl.cities.map((o) => o.id).toSet();
      final safeValue = allowed.contains(ctrl.selectedCityId.value)
          ? ctrl.selectedCityId.value
          : null;

      return DropdownButtonFormField<String>(
        initialValue: safeValue,
        isExpanded: true,
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Sélectionner la ville",
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        ),
        items: ctrl.cities
            .map((o) =>
                DropdownMenuItem<String>(value: o.id, child: Text(o.name)))
            .toList(),
        onChanged: (id) {
          final opt = ctrl.cities.firstWhereOrNull((e) => e.id == id);
          ctrl.onCitySelected(opt);
        },
        validator: (_) =>
            ctrl.validateSelect(ctrl.selectedCityId.value, label: "Ville"),
      );
    });
  }

  Widget _genreDropdown() {
    return Obx(() {
      return DropdownButtonFormField<String>(
        initialValue: ctrl.genre.value.isEmpty ? null : ctrl.genre.value,
        isExpanded: true,
        dropdownColor: Colors.white,
        decoration: const InputDecoration(
            border: InputBorder.none, hintText: "Sélectionner le genre"),
        items: const ['M', 'F']
            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) {
          if (val != null) {
            ctrl.genre.value = val;
            ctrl.fieldsUpdated.value++;
          }
        },
        validator: (_) => ctrl.validateGenre(ctrl.genre.value),
      );
    });
  }

  Widget _birthPickerField() {
    return TextFormField(
      controller: ctrl.birthDateCtrl,
      focusNode: ctrl.birthNode,
      readOnly: true,
      showCursor: false,
      keyboardType: TextInputType.none,
      validator: (_) => ctrl.validateBirth(ctrl.birthDateCtrl.text),
      onTap: () => ctrl.pickBirthDate(context),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "JJ/MM/AAAA",
        hintStyle: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[400],
            fontStyle: FontStyle.italic),
        suffixIcon: IconButton(
          tooltip: "Choisir une date",
          icon: const Icon(Icons.calendar_month),
          onPressed: () => ctrl.pickBirthDate(context),
        ),
      ),
      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
    );
  }

  Widget _editableField(String label, {TextInputType? keyboard}) {
    TextEditingController? getController() {
      switch (label) {
        case "Nom(s)":
          return ctrl.nameCtrl;
        case "Prénom(s)":
          return ctrl.firstNameCtrl;
        case "Adresse":
          return ctrl.addressCtrl;
        case "Téléphone":
          return ctrl.phoneCtrl;
        case "Autre numéro":
          return ctrl.altPhoneCtrl;
        case "Email":
          return ctrl.emailCtrl;
        case "Code de Parrain":
          return ctrl.codeParrainCtrl;
      }
      return null;
    }

    FocusNode? getNode() {
      switch (label) {
        case "Nom(s)":
          return ctrl.nameNode;
        case "Prénom(s)":
          return ctrl.firstNameNode;
        case "Adresse":
          return ctrl.addressNode;
        case "Téléphone":
          return ctrl.phoneNode;
        case "Autre numéro":
          return ctrl.altPhoneNode;
        case "Email":
          return ctrl.emailNode;
        case "Code de Parrain":
          return ctrl.codeParrainNode;
      }
      return null;
    }

    String? validator(_) {
      switch (label) {
        case "Nom(s)":
          return ctrl.validateNonVide(ctrl.nameCtrl.text, label: "Nom");
        case "Prénom(s)":
          return ctrl.validateNonVide(ctrl.firstNameCtrl.text, label: "Prénom");
        case "Adresse":
          return ctrl.validateNonVide(ctrl.addressCtrl.text, label: "Adresse");
        case "Téléphone":
          return ctrl.validatePhone(ctrl.phoneCtrl.text);
        case "Autre numéro":
          return ctrl.validateAltPhone(ctrl.altPhoneCtrl.text);
        case "Email":
          return ctrl.validateEmail(ctrl.emailCtrl.text);
        case "Code de Parrain":
          return ctrl.validateCodeParrain(ctrl.codeParrainCtrl.text);
      }
      return null;
    }

    final inputFormatters = <TextInputFormatter>[
      if (label == "Téléphone" || label == "Autre numéro")
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
    ];

    return TextFormField(
      controller: getController(),
      focusNode: getNode(),
      keyboardType: keyboard,
      textInputAction: TextInputAction.next,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: (_) => ctrl.fieldsUpdated.value++,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "Touchez pour saisir",
        hintStyle: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[400],
            fontStyle: FontStyle.italic),
        suffixIcon: IconButton(
          tooltip: "Effacer",
          icon: const Icon(Icons.clear),
          onPressed: () {
            getController()?.clear();
            ctrl.fieldsUpdated.value++;
          },
        ),
      ),
      enableInteractiveSelection: true,
      autocorrect: false,
      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
    );
  }

  void _showMissingFieldsDialog(List<String> missingFields) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text("Compléter les informations",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Veuillez remplir les champs suivants :",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
                Gap(2.h),
                ...List.generate(missingFields.length, (i) {
                  final f = missingFields[i];
                  final isLast = i == missingFields.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 2.h),
                    child: _missingFieldInput(f),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text("Annuler",
                  style: TextStyle(
                      color: Colors.grey[600], fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                ctrl.fieldsUpdated.value++;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorModel.Bluecolor242,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text("Sauvegarder",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _missingFieldInput(String fieldName) {
    if (fieldName == "Pays") return _countrySelect();
    if (fieldName == "Département") return _departmentSelect();
    if (fieldName == "Ville") return _citySelect();
    if (fieldName == "Genre") {
      return DropdownButtonFormField<String>(
        initialValue: ctrl.genre.value.isEmpty ? null : ctrl.genre.value,
        decoration: InputDecoration(
          labelText: fieldName,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        ),
        items: const ['M', 'F']
            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
            .toList(),
        onChanged: (v) {
          if (v != null) {
            ctrl.genre.value = v;
            ctrl.fieldsUpdated.value++;
          }
        },
        validator: (_) => ctrl.validateGenre(ctrl.genre.value),
      );
    }
    if (fieldName == "Date de naissance") {
      return TextFormField(
        controller: ctrl.birthDateCtrl,
        readOnly: true,
        onTap: () => ctrl.pickBirthDate(context),
        validator: (_) => ctrl.validateBirth(ctrl.birthDateCtrl.text),
        decoration: InputDecoration(
          labelText: fieldName,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
      );
    }

    TextEditingController? c;
    TextInputType type = TextInputType.text;
    switch (fieldName) {
      case "Nom":
        c = ctrl.nameCtrl;
        break;
      case "Prénom":
        c = ctrl.firstNameCtrl;
        break;
      case "Adresse":
        c = ctrl.addressCtrl;
        break;
      case "Téléphone":
        c = ctrl.phoneCtrl;
        type = TextInputType.phone;
        break;
      case "Autre numéro":
        c = ctrl.altPhoneCtrl;
        type = TextInputType.phone;
        break;
      case "Code de Parrain":
        c = ctrl.codeParrainCtrl;
        type = TextInputType.text;
        break;
      case "Email":
        c = ctrl.emailCtrl;
        type = TextInputType.emailAddress;
        break;
    }
    if (c != null) {
      return TextFormField(
        controller: c,
        keyboardType: type,
        onChanged: (_) => ctrl.fieldsUpdated.value++,
        decoration: InputDecoration(
          labelText: fieldName,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
