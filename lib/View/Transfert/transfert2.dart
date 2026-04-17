import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Controller/transfert/operateur_controller.dart';
import 'package:onyfast/Controller/transfertcountry.dart';
import 'package:onyfast/View/Transfert/transfert3.dart';
import 'package:onyfast/View/Transfert/transfert4.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/notificationWidget.dart';

import '../../Controller/bankcontroller.dart';
import '../Activité/operateurcontroller.dart';
import '../Notification/notification.dart';
import 'package:shimmer/shimmer.dart';

class Transfert2 extends StatefulWidget {
  const Transfert2({super.key});

  @override
  State<Transfert2> createState() => _Transfert2State();
}

class _Transfert2State extends State<Transfert2> {
  
  String? selectedMobileMoney;
  String? selectedBank;
  final controller = Get.put(OperatorController());
  final countryController = Get.put(TransfertCountryController());
  String indicatif = '';
  bool get isNextButtonEnabled =>
      selectedMobileMoney != null || selectedBank != null;
  @override
  void initState() {
    super.initState();
    controller.loadOperators(countryController
        .selectedCountry.value!.idContries); // ou autre ID de pays
  
  final Map<String, dynamic> args = Get.arguments;
    indicatif = args['indicatif'] ?? '';
    print(" Transfert 2 Indicatif reçu : $indicatif");
  }

