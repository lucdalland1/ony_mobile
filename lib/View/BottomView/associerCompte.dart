import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import '../../Color/app_color_model.dart';
import '../../Controller/countrycontroller.dart';
import '../../Widget/container.dart';
import '../../Widget/icon.dart';
import '../../Controller/languescontroller.dart';

class AssocierCompte extends StatelessWidget {
  const AssocierCompte({super.key});

  void _showDialog(BuildContext context) {
    final AppController appState = Get.put(AppController());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Mon profil')),
          actions: [
            Column(
              children: [
                Container(
                  height: 2,
                  width: 250,
                  decoration: BoxDecoration(
                    color: AppColorModel.Grey,
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/associercompte");
                    },
                    child: Text(
                      "Associer à mon compte bancaire",
                      style: TextStyle(color: AppColorModel.black),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/parametre");
                    },
                    child: Text(
                      "Paramètres",
                      style: TextStyle(color: AppColorModel.black),
                    ))
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppController appState = Get.put(AppController());
    final PhoneController phoneController = Get.put(PhoneController());

    TextEditingController NomBankController = TextEditingController();
    TextEditingController PaysBankController = TextEditingController();
    TextEditingController NumeroCompteController = TextEditingController();
    TextEditingController VilleBankController = TextEditingController();
    TextEditingController CodeGuichetBankController = TextEditingController();
    TextEditingController CodeBanqueBankController = TextEditingController();
    TextEditingController CleRIBController = TextEditingController();

    // Utiliser MediaQuery pour adapter les dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child:  Column(
            children: [
              ContainerWidget(
                height: screenHeight * 0.08, // Ajuster la hauteur
                width: screenWidth, // Utiliser la largeur de l'écran
                color: AppColorModel.BlueColor,
                child: null,
              ),
              ContainerWidget(
                height: screenHeight * 0.1, // Ajuster la hauteur
                width: screenWidth, // Utiliser la largeur de l'écran
                color: AppColorModel.WhiteColor,
                child: Row(
                  children: [
                    Image.asset(
                      "asset/onylogo.png",
                      height: screenHeight * 0.07, // Ajuster la hauteur
                      width: screenWidth * 0.2, // Ajuster la largeur
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 20, bottom: 1, top: 1),
                          child: Text(
                            appState.language == AppLanguage.french
                                ? 'Associer mon'
                                : 'Link my',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColorModel.WhiteColor,
                                fontSize: screenHeight * 0.025), // Ajuster la taille de police
                          ),
                        ),
                        Text(
                          appState.language == AppLanguage.french
                              ? 'compte bancaire'
                              : 'bank account',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColorModel.blackColor,
                              fontSize: screenHeight * 0.025), // Ajuster la taille de police
                        ),
                      ],
                    ),
                    Spacer(),
                    NotificationWidget(),
                    IconButtonWidget(
                        onPressed: () {
                          _showDialog(context);
                        },
                        icon: Icon(
                          Icons.menu,
                          color: AppColorModel.blackColor,
                          size: 35,
                        )),
                  ],
                ),
              ),
              Gap(screenHeight * 0.05), // Ajuster l'espacement
              Text(
                appState.language == AppLanguage.french
                    ? 'Enregistrer votre compte bancaire'
                    : 'Register your bank account',
                style: TextStyle(fontSize: 16),
              ),
              Gap(screenHeight * 0.03), // Ajuster l'espacement
              ContainerWidget(
                height: screenHeight * 0.4, // Ajuster la hauteur
                width: screenWidth * 0.9, // Ajuster la largeur
                borderRadius: BorderRadius.circular(5),
                color: AppColorModel.BlueWhiteColor,
                child: Column(
                  children: [
                    Gap(screenHeight * 0.01), // Ajuster l'espacement
                    Row(
                      children: [
                        Gap(10),
                        Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Obx(() => InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  phoneController.phoneNumber.value = number;
                },
                onInputValidated: (bool value) {
                  print(value);
                },
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  useBottomSheetSafeArea: true,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: TextStyle(color: Colors.black),
                initialValue: phoneController.phoneNumber.value,
                textFieldController: phoneController.controller,
                formatInput: true,
                keyboardType:
                    TextInputType.numberWithOptions(signed: true, decimal: true),
                inputBorder: OutlineInputBorder(),
                onSaved: (PhoneNumber number) {
                  print('On Saved: $number');
                },
              )),
              ElevatedButton(
                onPressed: () {
                  // Here, you can send the fullPhoneNumber to your API
                  final fullNumber = phoneController.fullPhoneNumber;
                  print('Full Phone Number to send: $fullNumber');
                  // Call your API here with fullNumber
                },
                child: Text('Send to API'),
              ),
            ],
          ),
        ),
                      ],
                    ),
                    Gap(screenHeight * 0.01), // Ajuster l'espacement
                    Container(
                      width: screenWidth * 0.9, // Ajuster la largeur
                      height: 50,
                      child: TextField(
                        controller: NumeroCompteController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: appState.language == AppLanguage.french
                                ? 'Numéro de compte'
                                : 'Account Number'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Gap(screenHeight * 0.01), // Ajuster l'espacement
                    Row(
                      children: [
                        Gap(10),
                        Container(
                          width: screenWidth * 0.4, // Ajuster la largeur
                          height: 50,
                          child: TextField(
                            controller: VilleBankController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: appState.language == AppLanguage.french
                                    ? 'Ville de la Banque'
                                    : 'Bank City'),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        Gap(10),
                        Container(
                          width: screenWidth * 0.4, // Ajuster la largeur
                          height: 50,
                          child: TextField(
                            controller: CodeGuichetBankController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: appState.language == AppLanguage.french
                                    ? 'Code Guichet'
                                    : 'Branch Code'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    Gap(screenHeight * 0.01), // Ajuster l'espacement
                    Container(
                      width: screenWidth * 0.9, // Ajuster la largeur
                      height: 50,
                      child: TextField(
                        controller: CodeBanqueBankController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: appState.language == AppLanguage.french
                                ? 'Code Banque'
                                : 'Bank Code'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Gap(screenHeight * 0.01), // Ajuster l'espacement
                    Container(
                      width: screenWidth * 0.9, // Ajuster la largeur
                      height: 50,
                      child: TextField(
                        controller: CleRIBController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: appState.language == AppLanguage.french
                                ? 'Clé RIB'
                                : 'RIB Key'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(screenHeight * 0.1), // Ajuster l'espacement
              ContainerWidget(
                height: 60,
                width: screenWidth * 0.9, // Ajuster la largeur
                borderRadius: BorderRadius.circular(10),
                color: AppColorModel.BlueColor,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, "/home");
                  },
                  child: Center(
                    child: Text(
                      appState.language == AppLanguage.french
                          ? 'Enregistrer un compte'
                          : 'To register an account',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColorModel.WhiteColor,
                          fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}