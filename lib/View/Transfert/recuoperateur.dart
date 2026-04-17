import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/RecenteTransaction/recenttransactcontroller.dart';
import 'package:onyfast/Controller/transfert/transfert_execution.dart';
import 'package:onyfast/Controller/transfert/transfert_operator_controller.dart';
import 'package:onyfast/View/Notification/notification.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import 'package:onyfast/verificationcode.dart';
import '../../Controller/formulaircontroller.dart';
import '../Activité/operateurcontroller.dart';

class RecuOperateur extends StatefulWidget {
  final String nom;
  final double pourcentage;
  const RecuOperateur(
      {super.key, required this.nom, required this.pourcentage});

  @override
  State<RecuOperateur> createState() => _RecuOperateurState();
}

class _RecuOperateurState extends State<RecuOperateur> {
  final OperateurController operateurcontroller = Get.find();
  final TransferController transferController = Get.find();
  final FormController controller = Get.find<FormController>();
  final execution = Get.put(TransfertExecuteCon());

  //final send=

  final bool _isLoading = false;
  final GetStorage storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    print('voila');
    print(widget.pourcentage);

    print(double.tryParse(controller.amount.value));

    var totalAmount = double.tryParse(controller.amount.value)! + widget.pourcentage;

    print('voila la somme $totalAmount');
    var user = storage.read('userInfo');
    print(user['telephone']);
    print("voila le operator_id ${transferController.operatorId}");
    print("voila le country_id ${transferController.countryId}");
    //print(" voila son token ${user['token']}");

    return Scaffold(
      backgroundColor: AppColorModel.GreyWhite,
      appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        elevation: 0,
        title: Text(
          "Transfert",
          style: TextStyle(
              fontSize: 17.dp,
              fontWeight: FontWeight.bold,
              color: AppColorModel.WhiteColor),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
         NotificationWidget(),
        ],
      ),
      body: Obx(() => transferController.errorMessage.value.isNotEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(20.dp),
                child: Container(
                  padding: EdgeInsets.all(24.dp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.dp),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.dp),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.error_outline,
                            color: Colors.red, size: 48.dp),
                      ),
                      Gap(16.dp),
                      Text(
                        "Erreur !",
                        style: TextStyle(
                          fontSize: 20.dp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Gap(12.dp),
                      Text(
                        transferController.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.dp,
                          color: globalColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColorModel.Bluecolor242.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.dp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress bar améliorée

                    // Titre de la section
                    Text(
                      "Récapitulatif du transfert",
                      style: TextStyle(
                        fontSize: 20.dp,
                        fontWeight: FontWeight.bold,
                        color: AppColorModel.blackColor,
                      ),
                    ),
                    Gap(4.dp),
                    Text(
                      "Vérifiez les informations avant de confirmer",
                      style: TextStyle(
                        fontSize: 14.dp,
                        color: AppColorModel.black,
                      ),
                    ),
                    Gap(24.dp),

                    // Container principal redesigné
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.dp),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.dp),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section destinataire
                          Container(
                            padding: EdgeInsets.all(16.dp),
                            decoration: BoxDecoration(
                              color:
                                  AppColorModel.Bluecolor242.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10.dp),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.dp),
                                  decoration: BoxDecoration(
                                    color: AppColorModel.Bluecolor242,
                                    borderRadius: BorderRadius.circular(10.dp),
                                  ),
                                  child: Icon(Icons.person,
                                      color: Colors.white, size: 24.dp),
                                ),
                                Gap(16.dp),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Bénéficiaire",
                                        style: TextStyle(
                                          fontSize: 12.dp,
                                          color: globalColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Gap(4.dp),
                                      Text(
                                        widget.nom,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.dp,
                                          color: AppColorModel.blackColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(20.dp),

                          // Section téléphone
                          Container(
                            padding: EdgeInsets.all(16.dp),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10.dp),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.dp),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10.dp),
                                  ),
                                  child: Icon(Icons.phone,
                                      color: Colors.white, size: 24.dp),
                                ),
                                Gap(16.dp),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Numéro de téléphone",
                                        style: TextStyle(
                                          fontSize: 12.dp,
                                          color: globalColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Gap(4.dp),
                                      Obx(
                                        () => Text(
                                          controller.phoneNumber.value,
                                          style: TextStyle(
                                            fontSize: 16.dp,
                                            color: AppColorModel.blackColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(20.dp),

                          // Divider stylé
                          Container(
                            height: 1,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  globalColor.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Gap(20.dp),

                          // Section montants
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Montant à transférer',
                                style: TextStyle(
                                  fontSize: 16.dp,
                                  color: globalColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "${NumberFormat("#,##0", "fr_FR").format(double.tryParse(controller.amount.value )??0.0)} FCFA",
                                style: TextStyle(
                                  fontSize: 16.dp,
                                  color: AppColorModel.blackColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Gap(12.dp),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Frais de transfert',
                                style: TextStyle(
                                  fontSize: 16.dp,
                                  color: globalColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "${NumberFormat("#,##0", "fr_FR").format(double.tryParse(widget.pourcentage.toString())??0.0)} FCFA",
                                style: TextStyle(
                                  fontSize: 16.dp,
                                  color: AppColorModel.blackColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Gap(16.dp),

                          // Total avec style spécial
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 15.dp),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColorModel.Bluecolor242.withOpacity(0.1),
                                    AppColorModel.Bluecolor242.withOpacity(
                                        0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10.dp),
                                border: Border.all(
                                  color: AppColorModel.Bluecolor242.withOpacity(
                                      0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'Total à payer',
                                    style: TextStyle(
                                      fontSize: 16.dp,
                                      color: AppColorModel.Bluecolor242,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                  Text(
                                    "${NumberFormat("#,##0", "fr_FR").format(totalAmount ??0.0)} FCFA",
                                    style: TextStyle(
                                      fontSize: 16.dp,
                                      color: AppColorModel.Bluecolor242,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                    Gap(30.dp),

                    // Bouton de confirmation amélioré
                    InkWell(
                      onTap: ()async {
                        // CodeVerification.show(context,(){
                      await   execution.executeTransfert(
                          operatorId: transferController.operatorId.value,
                          countryId: transferController.countryId.value,
                          montant: controller.amount.value,
                          fromTelephone: user['telephone'],
                          toTelephone: controller.phoneNumber.value,
                          beneficiaryName: widget.nom,
                          context: context,
                        );

                        // });
                      },
                      child: Container(
                        height: 60.dp,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.dp),
                          gradient: LinearGradient(
                            colors: [
                              AppColorModel.Bluecolor242,
                              AppColorModel.Bluecolor242.withOpacity(0.8),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Center(
                          child: execution.isLoading.value
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20.dp,
                                      height: 20.dp,
                                      child: CupertinoActivityIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                    Gap(12.dp),
                                    Text(
                                      "Traitement en cours...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.dp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 20.dp,
                                    ),
                                    Gap(8.dp),
                                    Text(
                                      "Confirmer le transfert",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.dp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    Gap(20.dp),
                  ],
                ),
              ),
            )),
    );
  }
}
