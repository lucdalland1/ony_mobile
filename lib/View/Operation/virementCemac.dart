import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:onyfast/model/banque.dart';
import '../../Api/banque.dart';
import '../../Color/app_color_model.dart';
import '../../Controller/countrycontroller.dart';
import '../../Controller/inscriptioncontroller.dart';
import '../../Widget/container.dart';
import '../../Widget/icon.dart';
import '../../Controller/languescontroller.dart';

class Virement extends StatelessWidget {
  const Virement({super.key});

  void _showDialog(BuildContext context) {
    final AppController appState = Get.put(AppController());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              Gap(40),
              Text(
                appState.language == AppLanguage.french
                    ? "D'autres informations"
                    : appState.language == AppLanguage.english
                        ? 'Other information'
                        : 'Otra información',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/associercompte");
                    },
                    child: Text(
                      appState.language == AppLanguage.french
                          ? 'Associer à mon compte bancaire'
                          : appState.language == AppLanguage.english
                              ? 'Link to my bank account'
                              : 'Vincular a mi cuenta bancaria',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/paiement");
                    },
                    child: Text(
                      appState.language == AppLanguage.french
                          ? 'Paiement de facture'
                          : appState.language == AppLanguage.english
                              ? 'Bill Payment'
                              : 'Pago de facturas',
                    ),
                  ),
                  TextButton(
                    child: Text(
                      appState.language == AppLanguage.french
                          ? 'Fermer'
                          : appState.language == AppLanguage.english
                              ? 'Close'
                              : 'Cerrar',
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
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
    TextEditingController NumeroCompteController = TextEditingController();
    TextEditingController CodeBankController = TextEditingController();
    TextEditingController CodeGuichefController = TextEditingController();
    TextEditingController CleRIBController = TextEditingController();
    TextEditingController SwiftController = TextEditingController();
    TextEditingController IbanController = TextEditingController();
    TextEditingController DeviseController = TextEditingController();
    TextEditingController MontantController = TextEditingController();

    final InscriptionController inscriptionController =
        Get.put(InscriptionController());


  final BankController bankController = Get.put(BankController());

    // Utilisation de MediaQuery pour adapter les dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ContainerWidget(
              height: screenHeight * 0.08, // Ajuster la hauteur
              width: screenWidth, // Utiliser la largeur de l'écran
              color: AppColorModel.BlueColor,
            ),
            ContainerWidget(
              height: screenHeight * 0.1, // Ajuster la hauteur
              width: screenWidth, // Utiliser la largeur de l'écran
              color: AppColorModel.WhiteColor,
              child: Row(
                children: [
                  Image.asset(
                    "asset/onylogo.png",
                    height: screenHeight * 0.08, // Ajuster la hauteur
                    width: screenWidth * 0.2, // Ajuster la largeur
                  ),
                  Text(
                    appState.language == AppLanguage.french
                        ? 'Virement'
                        : appState.language == AppLanguage.english
                            ? 'CEMAC Transfer'
                            : 'Transferencia CEMAC',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColorModel.BlueColor,
                      fontSize: screenHeight * 0.025, // Ajuster la taille de police
                    ),
                  ),
                  Spacer(),
                  NotificationWidget(),
                  IconButtonWidget(
                    onPressed: () {
                      _showDialog(context); // Appel de la fonction avec le contexte
                    },
                    icon: Icon(
                      Icons.menu,
                      color: AppColorModel.blackColor,
                      size: 42,
                    ),
                  ),
                ],
              ),
            ),
            ContainerWidget(
              height: screenHeight * 0.9, // Ajuster la hauteur
              margin: EdgeInsets.symmetric(horizontal: 10),
              width: screenWidth * 0.9, // Ajuster la largeur
              color: AppColorModel.WhiteColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
          //           Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     Obx(() => InternationalPhoneNumberInput(
          //       onInputChanged: (PhoneNumber number) {
          //         phoneController.phoneNumber.value = number;
          //       },
          //       onInputValidated: (bool value) {
          //         print(value);
          //       },
          //       selectorConfig: SelectorConfig(
          //         selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          //         useBottomSheetSafeArea: true,
          //       ),
          //       ignoreBlank: false,
          //       autoValidateMode: AutovalidateMode.disabled,
          //       selectorTextStyle: TextStyle(color: Colors.black),
          //       initialValue: phoneController.phoneNumber.value,
          //       textFieldController: phoneController.controller,
          //       formatInput: true,
          //       keyboardType:
          //           TextInputType.numberWithOptions(signed: true, decimal: true),
          //       inputBorder: OutlineInputBorder(),
          //       onSaved: (PhoneNumber number) {
          //         print('On Saved: $number');
          //       },
          //     )),
          //   ],
          // ),
         Obx(() {
          if (bankController.isLoading.value) {
            return CupertinoActivityIndicator();
          }  
          return DropdownButton<Bank>(
            hint: Text("Choisissez une banque"),
            items: bankController.banks.map((Bank bank) {
              return DropdownMenuItem<Bank>(
                value: bank,
                child: Text(bank.designation),
              );
            }).toList(),
            onChanged: (Bank? selectedBank) {
              if (selectedBank != null) {
                // Action à réaliser lors de la sélection
                print("Banque sélectionnée : ${selectedBank.designation}");
              }
            },
          );
        }),
                    _buildTextField(NomBankController, appState, 'Nom de la Banque', 'Bank Name', 'Nombre del Banco'),
                    _buildTextField(NumeroCompteController, appState, 'Numéro de compte', 'Account Number', 'Número de cuenta'),
                    _buildTextField(CodeBankController, appState, 'Code Banque', 'Bank Code', 'Código Bancario'),
                    _buildTextField(CodeGuichefController, appState, 'Code Guichet', 'Branch Code', 'Código de Sucursal'),
                    _buildTextField(CleRIBController, appState, 'Clé RIB', 'RIB Key', 'Clave RIB'),
                    _buildTextField(SwiftController, appState, 'SWIFT / BIC', 'SWIFT / BIC', 'SWIFT / BIC'),
                    _buildTextField(IbanController, appState, 'IBAN', 'IBAN', 'IBAN'),
                    _buildTextField(DeviseController, appState, 'Devise', 'Currency', 'Moneda'),
                    _buildTextField(MontantController, appState, 'Montant XAF', 'Amount XAF', 'Cantidad XAF'),
                    Gap(screenHeight * 0.03), // Ajuster l'espacement
                    InkWell(
                      onTap: () {
                        // Soumettre l'action
                      },
                      child: ContainerWidget(
                        height: screenHeight * 0.07, // Ajuster la hauteur
                        width: screenWidth * 0.8, // Ajuster la largeur
                        borderRadius: BorderRadius.circular(10),
                        color: AppColorModel.BlueColor,
                        child: Center(
                          child: Text(
                            appState.language == AppLanguage.french
                                ? "Soumettre"
                                : appState.language == AppLanguage.english
                                    ? "Submit"
                                    : "Enviar",
                            style: TextStyle(
                                color: AppColorModel.WhiteColor,
                                fontSize: 23,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, AppController appState, String labelFr, String labelEn, String labelEs) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: appState.language == AppLanguage.french
            ? labelFr
            : appState.language == AppLanguage.english
                ? labelEn
                : labelEs,
      ),
    );
  }
}