import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/BloquerPhysique.dart';
import 'package:onyfast/Widget/container.dart';

import '../../Color/app_color_model.dart';

class CartesInactif extends StatefulWidget {
  const CartesInactif({super.key});

  @override
  State<CartesInactif> createState() => _CartesInactifState();
}

class _CartesInactifState extends State<CartesInactif> {
  @override
  Widget build(BuildContext context) {

    final BloquerPhysiqueController toggleController = Get.put(BloquerPhysiqueController());
    return Scaffold(
      backgroundColor: AppColorModel.Grey,
      body: Column(
        children: [
          Gap(50),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                    key: const ValueKey(1),
                    width: 600,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColorModel.BlueColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: AppColorModel.Bluewhite,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.arrow_back_ios,
                                      color: AppColorModel.WhiteColor,
                                    )),
                              ),
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: AppColorModel.Bluewhite,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColorModel.WhiteColor,
                                    )),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColorModel.WhiteColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add,
                              color: AppColorModel.Grey,size: 70,
                            ),
                          ),
                        )
                      ],
                    )),
              )),
              Gap(15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 02.dp, vertical: 10),
                  child: Row(
                              children: [
                                Gap(08),
                                InkWell(
                  onTap: () {},
                  child: ContainerWidget(
                    height: 80,
                    width: 16,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColorModel.black, width: 1),
                    color: AppColorModel.WhiteColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Gap(2),
                        Column(
                          children: [
                            Icon(Icons.arrow_downward,size: 40,color: AppColorModel.Grey,),
                            Text("Déposer",
                                style: TextStyle(fontSize: 15, color: AppColorModel.Grey,fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                                ),
                                Gap(10),
                                 InkWell(
                  onTap: () {
                    Get.to(CartesInactif());
                  },
                  child: ContainerWidget(
                    height: 80,
                    width: 166,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColorModel.blackColor, width: 1),
                    color: AppColorModel.WhiteColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.arrow_upward,size: 40,color: AppColorModel.Grey,),
                            Text("Retirer",
                                style: TextStyle(
                                    fontSize: 15, color: AppColorModel.Grey,fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                                ),
                              ],
                            ),
                ),
          Gap(20),
          InkWell(
                onTap: () {},
                child: ContainerWidget(
                  height: 50,
                  width: 346,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColorModel.blackColor, width: 1),
                  color: AppColorModel.WhiteColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Gap(2),
                    Obx(() {
                            return Text(
                              toggleController.isActive.value
                                  ? 'Débloquer ma carte Physique'
                                  : 'Bloquer ma carte Physique',
                              style: TextStyle(
                                color: AppColorModel.Grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              key: ValueKey<bool>(toggleController.isActive.value),
                            );
                          }),
                          Gap(10),
                          Obx(() {
                            return GestureDetector(
                              onTap: () {
                                toggleController.toggle();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 60,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: toggleController.isActive.value
                                      ? AppColorModel.BlueColor
                                      : AppColorModel.GreyWhite,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColorModel.GreyWhite,
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
                                    const SizedBox(width: 10),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
