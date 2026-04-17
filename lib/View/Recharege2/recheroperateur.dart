import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';

import '../../Widget/container.dart';

class RechargeOperateur extends StatefulWidget {
  const RechargeOperateur({super.key});

  @override
  State<RechargeOperateur> createState() => _RechargeOperateurState();
}

class _RechargeOperateurState extends State<RechargeOperateur> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorModel.GreyWhite,
      appBar: AppBar(
        title: Text("Choisir un opérateur Momo", style: TextStyle(fontSize: 16.dp, color: AppColorModel.GreyBlack, fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Gap(25.dp),
            Padding(
              padding: EdgeInsets.all(8.dp),
              child: ContainerWidget(height: 55.h,width: 100.w,borderRadius: BorderRadius.circular(10.dp),
              color: AppColorModel.WhiteColor,
              child: Column(
                children: [
                  Gap(08.dp),
                  Container(
                                key: const ValueKey(1),
                                width: 90.w,
                                height: 26.h,
                                decoration: BoxDecoration(
                                  color: AppColorModel.BlueColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.asset(
                                  "asset/image_ony.png",
                                  width: 100,
                                  height: 100,fit: BoxFit.fill,
                                )),
                                Gap(40.dp),
                                InkWell(
                                  onTap: (){  
                                  },
                                  child: ContainerWidget(height: 07.h,width: 90.w,color: AppColorModel.BlueColor,borderRadius: BorderRadius.circular(10),
                                  child: Center(
                                    child: Text("Airtel Money",style: TextStyle(color: AppColorModel.WhiteColor,fontSize: 17.dp, fontWeight: FontWeight.bold),),
                                  ),
                                  ),
                                ),
                               
                                Gap(10.dp),
                                InkWell(
                                  onTap: (){  
                                  },
                                  child: ContainerWidget(height: 07.h,width: 90.w,color: AppColorModel.BlueColor,borderRadius: BorderRadius.circular(10),
                                  child: Center(
                                    child: Text("MTN Money",style: TextStyle(color: AppColorModel.WhiteColor,fontSize: 17.dp, fontWeight: FontWeight.bold),),
                                  ),
                                  ),
                                ),
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