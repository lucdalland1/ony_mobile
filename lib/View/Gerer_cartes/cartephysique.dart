import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <= pour les inputFormatters
import 'package:flutter_contacts/diacritics.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/carte/cartephysiquecontroller.dart';
import 'package:onyfast/Controller/features/features_controller.dart';
import 'package:onyfast/Controller/info_user/usercontroller.dart';
import 'package:onyfast/View/Notification/notification.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:onyfast/utils/testInternet.dart';

// Contrôleur GetX pour la validation
class CartePhysiqueController extends GetxController {
  final formKey = GlobalKey<FormState>();
final box = GetStorage();
  static const String STORAGE_KEY = 'carte_physique_draft';
  
  // Timer pour la sauvegarde automatique
  Timer? _autoSaveTimer;
  // Controllers pour les champs
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final identifiantController = TextEditingController();
  final dernierChiffresController = TextEditingController();
  final expireController = TextEditingController();
  final emailController = TextEditingController();
  final telephonecontroller=TextEditingController();

  // FocusNodes pour la redirection
  final nomFocusNode = FocusNode();
  final prenomFocusNode = FocusNode();
  final identifiantFocusNode = FocusNode();
  final dernierChiffresFocusNode = FocusNode();
  final expireFocusNode = FocusNode();
  final emailFocusNode = FocusNode();

  // Variable pour le chargement
  var isLoading = false.obs;
  
  // Observable pour déclencher les mises à jour de l'interface
  var fieldsUpdated = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUserData();
     Future.delayed(const Duration(milliseconds: 300), () {
      loadDraftFromStorage();
    });
    
    // Configurer l'auto-save
    _setupAutoSave();
  }

  // Méthode pour initialiser les données utilisateur
  void _initializeUserData() {
    nomController.text = "DUPONT"; 
    prenomController.text = "Jean"; 
    emailController.text = "jean.dupont@example.com";
    telephonecontroller.text="242057773993";
    fieldsUpdated.value++; // Déclencher la mise à jour
  }

  // Méthode pour mettre à jour les champs utilisateur
  void updateUserData(String nom, String prenom, String email,String tel) {
    nomController.text = nom;
    prenomController.text = prenom;
    emailController.text = email;
    telephonecontroller.text=tel;
    fieldsUpdated.value++; // Déclencher la mise à jour
  }

  // Vérifier les champs manquants
  List<String> getMissingFields() {
    List<String> missingFields = [];
    
    if (nomController.text.isEmpty) missingFields.add("Nom");
    if (prenomController.text.isEmpty) missingFields.add("Prénom");
    if (identifiantController.text.isEmpty) missingFields.add("Identifiant");
    if (dernierChiffresController.text.isEmpty) missingFields.add("4 derniers chiffres");
    if (expireController.text.isEmpty) missingFields.add("Date d'expiration");
    if (emailController.text.isEmpty) missingFields.add("Email");
    
    return missingFields;
  }

  @override
  void onClose() {

      _autoSaveTimer?.cancel(); // ← Annuler le timer

    nomController.dispose();
    prenomController.dispose();
    identifiantController.dispose();
    dernierChiffresController.dispose();
    expireController.dispose();
    emailController.dispose();
    
    nomFocusNode.dispose();
    prenomFocusNode.dispose();
    identifiantFocusNode.dispose();
    dernierChiffresFocusNode.dispose();
    expireFocusNode.dispose();
    emailFocusNode.dispose();
    
    super.onClose();
  }

  // Validation des champs
  String? validateNom(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom est requis';
    }
    return null;
  }

  String? validatePrenom(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le prénom est requis';
    }
    return null;
  }
