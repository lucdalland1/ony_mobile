import 'dart:convert';

import 'package:country_picker_flutter/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart'; // ajouté pour CupertinoPageScaffold
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:onyfast/Api/const.dart';
import 'package:onyfast/Api/otp_renitialisation_key/send.dart';
import 'package:onyfast/Controller/apiUrlController.dart';
import 'package:onyfast/Controller/contryOnyfast/contry_onyfast_controller.dart';
import 'package:onyfast/Controller/otp_renitisalistion_key/otpcontroller.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/otplogin.dart';

import '../../../Color/app_color_model.dart';
import '../../../Controller/inscriptioncontroller.dart';
import '../../../Controller/languescontroller.dart';
import '../../../Controller/logincontroller.dart';
import '../../../Controller/numbercontroller.dart';
import '../../../Controller/passwordcontroller.dart';
import '../../../Controller/selectioncountry.dart';
import '../../../Api/user_inscription.dart';
import '../../../Widget/container.dart';

class NumeroRenitialisation extends StatefulWidget {
  const NumeroRenitialisation({super.key});

  @override
  _NumeroRenitialisationState createState() => _NumeroRenitialisationState();
}

class RenitialisationController extends GetxController {
  OtpRenitPasswordController otp = Get.put(OtpRenitPasswordController());

  var isLoading = false.obs;
  String removePlus(String phone) {
    return phone.replaceAll("+", "");
  }

  Future<void> login(String phoneNumber) async {
    phoneNumber = removePlus(phoneNumber);
    print("✅ Numéro valide $phoneNumber");
    isLoading.value = true;

    // await OtpResource().sendOtpNumber(phoneNumber);
    isLoading.value = false;
  }
}

class _NumeroRenitialisationState extends State<NumeroRenitialisation> {
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
                                    textAlign: TextAlign.center,
                                    "Mot de passe Oublié",
                                    style: TextStyle(
                                      fontSize: 16.sp,
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
                                            enabled: !connect.isLoading.value,

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
                                          enabled: !connect.isLoading.value,
                                          controller: phoneNumberController,
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            labelStyle:
                                                TextStyle(fontSize: 9.sp),
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
                                Gap(screenHeight * 0.04),
                                Obx(() {
                                  final isLoading = connect.isLoading.value;

                                  print('voila le chargement $isLoading');

                                  return GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () async {
                                            connect.isLoading.value = true;
                                            //
                                            print(
                                                ' voila le numero${connectController.fullPhoneNumberController.text}');

                                            try {
                                              final headers = {
                                                'Accept': 'application/json',
                                                'Content-Type':
                                                    'application/json',
                                              };

                                              final telephone = connectController
                                                  .fullPhoneNumberController
                                                  .text
                                                  .replaceFirst(RegExp(r'^\+'),
                                                      '') // enlève + en début
                                                  .replaceAll(RegExp(r'\s+'),
                                                      ''); // enlève espaces
                                              print(
                                                  "voila le numero $telephone");

                                              print("📤 GET /api/check-phone");
                                              print(
                                                  "➡️ URL: ${ApiEnvironmentController.to.baseUrl}/check-phone");
                                              print(
                                                  "➡️ Query: { telephone: $telephone }");
                                              print("➡️ Headers: $headers");

                                              final dio = Dio();
                                              final res = await dio.get(
                                                '${ApiEnvironmentController.to.baseUrl}/check-phone',
                                                queryParameters: {
                                                  'telephone': telephone
                                                }, // GET => queryParameters
                                                options:
                                                    Options(headers: headers),
                                              );

                                              print(
                                                  "📡 Status: ${res.statusCode}");
                                              print(
                                                  "📡 Response headers: ${res.headers}");
                                              print(
                                                  "📡 Response raw: ${res.data}");

                                              // Normaliser la donnée retournée
                                              final data = res.data is String
                                                  ? jsonDecode(res.data)
                                                  : res.data;

                                              if (res.statusCode == 200 &&
                                                  data is Map) {
                                                final success =
                                                    data['success'] == true;
                                                final exists =
                                                    data['exists'] == true;

                                                if (success &&
                                                    data.containsKey(
                                                        'exists')) {
                                                  print(
                                                      "✅ OK: exists=$exists, telephone=${data['telephone']}");
                                                  // Notif UI selon le cas
                                                  if (exists) {
                                                    await AuthController()
                                                        .requestOtp(
                                                            connectController
                                                                .fullPhoneNumberController
                                                                .text);

                                                    Get.offAll(
                                                        Otplogin(
                                                          iswhatssap: true,
                                                          isTelephone: true,
                                                        ),
                                                        arguments: {
                                                          'telephone':
                                                              connectController
                                                                  .fullPhoneNumberController
                                                                  .text,
                                                          'password':
                                                              connectController
                                                                  .fullPhoneNumberController
                                                                  .text,
                                                          "verif": true
                                                        });
                                                  } else {
                                                    //Get.snackbar('Info', 'Numéro disponible (${data['telephone']})');
                                                  }
                                                } else {
                                                  // Format inattendu (ex: un message d’erreur mais status 200)
                                                  final msg = (data[
                                                              'message'] ??
                                                          'Réponse inattendue')
                                                      .toString();
                                                  print(
                                                      "⚠️ Format inattendu: $msg");
                                                  SnackBarService.warning(msg);
                                                }
                                              } else {
                                                print(
                                                    "❌ HTTP Error: ${res.statusCode} ${res.statusMessage}");
                                                // SnackBarService.warning(
                                                //     '(${res.statusCode}) ${res.statusMessage}');
                                              }
                                            } on DioException catch (e, s) {
                                              print(
                                                  "💥 DioException: ${e.type}");
                                              print(
                                                  "📡 Status: ${e.response?.statusCode}");
                                              print(
                                                  "📡 Response headers: ${e.response?.headers}");
                                              print(
                                                  "📡 Response data: ${e.response?.data}");
                                              print("📚 Stack: $s");

                                              // Gestion spécifique 422 (validation Laravel)
                                              if (e.response?.statusCode ==
                                                  422) {
                                                final body = e.response?.data;
                                                String msg = 'Requête invalide';
                                                if (body is Map) {
                                                  msg = (body['message'] ??
                                                          (body['errors']?[
                                                                          'telephone']
                                                                      is List &&
                                                                  body['errors']
                                                                          [
                                                                          'telephone']
                                                                      .isNotEmpty
                                                              ? body['errors'][
                                                                  'telephone'][0]
                                                              : null) ??
                                                          body.toString())
                                                      .toString()
                                                      .trim();
                                                }
                                                SnackBarService.warning(msg);
                                              } else {
                                                final msg = e.response?.data
                                                        is Map
                                                    ? (e.response!
                                                            .data['message'] ??
                                                        e.message)
                                                    : e.message;
                                                // SnackBarService.warning(
                                                //     '(${e.response?.statusCode}) $msg');
                                              }
                                            } catch (e, s) {
                                              print("💥 Exception: $e");
                                              print("📚 Stack: $s");
                                            }

                                            connect.isLoading.value = false;
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
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text(
                                                "Envoyer",
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
                                Gap(screenHeight * 0.065),
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
}
