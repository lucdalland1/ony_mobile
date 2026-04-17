import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/formulaircontroller.dart';
import 'package:onyfast/Controller/transfert/FraisFixeController.dart';
import 'package:onyfast/Controller/transfert/transfert_operator_controller.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Color/app_color_model.dart';
import '../Activité/operateurcontroller.dart';
import '../Notification/notification.dart';

class Transfert3 extends StatefulWidget {
  final int operatorId;
  final int contryId;
  final String imagePath;
  final String name;
  final String indicatif;
  const Transfert3({
    super.key,
    required this.operatorId,
    required this.contryId,
    required this.imagePath,
    required this.name,
    required this.indicatif,
  });

  @override
  State<Transfert3> createState() => _Transfert3State();
}

double calculerPourcentage(double ancienPrix, double nouveauPrix) {
  if (ancienPrix == 0) {
    throw ArgumentError('L\'ancien prix ne peut pas être zéro.');
  }
  double difference = nouveauPrix - ancienPrix;
  return (difference / ancienPrix) * 100;
}

class _Transfert3State extends State<Transfert3> {
  final FormController controller = Get.put(FormController());
  final OperateurController operateurcontroller = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TransferController transferController = Get.put(TransferController());
  String nom = '';
  bool showFraisInfo = false;
  final FraisFixeController fraisFixeController = Get.find();

  void checkFieldsFilled() {
    final nomValid = nom.trim().isNotEmpty;
    final phoneValid = controller.phoneNumber.value.trim().isNotEmpty;
    final montantValid = controller.amount.value.trim().isNotEmpty;

    setState(() {
      showFraisInfo = nomValid && phoneValid && montantValid;
    });
  }

  @override
  void initState() {
    super.initState();
    fraisFixeController.loadFraisFixe();
  }

