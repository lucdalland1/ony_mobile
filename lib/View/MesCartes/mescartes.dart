import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/BloquerVirtuelle.dart';
import 'package:onyfast/Controller/oeilsolde.dart';
import 'package:onyfast/Controller/remplacercartecontroller.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import '../../Color/app_color_model.dart';
import '../../Controller/BloquerPhysique.dart';
import '../../Widget/container.dart';

class MesCartes extends StatefulWidget {
  const MesCartes({super.key});

  @override
  State<MesCartes> createState() => _MesCartesState();
}
SliverWoltModalSheetPage page1(
      BuildContext modalSheetContext, TextTheme textTheme) {
    return WoltModalSheetPage(
        hasSabGradient: false,
        stickyActionBar: Padding(
          padding: EdgeInsets.all(08.dp),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: 09.dp, top: 05.dp, right: 05.dp, bottom: 1.dp),
                child: InkWell(
                  onTap: () {
                  },
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text("Montant (en XAF)"),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      Gap(50),
                      ContainerWidget(height: 45,width: 330,color: AppColorModel.BlueColor,
                      borderRadius: BorderRadius.circular(10),
                      child: Center(child: Text("Déposer",style: TextStyle(color: AppColorModel.WhiteColor,fontSize: 18, fontWeight: FontWeight.bold),)),
                      ),
                      Gap(50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
  SliverWoltModalSheetPage page2(
      BuildContext modalSheetContext, TextTheme textTheme) {
    return WoltModalSheetPage(
        hasSabGradient: false,
        stickyActionBar: Padding(
          padding: const EdgeInsets.all(08),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 09, top: 10, right: 10, bottom: 1),
                child: InkWell(
                  onTap: () {
                  },
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text("Montant (en XAF)"),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      Gap(50),
                      ContainerWidget(height: 45,width: 330,color: AppColorModel.BlueColor,
                      borderRadius: BorderRadius.circular(10),
                      child: Center(child: Text("Retirer",style: TextStyle(color: AppColorModel.WhiteColor,fontSize: 18, fontWeight: FontWeight.bold),)),
                      ),
                      Gap(50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

class _MesCartesState extends State<MesCartes> {
  @override
  Widget build(BuildContext context) {
    final RemplacerContainerController controller = Get.put(RemplacerContainerController());

    final BloquerPhysiqueController toggleController = Get.put(BloquerPhysiqueController());

    final BloquerVirtuelleController virtuellecontroller = Get.put(BloquerVirtuelleController());


    final SoldeController balanceController = Get.put(SoldeController());
  //  double screenWidth = MediaQuery.of(context).size.width;
//final ListController listviewcontroller = Get.put(ListController());

final List<Map<String, String>> items = [
    {'date': 'Le 11/11/2025', 'heure': 'à 01:34:08'},
    {'date': 'Le 11/11/2025', 'heure': 'à 01:34:08'},
    {'date': 'Le 11/11/2025', 'heure': 'à 01:34:08'},

    {'date': 'Le 11/11/2025', 'heure': 'à 01:34:08'},
    {'date': 'Le 11/11/2025', 'heure': 'à 01:34:08'},

    {'date': 'Le 11/11/2025', 'heure': 'à 01:34:08'},
    {'date': 'Le 11/11/2025', 'heure': 'à 01:34:08'},
    // Ajoutez d'autres éléments ici
  ];

    return Scaffold(
      backgroundColor: AppColorModel.GreyWhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bouton gauche
            // Padding(
            //   padding: const EdgeInsets.all(20.0),
            //   child: ElevatedButton(
            //     onPressed: () => controller.toggleContainers(),
            //     child: const Icon(Icons.arrow_back),
            //   ),
            // ),
        
            // Containers qui s'échangent
            Gap(40.dp),
            Padding(
              padding: EdgeInsets.all(06.dp),
              child: Obx(() => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: controller.showFirstContainer.value
                        ? Column(
                          children: [
                            Container(
                                key: const ValueKey(1),
                                width: 100.w,
                                height: 28.h,
                                decoration: BoxDecoration(
                                  color: AppColorModel.BlueColor,
                                  borderRadius: BorderRadius.circular(10.dp),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0.dp),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 10.w,
                                            height: 05.h,
                                            decoration: BoxDecoration(
                                              color: AppColorModel.Bluewhite,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                                onPressed: () =>
                                                    controller.toggleContainers(),
                                                icon: Icon(
                                                  Icons.arrow_back_ios,
                                                  color: AppColorModel.WhiteColor,
                                                )),
                                          ),
                                          Container(
                                            width: 10.w,
                                            height: 05.h,
                                            decoration: BoxDecoration(
                                              color: AppColorModel.Bluewhite,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                                onPressed: () =>
                                                    controller.toggleContainers(),
                                                icon: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: AppColorModel.WhiteColor,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Gap(118.dp),
                                        Obx(() {
                                          return Text(
                                            balanceController.isBalanceVisible.value
                                                ? "500.000 FCFA"
                                                : '????', // Masque le solde
                                            style: TextStyle(
                                              fontSize: 14.dp,
                                              fontWeight: FontWeight.bold,
                                              color: AppColorModel.WhiteColor,
                                            ),
                                          );
                                        }),
                                        Gap(5.dp),
                                        GestureDetector(
                                          onTap: balanceController
                                              .toggleBalanceVisibility,
                                          child: Obx(() {
                                            return Icon(
                                              balanceController.isBalanceVisible.value
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              size: 22.dp,
                                              color: AppColorModel.WhiteColor,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    Gap(05.dp),
                                    Row(
                                      children: [
                                        Gap(73.dp),
                                        Text(
                                          "IDENTIFIANT : ",
                                          style: TextStyle(
                                              fontSize: 14.dp,
                                              color: AppColorModel.WhiteColor),
                                        ),
                                        Text(
                                          "19990088",
                                          style: TextStyle(
                                              fontSize: 14.dp,
                                              color: AppColorModel.WhiteColor),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Gap(80),
                                        Text(
                                          "**** **** ****",
                                          style: TextStyle(
                                              fontSize: 18.dp,
                                              color: AppColorModel.WhiteColor),
                                        ),
                                        Text(
                                          "1234",
                                          style: TextStyle(
                                              fontSize: 18.dp,
                                              color: AppColorModel.WhiteColor),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Gap(190),
                                        Column(
                                          children: [
                                            Text(
                                              "EXPIRE",
                                              style: TextStyle(
                                                  fontSize: 10.dp,
                                                  color: AppColorModel.WhiteColor),
                                            ),
                                            Text(
                                              "A FIN",
                                              style: TextStyle(
                                                  fontSize: 10.dp,
                                                  color: AppColorModel.WhiteColor),
                                            ),
                                          ],
                                        ),
                                        Gap(10.dp),
                                        Text(
                                          "06/27",
                                          style: TextStyle(
                                              fontSize: 15.dp,
                                              color: AppColorModel.WhiteColor),
                                        ),
                                      ],
                                    ),
                                    Gap(08.dp),
                                    Row(
                                      children: [
                                        Gap(82.dp),
                                        Text(
                                          "OPIMBA Rosca Privah",
                                          style: TextStyle(
                                              fontSize: 14.dp,
                                              color: AppColorModel.WhiteColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                                ),
                                                Gap(08.dp),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 02.dp, vertical: 02.dp),
              child: Row(
                children: [
                  Gap(04.dp),
                  InkWell(
                    onTap: () {
              
                        WoltModalSheet.show<void>(
                          context: context,
                          pageListBuilder: (modalSheetContext) {
                            final textTheme = Theme.of(context).textTheme;
                            return [
                              page1(modalSheetContext, textTheme),
                            ];
                          },
                        );
                    },
                    child: ContainerWidget(
                      height: 10.50.h,
                      width: 47.w,
                      borderRadius: BorderRadius.circular(5.dp),
                      color: AppColorModel.WhiteColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Gap(2.dp),
                          Column(
                            children: [
                              Icon(Icons.arrow_downward,size: 39.dp,color: AppColorModel.BlueColor,),
                              Text("Déposer",
                                  style: TextStyle(
                                      fontSize: 14.dp, color: AppColorModel.black,fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(07.dp),
                   InkWell(
                    onTap: () {
                     
                        WoltModalSheet.show<void>(
                          context: context,
                          pageListBuilder: (modalSheetContext) {
                            final textTheme = Theme.of(context).textTheme;
                            return [
                              page2(modalSheetContext, textTheme),
                            ];
                          },
                        );
                    },
                    child: ContainerWidget(
                      height: 10.50.h,
                      width: 44.w,
                      borderRadius: BorderRadius.circular(5),
                      color: AppColorModel.WhiteColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.arrow_upward,size: 39.dp,color: AppColorModel.BlueColor,),
                              Text("Retirer",
                                  style: TextStyle(
                                      fontSize: 15.dp, color: AppColorModel.black,fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Gap(20.dp),
            InkWell(
                  onTap: () {},
                  child: ContainerWidget(
                    height: 06.h,
                    width: 96.w,
                    borderRadius: BorderRadius.circular(5.dp),
                    color: AppColorModel.WhiteColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Gap(2.dp),
                      Obx(() {
                              return Row(
                                children: [
                                  Text(
                                    virtuellecontroller.isActive.value
                                        ? 'Débloquer ma carte Virtuelle'
                                        : 'Bloquer ma carte Virtuelle',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.dp,
                                    ),
                                    key: ValueKey<bool>(virtuellecontroller.isActive.value),
                                  ),
                                ],
                              );
                            }),
                            Gap(44.dp),
                            Obx(() {
                              return GestureDetector(
                                onTap: () {
                                  virtuellecontroller.toggle();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 17.w,
                                  height: 04.h,
                                  decoration: BoxDecoration(
                                    color: virtuellecontroller.isActive.value
                                        ? AppColorModel.BlueColor
                                        : AppColorModel.GreyWhite,
                                    borderRadius: BorderRadius.circular(20.dp),
                                    border: Border.all(
                                      color: AppColorModel.BlueColor,
                                    )
                                  ),
                                  alignment: virtuellecontroller.isActive.value
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Row(
                                    mainAxisAlignment: virtuellecontroller.isActive.value
                                       ? MainAxisAlignment.end
                                        : MainAxisAlignment.spaceBetween,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: 30,
                                        height: 120,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                ),
                Gap(10.dp),
                ContainerWidget(height:43.h,width: 100.w,color: AppColorModel.WhiteColor,borderRadius: BorderRadius.circular(10.dp),
                child: Column(
                  children: [
                    Gap(10.dp),
                    Row(
                      children: [
                        Gap(20.dp),
                        Text("Historique de paiements récents",style: TextStyle(fontWeight: FontWeight.bold,color: AppColorModel.BlueColor,fontSize: 15.dp),),
                      ],
                    ),
                   Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
        return Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 07.dp,right: 05.dp,bottom: 02.dp,top: 02.dp),
              child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
              Row(
                children: [
                  Gap(14.dp),
                  Text(
                    items[index]['date']!,
                    style:  TextStyle(
                      fontSize: 11.dp, 
                    ),
                  ),
                ],
              ),
              Gap(2.dp),
              Row(
                children: [
                   Gap(14.dp),
                  Text(
                    items[index]['heure']!,
                    style: TextStyle(
                      fontSize: 12.dp, 
                    ),
                  ),
                ],
              ),
                      ],
                    ),
            ),
        Gap(90.dp),
        Row(
          children: [
            Column(
              children: [
                Text("Funds Transfer External",style: TextStyle(fontWeight: FontWeight.bold,color: AppColorModel.black,fontSize: 09.dp),),
                 Text("Account to Card",style: TextStyle(fontWeight: FontWeight.bold,color: AppColorModel.black,fontSize: 09.dp),),
              ],
            ),
            Gap(10.dp),
            Icon(
          Icons.arrow_downward, 
          color: AppColorModel.black,
          size: 20.dp,  
        ),
          ],
        )
          ],
        );
            },
          ),
        )
                  ],
                ),
                ),
                          ],
                        )
                        : Column(
                          children: [
                            Container(
                                key: const ValueKey(1),
                                width: 100.w,
                                height: 28.h,
                                decoration: BoxDecoration(
                                  color: AppColorModel.BlueColor1,
                                  borderRadius: BorderRadius.circular(10.dp),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0.dp),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 10.w,
                                            height: 05.h,
                                            decoration: BoxDecoration(
                                              color: AppColorModel.Bluewhite,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                                onPressed: () =>
                                                    controller.toggleContainers(),
                                                icon: Icon(
                                                  Icons.arrow_back_ios,
                                                  color: AppColorModel.WhiteColor,
                                                )),
                                          ),
                                          Container(
                                            width: 10.w,
                                            height: 05.h,
                                            decoration: BoxDecoration(
                                              color: AppColorModel.Bluewhite,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                                onPressed: () =>
                                                    controller.toggleContainers(),
                                                icon: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: AppColorModel.WhiteColor,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Gap(118.dp),
                                        Obx(() {
                                          return Text(
                                            balanceController.isBalanceVisible.value
                                                ? "800.000 FCFA"
                                                : '????', // Masque le solde
                                            style: TextStyle(
                                              fontSize: 14.dp,
                                              fontWeight: FontWeight.bold,
                                              color: AppColorModel.WhiteColor,
                                            ),
                                          );
                                        }),
                                        Gap(5.dp),
                                        GestureDetector(
                                          onTap: balanceController
                                              .toggleBalanceVisibility,
                                          child: Obx(() {
                                            return Icon(
                                              balanceController.isBalanceVisible.value
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              size: 22.dp,
                                              color: AppColorModel.WhiteColor,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    Gap(05.dp),
                                    Row(
                                      children: [
                                        Gap(73.dp),
                                        Text(
                                          "IDENTIFIANT : ",
                                          style: TextStyle(
                                              fontSize: 14.dp,
                                              color: AppColorModel.WhiteColor),
                                        ),
                                        Text(
                                          "19990077",
                                          style: TextStyle(
                                              fontSize: 14.dp,
                                              color: AppColorModel.WhiteColor),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Gap(80),
                                        Text(
                                          "**** **** ****",
                                          style: TextStyle(
                                              fontSize: 18.dp,
                                              color: AppColorModel.WhiteColor),
                                        ),
                                        Text(
                                          "8323",
                                          style: TextStyle(
                                              fontSize: 18.dp,
                                              color: AppColorModel.WhiteColor),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Gap(190),
                                        Column(
                                          children: [
                                            Text(
                                              "EXPIRE",
                                              style: TextStyle(
                                                  fontSize: 10.dp,
                                                  color: AppColorModel.WhiteColor),
                                            ),
                                            Text(
                                              "A FIN",
                                              style: TextStyle(
                                                  fontSize: 10.dp,
                                                  color: AppColorModel.WhiteColor),
                                            ),
                                          ],
                                        ),
                                        Gap(10.dp),
                                        Text(
                                          "06/34",
                                          style: TextStyle(
                                              fontSize: 15.dp,
                                              color: AppColorModel.WhiteColor),
                                        ),
                                      ],
                                    ),
                                    Gap(08.dp),
                                    Row(
                                      children: [
                                        Gap(82.dp),
                                        Text(
                                          "OPIMBA Rosca",
                                          style: TextStyle(
                                              fontSize: 14.dp,
                                              color: AppColorModel.WhiteColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                                ),
                                Gap(08.dp),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 02.dp, vertical: 02.dp),
              child: Row(
                children: [
                  Gap(04.dp),
                  InkWell(
                    onTap: () {
              
                        WoltModalSheet.show<void>(
                          context: context,
                          pageListBuilder: (modalSheetContext) {
                            final textTheme = Theme.of(context).textTheme;
                            return [
                              page1(modalSheetContext, textTheme),
                            ];
                          },
                        );
                    },
                    child: ContainerWidget(
                      height: 10.50.h,
                      width: 47.w,
                      borderRadius: BorderRadius.circular(5.dp),
                      color: AppColorModel.WhiteColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Gap(2.dp),
                          Column(
                            children: [
                              Icon(Icons.arrow_downward,size: 39.dp,color: AppColorModel.BlueColor,),
                              Text("Déposer",
                                  style: TextStyle(
                                      fontSize: 14.dp, color: AppColorModel.black,fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(07.dp),
                   InkWell(
                    onTap: () {
                     
                        WoltModalSheet.show<void>(
                          context: context,
                          pageListBuilder: (modalSheetContext) {
                            final textTheme = Theme.of(context).textTheme;
                            return [
                              page2(modalSheetContext, textTheme),
                            ];
                          },
                        );
                    },
                    child: ContainerWidget(
                      height: 10.50.h,
                      width: 44.w,
                      borderRadius: BorderRadius.circular(5),
                      color: AppColorModel.WhiteColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.arrow_upward,size: 39.dp,color: AppColorModel.BlueColor,),
                              Text("Retirer",
                                  style: TextStyle(
                                      fontSize: 15.dp, color: AppColorModel.black,fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Gap(20.dp),
            InkWell(
                  onTap: () {},
                  child: ContainerWidget(
                    height: 06.h,
                    width: 96.w,
                    borderRadius: BorderRadius.circular(5.dp),
                    color: AppColorModel.WhiteColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Gap(2.dp),
                      Obx(() {
                              return Row(
                                children: [
                                  Text(
                                    toggleController.isActive.value
                                        ? 'Débloquer ma carte Physique'
                                        : 'Bloquer ma carte Physique',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.dp,
                                    ),
                                    key: ValueKey<bool>(toggleController.isActive.value),
                                  ),
                                ],
                              );
                            }),
                            Gap(44.dp),
                            Obx(() {
                              return GestureDetector(
                                onTap: () {
                                  toggleController.toggle();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 17.w,
                                  height: 04.h,
                                  decoration: BoxDecoration(
                                    color: toggleController.isActive.value
                                        ? AppColorModel.BlueColor
                                        : AppColorModel.GreyWhite,
                                    borderRadius: BorderRadius.circular(20.dp),
                                    border: Border.all(
                                      color: AppColorModel.BlueColor,
                                    )
                                  ),
                                  alignment: toggleController.isActive.value
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Row(
                                    mainAxisAlignment: toggleController.isActive.value
                                       ? MainAxisAlignment.end
                                        : MainAxisAlignment.spaceBetween,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: 30,
                                        height: 120,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                ),
                Gap(10.dp),
                ContainerWidget(height:43.h,width: 100.w,color: AppColorModel.WhiteColor,borderRadius: BorderRadius.circular(10.dp),
                child: Column(
                  children: [
                    Gap(10.dp),
                    Row(
                      children: [
                        Gap(20.dp),
                        Text("Historique de paiements récents",style: TextStyle(fontWeight: FontWeight.bold,color: AppColorModel.BlueColor,fontSize: 15.dp),),
                      ],
                    ),
                   Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
        return Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 07.dp,right: 05.dp,bottom: 02.dp,top: 02.dp),
              child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
              Row(
                children: [
                  Gap(14.dp),
                  Text(
                    items[index]['date']!,
                    style:  TextStyle(
                      fontSize: 11.dp, 
                    ),
                  ),
                ],
              ),
              Gap(2.dp),
              Row(
                children: [
                   Gap(14.dp),
                  Text(
                    items[index]['heure']!,
                    style: TextStyle(
                      fontSize: 12.dp, 
                    ),
                  ),
                ],
              ),
                      ],
                    ),
            ),
        Gap(90.dp),
        Row(
          children: [
            Column(
              children: [
                Text("Funds Transfer External",style: TextStyle(fontWeight: FontWeight.bold,color: AppColorModel.black,fontSize: 09.dp),),
                 Text("Account to Card",style: TextStyle(fontWeight: FontWeight.bold,color: AppColorModel.black,fontSize: 09.dp),),
              ],
            ),
            Gap(10.dp),
            Icon(
          Icons.arrow_downward, 
          color: AppColorModel.black,
          size: 20.dp,  
        ),
          ],
        )
          ],
        );
            },
          ),
        )
                  ],
                ),
                ),
                          ],
                        )
                  )
                  ),
            ),
            
                
                // ItemWidget(index: 3),
        
            // Bouton droit
            // Padding(
            //   padding: const EdgeInsets.all(20.0),
            //   child: ElevatedButton(
            //     onPressed: () => controller.toggleContainers(),
            //     child: const Icon(Icons.arrow_forward),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
