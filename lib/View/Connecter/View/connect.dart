import 'package:country_picker_flutter/country_code_picker.dart';
import 'package:flutter/cupertino.dart'; // ajouté pour CupertinoPageScaffold
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/contryOnyfast/contry_onyfast_controller.dart';
import 'package:onyfast/View/Connecter/View/KeyOublie.dart';

import '../../../Color/app_color_model.dart';
import '../../../Controller/inscriptioncontroller.dart';
import '../../../Controller/languescontroller.dart';
import '../../../Controller/logincontroller.dart';
import '../../../Controller/numbercontroller.dart';
import '../../../Controller/passwordcontroller.dart';
import '../../../Controller/selectioncountry.dart';
import '../../../Api/user_inscription.dart';
import '../../../Widget/container.dart';

class Connect extends StatefulWidget {
  const Connect({super.key});

  @override
  _ConnectState createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String selectedCountryCode = '+242';

  @override
  void initState() {
    super.initState();
    // Observer les changements dans la liste des pays
    ever(contryController.tabCountrycode, (List<String> countries) {
      print('Changement détecté dans tabCountrycode: $countries');
      if (mounted) {
        setState(() {}); // Forcer la reconstruction du widget
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    phoneNumberController.dispose();
    contryController.dispose();
    super.dispose();
  }

  final InscriptionController inscriptionController =
      Get.put(InscriptionController());
  final PasswordController passwordController = Get.put(PasswordController());
  final TextEditingController motdepassController = TextEditingController();

  final NumberController phoneController = Get.put(NumberController());
  final contryController = Get.put(ContryOnyfastController());

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final AuthController connect = Get.put(AuthController());
    final LoginController connectController = Get.put(LoginController());

    return CupertinoPageScaffold(
      child: Material(
        // <-- ajouté ici
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: screenHeight,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: AppColorModel.WhiteColor,
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: screenHeight * 0.12,
                            left: screenWidth * 0.30,
                            right: screenWidth * 0.1,
                          ),
                          child: SizedBox(
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
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.1, vertical: 10),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: screenHeight * 0.34),
                                  child: Text(
                                    "Connectez-vous",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.075,
                                      color: AppColorModel.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Gap(screenHeight * 0.02),
                                Container(
                                  height: 07.h,
                                  width: 130.w,
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
                                      // Sélecteur de pays avec correction
                                      Obx(() {
                                        print(
                                            'voila les pays ${contryController.tabCountrycode}');

                                        List<String> countryFilter =
                                            contryController
                                                    .tabCountrycode.isNotEmpty
                                                ? contryController
                                                    .tabCountrycode
                                                    .map<String>(
                                                        (e) => e.toString())
                                                    .toList()
                                                : ['CG'];

                                        print('Country filter: $countryFilter');

                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6),
                                          child: CountryCodePicker(
                                            key: ValueKey(
                                                'country_picker_${countryFilter.join('_')}_${contryController.tabCountrycode.length}'), // Clé unique pour forcer la reconstruction
                                            onChanged: (countryCode) {
                                              setState(() {
                                                selectedCountryCode =
                                                    countryCode.dialCode!;
                                              });
                                              // Mettre à jour le numéro complet
                                              connectController
                                                      .fullPhoneNumberController
                                                      .text =
                                                  selectedCountryCode +
                                                      phoneNumberController
                                                          .text;
                                              print(
                                                  'Pays sélectionné: ${countryCode.name}');
                                              print(
                                                  'Code: ${countryCode.dialCode}');
                                            },
                                            initialSelection:
                                                countryFilter.isNotEmpty
                                                    ? countryFilter.first
                                                    : 'CG',
                                            countryFilter: countryFilter,
                                            showCountryOnly: false,
                                            showOnlyCountryWhenClosed: false,
                                            alignLeft: false,
                                            padding: EdgeInsets.zero,
                                            textStyle:
                                               TextStyle(fontSize: 9.sp),
                                            dialogTextStyle:
                                                TextStyle(fontSize: 9.sp),
                                            searchStyle:
                                                TextStyle(fontSize: 9.sp),
                                            flagWidth: 20,
                                            hideMainText: false,
                                            showDropDownButton: true,
                                            enabled: !connect.isLoading.value,
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
                                      Expanded(child: Obx(() {
                                        return TextFormField(
                                          style: TextStyle(fontSize: 10.sp),
                                          enabled: !connect.isLoading.value
                                              ? true
                                              : false,
                                          controller: phoneNumberController,
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            labelStyle:
                                                TextStyle(fontSize: 9.sp),
                                            enabled: !connect.isLoading.value,
                                            hintText: 'Numéro de téléphone',
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 12),
                                          ),
                                          onChanged: (value) {
                                            // Mettre à jour le numéro complet
                                            connectController
                                                    .fullPhoneNumberController
                                                    .text =
                                                selectedCountryCode + value;
                                            print(
                                                'Numéro complet: ${selectedCountryCode + value}');
                                          },
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(9),
                                          ],
                                        );
                                      })),
                                    ],
                                  ),
                                ),
                                Gap(screenHeight * 0.01),
                                Obx(() {
                                  return TextFormField(
                                    style: TextStyle(fontSize: 10.sp),
                                    enabled: !connect.isLoading.value,
                                    controller:
                                        connectController.passwordController,
                                    obscureText: !passwordController
                                        .isPasswordVisible.value,
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
                                      labelText: "Mot de passe",
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          passwordController
                                                  .isPasswordVisible.value
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off,
                                          color: AppColorModel.DeepPurple,
                                        ),
                                        onPressed: () {
                                          passwordController
                                              .togglePasswordVisibility();
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
                                TextButton(
                                    onPressed: () {
                                      Get.to(
                                        NumeroRenitialisation(),
                                        transition: Transition.cupertino,
                                      );
                                    },
                                    child: Text(
                                      'Mot de passe oublié',
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        color: AppColorModel.blackColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                    )),
                                Gap(screenHeight * 0.04),
                                Obx(() {
                                  final isLoading = connect.isLoading.value;

                                  print('voila le chargement $isLoading');

                                  return GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () async {
                                            await connect.login(
                                              connectController
                                                  .fullPhoneNumberController
                                                  .text,
                                              connectController
                                                  .passwordController.text,
                                            );
                                          },
                                    child: ContainerWidget(
                                      height: 06.h,
                                      width: screenWidth * 0.78,
                                      color: isLoading
                                          ? Colors.grey.shade400
                                          : AppColorModel.BlueColor,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Center(
                                        child: isLoading
                                            ? SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CupertinoActivityIndicator(
                                                  radius: 15,
                                                  color:
                                                      AppColorModel.WhiteColor,
                                                ),
                                              )
                                            : Text(
                                                "Se connecter",
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color:
                                                      AppColorModel.WhiteColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Future<String> loadFromJson() async {
    return await rootBundle.loadString('assets/countries/country_list_en.json');
  }
}