  @override
  Widget build(BuildContext context) {
    var valeurPourcentage = fraisFixeController.fraisFixe.value?.pourcentage==null ? 0.0:fraisFixeController.fraisFixe.value?.pourcentage;
    double montant = double.tryParse(controller.amount.value) ?? 0.0;
    double pourcentage = fraisFixeController.fraisFixe.value != null
        ? montant *
            (fraisFixeController.fraisFixe.value!.pourcentage ?? 0.0) /
            100
        : 0.0;
    double total = montant + pourcentage;

    return Scaffold(
      backgroundColor: AppColorModel.GreyWhite,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: AppColorModel.Bluecolor242,
        title: Text(
          "Transfert ",
          style: TextStyle(
              fontSize: 17.dp,
              fontWeight: FontWeight.bold,
              color: AppColorModel.WhiteColor),
        ),
        centerTitle: true,
        actions: [
         NotificationWidget(),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Gap(20),
                Column(
                  children: [
                    Row(
                      children: [
                        Gap(20.dp),
                        Text("Informations du",
                            style: TextStyle(
                                fontSize: 22.dp, fontWeight: FontWeight.bold)),
                        Gap(80.dp),
                        Column(
                          children: [
                            Container(
                              height: 09.h,
                              width: 15.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.dp),
                                color: AppColorModel.WhiteColor,
                              ),
                              child: Center(
                                child: widget.imagePath.isNotEmpty
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Hero(
                                            tag: 'operator',
                                            child: Container(
                                              width: 09.w,
                                              height: 08.h,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      widget.imagePath),
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    : Text(""),
                              ),
                            ),
                            Text(operateurcontroller.selectedBankName.value
                                    .toString() ??
                                "")
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Gap(20.dp),
                        Text("beneficiaire",
                            style: TextStyle(
                                fontSize: 22.dp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                Gap(20.dp),
                Container(
                  width: 95.w,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColorModel.Bluecolor242, width: 1),
                    borderRadius: BorderRadius.circular(5.dp),
                    color: AppColorModel.WhiteColor,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 35.dp, vertical: 10.dp),
                    child: Column(
                      children: [
                        Gap(22.dp),
                        Obx(
                          () => TextFormField(
                            maxLength: 19,
                            inputFormatters: [UpperCaseTextFormatter()],
                            enabled: !transferController.isLoading.value,
                            decoration: InputDecoration(
                              labelText: "Nom Du Beneficiaire",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Veuillez entrer un nom';
                              if (!RegExp(r'^[a-zA-ZÀ-ÿ\s\-]+$')
                                  .hasMatch(value.toString().trim()))
                                return 'Veuillez entrer uniquement des lettres valides';
                              return null;
                            },
                            onChanged: (value) {
                              nom = value;
                              checkFieldsFilled();
                            },
                            onSaved: (value) => nom = value!,
                          ),
                        ),
                        Gap(22.dp),
                        Obx(
                          () => TextFormField(
                            maxLength: 10,
                            enabled: !transferController.isLoading.value,
                            decoration: InputDecoration(
                              prefixText: '${widget.indicatif} ',
                              labelText: "Numéro de téléphone",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Veuillez entrer un numéro';
                              if (!RegExp(r'^[0-9]+$').hasMatch(value))
                                return 'Veuillez entrer uniquement des chiffres';
                              return null;
                            },
                            onChanged: (value) {
                              controller.phoneNumber.value = value;
                              checkFieldsFilled();
                            },
                            onSaved: (value) =>
                                controller.phoneNumber.value = value!,
                          ),
                        ),
                        Gap(20.dp),
                        Obx(
                          () => TextFormField(
                            maxLength: 7,
                            enabled: !transferController.isLoading.value,
                            decoration: InputDecoration(
                              labelText: "Montant",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Veuillez entrer un montant';
                              if (!RegExp(r'^[0-9]+$').hasMatch(value))
                                return 'Veuillez entrer uniquement des chiffres';
                              if (int.parse(value.toString()) < 500)
                                return 'le montant minimum doit être 500 ';
                              if (value.length > 7) {
                                return 'Le montant doit etre inferieur a 1000000';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              controller.amount.value = value;
                              checkFieldsFilled();
                            },
                            onSaved: (value) =>
                                controller.amount.value = value!,
                          ),
                        ),
                        Gap(20.dp),
                        Visibility(
                          visible: showFraisInfo,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color:
                                  AppColorModel.Bluecolor242.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Informations frais',
                                        style: TextStyle(
                                            color: AppColorModel.WhiteColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Type de frais',
                                        style: TextStyle(
                                            color: AppColorModel.WhiteColor)),
                                    Text('Frais fixe',
                                        style: TextStyle(
                                            color: AppColorModel.WhiteColor,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Pourcentage appliqué',
                                        style: TextStyle(
                                            color: AppColorModel.WhiteColor,
                                            fontSize: 2.4.w)),
                                    Text(
                                      
                                      '${ valeurPourcentage} %',
                                        style: TextStyle(
                                            color: AppColorModel.WhiteColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 2.4.w)),
                                  ],
                                ),
                                Divider(color: AppColorModel.WhiteColor),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total',
                                        style: TextStyle(
                                          color: AppColorModel.WhiteColor,
                                        )),
                                    Text('${total.toStringAsFixed(0)} FCFA',
                                        style: TextStyle(
                                            color: AppColorModel.WhiteColor,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Gap(30.dp),
                Obx(
                  () => InkWell(
                    onTap: transferController.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              transferController.previewTransfer(
                                operatorId: widget.operatorId,
                                countryId: widget.contryId,
                                amount: double.parse(controller.amount.value),
                                phoneNumber:
                                    '${widget.indicatif}${controller.phoneNumber.value}',
                                nom: nom,
                                pourcentage: pourcentage,
                              );
                            }
                          },
                    child: Container(
                      height: 06.h,
                      width: 95.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColorModel.Bluecolor242,
                      ),
                      child: Center(
                        child: transferController.isLoading.value
                            ? CupertinoActivityIndicator(
                                color: AppColorModel.WhiteColor)
                            : Text("Valider",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColorModel.WhiteColor,
                                    fontSize: 20.dp)),
                      ),
                    ),
                  ),
                ),
                Gap(10.dp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