void _setupAutoSave() {
    // Écouter les changements sur les champs éditables
    identifiantController.addListener(_triggerAutoSave);
    dernierChiffresController.addListener(_triggerAutoSave);
    expireController.addListener(_triggerAutoSave);
  }

  /// Déclenche la sauvegarde avec un délai (debounce)
  void _triggerAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      saveDraftToStorage();
    });
  }

  /// Sauvegarde les champs éditables
  void saveDraftToStorage() {
    try {
      final draftData = {
        'identifiant': identifiantController.text.trim(),
        'derniers_chiffres': dernierChiffresController.text.trim(),
        'expire': expireController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      box.write(STORAGE_KEY, draftData);
      print('✅ Brouillon sauvegardé automatiquement (Identifiant, 4 derniers chiffres, Date expiration)');
    } catch (e) {
      print('❌ Erreur sauvegarde: $e');
    }
  }

  /// Charge le brouillon depuis le storage
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
          return;
        }
      }

      print('🔄 Restauration du brouillon...');

      // Restaurer les champs
      if (draftData['identifiant'] != null && draftData['identifiant'].toString().isNotEmpty) {
        identifiantController.text = draftData['identifiant'];
        print('  ✓ Identifiant: ${draftData['identifiant']}');
      }
      
      if (draftData['derniers_chiffres'] != null && draftData['derniers_chiffres'].toString().isNotEmpty) {
        dernierChiffresController.text = draftData['derniers_chiffres'];
        print('  ✓ 4 derniers chiffres: ${draftData['derniers_chiffres']}');
      }
      
      if (draftData['expire'] != null && draftData['expire'].toString().isNotEmpty) {
        expireController.text = draftData['expire'];
        print('  ✓ Date expiration: ${draftData['expire']}');
      }

      fieldsUpdated.value++;
      
      // Afficher un message à l'utilisateur
      // Future.delayed(const Duration(seconds: 1), () {
      //   Get.snackbar(
      //     'Brouillon restauré',
      //     'Vos informations de carte ont été récupérées',
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
  String? validateIdentifiant(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'identifiant est requis';
    }
    if (value.length !=8) {
      return 'L\'identifiant doit contenir exactement 8 chiffres';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'L\'identifiant ne doit contenir que des chiffres';
    }
    return null;
  }

  String? validateDernierChiffres(String? value) {
    if (value == null || value.isEmpty) {
      return 'Les 4 derniers chiffres sont requis';
    }
    if (value.length != 4) {
      return 'Doit contenir exactement 4 chiffres';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Ne doit contenir que des chiffres';
    }
    return null;
  }

  String? validateExpire(String? value) {
    if (value == null || value.isEmpty) {
      return 'La date d\'expiration est requise';
    }
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
      return 'Format requis : MM/YY';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  // ---- AJOUTS MINIMAUX : helpers focus + check global ----
  void _focus(FocusNode node) {
    final ctx = Get.context;
    if (ctx != null) FocusScope.of(ctx).requestFocus(node);
  }

  void _toast(String msg) {
    SnackBarService.warning(msg);
  }

  /// Retourne false si un champ est invalide et place le focus dessus.
  bool validateAllAndRedirect() {
    final idErr   = validateIdentifiant(identifiantController.text);
    final l4Err   = validateDernierChiffres(dernierChiffresController.text);
    final expErr  = validateExpire(expireController.text);
    final mailErr = validateEmail(emailController.text);

    if (idErr != null)   { _focus(identifiantFocusNode); _toast('Veuillez corriger l\'identifiant (8 chiffres requis)'); return false; }
    if (l4Err != null)   { _focus(dernierChiffresFocusNode); _toast('Veuillez corriger les 4 derniers chiffres'); return false; }
    if (expErr != null)  { _focus(expireFocusNode); _toast('Veuillez corriger la date d\'expiration (MM/YY)'); return false; }
    if (mailErr != null) { _focus(emailFocusNode); _toast('Veuillez fournir un email valide'); return false; }
    return true;
  }

  /// NEW: permet de savoir si un champ (par label) a une erreur => le rendre éditable.
  bool hasFieldErrorByLabel(String label) {
    if (label == "Identifiant (face arrière) - 8 chiffres") {
      return validateIdentifiant(identifiantController.text) != null;
    } else if (label == "4 derniers chiffres (face avant)") {
      return validateDernierChiffres(dernierChiffresController.text) != null;
    } else if (label == "Expire en (MM/YY)") {
      return validateExpire(expireController.text) != null;
    } else if (label == "Email") {
      return validateEmail(emailController.text) != null;
    }
    return false;
  }
  // --------------------------------------------------------

  // Méthode pour soumettre le formulaire

  String cleanText(String input) {
  // 1. Supprime les accents (é → e, à → a, ô → o, ñ → n, etc.)
  String withoutAccents = removeDiacritics(input);

  // 2. Supprime tous les caractères spéciaux sauf lettres/chiffres/espaces
  return withoutAccents.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
}
  void submitForm() async {
    final emmettreCartePhysiqueController = Get.find<EmmettreCartePhysiqueController>();


    if (formKey.currentState!.validate()) {
      // Garde-fou : bloque si un champ est invalide et redirige le focus
      if (!validateAllAndRedirect()) return;

      isLoading.value = true;


      bool isConnected = await hasInternetConnection();

      if (isConnected) {
        print('Connexion Internet disponible');
      } else {
        SnackBarService.error('Pas de connexion Internet');
        isLoading.value = false;
        return;
      }

      final service = FeaturesService();

        final isActive = await service.isFeatureActive(AppFeature.ajoutCartePhysique);

        if (isActive) {
          print('✅ Ajout de la carte actuellement dispo');
        } else {
          Get.back();
          isLoading.value = false;
          SnackBarService.error('❌ Ce service est momentanément indisponible');

          return;
        }


      try {
  print("nom   ${cleanText(nomController.text)}");
  print("prenom   ${cleanText(prenomController.text)}");
  
  var headers = {'Accept': 'application/json'};
  var dio = Dio();

  final url = Uri.https(
    "api.dev.onyfastbank.com",
    "/v1/admin-users.php",
    {
      "method": "add_card",
      "phone": telephonecontroller.text,
      "cardID": identifiantController.text,
      "email": emailController.text,
      "cardLast4Digits": dernierChiffresController.text,
      "cardExpireAt": expireController.text,
      "firstName": cleanText(nomController.text),
      "lastName": cleanText(prenomController.text),
    },
  ).toString();

  print("URL générée : $url");
  print("Appel en cours...");

  // ⬇️ Options ajoutées pour éviter FormatException et voir le body même en 4xx/5xx
  final res = await dio.get(
    url,
    options: Options(
      headers: headers,
      receiveDataWhenStatusError: true,
      validateStatus: (_) => true,
      responseType: ResponseType.plain, // on lit d’abord comme du texte
    ),
  );

  print("Réponse reçue (status: ${res})");           // <-- gardé
  print("Status code: ${res.statusCode}");           // <-- ajout info lisible
  print("Content-Type: ${res.headers.value('content-type')}");

  // ⬇️ Normalisation en Map si possible
  dynamic data = res.data;
  Map<String, dynamic>? json;
  if (data is String) {
    final body = data.trim();
    // On tente de parser uniquement si ça ressemble à du JSON
    if (body.startsWith('{') || body.startsWith('[')) {
      try {
        json = jsonDecode(body) as Map<String, dynamic>?;
      } catch (_) {
        // Pas du JSON valide → on laisse json = null
      }
    }
  } else if (data is Map) {
    json = Map<String, dynamic>.from(data as Map);
  }

  // Par sécurité, si jamais c’est resté une String, on imprime un extrait
  if (json == null) {
    final s = (data ?? '').toString();
    print('BODY (200c max): ${s.substring(0, s.length > 200 ? 200 : s.length)}');
  }

  // ⬇️ Accès safe à status.code (évite les crashs si la structure change)
  int? code;
  if (json != null) {
    final status = json['status'];
    if (status is Map && status['code'] != null) {
      // le code peut être un int ou une string
      final raw = status['code'];
      if (raw is int) {
        code = raw;
      } else if (raw is String) {
        code = int.tryParse(raw);
      }
    }
  }

  // On garde ta ligne d’origine mais on la protège pour éviter FormatException
  try {
    print("Réponse reçue (status: ${json?['status']?['code']})");
  } catch (_) {
    print("Réponse reçue (status: --)");
  }

  if (res.statusCode == 200) {
    if (code == 404) {
      _clearForm();
      showAlert("Erreur", "Carte non trouvée", isError: true);
      print("carte non trouvée");
      return;
    }
    if (code == 401) {
      _clearForm();
      showAlert("Erreur", "Identifiant incorrect", isError: true);
      print("carte non trouvée");
      return;
    }

    showAlert("Succès", "Carte ajoutée avec succès", isError: false);
      clearDraftFromStorage();
  }

} catch (e) {
  print(e.toString());
  SnackBarService.warning(
    'Une erreur s\'est produite',
   
  );
} finally {
  isLoading.value = false;
}

    } else {
      _redirectToFirstErrorField();
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 15.w,
            ),
            Gap(2.h),
            Text(
              "Succès !",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap(1.h),
            Text(
              "Votre carte physique a été ajoutée avec succès.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorModel.Bluecolor242,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _clearForm() {
    identifiantController.clear();
    dernierChiffresController.clear();
    expireController.clear();
    fieldsUpdated.value++; // Déclencher la mise à jour
  }

  void _redirectToFirstErrorField() {
    if (validateIdentifiant(identifiantController.text) != null) {
      FocusScope.of(Get.context!).requestFocus(identifiantFocusNode);
      SnackBarService.error(
        'Veuillez corriger l\'identifiant (8 chiffres requis)',
      );
    } else if (validateDernierChiffres(dernierChiffresController.text) != null) {
      FocusScope.of(Get.context!).requestFocus(dernierChiffresFocusNode);
      SnackBarService.error(
        'Veuillez corriger les 4 derniers chiffres',
      );
    } else if (validateExpire(expireController.text) != null) {
      FocusScope.of(Get.context!).requestFocus(expireFocusNode);
      SnackBarService.error(
        'Veuillez corriger la date d\'expiration (format MM/YY)',
      );
    }
  }
}

class CartePhysique extends StatefulWidget {
  const CartePhysique({super.key});

  @override
  State<CartePhysique> createState() => _CartePhysiqueState();
}

class _CartePhysiqueState extends State<CartePhysique> {
  final CartePhysiqueController controller = Get.put(CartePhysiqueController());
  final userCtrl = Get.put(UserMeController());

  @override
  void initState() { 
    super.initState();
    userCtrl.loadMe();

  //   Future.delayed(const Duration(milliseconds: 300), () {
  //   // loadDraftFromStorage();
  // });
  
  // Configurer l'auto-save
  // _setupAutoSave();
  
  }

  @override
  void dispose() {
    // Ne pas disposer les contrôleurs GetX ici, ils se gèrent automatiquement
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        title: Text(
          "Ajouter ma carte Physique",
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          NotificationWidget()
        ],
      ),
      body: Obx(() {
        if (userCtrl.isLoading.value && userCtrl.user.value == null) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (userCtrl.errorMessage.isNotEmpty && userCtrl.user.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  userCtrl.errorMessage.value.isNotEmpty
                      ? "Vous n'êtes pas connecté"
                      : "Impossible de récupérer les données. Vérifiez votre connexion.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => userCtrl.refreshMe(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Réessayer"),
                ),
              ],
            ),
          );
        }
        if (userCtrl.user.value == null) return const SizedBox.shrink();
          print('voila son numero au niveau du chargement ${userCtrl.user.value!.telephone}');
        // Mettre à jour les données utilisateur dans le contrôleur
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (userCtrl.user.value != null) {
            controller.updateUserData(
              userCtrl.user.value!.name ?? "",
              userCtrl.user.value!.prenom ?? "",
              userCtrl.user.value!.email ?? "",
              userCtrl.user.value!.telephone ?? "",
            );
          }
        });

        return body();
      }),
    );
  }
