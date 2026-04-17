import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/inscriptioncontroller.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/alerte.dart';
import '../../Color/app_color_model.dart';

class InscritInfoSuplementaire extends StatefulWidget {
  const InscritInfoSuplementaire({super.key});

  @override
  State<InscritInfoSuplementaire> createState() =>
      _InscritInfoSuplementaireState();
}

class _InscritInfoSuplementaireState extends State<InscritInfoSuplementaire> {
  late InscriptionController controller;
  final FocusNode _nomFocus = FocusNode();
  final FocusNode _prenomFocus = FocusNode();
  final FocusNode _adresseFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  var isLoading =
      false.obs; // <-- utilisé pour (dés)activer les champs & bouton

  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    controller = Get.put(InscriptionController());

    controller.nomController.addListener(_onNomChanged);
    controller.prenomController.addListener(_onPrenomChanged);
    controller.adresseController.addListener(_onAdresseChanged);
    controller.emailController.addListener(_onEmailChanged);
  }

  void _onNomChanged() {
    if (_mounted && mounted) setState(() {});
  }

  void _onPrenomChanged() {
    if (_mounted && mounted) setState(() {});
  }

  void _onAdresseChanged() {
    if (_mounted && mounted) setState(() {});
  }

  void _onEmailChanged() {
    if (_mounted && mounted) setState(() {});
  }

  void _onDateNaissanceChanged() {
    if (_mounted && mounted) setState(() {});
  }

  void _safeSetState(VoidCallback fn) {
    if (_mounted && mounted) setState(fn);
  }

  @override
  void dispose() {
    _mounted = false;

    controller.nomController.removeListener(_onNomChanged);
    controller.prenomController.removeListener(_onPrenomChanged);
    controller.adresseController.removeListener(_onAdresseChanged);
    controller.emailController.removeListener(_onEmailChanged);

    _nomFocus.dispose();
    _prenomFocus.dispose();
    _adresseFocus.dispose();
    _emailFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        title: Text(
          'Informations supplémentaires',
          style: TextStyle(
            fontSize: 17.dp,
            fontWeight: FontWeight.bold,
            color: AppColorModel.WhiteColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.dp, vertical: 20.dp),
          child: Obx(() {
            // <-- reconstruit quand isLoading change
            final disabled = isLoading.value;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 20.dp),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColorModel.Bluecolor242,
                            ),
                            child: Icon(Icons.person,
                                size: 50, color: AppColorModel.WhiteColor),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 50,
                          right: 0,
                          child: TextButton(
                            onPressed: disabled
                                ? null
                                : () {
                                    // controller.choixCameraPhto();
                                  },
                            style: ButtonStyle(
                              overlayColor:
                                  WidgetStateProperty.all(Colors.transparent),
                              splashFactory: NoSplash.splashFactory,
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 49,
                              color: AppColorModel.WhiteColor.withOpacity(
                                  disabled ? 0.5 : 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // NOM
                  Container(
                    margin: EdgeInsets.only(bottom: 20.dp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Nom",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                             inputFormatters: [
                              LengthLimitingTextInputFormatter(60),
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-ZÀ-ÿ\s]"),
                              ),
                            ],
                          controller: controller.nomController,
                          focusNode: _nomFocus,
                          enabled: !disabled, // <-- désactivation en chargement
                          textInputAction: controller
                                      .nomController.text.isNotEmpty &&
                                  RegExp(r'^[a-zA-Z\s-]+$')
                                      .hasMatch(controller.nomController.text)
                              ? TextInputAction.next
                              : (Platform.isAndroid
                                  ? TextInputAction.none
                                  : TextInputAction.done),
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: "Entrez votre nom",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            errorText: controller
                                        .nomController.text.isNotEmpty &&
                                    !RegExp(r'^[a-zA-Z\s-]+$')
                                        .hasMatch(controller.nomController.text)
                                ? 'Caractères invalides'
                                : null,
                          ),
                          onSubmitted: (value) {
                            if (!disabled &&
                                controller.nomController.text.isNotEmpty &&
                                RegExp(r'^[a-zA-Z\s-]+$')
                                    .hasMatch(controller.nomController.text)) {
                              FocusScope.of(context).requestFocus(_prenomFocus);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // PRÉNOM
                  Container(
                    margin: EdgeInsets.only(bottom: 20.dp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Prénom",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                             inputFormatters: [
                              LengthLimitingTextInputFormatter(60),
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-ZÀ-ÿ\s]"),
                              ),
                            ],
                          controller: controller.prenomController,
                          focusNode: _prenomFocus,
                          enabled: !disabled, // <--
                          textInputAction:
                              controller.prenomController.text.isNotEmpty &&
                                      RegExp(r'^[a-zA-Z\s-]+$').hasMatch(
                                          controller.prenomController.text)
                                  ? TextInputAction.next
                                  : (Platform.isAndroid
                                      ? TextInputAction.none
                                      : TextInputAction.done),
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: "Entrez votre prénom",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            errorText:
                                controller.prenomController.text.isNotEmpty &&
                                        !RegExp(r'^[a-zA-Z\s-]+$').hasMatch(
                                            controller.prenomController.text)
                                    ? 'Caractères invalides'
                                    : null,
                          ),
                          onSubmitted: (value) {
                            if (!disabled &&
                                controller.prenomController.text.isNotEmpty &&
                                RegExp(r'^[a-zA-Z\s-]+$').hasMatch(
                                    controller.prenomController.text)) {
                              FocusScope.of(context)
                                  .requestFocus(_adresseFocus);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // DATE DE NAISSANCE
                  Container(
                    margin: EdgeInsets.only(bottom: 20.dp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Date de naissance",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.dateNaissanceController,
                          enabled: !disabled,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            hintText: "JJ/MM/AAAA",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            // Dans le champ dateNaissance (lignes 263-267)
                            errorText: controller.dateNaissanceController.text
                                        .isNotEmpty &&
                                    !RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(
                                        controller.dateNaissanceController.text)
                                ? 'Format JJ/MM/AAAA requis'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SEXE
                  Container(
                    margin: EdgeInsets.only(bottom: 20.dp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Sexe",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Obx(() => RadioListTile<String>(
                                    title: const Text('Masculin'),
                                    value: 'M',
                                    groupValue: controller.sexeController.value,
                                    onChanged: disabled
                                        ? null
                                        : (value) {
                                            controller.sexeController.value =
                                                value!;
                                          },
                                    contentPadding: EdgeInsets.zero,
                                  )),
                            ),
                            Expanded(
                              child: Obx(() => RadioListTile<String>(
                                    title: const Text('Féminin'),
                                    value: 'F',
                                    groupValue: controller.sexeController.value,
                                    onChanged: disabled
                                        ? null
                                        : (value) {
                                            controller.sexeController.value =
                                                value!;
                                          },
                                    contentPadding: EdgeInsets.zero,
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ADRESSE
                  Container(
                    margin: EdgeInsets.only(bottom: 30.dp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Adresse",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.adresseController,
                          focusNode: _adresseFocus,
                          
                          enabled: !disabled, // <--
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(30),
                              
                            ],
                          textInputAction:
                              controller.adresseController.text.isNotEmpty
                                  ? TextInputAction.next
                                  : (Platform.isAndroid
                                      ? TextInputAction.none
                                      : TextInputAction.done),
                          decoration: InputDecoration(
                            hintText: "Entrez votre adresse",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onSubmitted: (value) {
                            if (!disabled &&
                                controller.adresseController.text.isNotEmpty) {
                              FocusScope.of(context).requestFocus(_emailFocus);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // EMAIL
                  Container(
                    margin: EdgeInsets.only(bottom: 30.dp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14.dp,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                             inputFormatters: [
                              LengthLimitingTextInputFormatter(60),
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-Z0-9.@_+-]"),
                              ),
                            ],
                          keyboardType: TextInputType.emailAddress,
                          controller: controller.emailController,
                          focusNode: _emailFocus,
                          enabled: !disabled, // <--
                          textInputAction: controller
                                      .emailController.text.isNotEmpty &&
                                  RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                                      .hasMatch(controller.emailController.text)
                              ? TextInputAction.done
                              : (Platform.isAndroid
                                  ? TextInputAction.none
                                  : TextInputAction.done),
                          decoration: InputDecoration(
                            hintText: "Entrez votre email",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            errorText: controller
                                        .emailController.text.isNotEmpty &&
                                    !RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                                        .hasMatch(
                                            controller.emailController.text)
                                ? 'Format email invalide'
                                : null,
                          ),
                          onSubmitted: (value) {
                            // rien, le bouton gère l’envoi
                          },
                        ),
                      ],
                    ),
                  ),

                  // BOUTON ENVOYER (spinner après le texte)
                  // --- Bouton ENVOYER avec chargement au niveau du bouton ---
// Version simplifiée pour tester
                  Obx(() {

                    return ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              controller.isLoading.value = true;

                              // Simulation d'une action longue
                                await Future.delayed(const Duration(seconds: 2));
                              try {
                                await controller.submitForm();
                              } catch (e) {
                                SnackBarService.error(e.toString());
                              } finally {
                                controller.isLoading.value = false;
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorModel.Bluecolor242,
                        minimumSize: Size(92.w, 6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CupertinoActivityIndicator(
                                color: globalColor,
                                radius: 15,
                              ),
                            )
                          : Text(
                              "Envoyer",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.dp,
                                color: Colors.white,
                              ),
                            ),
                    );
                  })
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
