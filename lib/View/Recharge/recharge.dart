import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:onyfast/View/Recharge/operateurRecharger.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Color/app_color_model.dart';
import '../../Controller/rechargecontroller.dart';
import '../../Widget/container.dart';
import '../../Widget/icon.dart';

class Recharge extends StatefulWidget {
  const Recharge({super.key});

  @override
  State<Recharge> createState() => _RechargeState();
}

class _RechargeState extends State<Recharge> {
  final RechargeController rechargeController = Get.put(RechargeController());
  final TextEditingController telephonController = TextEditingController();
  final TextEditingController montantController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                  Gap(5),
                  Text(
                    'Effectuer vos transactions'.tr,
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
              height: 590,
              width: 340,
              color: AppColorModel.WhiteColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: AppColorModel.Grey,
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                    Text(
                      "Recharger votre carte VISA Onyfast à travers ",
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColorModel.GreyBlack,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "votre compte Mobile Money.",
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColorModel.GreyBlack,
                          fontWeight: FontWeight.bold),
                    ),
                    Gap(8),
                    Row(
                      children: [
                        Gap(43),
                        Text(
                          "Vous avez sélectionné la carte:",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColorModel.GreyBlack,
                          ),
                        ),
                        Text(
                          " 19990995",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColorModel.GreyBlack,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 30, right: 30, top: 10, bottom: 10),
                      child: Column(
                        children: [
                          Obx(() => TextFormField(
                          onChanged: rechargeController.updateTelephone,
                          decoration: InputDecoration(labelText: "Numéro de téléphone"),
                          keyboardType: TextInputType.phone,
                          initialValue: rechargeController.telephone.value, 
                        )),
                          Obx(() => TextFormField(
                          onChanged: rechargeController.updateMontant,
                          decoration: InputDecoration(labelText: "Montant"),
                          keyboardType: TextInputType.number,
                          initialValue: rechargeController.montant.value.toString(),)),
                          Gap(50),
                          Obx(() => InkWell(
                                onTap: rechargeController.montant.value >= 1000
                                    ? () {
                                       Get.to(OperateurRecharge());
                                      }
                                    : null,
                                child: Container(
                                  height: 40,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    color:
                                        rechargeController.montant.value >= 1000
                                            ? AppColorModel.DeepPurple
                                            : Colors.grey,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Recharger cette carte",
                                      style: TextStyle(
                                          color: AppColorModel.WhiteColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
