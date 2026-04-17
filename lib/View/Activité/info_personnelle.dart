import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Controller/info_user/usercontroller.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Widget/dialog.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import '../../Color/app_color_model.dart';
import '../Notification/notification.dart';

class InformationsPersonnellesPage extends StatefulWidget {
  const InformationsPersonnellesPage({super.key});

  @override
  State<InformationsPersonnellesPage> createState() =>
      _InformationsPersonnellesPageState();
}

class _InformationsPersonnellesPageState
    extends State<InformationsPersonnellesPage> {
  final _formKey = GlobalKey<FormState>();
  final userCtrl = Get.put(UserMeController());

  bool _isLoading = false;

  final prenomController = TextEditingController();
  final nomController = TextEditingController();
  final emailController = TextEditingController();
  final telephoneController = TextEditingController();
  final adresseController = TextEditingController();
  final sexeController = TextEditingController();
  final dateNaissanceController = TextEditingController();

  String? _initialPrenom;
  String? _initialNom;
  String? _initialEmail;
  String? _initialAdresse;
  String? _initialSexe;
  String? _initialDateNaissance;

  // Worker pour s'abonner proprement (ici on va utiliser `once`)
  late final Worker _userOnce;

  String _genreIdToLabel(int? id) {
    switch (id) {
      case 1:
        return 'Féminin';
      case 2:
        return 'Masculin';
      default:
        return '';
    }
  }

  int? _labelToGenreId(String label) {
    switch (label) {
      case 'Féminin':
        return 1;
      case 'Masculin':
        return 2;
      default:
        return null;
    }
  }

  bool get _hasChanges =>
      _initialPrenom != prenomController.text.trim() ||
      _initialNom != nomController.text.trim() ||
      _initialEmail != emailController.text.trim() ||
      _initialAdresse != adresseController.text.trim() ||
      _initialSexe != sexeController.text.trim() ||
      _initialDateNaissance != dateNaissanceController.text.trim();

  @override
  void initState() {
    super.initState();
    ValidationTokenController.to.validateToken();
    // Injecter UNE SEULE FOIS quand le profil arrive
    _userOnce = once(userCtrl.user, (u) {
      if (!mounted || u == null) return;

      prenomController.text = u.prenom;
      nomController.text = u.name;
      emailController.text = u.email;
      telephoneController.text = '+${u.telephone}';
      adresseController.text = u.adresse;
      sexeController.text = _genreIdToLabel(u.genreId);
      dateNaissanceController.text = u.dateNaissance ?? '';

      _initialPrenom = u.prenom;
      _initialNom = u.name;
      _initialEmail = u.email;
      _initialAdresse = u.adresse;
      _initialSexe = sexeController.text;
      _initialDateNaissance = u.dateNaissance;

      print(
          '✅ [InformationsPersonnellesPage] Profil injecté dans le formulaire (once)');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      userCtrl.loadMe();
    });
    // Charger le profil après avoir branché le worker
  }

  @override
  void dispose() {
    // Couper l’abonnement avant de disposer les controllers
    _userOnce.dispose();

    prenomController.dispose();
    nomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    adresseController.dispose();
    sexeController.dispose();
    dateNaissanceController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_isLoading) return false;
    if (!_hasChanges) return true;
    var leave = false;
    await Get.dialog(
      AppDialog(
        title: "Quitter sans enregistrer ?",
        body:
            "Vous avez des modifications non enregistrées. Voulez-vous vraiment quitter ?",
        actions: [
          AppDialogAction(
            label: "Non",
            onPressed: () => Get.back(),
          ),
          AppDialogAction(
            label: "Oui",
            isDefault: true,
            onPressed: () {
              setState(() {
                leave = true;
              });
              Get.back();
              // ta logique ici
            },
          ),
        ],
      ),
    );

    return leave ?? false;
  }

  Future<void> _updateUserInfo() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    var deviceskey = await ValidationTokenController.to.getDeviceIMEI();
    var ip = await ValidationTokenController.to.getPublicIP();
    // Construire le payload avec uniquement les champs modifiés
    final Map<String, dynamic> payload = {'device': deviceskey, 'ip': ip};
    if (_initialNom != nomController.text.trim()) {
      payload['name'] = nomController.text.trim();
    }
    if (_initialPrenom != prenomController.text.trim()) {
      payload['prenom'] = prenomController.text.trim();
    }
    if (_initialAdresse != adresseController.text.trim()) {
      payload['adresse'] = adresseController.text.trim();
    }
    // N’ajouter l’email que s’il a CHANGÉ
    if (_initialEmail != emailController.text.trim()) {
      print('📡 📡 📡 📡  Email ');
      payload['email'] = emailController.text.trim();
    }
    if (_initialSexe != sexeController.text.trim()) {
      final genreId = _labelToGenreId(sexeController.text.trim());
      if (genreId != null) {
        payload['genre_id'] = genreId;
      }
    }
    if (_initialDateNaissance != dateNaissanceController.text.trim()) {
      print('📡 📡 📡 📡  Date de Naissance ');
      payload['date_naissance'] = dateNaissanceController.text.trim();
    }
    // Tu peux aussi envoyer profile_photo_path si tu le gères :
    // payload['profile_photo_path'] = '';

    if (payload.isEmpty) {
      SnackBarService.info('Aucune modification n\'a été effectuée');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final box = GetStorage();
      final token = box.read('token');
      print("🔑 Token lu depuis le stockage : $token");

      final url = '${ApiEnvironmentController.to.baseUrl}/user/update-profile';
      print("🌐 URL API : $url");

      final resp = await http.patch(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      print("📥 Statut HTTP : ${resp.statusCode}");
      print("📥 Réponse brute : ${resp.body}");

      Map<String, dynamic>? data;
      try {
        data = jsonDecode(resp.body) as Map<String, dynamic>?;
        print("📂 JSON décodé : $data");
      } catch (e) {
        print("❌ Erreur de parsing JSON : $e");
        data = null;
      }

      if (resp.statusCode == 200) {
        print("✅ Mise à jour réussie");
        SnackBarService.success('Informations mises à jour avec succès');
        await userCtrl.refreshMe();
        if (!mounted) return;
        Navigator.pop(context);
        return;
      }

      if (resp.statusCode == 422) {
        print("⚠️ Erreur de validation");
        final msg = data?['message'] ?? 'Données invalides';
        final errors = data?['errors'];
        String details = '';
        if (errors is Map) {
          details = errors.entries
              .map((e) => '- ${e.key}: ${(e.value as List).join(", ")}')
              .join('\n');
        }
        // Get.snackbar('Validation', '$msg${details.isNotEmpty ? '\n$details' : ''}');
      } else if (resp.statusCode == 401) {
        print("🚫 Non autorisé (401)");
        SnackBarService.warning(
            data?['message'] ?? 'Session expirée. Veuillez vous reconnecter.');
      } else {
        print("❌ Erreur serveur ou autre (${resp.statusCode})");
        final msg =
            data?['message'] ?? 'Une erreur est survenue (${resp.statusCode})';
        SnackBarService.warning(msg);
      }
    } catch (e) {
      print("🔥 Exception lors de la mise à jour : $e");
      // SnackBarService.warning('Erreur lors de la mise à jour : ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
      print("🏁 [_updateUserInfo] Fin de la méthode");
    }
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: globalColor),
      ),
      errorStyle: const TextStyle(color: Colors.red),
      contentPadding: EdgeInsets.symmetric(
        horizontal: (3.5.w).clamp(12.0, 20.0),
        vertical: (1.2.h).clamp(10.0, 16.0),
      ),
    );
  }

  Future<void> _selectDateNaissance() async {
    final now = DateTime.now();
    final maxDate = DateTime(now.year - 18, now.month, now.day);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: maxDate,
      firstDate: DateTime(1900),
      lastDate: maxDate,
    );
    if (pickedDate != null) {
      setState(() {
        dateNaissanceController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
        fontSize: (14.sp).clamp(15.0, 20.0), color: AppColorModel.WhiteColor);
    const List<String> sexOptions = ['Masculin', 'Féminin'];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColorModel.Bluecolor242,
          title: Text('Informations personnelles', style: titleStyle),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                color: Colors.white),
            onPressed: () async {
              final canLeave = await _onWillPop();
              if (canLeave && mounted) Navigator.of(context).pop();
            },
          ),
          actions: [
            NotificationWidget(),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Obx(() {
            if ((userCtrl.isLoading.value && userCtrl.user.value == null) ||
                telephoneController.text.isEmpty) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoActivityIndicator(),
                  Text(
                    'Chargement..',
                    style: TextStyle(fontSize: 12.sp),
                  )
                ],
              ));
            }

            if (userCtrl.errorMessage.isNotEmpty &&
                userCtrl.user.value == null) {
              return
                  // Center(
                  //   child: Column(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  //       const SizedBox(height: 12),
                  //       Text(
                  //         userCtrl.errorMessage.value.isNotEmpty
                  //             ? userCtrl.errorMessage.value
                  //             : "Impossible de récupérer les données. Vérifiez votre connexion.",
                  //         textAlign: TextAlign.center,
                  //       ),
                  //       const SizedBox(height: 12),
                  //       ElevatedButton.icon(
                  //         onPressed: () => userCtrl.refreshMe(),
                  //         icon: const Icon(Icons.refresh),
                  //         label: const Text("Réessayer"),
                  //       ),
                  //     ],
                  //   ),
                  // );

                  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icône simple
                            Icon(
                              Icons.wifi_off,
                              size: 80,
                              color: Colors.red.shade600,
                            ),

                            const SizedBox(height: 30),

                            // Titre
                            Text(
                              'Connexion Impossible',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 15),

                            // Message
                            Text(
                              'Vérifiez votre connexion internet\net réessayez',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 40),

                            // Bouton principal
                            ElevatedButton.icon(
                              onPressed: () {
                                userCtrl.refreshMe();
                              },
                              icon: const Icon(Icons.refresh,
                                  color: Colors.white),
                              label: const Text(
                                'Réessayer',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F52BA),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all((4.w).clamp(16.0, 28.0)),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text('Informations personnelles',
                        style: TextStyle(
                            fontSize: (13.sp).clamp(14.0, 18.0),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: EdgeInsets.all((4.w).clamp(14.0, 24.0)),
                        child: Column(
                          children: [
                            // Prénom
                            TextFormField(
                              style: TextStyle(
                                  fontSize: 11
                                      .sp), // taille responsive avec flutter_sizer

                              controller: prenomController,
                              textInputAction: TextInputAction.next,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(60)
                              ],
                              decoration: _input('Prénom'),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Le prénom est requis'
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            // Nom
                            TextFormField(

                              style: TextStyle(
                                  fontSize: 11
                                      .sp), // taille responsive avec flutter_sizer
                              controller: nomController,
                              textInputAction: TextInputAction.next,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(60)
                              ],
                              decoration: _input('Nom'),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Le nom est requis'
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            // Email
                            TextFormField(
                              style: TextStyle(
                                  fontSize: 11
                                      .sp), // taille responsive avec flutter_sizer
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: _input('Adresse e-mail'),
                              validator: (v) {
                                final value = v?.trim() ?? '';
                                if (value.isEmpty) return 'L\'email est requis';
                                final emailRegex =
                                    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                                if (!emailRegex.hasMatch(value))
                                  return 'Email invalide';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Téléphone (non modifiable)
                            TextFormField(
                              style: TextStyle(
                                  fontSize: 11
                                      .sp), // taille responsive avec flutter_sizer
                              controller: telephoneController,
                              enabled: false,
                              decoration: _input('Numéro de téléphone'),
                            ),
                            const SizedBox(height: 12),

                            // Adresse
                            TextFormField(
                              style: TextStyle(
                                  fontSize: 11
                                      .sp), // taille responsive avec flutter_sizer
                              controller: adresseController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              textInputAction: TextInputAction.done,
                              maxLines: 2,
                              minLines: 1,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(120)
                              ],
                              decoration: _input('Adresse'),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'L\'adresse est requise'
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            // Date de naissance
                            TextFormField(
                              style: TextStyle(
                                  fontSize: 11
                                      .sp), // taille responsive avec flutter_sizer
                              controller: dateNaissanceController,
                              readOnly: true,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: _input('Date de naissance').copyWith(
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: _selectDateNaissance,
                                ),
                              ),
                              validator: (v) {
                                final value = v?.trim() ?? '';
                                if (value.isEmpty) {
                                  return 'La date de naissance est requise';
                                }

                                final parsed = DateTime.tryParse(value);
                                if (parsed == null) {
                                  return 'Date de naissance invalide';
                                }

                                final now = DateTime.now();
                                final eighteenYearsAgo =
                                    DateTime(now.year - 18, now.month, now.day);

                                if (parsed.isAfter(eighteenYearsAgo)) {
                                  return 'Vous devez avoir au moins 18 ans';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Sexe
                            DropdownButtonFormField<String>(
                              style: TextStyle(
                                color: Colors.black,
                                  fontSize: 11
                                      .sp), // taille responsive avec flutter_sizer
                              initialValue:
                                  sexOptions.contains(sexeController.text)
                                      ? sexeController.text
                                      : null,
                              decoration: _input('Sexe'),
                              items: sexOptions
                                  .map(
                                    (value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  sexeController.text = value;
                                });
                              },
                              validator: (value) {
                                final v = value ?? sexeController.text;
                                if (v.trim().isEmpty) {
                                  return 'Le sexe est requis';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Bouton "Enregistrer"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _updateUserInfo,
                        icon: const Icon(Icons.save),
                        label: _isLoading
                            ? Text('Enregistrement...',
                                style: TextStyle(fontSize: sizeTextBouton))
                            : Text(
                                'Enregistrer',
                                style: TextStyle(
                                    fontSize:
                                        sizeTextBouton), // taille responsive avec flutter_sizer
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorModel.Bluecolor242,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: (1.8.h).clamp(12.0, 20.0)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
