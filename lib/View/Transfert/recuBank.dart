import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/bankcontroller.dart';
import 'package:onyfast/Widget/container.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import '../../Controller/formulaircontroller.dart';
import '../Notification/notification.dart';
import 'recuoperateur.dart';

class RecuBank extends StatefulWidget {
  const RecuBank({super.key});

  @override
  State<RecuBank> createState() => _Recu1State();
}

class _Recu1State extends State<RecuBank> {

  final BankController bankController = Get.find();
  final FormController controller = Get.find<FormController>();
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppColorModel.GreyWhite,
       appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        title: Text("Transfert", style: TextStyle(fontSize: 17.dp, fontWeight: FontWeight.bold, color: AppColorModel.WhiteColor),),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        actions: [
    NotificationWidget(),
  ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Gap(33.dp),
            Padding(
              padding: EdgeInsets.all(8.dp),
              child: Container(
                height: 77.h,
                width: 100.w,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColorModel.BlueColor, width: 1),
                  borderRadius: BorderRadius.circular(5.dp),
                  color: AppColorModel.WhiteColor,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Gap(28.dp),
                      Row(
                        children: [
                          Gap(10.dp),
                          Text(
                            "Transférer à",
                            style: TextStyle(
                                fontSize: 18.dp,
                                color: AppColorModel.Greywhitevisible3),
                          ),
                          
                        ],
                      ),
                      Row(
                        children: [
                          Gap(10.dp),
                          Text(
                            "Rosca OPIMBA",
                            style: TextStyle(
                                fontSize: 22.dp,
                                color: AppColorModel.black,fontWeight: FontWeight.bold),
                          ),
                          
                        ],
                      ),
                       Row(
                        children: [
                          Gap(10.dp),
                          Container(
                                           height: 19.h,
                                           width: 17.w,
                                           decoration: BoxDecoration(
                                             borderRadius: BorderRadius.circular(30.dp),
                                             color: AppColorModel.WhiteColor,
                                           ),
                                           child: Center(
                                child: Obx(() => bankController
                                        .selectedImagePath.isNotEmpty
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 14.w,
                                            height: 14.h,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    bankController
                                                        .selectedImagePath.value),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text("")),
                              ),
                                    ),
                                    Gap(15.dp),
                                    Text(bankController.selectedBankName.value,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.dp),),
                        ],
                      ),
                       Row(
                        children: [
                          Gap(09.dp),
                          Text(
                            "Code Banque",
                            style: TextStyle(
                                fontSize: 17.dp,
                                color: AppColorModel.Greywhitevisible3),
                          ),
                          
                        ],
                      ),
                          Row(
                        children: [
                          Gap(10),
                          Obx(()=>Text(
                            "${controller.bankCode.value}",
                            style: TextStyle(
                                fontSize: 19.dp,
                                color: AppColorModel.black,fontWeight: FontWeight.bold),
                          ),)
                          
                        ],
                      ),
                       Row(
                        children: [
                           Gap(09.dp),
                          Text(
                            "Code Guichet",
                            style: TextStyle(
                                fontSize: 17.dp,
                                color: AppColorModel.Greywhitevisible3),
                          ),
                          
                        ],
                      ),
                       Row(
                        children: [
                           Gap(09.dp),
                          Obx(()=>Text(
                            "${controller.branchCode.value}",
                            style: TextStyle(
                                fontSize: 19.dp,
                                color: AppColorModel.black,fontWeight: FontWeight.bold),
                          ),)
                          
                        ],
                      ),
                       Row(
                        children: [
                           Gap(09.dp),
                          Text(
                            "Numéro de compte",
                            style: TextStyle(
                                fontSize: 17.dp,
                                color: AppColorModel.Greywhitevisible3),
                          ),
                          
                        ],
                      ),
                      Row(
                        children: [
                           Gap(09.dp),
                  Obx(()=>                        Text(
                            "${controller.accountNumber.value}",
                            style: TextStyle(
                                fontSize: 19.dp,
                                color: AppColorModel.black,fontWeight: FontWeight.bold),
                          ),)
                          
                        ],
                      ),
                        Row(
                        children: [
                           Gap(09.dp),
                          Text(
                            "Clés",
                            style: TextStyle(
                                fontSize: 17.dp,
                                color: AppColorModel.Greywhitevisible3),
                          ),
                          
                        ],
                      ),
                         Row(
                        children: [
                         Gap(09.dp),
                  Obx(()=>                        Text(
                            "${controller.key.value}",
                            style: TextStyle(
                                fontSize: 19.dp,
                                color: AppColorModel.black,fontWeight: FontWeight.bold),
                          ),)
                          
                        ],
                      ),
                                           Row(
                        children: [
                           Gap(09.dp),
                          Text(
                            "Montant",
                            style: TextStyle(
                                fontSize: 17.dp,
                                color: AppColorModel.Greywhitevisible3),
                          ),
                          
                        ],
                      ),
                         Row(
                        children: [
                         Gap(09.dp),
                  Obx(()=>                        Text(
                            "${controller.amount.value}",
                            style: TextStyle(
                                fontSize: 19.dp,
                                color: AppColorModel.black,fontWeight: FontWeight.bold),
                          ),)
                          
                        ],
                      ),
                      Gap(10.dp),
                      InkWell(
                        onTap: () {
                              Get.to(RecuOperateur(nom: '', pourcentage: 0,));
                        },
                        child: Container(
                       height: 06.h,
                        width: 92.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColorModel.Bluecolor242,
                          ),
                          child: Center(
                            child: Text(
                              "Envoyer",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,fontSize: 18.dp,
                                color: AppColorModel.WhiteColor,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Gap(90),
          ],
        ),
      ),
    );
  }
}