/// Configure la sauvegarde automatique
// void _setupAutoSave() {
//   // Écouter les changements sur les champs éditables
//   identifiantController.addListener(_triggerAutoSave);
//   dernierChiffresController.addListener(_triggerAutoSave);
//   expireController.addListener(_triggerAutoSave);
// }

// /// Déclenche la sauvegarde avec un délai (debounce)
// void _triggerAutoSave() {
//   _autoSaveTimer?.cancel();
//   _autoSaveTimer = Timer(const Duration(seconds: 2), () {
//     saveDraftToStorage();
//   });
// }

// /// Sauvegarde les champs éditables
// void saveDraftToStorage() {
//   try {
//     final draftData = {
//       'identifiant': identifiantController.text.trim(),
//       'derniers_chiffres': dernierChiffresController.text.trim(),
//       'expire': expireController.text.trim(),
//       'timestamp': DateTime.now().toIso8601String(),
//     };

//     box.write(STORAGE_KEY, draftData);
//     print('✅ Brouillon sauvegardé automatiquement (Identifiant, 4 derniers chiffres, Date expiration)');
//   } catch (e) {
//     print('❌ Erreur sauvegarde: $e');
//   }
// }


/// Supprime le brouillon du local storage
// void clearDraftFromStorage() {
//   try {
//     box.remove(STORAGE_KEY);
//     print('🗑️ Brouillon supprimé');
//   } catch (e) {
//     print('❌ Erreur suppression: $e');
//   }
// }

