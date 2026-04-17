import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Api/user_inscription.dart';
import 'package:onyfast/Controller/transactionwalletcontroller.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Api/Userapi.dart';
import '../../Api/transactionwallet.dart';
import '../../Color/app_color_model.dart';
import '../../Widget/container.dart';
import '../../Widget/icon.dart';

class PayerPhone extends StatefulWidget {
  const PayerPhone({super.key});

  @override
  State<PayerPhone> createState() => _RechargePhoneState();
}

class _RechargePhoneState extends State<PayerPhone> {
  final RechargeWalletController rechargeController = Get.put(RechargeWalletController());


  final TextEditingController fromTelephoneController = TextEditingController();
  final TextEditingController toTelephoneController = TextEditingController();
  final TextEditingController montantController = TextEditingController();

  

  
  

  @override
  
  Widget build(BuildContext context) {

    final AuthController authController = Get.find();
    var user = authController.getUser();
    TextEditingController fromTelephoneController = TextEditingController(text: user?.telephone);
    void handleTransaction() async {
    final result = await TransactionService().makeTransaction(
      fromTelephone: fromTelephoneController.text,
      toTelephone: rechargeController.toTelephoneController.text,
      amount: rechargeController.montantController.text,
      context: context, to_card_id: '',
    );
  }
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ContainerWidget(
              height: screenHeight * 0.08,
              width: screenWidth,
              color: AppColorModel.BlueColor,
            ),
            ContainerWidget(
              height: screenHeight * 0.1,
              width: screenWidth,
              color: AppColorModel.WhiteColor,
              child: Row(
                children: [
                  Gap(10),
                  Image.asset(
                    "asset/onylogo.png",
                    height: screenHeight * 0.05,
                    width: screenWidth * 0.1,
                  ),
                  Gap(20),
                  Text(
                    "Payer avec un numéro".tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColorModel.BlueColor,
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                  Spacer(),
                  NotificationWidget(),
                ],
              ),
            ),
            ContainerWidget(
              height: 200,
              width: 340,
              color: AppColorModel.Blue,
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                "asset/3.jpeg",
                fit: BoxFit.cover,
              ),
            ),
            Gap(10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 1),
              child: Column(
                children: [
                  TextFormField(
                    controller: fromTelephoneController,
                    decoration: InputDecoration(
                      labelText: "Votre Numéro de téléphone".tr,
                      fillColor: AppColorModel.WhiteColor,
                      hintText: "Votre Numéro de téléphone".tr,
                      hintStyle: TextStyle(color: AppColorModel.Grey),
                      enabled: false // Désactiver le champ pour griser
                    ),
                  ),
                  
                  TextFormField(
                    controller: rechargeController.toTelephoneController,
                    decoration: InputDecoration(
                      labelText: "Numéro de téléphone à payer".tr,
                      fillColor: AppColorModel.WhiteColor,
                      hintText: "Numéro de téléphone à payer".tr,
                      hintStyle: TextStyle(color: AppColorModel.Grey),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  TextFormField(
                    controller: rechargeController.montantController,
                    onChanged: (value) => rechargeController.updateMontant(double.tryParse(value) ?? 0),
                    decoration: InputDecoration(
                      labelText: "Montant",
                      hintText: "A partir de 1000f",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  Gap(50),
                  Obx(() => InkWell(
                        onTap: rechargeController.montant.value >= 1000
                            ? () {
                                handleTransaction();
                              }
                            : null,
                        child: Container(
                          height: 40,
                          width: 320,
                          decoration: BoxDecoration(
                            color: rechargeController.montant.value >= 1000
                                ? AppColorModel.DeepPurple
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              "Effectuer la transaction".tr,
                              style: TextStyle(
                                  color: AppColorModel.WhiteColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}