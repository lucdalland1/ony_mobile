import 'package:country_picker_flutter/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/contryOnyfast/contry_onyfast_controller.dart';
import 'package:onyfast/View/const.dart';

import '../Color/app_color_model.dart';
import '../Controller/logincontroller.dart';
import '../Controller/passwordcontroller.dart';
import '../Api/user_inscription.dart';
import '../Widget/container.dart';

class Inscrit extends StatefulWidget {
  const Inscrit({super.key});

  @override
  _InscritState createState() => _InscritState();
}

class _InscritState extends State<Inscrit> with TickerProviderStateMixin {
  final PasswordController passwordController = Get.put(PasswordController());
  final AuthController register = Get.put(AuthController());
  final LoginController inscriptController = Get.put(LoginController());
  final contryController = Get.put(ContryOnyfastController());

  late final AnimationController _floatingController;
  late final Animation<double> _floatingAnimation;

  // --- Animations pour les éléments ---
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _featuresController;
  late final AnimationController _buttonsController;

  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _featuresSlide;
  late final Animation<double> _buttonsOpacity;
  // Si user ne selectionne rien par defaut on stipule qu'il est au Congo
  String Code = '+242';
  String Indicatif = 'CG';
  // Controllers manquants
  final TextEditingController phoneNumberController = TextEditingController();
  String selectedCountryCode = '+242';