/// Vérifie s'il existe un brouillon sauvegardé
// bool hasDraft() {
//   return box.hasData(STORAGE_KEY);
// }
  Widget body() => SingleChildScrollView(
    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
    child: GestureDetector(
      onTap: () => FocusScope.of(Get.context!).unfocus(),
      child:Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre et sous-titre
        Text(
          "Onyfast",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Gap(1.h),
        Text(
          "Ajoutez votre carte physique en remplissant soigneusement les champs ci-dessous.",
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        Gap(3.h),

        // Alerte pour champs manquants - Wrapped in separate Obx
        Obx(() {
          // Observer fieldsUpdated pour déclencher le recalcul
          controller.fieldsUpdated.value; // Cette ligne déclenche l'observation
          
          final missingFields = controller.getMissingFields();
          if (missingFields.isNotEmpty) {
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
                  const Icon(Icons.warning, color: Colors.red),
                  Gap(3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Informations incomplètes",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[800],
                          ),
                        ),
                        Text(
                          "${missingFields.length} champ(s) manquant(s)",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _showMissingFieldsDialog(missingFields),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Compléter",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // Champs d'information - Wrapped in separate Obx
        Obx(() {
          // Observer fieldsUpdated pour déclencher le recalcul
          controller.fieldsUpdated.value; // Cette ligne déclenche l'observation
          
          return Form(
            key: controller.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction, // <= NEW: erreurs en direct
            child: Column(
              children: [
                _buildInfoField(
                  "Nom(s)", 
                  controller.nomController.text, 
                  Icons.person,
                  isReadOnly: true,
                  isEmpty: controller.nomController.text.isEmpty,
                ),
                _buildInfoField(
                  "Prénom(s)", 
                  controller.prenomController.text, 
                  Icons.person_outline,
                  isReadOnly: true,
                  isEmpty: controller.prenomController.text.isEmpty,
                ),
                _buildInfoField(
                  "Identifiant (face arrière) - 8 chiffres", 
                  controller.identifiantController.text, 
                  Icons.credit_card,
                  // isReadOnly: true,
                  helper: "⚠️ Les 8 chiffres en bas sur la face arrière de la carte.",
                  isEmpty: controller.identifiantController.text.isEmpty,
                ),
                _buildInfoField(
                  "4 derniers chiffres (face avant)", 
                  controller.dernierChiffresController.text, 
                  Icons.lock_outline,
                  // isReadOnly: true,
                  helper: "⚠️ Les 4 derniers chiffres des 16 au recto de la carte.",
                  isEmpty: controller.dernierChiffresController.text.isEmpty,
                ),
                _buildInfoField(
                  "Expire en (MM/YY)", 
                  controller.expireController.text, 
                  Icons.calendar_today,
                  // isReadOnly: true,
                  helper: "🔍 Visible sous 'VALID THRU' sur la carte.",
                  // isEmpty: controller.expireController.text.isEmpty,
                ),
                _buildInfoField(
                  "Email", 
                  controller.emailController.text, 
                  Icons.email,
                  isReadOnly: true,
                  isEmpty: controller.emailController.text.isEmpty,
                ),
                 _buildInfoField(
                  "Telephone", 
                  controller.telephonecontroller.text, 
                  Icons.phone,
                  isReadOnly: true,
                  isEmpty: controller.telephonecontroller.text.isEmpty,
                ),
              ],
            ),
          );
        }),

        Gap(3.h),

        // Information sur les frais
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
        //       Icon(
        //         Icons.info_outline,
        //         color: Colors.blue,
        //         size: 5.w,
        //       ),
        //       Gap(3.w),
        //       Expanded(
        //         child: Text(
        //           "Aucun frais ne sera débité pour ajouter votre carte physique.",
        //           style: TextStyle(
        //             fontSize: 11.sp,
        //             color: Colors.blue[800],
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        Gap(4.h),

        // Boutons d'action - Wrapped in separate Obx
        Row(
          children: [
            // Bouton Retour
            Expanded(
              child: InkWell(
                onTap:  () {
      // Sauvegarder avant de quitter
      controller.saveDraftToStorage();
      Get.back();
    },
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "Retour",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Gap(3.w),
            // Bouton Ajouter ma carte
            Expanded(
              flex: 2,
              child: Obx(() {
                // Observer fieldsUpdated et isLoading
                controller.fieldsUpdated.value; // Cette ligne déclenche l'observation
                
                final missingFields = controller.getMissingFields();
                final isComplete = missingFields.isEmpty;
                
                return InkWell(
                  onTap: (isComplete && !controller.isLoading.value) 
                      ? () => controller.submitForm() 
                      : null,
                  child: Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: (isComplete && !controller.isLoading.value) 
                          ? AppColorModel.Bluecolor242 
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: controller.isLoading.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 4.w,
                                  height: 4.w,
                                  child: const CupertinoActivityIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                                Gap(2.w),
                                Text(
                                  "Traitement...",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              "Ajouter ma carte",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
    )
  );

  // Dans la méthode _buildInfoField, remplacez cette ligne :
// final showEditable = !isReadOnly && (isEmpty || controller.hasFieldErrorByLabel(label));

// Par cette nouvelle logique :
Widget _buildInfoField(
  String label, 
  String value, 
  IconData icon, {
  String? helper,
  bool isReadOnly = false,
  bool isEmpty = false,
}) {
  // Les champs éditables : toujours afficher le champ de saisie s'ils ne sont pas en lecture seule
  final alwaysEditableLabels = [
    "Identifiant (face arrière) - 8 chiffres",
    "4 derniers chiffres (face avant)",
    "Expire en (MM/YY)",
  ];
  
  // Afficher le champ éditable si :
  // 1. Ce n'est pas un champ en lecture seule ET
  // 2. (Le champ est vide OU il fait partie des champs toujours éditables)
  final showEditable = !isReadOnly && (isEmpty || alwaysEditableLabels.contains(label));
  
  return Column(
    children: [
      Container(
        width: 100.w,
        margin: EdgeInsets.only(bottom: helper != null ? 0.5.h : 2.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (isEmpty || controller.hasFieldErrorByLabel(label))
                ? Colors.red[300]!
                : Colors.grey[300]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4.w, top: 2.w, right: 4.w),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: (isEmpty || controller.hasFieldErrorByLabel(label)) ? Colors.red : Colors.grey[600],
                    size: 5.w,
                  ),
                  Gap(3.w),
                  Expanded(
                    child: showEditable
                        ? _buildEditableField(label, icon)
                        : Text(
                            isEmpty ? "Non renseigné" : value,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isEmpty ? Colors.red[600] : Colors.black87,
                              fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                  ),
                  if (isReadOnly)
                    Icon(
                      Icons.lock_outline,
                      color: Colors.grey[500],
                      size: 4.w,
                    )
                  else if (isEmpty || controller.hasFieldErrorByLabel(label) || alwaysEditableLabels.contains(label))
                    Icon(
                      Icons.edit_outlined,
                      color: isEmpty || controller.hasFieldErrorByLabel(label) ? Colors.red : Colors.blue,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (helper != null)
        Padding(
          padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 2.h),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              helper,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
    ],
  );
}
  Widget _buildEditableField(String label, IconData icon) {
    TextEditingController? getController() {
      switch (label) {
        case "Identifiant (face arrière) - 8 chiffres":
          return controller.identifiantController;
        case "4 derniers chiffres (face avant)":
          return controller.dernierChiffresController;
        case "Expire en (MM/YY)":
          return controller.expireController;
        default:
          return null;
      }
    }

    FocusNode? getFocusNode() {
      switch (label) {
        case "Identifiant (face arrière) - 8 chiffres":
          return controller.identifiantFocusNode;
        case "4 derniers chiffres (face avant)":
          return controller.dernierChiffresFocusNode;
        case "Expire en (MM/YY)":
          return controller.expireFocusNode;
        default:
          return null;
      }
    }

    TextInputType getInputType() {
      switch (label) {
        case "Identifiant (face arrière) - 8 chiffres":
        case "4 derniers chiffres (face avant)":
          return TextInputType.number;
        case "Expire en (MM/YY)":
          return TextInputType.datetime;
        default:
          return TextInputType.text;
      }
    }

    List<TextInputFormatter> getFormatters() {
      switch (label) {
        case "Identifiant (face arrière) - 8 chiffres":
          return [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)];
        case "4 derniers chiffres (face avant)":
          return [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)];
        case "Expire en (MM/YY)":
          return [
            FilteringTextInputFormatter.allow(RegExp(r'[\d/]')),
            LengthLimitingTextInputFormatter(5),
          ];
        default:
          return const [];
      }
    }

    String? validatorByLabel() {
      if (label == "Identifiant (face arrière) - 8 chiffres") {
        return controller.validateIdentifiant(controller.identifiantController.text);
      } else if (label == "4 derniers chiffres (face avant)") {
        return controller.validateDernierChiffres(controller.dernierChiffresController.text);
      } else if (label == "Expire en (MM/YY)") {
        return controller.validateExpire(controller.expireController.text);
      }
      return null;
    }

    void focusNext() {
      if (label == "Identifiant (face arrière) - 8 chiffres") {
        FocusScope.of(Get.context!).requestFocus(controller.dernierChiffresFocusNode);
      } else if (label == "4 derniers chiffres (face avant)") {
        FocusScope.of(Get.context!).requestFocus(controller.expireFocusNode);
      } else {
        FocusScope.of(Get.context!).unfocus();
      }
    }

    return  (label == "Expire en (MM/YY)")
    ? _ExpiryPickerField(
        controller: controller,
        getController: getController,
        getFocusNode: getFocusNode,
      )
    : TextFormField(
        controller: getController(),
        focusNode: getFocusNode(),
        keyboardType: getInputType(),
        textInputAction: (label == "Identifiant (face arrière) - 8 chiffres" || label == "4 derniers chiffres (face avant)")
            ? TextInputAction.next
            : TextInputAction.done,
        inputFormatters: getFormatters(),
        validator: (_) => validatorByLabel(),
        onFieldSubmitted: (_) => focusNext(),
        onChanged: (_) {
          controller.fieldsUpdated.value++;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Touchez pour saisir",
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[400],
            fontStyle: FontStyle.italic,
          ),
          suffixIcon: IconButton(
            tooltip: "Effacer",
            icon: const Icon(Icons.clear),
            onPressed: () {
              final c = getController();
              c?.clear();
              controller.fieldsUpdated.value++;
            },
          ),
        ),
        enableInteractiveSelection: true,
        autocorrect: false,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.black87,
        ),
      );

  }

  void _showMissingFieldsDialog(List<String> missingFields) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            "Compléter les informations",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Veuillez remplir les champs suivants :",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                  ),
                ),
                Gap(2.h),
                ...missingFields.map((field) => _buildMissingFieldInput(field)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Annuler",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.fieldsUpdated.value++; // Déclencher la mise à jour
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorModel.Bluecolor242,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                "Sauvegarder",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMissingFieldInput(String fieldName) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldName,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Gap(0.5.h),
          TextFormField(
            controller: _getControllerForField(fieldName),
            onChanged: (_) => controller.fieldsUpdated.value++, // Déclencher la mise à jour
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            ),
            keyboardType: _getInputTypeForField(fieldName),
          ),
        ],
      ),
    );
  }

  TextEditingController? _getControllerForField(String fieldName) {
    switch (fieldName) {
      case "Nom":
        return controller.nomController;
      case "Prénom":
        return controller.prenomController;
      case "Identifiant":
        return controller.identifiantController;
      case "4 derniers chiffres":
        return controller.dernierChiffresController;
      case "Date d'expiration":
        return controller.expireController;
      case "Email":
        return controller.emailController;
      default:
        return null;
    }
  }

  TextInputType _getInputTypeForField(String fieldName) {
    switch (fieldName) {
      case "Identifiant":
      case "4 derniers chiffres":
        return TextInputType.number;
      case "Email":
        return TextInputType.emailAddress;
      default:
        return TextInputType.text;
    }
  }
}
class _ExpiryPickerField extends StatelessWidget {
  final CartePhysiqueController controller;
  final TextEditingController? Function() getController;
  final FocusNode? Function() getFocusNode;

  const _ExpiryPickerField({
    Key? key,
    required this.controller,
    required this.getController,
    required this.getFocusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> _pickExpiry() async {
      final now = DateTime.now();
      final initial = DateTime(
  now.year < 2024 ? 2024 : now.year, 
  now.month, 
  now.day,
);
      final picked = await showDatePicker(
  context: context,
  initialDate: now.isBefore(DateTime(2024, 1, 1)) 
      ? DateTime(2024, 1, 1) 
      : now, // 👈 toujours >= firstDate
  firstDate: DateTime(2024, 1, 1), // 👈 minimum 2024
  lastDate: DateTime(2100),        // 👈 requis par Flutter, tu peux mettre très loin
  helpText: "Choisir la date d'expiration",
  cancelText: "Annuler",
  confirmText: "Valider",
);






      if (picked != null) {
        final mm = picked.month.toString().padLeft(2, '0');
        final yy = (picked.year % 100).toString().padLeft(2, '0');
        // Remplit au format MM/YY
        controller.expireController.text = "$mm/$yy";
        controller.fieldsUpdated.value++;
        // Place le focus sur le champ suivant si tu veux
        FocusScope.of(context).requestFocus(controller.emailFocusNode);
      }
    }

    return TextFormField(
      controller: getController(),
      focusNode: getFocusNode(),
      readOnly: true,                    // ⬅️ pas de clavier
      showCursor: false,
      keyboardType: TextInputType.none,  // ⬅️ désactive le clavier
      validator: (_) => controller.validateExpire(controller.expireController.text),
      onTap: _pickExpiry,                // ⬅️ ouvre le DatePicker
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "MM/YY",
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: Colors.grey[400],
          fontStyle: FontStyle.italic,
        ),
        suffixIcon: IconButton(
          tooltip: "Choisir une date",
          icon: const Icon(Icons.calendar_month),
          onPressed: _pickExpiry,       // ⬅️ même action via l’icône
        ),
      ),
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.black87,
      ),
    );
  }
}
void showAlert(String title, String message, {bool isError = false}) {
  Get.dialog(
    CupertinoAlertDialog(
      title: Column(
        children: [
          Icon(
            isError ? Icons.error : Icons.check_circle,
            color: isError ? const Color.fromARGB(255, 148, 68, 62) : Colors.green,
            size: 40, // Cupertino n’accepte pas .w directement
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isError ? const Color.fromARGB(255, 148, 68, 62) : Colors.green,
            ),
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Get.back();
            Get.back();
          },
          child: Text(
            "OK",
            style: TextStyle(
              color: isError ? const Color.fromARGB(255, 148, 68, 62): AppColorModel.Bluecolor242,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
    barrierDismissible: true,
  );
}