  @override
  Widget build(BuildContext context) {
      print(indicatif);
    // ignore: unused_local_variable
    final BankController bankcontrollers = Get.put(BankController());
    //final AssetSliderController controller = Get.put(AssetSliderController());
    //final BankSliderController bankcontroller = Get.put(BankSliderController());
    final OperateurController operateurcontroller =
        Get.put(OperateurController());
    return Scaffold(
        backgroundColor: AppColorModel.GreyWhite,
        appBar: AppBar(
          backgroundColor: globalColor,
          leading: BackButton(color: Colors.white),
          title: Text(
            "Transfert",
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
        body: Obx(() {
          if (controller.isLoading.value) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              period: const Duration(milliseconds: 1200),
              direction: ShimmerDirection.ltr,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                 // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Gap(40.dp),
                    Row(
                      children: [
                        Gap(18.dp),
                        Container(
                          width: 200.dp,
                          height: 20.dp,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                    Gap(20.dp),
                    Container(
                      width: double.infinity,
                      height: 130.dp,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey[300],
                      ),
                    ),
                    Gap(15.dp),
                    Container(
                      width: double.infinity,
                      height: 130.dp,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey[300],
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: double.infinity,
                      height: 50.dp,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                    ),
                    Gap(40.dp),
                  ],
                ),
              ),
            );
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Gap(40.dp),
              Row(
                children: [
                  Gap(18.dp),
                  Text(
                    "Transfert d'argent",
                    style:
                        TextStyle(fontSize: 22.dp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Gap(08.dp),
              Row(
                children: [
                  Gap(20),
                  Text(
                    "Étape 2",
                    style: TextStyle(
                        fontSize: 17.dp,
                        color: AppColorModel.Greywhitevisible3),
                  ),
                ],
              ),
              Gap(2.dp),
              Row(
                children: [
                  Gap(20.dp),
                  Text(
                    "choisir un service",
                    style: TextStyle(
                      fontSize: 17.dp,
                      fontWeight: FontWeight.bold,
                      color: AppColorModel.black,
                    ),
                  ),
                ],
              ),
              Gap(20.dp),
              // Mobile Money Section
              Container(
                height: 130,
                width: MediaQuery.of(context).size.width * 0.92,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: controller.select.value
                        ? Colors.blue.withOpacity(0.8)
                        : Colors.blue,
                   
                  ),
                  borderRadius: BorderRadius.circular(5),
                  color: controller.select.value
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.white,
                ),
                child: (controller.operators.isEmpty)
                    ? Center(child: Text('Pas d\'opérateur pour ce pays'))
                    : Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 20),
                              Text(
                                controller
                                    .operators[controller.index.value].name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: controller.select.value == true
                                      ? Colors.blue
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  size: 38,
                                  color: controller.index.value != 0
                                      ? Colors.blue
                                      : Colors.black,
                                ),
                                onPressed: controller.index.value == 0
                                    ? null
                                    : () {
                                        controller.index.value--;
                                        controller.select2.value = false;
                            controller.select.value = true;
                                      },
                              ),
                              SizedBox(width: 50),
                              GestureDetector(
                                  onTap: () {
controller.select2.value = false;
                            controller.select.value = true;                                   
                             //Get.to(Transfert3()); 
                                  },
                                  child: Hero(tag: 'operator', child: Container(
                                    width: 21.w,
                                    height: 08.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            controller.operators[controller.index.value].imagePath),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) =>
                                            const AssetImage(
                                                'assets/default_operator.png'),
                                      ),
                                      border: Border.all(
                                        color: controller.select.value == true
                                                    ? Colors.blue
                                                    : Colors.black,
                                        width: 2,
                                      ),
                                    ),
                                  ))),
                              SizedBox(width: 50),
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 40,
                                  color: controller.operators.length !=
                                          controller.index.value+1
                                      ? Colors.blue
                                      : Colors.black,
                                ),
                                onPressed: controller.operators.length ==
                                        controller.index.value+1
                                    ? null
                                    : () {
                                        print(controller.index.value);
                                        if (controller.index.value ==
                                            controller.operators.length) return;
                                        controller.index.value++;
                                        controller.select2.value = false;
                                        controller.select.value = true;
                                      },
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              Gap(15.dp),
              // Bank Section
              // Container(
              //   height: 130,
              //   width: MediaQuery.of(context).size.width * 0.92,
              //   decoration: BoxDecoration(
              //     border: Border.all(
              //       color: controller.select2.value == true
              //           ? Colors.blue.withOpacity(0.8)
              //           : Colors.blue,
              //     ),
              //     borderRadius: BorderRadius.circular(5),
              //     color: controller.select2.value == true
              //         ? Colors.blue.withOpacity(0.1)
              //         : Colors.white,
              //   ),
              //   child: Column(
              //     children: [
              //       Row(
              //         children: [
              //           SizedBox(width: 20),
              //           Text(
              //             "Banques",
              //             style: TextStyle(
              //               fontWeight: FontWeight.bold,
              //               color: controller.select2.value == true
              //                   ? Colors.blue
              //                   : Colors.black,
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 5),
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           IconButton(
              //             icon: Icon(
              //               Icons.arrow_back_ios,
              //               size: 38,
              //               color: bankcontrollers.selectedImagePath.isNotEmpty
              //                   ? Colors.blue
              //                   : Colors.black,
              //             ),
              //             onPressed:() {
              //               controller.select2.value = true;
              //               controller.select.value = false;
              //               bankcontrollers.previousImages();
              //             },
              //           ),
              //           SizedBox(width: 50),
              //           GestureDetector(
              //             onTap: () {
              //               controller.select2.value = true;
              //               controller.select.value = false;
              //               bankcontrollers.selectImage(); // Sélectionner l'image et le nom
              //               //Get.to(Transfert4()); // Naviguer vers l'écran d'affichage
              //             },
              //             child: Obx(() => Container(
              //                   width: 21.w,
              //                   height: 08.h,
              //                   decoration: BoxDecoration(
              //                     borderRadius: BorderRadius.circular(10),
              //                     image: DecorationImage(
              //                       image: AssetImage(bankcontrollers
              //                               .assetImagess[
              //                           bankcontrollers.currentIndex.value]),
              //                       fit: BoxFit.cover,
              //                     ),
              //                     border: Border.all(
              //                       color: bankcontrollers
              //                                   .selectedImagePath.value ==
              //                               bankcontrollers.assetImagess[
              //                                   bankcontrollers
              //                                       .currentIndex.value]
              //                           ? Colors.blue
              //                           : Colors.transparent,
              //                       width: 2,
              //                     ),
              //                   ),
              //                 )),
              //           ),
              //           SizedBox(width: 50),
              //           IconButton(
              //             icon: Icon(
              //               Icons.arrow_forward_ios,
              //               size: 40,
              //               color:controller.select2.value == true
              //                   ? Colors.blue
              //                   : Colors.black,
              //             ),
              //             onPressed:(){ bankcontrollers.nextImages();
              //             controller.select2.value = true;
              //               controller.select.value = false;}
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 40.dp),
                child: InkWell(
                  onTap: controller.select.value == true||controller.select2.value == true
                      ? () {

                        

                        print('voila le lien de son image ${controller.operators[controller.index.value].imagePath}');
                        
                         controller.select.value == true? Get.to(
                          Transfert3(
                            operatorId: controller.operators[controller.index.value].id, 
                            contryId: countryController.selectedCountry.value!.idContries, 
                            imagePath:controller.operators[controller.index.value].imagePath, name: controller.operators[controller.index.value].name,
                            indicatif: indicatif,
                            ),
                            
                            ): Get.to(const Transfert4(), arguments: {"indicatif": indicatif});
                        }
                      : null,
                  child: Container(
                    height: 06.h,
                    width: 90.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: controller.select.value == true||controller.select2.value == true
                          ? globalColor
                          : AppColorModel.Greywhitevisible3,
                    ),
                    child: Center(
                      child: Text(
                        "Suivant",  
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: controller.select.value == true||controller.select2.value == true
                                ? AppColorModel.WhiteColor
                                : AppColorModel.Bluecolor242,
                            fontSize: 20.dp),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }));
  }
}