  @override
  void initState() {
    super.initState();
    ever(contryController.tabCountrycode, (List<String> countries) {
      print('Changement détecté dans tabCountrycode: $countries');
      if (mounted) {
        setState(() {}); // Forcer la reconstruction du widget
      }
    });
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // Contrôleurs
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _featuresController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Flottement
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // Courbes
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _featuresSlide =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _featuresController, curve: Curves.easeOutCubic),
    );

    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _textController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) _featuresController.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) _buttonsController.forward();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _featuresController.dispose();
    _buttonsController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: AppColorModel.WhiteColor,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Gap(screenHeight * 0.09),
                  AnimatedBuilder(
                    animation:
                        Listenable.merge([_logoScale, _floatingAnimation]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.translate(
                          offset: Offset(0, _floatingAnimation.value),
                          child: Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.circular(8.w),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: globalColor.withOpacity(0.1),
                                  blurRadius: 5.w,
                                  offset: Offset(0, 3.w),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: 85.dp,
                              //  height: screenWidth * 0.4,
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.dp),
                                  child: Image.asset(
                                    "asset/onylogo.png",
                                    height: 40.h,
                                    width: 30.w,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: (screenHeight * 0.09),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 0),
                          child: Text(
                            "Créez votre compte",
                            style: TextStyle(
                              fontSize: 20.dp,
                              color: AppColorModel.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Gap(screenHeight * 0.02),

                        // Container pour le champ téléphone
                        Container(
                          height: 07.h,
                          width: 90.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: AppColorModel.GreyBlack,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(04.dp),
                          ),
                          child: Row(
                            children: [
                              // Sélecteur de pays
                              Obx(() {
                                print(
                                    'voila les pays ${contryController.tabCountrycode}');

                                List<String> countryFilter =
                                    contryController.tabCountrycode.isNotEmpty
                                        ? contryController.tabCountrycode
                                            .map<String>((e) => e.toString())
                                            .toList()
                                        : ['CG'];

                                print('Country filter: $countryFilter');

                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: CountryCodePicker(
                                    enabled: !register.isLoading.value,
                                    key: ValueKey(
                                        'country_picker_${countryFilter.join('_')}_${contryController.tabCountrycode.length}'),
                                    onChanged: (countryCode) {
                                      setState(() {
                                        selectedCountryCode =
                                            countryCode.dialCode!;
                                        Code = countryCode.dialCode!;
                                        Indicatif = countryCode.code!;
                                      });
                                      // Mettre à jour le numéro complet
                                      inscriptController
                                              .fullPhoneNumberController.text =
                                          selectedCountryCode +
                                              phoneNumberController.text;
                                      print(
                                          'Pays sélectionné: ${countryCode.name}');
                                      print('Code: $Code');
                                      print('indicatif: $Indicatif');
                                    },
                                    initialSelection: countryFilter.isNotEmpty
                                        ? countryFilter.first
                                        : 'CG',
                                    countryFilter: countryFilter,
                                    showCountryOnly: false,
                                    showOnlyCountryWhenClosed: false,
                                    alignLeft: false,
                                    padding: EdgeInsets.zero,
                                    textStyle: TextStyle(fontSize: 9.sp),
                                    dialogTextStyle: TextStyle(fontSize: 9.sp),
                                    searchStyle: TextStyle(fontSize: 9.sp),
                                    flagWidth: 20,
                                    hideMainText: false,
                                    showDropDownButton: true,
                                  ),
                                );
                              }),

                              // Ligne de séparation
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey[300],
                              ),

                              // Champ numéro de téléphone
                              Expanded(
                                child: Obx(() {
                                  return TextFormField(
                                    style: TextStyle(fontSize: 10.sp),
                                    enabled: !register.isLoading.value,
                                    controller: phoneNumberController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(fontSize: 9.sp),
                                      hintText: 'Numéro de téléphone',
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                    onChanged: (value) {
                                      // Mettre à jour le numéro complet
                                      inscriptController
                                          .fullPhoneNumberController
                                          .text = selectedCountryCode + value;
                                      print(
                                          'Numéro complet: ${selectedCountryCode + value}');
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(9),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),

                        Gap(screenHeight * 0.01),

                        // Champ code PIN
                        Obx(() {
                          return TextFormField(
                            style: TextStyle(fontSize: 10.sp),
                            enabled: !register.isLoading.value,
                            controller: inscriptController.passwordController,
                            obscureText:
                                !passwordController.isPasswordVisible.value,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Veuillez entrer le code pin';
                              } else if (value.length != 4) {
                                return 'Le code pin doit être composé de 4 chiffres';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                               labelStyle: TextStyle(
                                fontSize: 9.sp
                              ),
                              labelText: 'Créer un code PIN',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  passwordController.isPasswordVisible.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off,
                                  color: AppColorModel.DeepPurple,
                                ),
                                onPressed: () {
                                  passwordController.togglePasswordVisibility();
                                },
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                          );
                        }),

                        Gap(screenHeight * 0.01),

                        // Champ confirmation code PIN
                        Obx(() {
                          return TextFormField(
                            style: TextStyle(fontSize: 10.sp),
                            enabled: !register.isLoading.value,
                            controller:
                                inscriptController.confirmPasswordController,
                            obscureText:
                                !passwordController.isPasswordVisible.value,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Veuillez entrer le code pin';
                              } else if (value.length != 4) {
                                return 'Le code pin doit être composé de 4 chiffres';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelStyle: TextStyle(fontSize: 9.sp),
                              labelText: 'Confirmez votre code PIN',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  passwordController.isPasswordVisible.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off,
                                  color: AppColorModel.DeepPurple,
                                ),
                                onPressed: () {
                                  passwordController.togglePasswordVisibility();
                                },
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                          );
                        }),
                        Gap(screenHeight * 0.01),

                        // Champ confirmation code PIN
                        Obx(() {
                          return TextFormField(
                            style: TextStyle(fontSize: 10.sp),
                            enabled: !register.isLoading.value,
                            controller:
                                inscriptController.CodeParrainController,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(fontSize: 9.sp),
                              labelText: 'Code parrain (facultatif)',
                              border: const OutlineInputBorder(),
                              suffixIcon: Icon(Icons.person,
                                  color: AppColorModel.DeepPurple),
                            ),
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              // ✅ CORRECT: permet lettres ET chiffres
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9]')),

                              // ✅ Optionnel: limite à 12 caractères
                              LengthLimitingTextInputFormatter(12),

                              // ✅ Optionnel: convertir en majuscules automatiquement
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                                  return TextEditingValue(
                                    text: newValue.text.toUpperCase(),
                                    selection: newValue.selection,
                                  );
                                },
                              ),
                            ],
                          );
                        }),
                        Gap(screenHeight * 0.02),

                        // Bouton d'inscription
                        Obx(() => InkWell(
                              onTap: register.isLoading.value
                                  ? null
                                  : () async {
                                      print(
                                          'voila ce que vous avez selectionné $Code et $Indicatif');
                                      await register.register(
                                          inscriptController
                                              .fullPhoneNumberController.text,
                                          inscriptController
                                              .passwordController.text,
                                          inscriptController
                                              .confirmPasswordController.text,
                                          Code,
                                          Indicatif,
                                          inscriptController
                                              .CodeParrainController.text);
                                    },
                              child: ContainerWidget(
                                height: 50,
                                width: screenWidth * 0.78,
                                color: register.isLoading.value
                                    ? Colors.grey
                                    : AppColorModel.BlueColor,
                                borderRadius: BorderRadius.circular(10),
                                child: Center(
                                  child: register.isLoading.value
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CupertinoActivityIndicator(
                                            color: AppColorModel.WhiteColor,
                                            radius: 15,
                                          ),
                                        )
                                      : Text(
                                          "Inscrivez-vous maintenant",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppColorModel.WhiteColor,
                                          ),
                                        ),
                                ),
                              ),
                            )),

                        Gap(screenHeight * 0.065),

                        // Textes légaux
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "S'inscrire signifie que vous",
                              style: TextStyle(
                                  fontSize: 9.sp,
                                  color: AppColorModel.blackColor),
                            ),
                            Gap(5),
                            Text(
                              "acceptez les termes ",
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: AppColorModel.blackColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Gap(10),
                            Text(
                              "et conditions",
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: AppColorModel.blackColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            Gap(5),
                            Text(
                              "mis en place par",
                              style: TextStyle(
                                  fontSize: 9.sp,
                                  color: AppColorModel.blackColor),
                            ),
                            Gap(5),
                            Text(
                              "Onyfast",
                              style: TextStyle(
                                  fontSize: 9.sp,
                                  color: AppColorModel.BlueColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Gap(10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Lisez notre politique de",
                              style: TextStyle(
                                  fontSize: 9.5.sp,
                                  color: AppColorModel.blackColor),
                            ),
                            Gap(5),
                            Text(
                              "confidentialité",
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                color: AppColorModel.blackColor,
                                // decoration: TextDecoration.underline,
                              ),
                            ),
                            Gap(5),
                            Text(
                              "avant de",
                              style: TextStyle(
                                  fontSize: 9.5.sp,
                                  color: AppColorModel.blackColor),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "continuer pour comprendre comment nous traitons",
                              style: TextStyle(
                                  fontSize: 9.5.sp,
                                  color: AppColorModel.blackColor),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "vos données personnelles.",
                              style: TextStyle(
                                  fontSize: 9.5.sp,
                                  color: AppColorModel.blackColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<String> loadFromJson() async {
    return await rootBundle.loadString('assets/countries/country_list_en.json');
  }
}
