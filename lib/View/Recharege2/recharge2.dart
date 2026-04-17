import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/View/Recharege2/rechargewalletmomo.dart';
import 'package:onyfast/Widget/container.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../Controller/oeilsolde.dart';

class Recharge2 extends StatefulWidget {
  const Recharge2({super.key});

  @override
  State<Recharge2> createState() => _Recharge2State();
}

SliverWoltModalSheetPage page2(
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
                  left: 09.dp, top: 10.dp, right: 10.dp, bottom: 1.dp),
              child: InkWell(
                onTap: () {},
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(RechargeMomo());
                      },
                      child: Row(
                        children: [
                          Gap(50),
                          SizedBox(
                            height: 10.h,
                            width: 10.w,
                            child: Image.asset("asset/recharge.png"),
                          ),
                          Gap(08.dp),
                          Text(
                            "Mobile Money",
                            style: TextStyle(
                                fontSize: 13.dp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Gap(80.dp),
                  ],
                ),
              ),
            ),
          ],
        ),
      ));
}

class _Recharge2State extends State<Recharge2> {
  @override
  Widget build(BuildContext context) {
    final SoldeController balanceController = Get.put(SoldeController());
    return Scaffold(
      backgroundColor: AppColorModel.GreyWhite,
      body: Column(
        children: [
          Gap(50),
          Padding(
            padding: EdgeInsets.all(8.0.dp),
            child: ContainerWidget(
              height: 90.h,
              width: 220.w,
              borderRadius: BorderRadius.circular(10.dp),
              color: AppColorModel.WhiteColor,
              child: Column(
                children: [
                  Gap(08.dp),
                  Container(
                      key: const ValueKey(1),
                      width: 90.w,
                      height: 25.h,
                      decoration: BoxDecoration(
                        color: AppColorModel.BlueColor,
                        borderRadius: BorderRadius.circular(10.dp),
                      ),
                      child: Container(
                        child: Column(
                          children: [
                            Gap(10.dp),
                            Row(
                              children: [
                                Gap(10.dp),
                                Text(
                                  "Rosca OPIMBA",
                                  style: TextStyle(
                                      fontSize: 12.dp,
                                      color: AppColorModel.WhiteColor),
                                ),
                              ],
                            ),
                            Gap(40.dp),
                            Text(
                              "Solde",
                              style: TextStyle(
                                  fontSize: 24.dp,
                                  color: AppColorModel.WhiteColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Gap(10.dp),
                            Row(
                              children: [
                                Gap(80.dp),
                                Obx(() {
                                  return Text(
                                    balanceController.isBalanceVisible.value
                                        ? "500.000 FCFA"
                                        : '????', // Masque le solde
                                    style: TextStyle(
                                      fontSize: 25.dp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColorModel.WhiteColor,
                                    ),
                                  );
                                }),
                                Gap(10.dp),
                                GestureDetector(
                                  onTap:
                                      balanceController.toggleBalanceVisibility,
                                  child: Obx(() {
                                    return Icon(
                                      balanceController.isBalanceVisible.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      size: 25.dp,
                                      color: AppColorModel.WhiteColor,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                  Gap(100.dp),
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
                      height: 07.h,
                      width: 90.w,
                      color: AppColorModel.BlueColor,
                      borderRadius: BorderRadius.circular(10),
                      child: Center(
                        child: Text(
                          "Recharger",
                          style: TextStyle(
                              color: AppColorModel.WhiteColor,
                              fontSize: 17.dp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
